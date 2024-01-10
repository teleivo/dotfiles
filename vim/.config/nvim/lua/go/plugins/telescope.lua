local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local curl = require('plenary.curl')

local go = require('go')

-- TODO fix search history. it does not show up
-- TODO make results tables to prepare adding richer info
-- TODO deal with standard library packages
-- TODO fetch the modules doc and put that html into the previewer and cache
-- TODO allow going back from module picker to search picker?

-- Cache past searches to go.pkg.dev
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

local module_picker = function(search_term)
  return function(opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = 'Pick module',
      results_title = 'Modules',
      finder = finders.new_table(get_modules(search_term)),
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
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()

          if selection then
            local module_path = selection.value
            go.add_dependency(module_path)
          end
        end)
        return true
      end,
    }):find()
  end
end

local function get_search_result(search_term)
  local search_terms = { search_term }
  for _, k in pairs(past_searches) do
    table.insert(search_terms, k)
  end

  return search_terms
end

local function search_finder()
  return function(prompt)
    return get_search_result(prompt)
  end
end

local pick_search = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'Search package on https://pkg.go.dev',
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
      fn = search_finder(),
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
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        Print(selection)
        if selection then
          vim.notify('Adding ' .. selection.value .. ' to go.mod', vim.log.levels.INFO)
          module_picker(selection.value)()
        end
      end)
      return true
    end,
  }):find()
end

return {
  pick_dependency = pick_search,
}
