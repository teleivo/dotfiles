---Telescope test picker to find and run tests.
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

---@class Test Test represents a test to be shown by the picker.
---@field name string The name of the test.
---@field start_row integer The one-indexed start row of the test.
---@field start_col integer The one-indexed start col of the test.
---@field path string The absolute path to the test file.

---@class TestOptions The telescope test picker options.
---@field finder fun(): Test[]
---@field runner fun(test: TestArgs?)

---@class (exact) TestArgs
---@field test Test?
---@field test_args string[]?

---@param opts TestOptions The options setting how tests are found and run.
function M.setup(opts)
  -- TODO validate
  M._finder = opts.finder
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
end

---@type TestArgs
local last_test_args

---Run test specified in args.
---@param args TestArgs? The test args. Defaults to last test args if nil.
function M.test(args)
  if not args and last_test_args then
    args = last_test_args
  else
    -- capture args to re-run them
    last_test_args = args
  end

  local command = M._runner(args)
  command = command .. '\n'

  local term_job_id = require('my-neovim').open_terminal(M._project_dir)
  vim.fn.chansend(term_job_id, command)
end

---Telescope test picker to find and run tests in the current buffer.
---@param opts table
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

        ---Navigate to the test identifier node.
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
