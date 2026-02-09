local ls = require('luasnip')

local go = require('my-go')
local sn = ls.sn
local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local c = ls.choice_node
local r = ls.restore_node
local k = require('luasnip.nodes.key_indexer').new_key
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep
local events = require('luasnip.util.events')
local make_condition = require('luasnip.extras.conditions').make_condition
local treesitter_postfix = require('luasnip.extras.treesitter_postfix').treesitter_postfix

local ts_locals = require('nvim-treesitter.locals')
local ts_utils = require('nvim-treesitter.ts_utils')

-- Return a snippet node comma separating given nodes using text nodes to make it a valid list according
-- to the Go spec.
-- See for example https://go.dev/ref/spec#ParameterList
local function sn_list(jump_index, nodes)
  if not next(nodes) then
    return sn(jump_index, nodes)
  end

  local result = {}
  for idx, node in pairs(nodes) do
    table.insert(result, node)
    if next(nodes, idx) then
      table.insert(result, t({ ', ' }))
    end
  end

  return sn(jump_index, result)
end

-- Create snippet node table representing a Go return statement.
-- https://go.dev/ref/spec#Return_statements
local fmta_return_statement = function(opts)
  local expression_list = t('')
  if opts.expression_list then
    expression_list = sn(1, { t(' '), opts.expression_list })
  end

  return fmta(
    [[
return<expression_list>
]],
    {
      expression_list = expression_list,
    }
  )
end

-- Create snippet node table representing a Go function or method declaration.
-- https://go.dev/ref/spec#Function_declarations
-- https://go.dev/ref/spec#Method_declarations
local fmta_fn_declaration = function(opts)
  local receiver = t('')
  if opts.receiver then
    receiver = sn(1, { t('('), opts.receiver, t(') ') })
  end
  local name = opts.name
  local parameters = opts.parameters or t('')
  local body = opts.body or i(0)
  local result = opts.result or t('')

  return fmta(
    [[
func <receiver><name>(<parameters>) <result>{
	<body>
}
]],
    {
      receiver = receiver,
      name = name,
      parameters = parameters,
      result = result,
      body = body,
    }
  )
end

-- Create snippet node table representing a Go if statement.
-- https://go.dev/ref/spec#If_statements
local fmta_if = function(opts)
  local max_jump_index = 0
  local simple_statement
  if opts.simple_statement then
    simple_statement = sn(1, { opts.simple_statement, t('; ') })
    max_jump_index = max_jump_index + 1
  else
    simple_statement = t('')
  end
  local expression = opts.expression
  max_jump_index = max_jump_index + 1
  local statement_list = opts.statement_list or i(max_jump_index + 1)

  return fmta(
    [[
if <simple_statement><expression> {
	<statement_list>
}<finish>
]],
    {
      simple_statement = simple_statement,
      expression = expression,
      statement_list = statement_list,
      finish = i(0),
    }
  )
end

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

-- Test whether the cursor is in scope of a function node.
local is_cursor_in_function = make_condition(function()
  local function_node = get_function_node_at_cursor()
  if not function_node then
    return false
  end

  return true
end)

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

local sn_errorf_string = function(err_name, restore_key)
  return sn(nil, {
    t('fmt.Errorf("'),
    restore_key and r(1, restore_key) or i(1),
    t(string.format(': %%s", %s)', err_name)),
  })
end

local sn_errorf_wrap = function(err_name, restore_key)
  return sn(nil, {
    t('fmt.Errorf("'),
    restore_key and r(1, restore_key) or i(1),
    t(string.format(': %%w", %s)', err_name)),
  })
end

local sn_errors_new = function(restore_key)
  return sn(nil, {
    t('errors.New("'),
    restore_key and r(1, restore_key) or i(1),
    t('")'),
  })
end

-- c_error creates a choice node at given jump index. Choices are either the error err_name as is,
-- expanding on its error using a new error, wrapping it, or creating a new error. The error message
-- is preserved when cycling between choices using a restore node.
local c_error = function(index, err_name)
  return c(index, {
    t(err_name),
    sn_errorf_string(err_name, 'err_msg'),
    sn_errorf_wrap(err_name, 'err_msg'),
    sn_errors_new('err_msg'),
  })
end

-- c_new_error creates a choice node at given jump index for creating a new error from scratch.
local c_new_error = function(index)
  return c(index, {
    sn_errors_new('err_msg'),
    sn_errorf_string('err', 'err_msg'),
    sn_errorf_wrap('err', 'err_msg'),
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

local sn_result_values_with_err = function(args)
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

local type_to_zero_value = function(type)
  local value = zero_values[type]
  -- when in doubt assume its a reference type, as I am using input nodes I can always override this
  -- default
  return value or 'nil'
end

local is_in_test_file = make_condition(function()
  local file = vim.fn.expand('%:t')
  if string.find(file, 'test') then
    return true
  end

  return false
end)

local sn_result_values = function()
  local types = get_function_result_types()

  if not next(types) then
    return sn(nil, { t('') })
  end

  local result = {}
  for idx, type in pairs(types) do
    local value = type_to_zero_value(type)
    table.insert(result, i(idx, value))
    if next(types, idx) then
      table.insert(result, t({ ', ' }))
    end
  end

  return sn(nil, result)
end

-- Test whether the buffer only contains the trigger. The buffer will contain the trigger, otherwise
-- this function will not even be called. The idea is to check whether the buffer is otherwise
-- empty.
local is_buffer_empty = make_condition(function()
  -- only get a couple of lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, 4, false)
  if #lines == 1 then
    return true
  end
  return false
end)

local function s_main_program()
  local nodes = fmta(
    [[package main


  ]],
    {}
  )
  vim.list_extend(
    nodes,
    fmta_fn_declaration({
      name = t('main'),
    })
  )
  return s(
    {
      trig = 'main',
      desc = 'Main program',
      show_condition = is_buffer_empty,
    },
    nodes,
    {
      condition = is_buffer_empty,
    }
  )
end

local function s_function_declaration()
  return s(
    {
      trig = 'func',
      desc = 'Function declaration',
    },
    fmta_fn_declaration({
      name = i(1, 'FunctionName'),
      parameters = i(2, ''),
      result = i(3, ''),
    })
  )
end

local function s_method_declaration()
  return s(
    {
      trig = 'method',
      desc = 'Method declaration',
    },
    fmta_fn_declaration({
      receiver = i(1, ''),
      name = i(2, 'MethodName'),
      parameters = i(3, ''),
      result = i(4, ''),
    })
  )
end

local function s_if_statement()
  return s(
    {
      trig = 'if',
      desc = 'If statement',
      show_condition = is_cursor_in_function,
    },
    fmta_if({
      expression = i(1, 'true'),
    }),
    { condition = is_cursor_in_function }
  )
end

-- TODO adapt fe snippet to my own snippet style so I can reuse the error return logic
local function s_if_err_statement()
  return s(
    {
      trig = 'ife',
      desc = 'If statement err != nil',
      show_condition = is_cursor_in_function,
    },
    fmta_if({
      expression = sn(1, { i(1, 'err', { key = 'err' }), t(' != nil ') }),
      statement_list = sn(
        2,
        fmta_return_statement({
          expression_list = d(1, sn_result_values_with_err, k('err')),
        })
      ),
    }),
    { condition = is_cursor_in_function }
  )
end

-- Return if statement to compare got and want values in a test.
-- https://go.dev/wiki/CodeReviewComments#useful-test-failures
-- Currently it defaults to 'tc.in' in the assertion message which is coming from snippet
-- s_table_driven test. This could of course be a repeat node using a key.
local function s_if_cmp_diff_statement()
  return s(
    {
      trig = 'ifd',
      desc = 'If statement asserting equality of values using cmp',
      show_condition = is_cursor_in_function,
    },
    fmta_if({
      simple_statement = sn(1, {
        t('diff := cmp.Diff'),
        t('('),
        sn_list(1, {
          i(1, 'want', { key = 'want' }),
          i(2, 'got', { key = 'got' }),
        }),
        t(')'),
      }),
      expression = t('diff != ""'),
      statement_list = sn(2, {
        t('t.Errorf("%s(%q) mismatch (-want +got):\\n%s", '),
        sn_list(1, {
          i(1, 'method'),
          i(2, 'tc.in'),
          t('diff'),
        }),
        t(')'),
      }),
    }),
    {
      condition = is_in_test_file * is_cursor_in_function,
      callbacks = {
        [-1] = {
          [events.leave] = function()
            -- TODO make it required. by default it seems as indirect
            go.import('github.com/google/go-cmp/cmp')
            go.gomod_add('github.com/google/go-cmp/cmp')
          end,
        },
      },
    }
  )
end

local function s_return_statement()
  return s(
    {
      trig = 'return',
      show_condition = is_cursor_in_function,
    },
    fmta_return_statement({
      expression_list = d(1, sn_result_values),
    }),
    { condition = is_cursor_in_function }
  )
end

local function s_fe()
  return s(
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
        result = d(5, sn_result_values_with_err, { 2 }),
        finish = i(0),
      }
    ),
    { condition = is_function_node_returning_error }
  )
end

local function s_test_function_declaration()
  return s(
    {
      trig = 'test',
      desc = 'Test',
      show_condition = is_in_test_file,
    },
    fmta_fn_declaration({
      name = sn(1, { t('Test'), i(1, 'Name') }),
      parameters = t('t *testing.T'),
    }),
    {
      condition = is_in_test_file,
      callbacks = {
        [-1] = {
          [events.leave] = function()
            go.import('testing')
          end,
        },
      },
    }
  )
end

local function s_table_driven_test()
  --  TODO how to best deal with different input types? use zero_values to then also set the default
  --  value in the first test case. Same for want. What if the type is itself a struct? Maybe deal
  --  with that later.
  --  TODO create assertion snippet for normal == and using cmp; use it then in this snippet via a
  --  choice node
  return s(
    {
      trig = 'tt',
      desc = 'Table-driven test',
      show_condition = is_in_test_file,
    },
    fmta(
      [[
        tests := []struct{
          in <in_type>
          want <want_type>
        }{
            {
              in: <in_value>,
              want: <want_value>,
            },
        }

        for _, tc := range tests {
          got := <fn>(tc.in)

          <finish>
        }
      ]],
      {
        in_type = i(1, 'string'),
        want_type = i(2, 'string'),
        in_value = d(3, function(args)
          return sn(nil, {
            i(1, type_to_zero_value(args[1][1])),
          })
        end, { 1 }),
        want_value = d(4, function(args)
          return sn(nil, {
            i(1, type_to_zero_value(args[1][1])),
          })
        end, { 2 }),
        fn = i(5, 'call'),
        finish = i(0),
      }
    ),
    { condition = is_in_test_file }
  )
end

local function s_struct_declaration()
  return s(
    {
      trig = 'struct',
      desc = 'Struct type declaration',
    },
    fmta(
      [[
type <name> struct {
	<fields>
}<finish>
]],
      {
        name = i(1, 'Name'),
        fields = i(2),
        finish = i(0),
      }
    )
  )
end

local function s_interface_declaration()
  return s(
    {
      trig = 'interface',
      desc = 'Interface type declaration',
    },
    fmta(
      [[
type <name> interface {
	<methods>
}<finish>
]],
      {
        name = i(1, 'Name'),
        methods = i(2),
        finish = i(0),
      }
    )
  )
end

local function s_switch_statement()
  return s(
    {
      trig = 'switch',
      desc = 'Switch statement',
      show_condition = is_cursor_in_function,
    },
    fmta(
      [[
switch <expr> {
case <case>:
	<body>
}<finish>
]],
      {
        expr = i(1),
        case = i(2),
        body = i(3),
        finish = i(0),
      }
    ),
    { condition = is_cursor_in_function }
  )
end

local function s_for_index()
  return s(
    {
      trig = 'fori',
      desc = 'For loop with index',
      show_condition = is_cursor_in_function,
    },
    fmta(
      [[
for <idx> := <start>; <idx_cond> << <end_cond>; <idx_inc>++ {
	<body>
}<finish>
]],
      {
        idx = i(1, 'i'),
        start = i(2, '0'),
        idx_cond = rep(1),
        end_cond = i(3, 'n'),
        idx_inc = rep(1),
        body = i(4),
        finish = i(0),
      }
    ),
    { condition = is_cursor_in_function }
  )
end

local function s_for_range()
  return s(
    {
      trig = 'forr',
      desc = 'For range loop',
      show_condition = is_cursor_in_function,
    },
    fmta(
      [[
for <idx>, <val> := range <iter> {
	<body>
}<finish>
]],
      {
        idx = i(1, '_'),
        val = i(2, 'v'),
        iter = i(3),
        body = i(4),
        finish = i(0),
      }
    ),
    { condition = is_cursor_in_function }
  )
end

local function s_error()
  return s(
    {
      trig = 'err',
      desc = 'Error value',
      show_condition = is_cursor_in_function,
    },
    c_new_error(1),
    { condition = is_cursor_in_function }
  )
end

local postfix_builtin = require('luasnip.extras.treesitter_postfix').builtin

local match_identifier = postfix_builtin.tsnode_matcher.find_topmost_types({
  'identifier',
  'selector_expression',
})

local s_postfix_error_wrap = function()
  return treesitter_postfix(
    {
      trig = '.w',
      desc = 'Wrap error',
      matchTSNode = match_identifier,
      reparseBuffer = 'live',
    },
    d(1, function(_, parent)
      return sn_errorf_wrap(parent.snippet.env.LS_TSMATCH[1])
    end)
  )
end

local s_postfix_error_describe = function()
  return treesitter_postfix(
    {
      trig = '.s',
      desc = 'Describe error',
      matchTSNode = match_identifier,
      reparseBuffer = 'live',
    },
    d(1, function(_, parent)
      return sn_errorf_string(parent.snippet.env.LS_TSMATCH[1])
    end)
  )
end

-- TODO how to get vars that are in scope? create a function for that
-- TODO pass in above function with vars per type and make a choice node per result type with the
-- zero value insert node as the first, followed by var text nodes
return {
  s_main_program(),
  s_function_declaration(),
  s_method_declaration(),
  s_struct_declaration(),
  s_interface_declaration(),
  s_for_index(),
  s_for_range(),
  s_if_statement(),
  s_if_err_statement(),
  s_if_cmp_diff_statement(),
  s_return_statement(),
  s_switch_statement(),
  s_error(),
  s_fe(),
  s_test_function_declaration(),
  s_table_driven_test(),
  s_postfix_error_wrap(),
  s_postfix_error_describe(),
}
