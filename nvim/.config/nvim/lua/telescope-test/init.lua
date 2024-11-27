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

---@class TestPickerOptions The telescope test picker options.
---@field finder fun(): Test[]
---@field runner fun(test: Test)

---@class TelescopeOptions The telescope options.
---@field test TestPickerOptions

-- TODO how to pass in the results and test run functions?
-- via setup of the extension? but then I need telescope to depend on my-java/my-go which depends on
-- telescope :joy:
local java = require('my-java')
---@type fun(): Test[]
local finder = java.find_tests
---@type fun(test: Test)
local runner = java.mvn_test

---@param opts TelescopeOptions
function M.test(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Find and run tests',
      results_title = 'Tests',
      finder = finders.new_table({
        results = finder(),
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
          runner(test)
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
