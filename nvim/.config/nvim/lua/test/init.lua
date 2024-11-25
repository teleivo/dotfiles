local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local transform_mod = require('telescope.actions.mt').transform_mod
local java = require('my-java')

local M = {}

-- TODO how to pass in the results and test run functions?
-- via setup of the extension? but then I need telescope to depend on my-java/my-go which depends on
-- telescope :joy:
function M.test(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Find and run tests',
      results_title = 'Tests',
      finder = finders.new_table({
        results = java.find_tests(),
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
        -- TODO fix preview, why does it not work anymore?
        -- TODO shield against no or multiple tests selected
        -- TODO add description so it shows up in help
        -- TODO declare/use a type for the results return value. Can I define one here and then keep
        -- the ones in my-java/my-go? they mostly overlap except for java has a class as well
        map({ 'i', 'n' }, '<C-r>', function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local test = entry.value
          java.mvn_test(test)
        end)

        ---Navigate to the test identifier node.
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local test = selection.value
          vim.api.nvim_win_set_cursor(0, { test.start_row, test.start_col })
        end)

        return true
      end,
    })
    :find()
end

return M
