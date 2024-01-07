local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local go = require('go')

-- TODO parse sample html using TS
-- TODO find TS query to get what I need for the result
-- TODO connect parsing/querying with telescope displaying the result from the HTML
-- TODO make request using curl to search for real. Make sure to require at least 3 chars. Cache
-- result.
-- TODO fetch the modules doc and put that html into the previewer and cache.

local pick_dependency = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'Add dependency to Go mod',
    finder = finders.new_table({
      results = {
        { 'github.com/google/go-cmp', 'github.com/google/go-cmp' },
        { 'cmp', 'cmp' },
      },
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1],
          ordinal = entry[1],
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    -- TODO get rid of default action like custom_action.top. returning false
    -- breaks everthing but search. cannot close the picker then
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        print(vim.inspect(selection))
        -- TODO make sure to pick the correct field
        go.add_dependency(selection.value[2])
      end)
      return true
    end,
  }):find()
end

-- TODO load this command from my plugin
vim.api.nvim_create_user_command('GoModPick', function()
  pick_dependency()
end, {
  nargs = 0,
})
