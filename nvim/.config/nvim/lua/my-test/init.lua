--- Test runner with telescope picker to find an run tests.
--- It is limited to one project right now, at least I have not yet tried it with running tests in two
--- projects in for example separate tabs.
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

--- @class Test Test represents a test to be shown by the picker.
--- @field name string The name of the test.
--- @field start_row integer The one-indexed start row of the test.
--- @field start_col integer The one-indexed start col of the test.
--- @field end_row integer The one-indexed end row of the test.
--- @field end_col integer The one-indexed end col of the test.
--- @field path string The absolute path to the test file.

--- @class TestOptions The telescope test picker options.
--- @field finder fun(): Test[]
--- @field runner fun(test: TestArgs?)
--- @field project_dir string The project directory from which to run tests.
--- @field keymaps Terminal.keymaps? Optional keymaps to set for the terminal buffer

--- @class (exact) TestArgs
--- @field test Test?
--- @field test_args string[]?

--- @type TestArgs?
local last_test_args

-- Keep track of the terminal/buffer in which the tests are being run.
local term_job_id
local term_bufnr

local function toggle_terminal()
  local neovim = require('my-neovim')

  -- assuming that if the buffer is valid the terminal is still running in it
  if not term_bufnr or not vim.api.nvim_buf_is_valid(term_bufnr) then
    vim.notify('my-test: there is no test terminal, run tests first', vim.log.levels.INFO)
    return
  end

  if not neovim.is_preview_window_open() then
    neovim.open_preview_window(term_bufnr, M._project_dir)
    neovim.auto_scroll_to_end(term_bufnr)
    return
  end

  -- close preview window
  vim.cmd.pclose()
end

--- Setup test plugin.
--- @param opts TestOptions The options setting how tests are found and run.
function M.setup(opts)
  vim.validate('opts', opts, 'table', false)
  M._finder = opts.finder
  M._keymaps = opts.keymaps
  -- TODO rename to something that sounds like it generates the test command
  M._runner = opts.runner
  M._project_dir = opts.project_dir
  vim.keymap.set('n', '<leader>ft', function()
    -- load_extension is a call to require under the hood so this should be cheap enough. reason for
    -- calling this here is I do not want to pay the cost on startup
    require('telescope').load_extension('test')
    require('telescope').extensions.test.test()
  end, { desc = 'Find and run tests' })

  vim.keymap.set('n', '<leader>tl', function()
    M.test()
  end, { desc = 'Re-run last test' })

  vim.keymap.set('n', '<leader>tn', function()
    M.test_nearest()
  end, { desc = 'Run the nearest test to the current cursor position' })

  vim.keymap.set('n', '<leader>tt', function()
    toggle_terminal()
  end, { desc = 'Open/close the test buffer' })
  vim.keymap.set('n', '<leader><leader>tt', function()
    toggle_terminal()
  end, { desc = 'Open/close the test buffer' })
end

--- Run test specified in args.
--- @param args TestArgs? The test args. Defaults to last test args if nil.
function M.test(args)
  local neovim = require('my-neovim')
  if not args and last_test_args then
    args = last_test_args
  else
    -- capture args to re-run them
    last_test_args = args
  end

  local command = M._runner(args)
  command = command .. '\n'

  if not term_bufnr or not vim.api.nvim_buf_is_valid(term_bufnr) then
    term_job_id, term_bufnr = neovim.open_terminal(M._project_dir, M._keymaps)
  end

  -- ensure preview window is open and autoscroll is on
  if not neovim.is_buffer_visible(term_bufnr) then
    neovim.open_preview_window(term_bufnr, M._project_dir)
    neovim.auto_scroll_to_end(term_bufnr)
  end
  vim.fn.chansend(term_job_id, command)
end

--- Find the nearest test to the current cursor position. The test the cursor is in is considered the
--- nearest. After that the nearest test is the one with either its start or end row closest to the
--- cursor row.
local function find_nearest_test()
  local tests = M._finder()
  table.sort(tests, function(a, b)
    return a.start_row < b.start_row
  end)

  local test
  local distance = math.huge
  local row = unpack(vim.api.nvim_win_get_cursor(0))
  for _, candidate in ipairs(tests) do
    if row >= candidate.start_row and row <= candidate.end_row then
      return candidate
    end

    local candidate_distance =
      math.min(math.abs(row - candidate.start_row), math.abs(row - candidate.end_row))
    if candidate_distance < distance then
      test = candidate
      distance = candidate_distance
    else
      return test
    end
  end
  return test
end

local ns = vim.api.nvim_create_namespace('my-test')

--- Run the nearest test to the current cursor position.
function M.test_nearest()
  -- get bufnr to ensure the highlight is created/cleared in the correct buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local test = find_nearest_test()
  if not test then
    vim.notify('my-tests: no test found', vim.log.levels.INFO)
    return
  end

  vim.hl.range(
    bufnr,
    ns,
    'Visual',
    { test.start_row - 1, test.start_col - 1 }, -- looks as if hl.range is 0-indexed
    { test.end_row - 1, test.end_col - 1 },
    { inclusive = true, timeout = 300 }
  )

  M.test({ test = test })
end

--- Telescope test picker to find and run tests in the current buffer.
--- @param opts table
function M.test_picker(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Find and run tests',
      results_title = 'Tests',
      finder = finders.new_table({
        results = M._finder(),
        ---@type fun(entry: Test): table
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
            lnum = entry.start_row,
            path = entry.path,
          }
        end,
      }),
      previewer = conf.grep_previewer(opts),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        ---Run the currently selected test. This will run the current selection and ignore any
        ---multi-selection.
        map({ 'i', 'n' }, '<C-r>', function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local test = entry.value
          M.test({ test = test })
        end, { desc = 'Run selected test. Only supports running one test!' })

        ---Navigate to the test.
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          ---@type Test
          local test = selection.value
          vim.api.nvim_win_set_cursor(0, { test.start_row, test.start_col })
        end)

        return true
      end,
    })
    :find()
end

return M
