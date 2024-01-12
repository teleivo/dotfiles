-- Allows searching of packages and adding a module dependency to the current modules go.mod.
-- Searching is done in https://pkg.go.dev.
-- See https://pkg.go.dev/search-help for details on the search capabilities.
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local transform_mod = require('telescope.actions.mt').transform_mod

local job = require('plenary.job')
local curl = require('plenary.curl')

local go = require('go')

-- TODO remove duplicate from past search if I enter the same key
-- TODO handle no internet gracefully
-- TODO can I assume the repo url is github.com/{owner}/{name} so getting rid of the tail after a
-- potential third / which separates the module_path from the package_path. What I called
-- module_path so far is likely the package_path or import path. Check naming
-- TODO fetch the modules doc and put that html into the previewer and cache
-- TODO do I preserve relevancy of search results from pkg.go.dev?
-- TODO allow going back from module picker to search picker?
-- TODO allow searching for symbols within a package like '#reader io'
-- TODO show more details? like description and imported by X
-- TODO handle edge case:
-- If the package path you specified is complete enough, matching a full package import path,
-- you will be brought directly to the details page for the latest version of that package.

-- Cache past searches to go.pkg.dev
local past_searches = {}

local function search_packageS(search_term)
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
  (_
    (element
      (start_tag
          (
            (attribute
              (
                (attribute_name) @package_href_attr
                (quoted_attribute_value (attribute_value) @package_href)
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
      (text) @package_name
      (#eq? @package_href_attr "href")
      (#eq? @next_attr_val "search result")
    )
  @package_result)

(element
  (text) @standard_library)?
  (#eq? @standard_library "standard library")

) @package_search_result
  ]]
  )

  local packages = {}
  for _, match, _ in query:iter_matches(root, body) do
    local package_path
    local package_name
    local is_standard_library = false
    for id, node in pairs(match) do
      local capture_name = query.captures[id]

      if capture_name == 'package_href' then
        package_path = vim.treesitter.get_node_text(node, body)
        if string.find(package_path, '^/') then
          package_path = string.sub(package_path, 2)
        end
      elseif capture_name == 'package_name' then
        package_name = vim.treesitter.get_node_text(node, body)
      elseif capture_name == 'standard_library' then
        is_standard_library = true
      end
    end

    local package = {
      package_path = package_path,
      package_name = package_name,
      is_standard_library = is_standard_library or false,
      pkg_go_dev_url = 'https://pkg.go.dev/' .. package_path,
    }
    table.insert(packages, package)
  end
  past_searches[search_term] = packages
  return packages
end

local custom_actions = {}
custom_actions.open_module_repository_url = function()
  local entry = action_state.get_selected_entry()

  -- TODO how to get from selection to the rich module which has the url?
  -- also the url is wrong. seems like I have the module path as url. they are not the same
  Print(entry)
  job
    :new({
      command = 'sensible-browser',
      args = { 'https://pkg.go.dev/' .. entry.value },
      cwd = '/usr/bin',
    })
    :start()
end
custom_actions = transform_mod(custom_actions)

local module_picker = function(search_term)
  return function(opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = 'Add module for package to go.mod',
      results_title = 'Packages',
      finder = finders.new_table({
        results = search_packageS(search_term),
        entry_maker = function(entry)
          local display = entry.package_name .. ' (' .. entry.package_path .. ')'
          if entry.is_standard_library then
            display = display .. ' standard library'
          end

          return {
            value = entry.package_path,
            display = display,
            ordinal = entry.package_path,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        -- disable mappings/actions that don't make sense in this context
        map({ 'i', 'n' }, '<C-x>', false)
        map({ 'i', 'n' }, '<C-v>', false)
        map({ 'i', 'n' }, '<C-t>', false)
        map({ 'i', 'n' }, '<Tab>', false)
        map({ 'i', 'n' }, '<S-Tab>', false)

        map({ 'i', 'n' }, '<C-b>', custom_actions.open_module_repository_url)

        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()

          if selection then
            local package_path = selection.value
            vim.notify("Adding '" .. package_path .. "' to go.mod", vim.log.levels.INFO)
            go.add_dependency(package_path)
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
    attach_mappings = function(prompt_bufnr, map)
      -- disable mappings/actions that don't make sense in this context
      map({ 'i', 'n' }, '<C-x>', false)
      map({ 'i', 'n' }, '<C-v>', false)
      map({ 'i', 'n' }, '<C-t>', false)
      map({ 'i', 'n' }, '<Tab>', false)
      map({ 'i', 'n' }, '<S-Tab>', false)

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
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
