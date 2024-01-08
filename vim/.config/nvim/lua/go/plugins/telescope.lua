local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local curl = require('plenary.curl')

local go = require('go')

-- TODO parse sample html using TS
-- TODO find TS query to get what I need for the result
-- TODO connect parsing/querying with telescope displaying the result from the HTML
-- TODO make request using curl to search for real. Make sure to require at least 3 chars. Cache
-- result.
-- require('plenary.curl').get('https://pkg.go.dev/github.com/google/go-cmp/cmp')
--
-- TODO fetch the modules doc and put that html into the previewer and cache.
-- (element
--   (start_tag
--     (attribute
--       (quoted_attribute_value
--         (attribute_value) @val
--           (#eq? @val "SearchSnippet-headerContainer"))))
-- @snippet)

-- valid but does not capture anything
-- (element
--   (start_tag
--
--     (
--
--     (attribute
--       (quoted_attribute_value
--         (attribute_value) @val
--           (#eq? @val "snippet-title")))
--
--     (attribute
--         (attribute_name) @href
--           (#eq? @href "href"))
--     )
-- )
-- )
-- @snippet

-- Cache past searches to go.pkg.dev
local past_searches = {}

local function find_package(search_term)
  local result
  result = past_searches[search_term]
  if not result then
    local request = curl.get('https://pkg.go.dev/search?q=' .. search_term)
    result = request.body
  end
  Print(result)

  local language_tree = vim.treesitter.get_string_parser(result, 'html')

  --    (element
  --    (start_tag
  -- ((attribute
  --         (quoted_attribute_value
  --           (attribute_value) @val
  --             ))))
  --  (#eq? @val "search result")) @snippet

  -- local syntax_tree = language_tree:parse()
  -- local root = syntax_tree[1]:root()
  -- print_node(root, bufnr)
end

local pick_dependency = function(opts)
  find_package('cmp')
  if true then
    return
  end

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

return {
  pick_dependency = pick_dependency,
}
