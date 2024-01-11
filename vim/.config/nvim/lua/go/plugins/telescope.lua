local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local curl = require('plenary.curl')

local go = require('go')

-- TODO allow opening module in browser
-- TODO deal with standard library packages
-- TODO fetch the modules doc and put that html into the previewer and cache
-- TODO do I preserve relevancy of search results from pkg.go.dev?
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

  local modules = {}
  for _, captures, _ in query:iter_matches(root, body) do
    local module_path = vim.treesitter.get_node_text(captures[2], body)
    if string.find(module_path, '^/') then
      module_path = string.sub(module_path, 2)
    end
    local module = {
      path = module_path,
      repository = 'https://' .. module_path,
    }
    table.insert(modules, module)
  end
  past_searches[search_term] = modules
  -- Print(past_searches)
  return modules
end

local module_picker = function(search_term)
  return function(opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = 'Add module to go.mod',
      results_title = 'Modules',
      finder = finders.new_table({
        results = get_modules(search_term),
        entry_maker = function(entry)
          return {
            value = entry.path,
            display = entry.path,
            ordinal = entry.path,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      -- TODO get rid of default action like custom_action.top. returning false
      -- breaks everthing but search. cannot close the picker then
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()

          if selection then
            local module_path = selection.value
            vim.notify("Adding '" .. module_path .. "' to go.mod", vim.log.levels.INFO)
            go.add_dependency(module_path)
          end
        end)
        return true
      end,
    }):find()
  end
end

local function get_search_result(search_term)
  local search_terms = {}

  -- add the typed search_term as a past search so it can be selected as an entry and passed on to
  -- the module picker
  if search_term and search_term ~= '' then
    table.insert(search_terms, search_term)
  end

  for k, _ in pairs(past_searches) do
    table.insert(search_terms, k)
  end

  Print(search_terms)
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
    prompt_title = 'Search by package on https://pkg.go.dev',
    results_title = 'Past searches',
    finder = finders.new_dynamic({
      fn = search_finder(),
      entry_maker = function(entry)
        -- TODO do I even need this or can I rely on a default if an entry is just a string?
        return {
          value = entry,
          display = entry,
          ordinal = entry,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    -- TODO get rid of default action like custom_action.top. returning false
    -- breaks everthing but search. cannot close the picker then
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        -- Print(selection)
        if selection then
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
