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
local current_search
local past_searches = {}

local function get_modules(search_term)
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

local function get_search_result(search_term)
  -- I don't want every char to lead to an entry in past searches. How can I only capture the one on
  -- enter. The one that should be the selection? Can that only be one from the entries.
  -- if so I could store it in a temp structure. And then only add the term/make the search on
  -- selection
  current_search = search_term

  local search_terms = { search_term }
  for _, k in pairs(past_searches) do
    table.insert(search_terms, k)
  end

  return search_terms
end

local function package_searcher(bufnr, opts)
  return function(prompt)
    return get_search_result(prompt)
  end
end

local pick_dependency = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'Search modules on https://pkg.go.dev',
    results_title = 'Past searches',
    -- TODO can I use telescope as a two step input, first input search term searching through past
    -- searches. The tricky thing might be if there is no entry.
    -- then searching through the results of the selected past search
    -- finder = finders.new_table(find_package('cmp')),
    finder = finders.new_dynamic({
      entry_maker = function(entry)
        -- TODO make sure to adapt if my finder returns richer stuff
        return {
          value = entry,
          display = entry,
          ordinal = entry,
        }
      end,
      fn = package_searcher(opts.bufnr, opts),
    }),
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
        Print(selection)

        -- TODO this needs to move into the next picker
        -- again using a dynamic finder or the oneshotjob?
        if selection then
          get_modules(selection.value)
        end
        -- local module_path = selection[1]
        -- Print(module_path)
        -- go.add_dependency(module_path)
      end)
      return true
    end,
  }):find()
end

return {
  pick_dependency = pick_dependency,
}
