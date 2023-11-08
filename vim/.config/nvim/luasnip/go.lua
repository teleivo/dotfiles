local ls = require('luasnip')

local sn = ls.sn

local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local c = ls.choice_node
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

local ts_locals = require('nvim-treesitter.locals')
local ts_utils = require('nvim-treesitter.ts_utils')

local get_node_text = vim.treesitter.get_node_text

local function_node_types = {
  function_declaration = true,
  method_declaration = true,
  func_literal = true,
}

-- Get the nearest function node in the scope enclosing the current cursor position.
---@return TSNode|nil
local get_function_node_at_cursor = function()
  local cursor_node = ts_utils.get_node_at_cursor()
  if not cursor_node then
    error('failed to get node at cursor')
  end

  local scope = ts_locals.get_scope_tree(cursor_node, 0)
  for _, node in ipairs(scope) do
    if function_node_types[node:type()] then
      return node
    end
  end

  return nil
end

-- Test whether the cursor is in scope of a function node returning a result.
local is_function_node_returning_result = function()
  local function_node = get_function_node_at_cursor()
  if not function_node then
    return false
  end

  local query = vim.treesitter.query.parse(
    'go',
    [[
      [
        (method_declaration result: (parameter_list) @result)
        (function_declaration result: (parameter_list) @result)
        (func_literal result: (parameter_list) @result)
      ]
    ]]
  )
  for _, _ in query:iter_captures(function_node, 0) do
    return true
  end

  return false
end

-- Test whether the cursor is in scope of a function node returning an error.
local is_function_node_returning_error = function()
  local function_node = get_function_node_at_cursor()
  if not function_node then
    return false
  end

  local query = vim.treesitter.query.parse(
    'go',
    [[
      [
        (method_declaration result: (parameter_list (parameter_declaration type: (type_identifier) @id (#eq? @id "error"))))
        (function_declaration result: (parameter_list (parameter_declaration type: (type_identifier) @id (#eq? @id "error"))))
        (func_literal result: (parameter_list (parameter_declaration type: (type_identifier) @id (#eq? @id "error"))))
      ]
    ]]
  )
  for _, _ in query:iter_captures(function_node, 0) do
    return true
  end

  return false
end

-- Get the result typeof the nearest function in the scope enclosing the current cursor position.
-- Calling this function outside of the scope of a function node is considered an error.
---@return string[]
local get_function_result_types = function()
  local function_node = get_function_node_at_cursor()
  if not function_node then
    error('Not inside of a function')
  end

  local query = vim.treesitter.query.parse(
    'go',
    [[
      [
        (method_declaration result: (parameter_list (parameter_declaration type: (_) @id)))
        (function_declaration result: (parameter_list (parameter_declaration type: (_) @id)))
        (func_literal result: (parameter_list (parameter_declaration type: (_) @id)))
      ]
    ]]
  )

  local result = {}
  for _, node in query:iter_captures(function_node, 0) do
    table.insert(result, get_node_text(node, 0))
  end

  return result
end

-- c_error creates a choice node at given jump index. Choices are either the error err_name as is,
-- expanding on its error using a new error or wrapping it.
local c_error = function(index, err_name)
  return c(index, {
    t(err_name),
    sn(nil, {
      t('fmt.Errorf("'),
      i(1),
      t(string.format(': %%s", %s)', err_name)),
    }),
    sn(nil, {
      t('fmt.Errorf("'),
      i(1),
      t(string.format(': %%w", %s)', err_name)),
    }),
  })
end

local transforms = {
  int = function(_, _)
    return t('0')
  end,

  bool = function(_, _)
    return t('false')
  end,

  string = function(_, _)
    return t([[""]])
  end,

  error = function(_, info)
    if info then
      info.index = info.index + 1
      return c_error(info.index, info.err_name)
    end

    return t('err')
  end,

  -- Types with a "*" mean they are pointers, so return nil
  [function(text)
    return string.find(text, '*', 1, true) ~= nil
  end] = function(_, _)
    return t('nil')
  end,
}

local transform = function(text, info)
  local condition_matches = function(condition, ...)
    if type(condition) == 'string' then
      return condition == text
    else
      return condition(...)
    end
  end

  for condition, result in pairs(transforms) do
    if condition_matches(condition, text, info) then
      return result(text, info)
    end
  end

  return t(text)
end

local handlers = {
  parameter_list = function(node, info)
    local result = {}

    local count = node:named_child_count()
    for idx = 0, count - 1 do
      local matching_node = node:named_child(idx)
      local type_node = matching_node:field('type')[1]
      table.insert(result, transform(get_node_text(type_node, 0), info))
      if idx ~= count - 1 then
        table.insert(result, t({ ', ' }))
      end
    end
    return result
  end,

  type_identifier = function(node, info)
    local text = get_node_text(node, 0)
    return { transform(text, info) }
  end,
}

local function go_result_type(info)
  local function_node = get_function_node_at_cursor()
  if not function_node then
    print('Not inside of a function')
    return t('')
  end

  local query = vim.treesitter.query.parse(
    'go',
    [[
      [
        (method_declaration result: (_) @id)
        (function_declaration result: (_) @id)
        (func_literal result: (_) @id)
      ]
    ]]
  )
  for _, node in query:iter_captures(function_node, 0) do
    if handlers[node:type()] then
      return handlers[node:type()](node, info)
    end
  end
end

local sn_return_values = function(args)
  return sn(
    nil,
    go_result_type({
      index = 0,
      err_name = args[1][1],
    })
  )
end

local zero_values = {
  byte = '0',
  rune = '0',
  int = '0',
  int8 = '0',
  int16 = '0',
  int32 = '0',
  int64 = '0',
  uint = '0',
  uint8 = '0',
  uint16 = '0',
  uint32 = '0',
  uint64 = '0',
  float32 = '0',
  float64 = '0',
  bool = 'false',
  string = '""',
}

local sn_result_types = function()
  local types = get_function_result_types()

  local result = {}
  for idx, type in pairs(types) do
    local value = zero_values[type]
    -- when in doubt assume its a reference type, as I am using input nodes I can always override this
    -- default
    value = value or 'nil'
    table.insert(result, i(idx, value))
    if next(types, idx) then
      table.insert(result, t({ ', ' }))
    end
  end

  return sn(nil, result)
end

-- TODO how to get vars that are in scope? create a function for that
-- TODO pass in above function with vars per type and make a choice node per result type with the
-- zero value insert node as the first, followed by var text nodes
-- TODO errors should get the fmt.Errorf %v and %w options in addition to the var ones
return {
  s(
    {
      trig = 're',
      show_condition = is_function_node_returning_result,
    },
    fmta(
      [[
return <result>
<finish>
]],
      {
        result = d(1, sn_result_types),
        finish = i(0),
      }
    ),
    { condition = is_function_node_returning_result }
  ),
  s(
    {
      trig = 'fe',
      show_condition = is_function_node_returning_error,
    },
    fmta(
      [[
<val>, <err> := <f>(<args>)
if <err_same> != nil {
	return <result>
}
<finish>
]],
      {
        val = i(1),
        err = i(2, 'err'),
        f = i(3),
        args = i(4),
        err_same = rep(2),
        result = d(5, sn_return_values, { 2 }),
        finish = i(0),
      }
    ),
    { condition = is_function_node_returning_error }
  ),
}
