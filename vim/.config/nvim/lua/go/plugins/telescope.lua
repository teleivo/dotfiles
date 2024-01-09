local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local curl = require('plenary.curl')

local go = require('go')

-- TODO connect parsing/querying with telescope displaying the result from the HTML
-- TODO deal with standard library packages
-- TODO fetch the modules doc and put that html into the previewer and cache.

-- Cache past searches to go.pkg.dev
local past_searches = {}

local function find_package(search_term)
  local result
  result = past_searches[search_term]
  if result then
    return result
  end

  local request = curl.get('https://pkg.go.dev/search?q=' .. search_term)
  local body = request.body

  local language_tree = vim.treesitter.get_string_parser(body, 'html')
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  local query = vim.treesitter.query.parse(
    'html',
    [[
(element
  (start_tag
    (
        (attribute
          (
           (attribute_name) @attr_name
           (quoted_attribute_value (attribute_value) @attr_val)
          )
        )
        .
        (attribute
          (
           (quoted_attribute_value (attribute_value) @next_attr_val)
          )
        )
    )
  )
(#eq? @attr_name "href")
(#eq? @next_attr_val "search result")
) @el
  ]]
  )

  local package_urls = {}
  for _, captures, _ in query:iter_matches(root, body) do
    local package_url = vim.treesitter.get_node_text(captures[2], body)
    if string.find(package_url, '^/') then
      package_url = string.sub(package_url, 2)
    end
    table.insert(package_urls, package_url)
  end
  past_searches[search_term] = package_urls
  return package_urls
end

local pick_dependency = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'Add dependency to Go mod',
    -- TODO can I use telescope as a two step input, first input search term searching through past
    -- searches. The tricky thing might be if there is no entry.
    -- then searching through the results of the selected past search
    finder = finders.new_table(find_package('cmp')),
    entry_maker = function(entry)
      -- TODO make sure to adapt if my finder returns richer stuff
      return {
        value = entry,
        display = entry,
        ordinal = entry,
      }
    end,
    sorter = conf.generic_sorter(opts),
    -- TODO get rid of default action like custom_action.top. returning false
    -- breaks everthing but search. cannot close the picker then
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        -- TODO nothing gets selected, why?
        local module_path = selection[1]
        Print(module_path)
        go.add_dependency(module_path)
      end)
      return true
    end,
  }):find()
end

return {
  pick_dependency = pick_dependency,
}
