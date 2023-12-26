local M = {}

-- TODO add type descriptions to docs

local function is_node_type(node, node_type)
  if node['node_type'] == node_type then
    return true
  end

  return false
end

-- TODO refer to tagged technique in book
-- and constructor/getter

-- Construct a function declaration with given name and signature.
-- https://go.dev/ref/spec#Function_declarations
M.function_decl = function(function_name, signature)
  return {
    ['node_type'] = 'FunctionDecl',
    ['function_name'] = function_name,
    ['signature'] = signature,
  }
end

M.is_function_decl = function(node)
  return is_node_type(node, 'FunctionDecl')
end

M.get_function_decl_function_name = function(function_decl)
  return function_decl['function_name']
end

M.get_function_decl_signature = function(function_decl)
  return function_decl['signature']
end

-- Construct a function name.
-- https://go.dev/ref/spec#FunctionName
-- TODO https://go.dev/ref/spec#identifier is just a string for now. Maybe it should also be
-- declared as a node type and node types should be distinguished as
-- >>  Lowercase production names are used to identify lexical (terminal) tokens. Non-terminals are in CamelCase. Lexical tokens are enclosed in double quotes "" or back quotes ``.
M.function_name = function(identifier)
  return {
    ['node_type'] = 'FunctionName',
    ['identifier'] = identifier,
  }
end

M.is_function_name = function(node)
  return is_node_type(node, 'FunctionName')
end

M.get_function_name_identifier = function(function_name)
  return function_name['identifier']
end

-- Construct a signature with given parameters and result.
-- https://go.dev/ref/spec#Signature
M.signature = function(parameters, result)
  return {
    ['node_type'] = 'Signature',
    ['parameters'] = parameters,
    ['result'] = result,
  }
end

M.is_signature = function(node)
  return is_node_type(node, 'Signature')
end

M.get_signature_parameters = function(signature)
  return signature['parameters']
end

M.get_signature_result = function(signature)
  return signature['result']
end

-- TODO don't quite understand why https://go.dev/ref/spec#Parameters
-- there is a ParameterList. Why can Parameters not only be composed of n ParameterDecl?
-- Skipping ParameterList for now until I know why its needed.
-- Construct a parameters with given parameter declarations.
-- https://go.dev/ref/spec#Parameters
M.parameters = function(parameter_decls)
  return {
    ['node_type'] = 'Parameters',
    ['parameter_list'] = parameter_decls,
  }
end

M.is_parameters = function(node)
  return is_node_type(node, 'Parameters')
end

M.get_parameters_parameter_decls = function(parameters)
  return parameters['parameter_list']
end

-- Construct a parameter declaration with given identifier list and type.
-- https://go.dev/ref/spec#ParameterDecl
-- TODO https://go.dev/ref/spec#Type keep it as a string for now at least.
M.parameter_decl = function(identifier_list, type)
  return {
    ['node_type'] = 'ParameterDecl',
    ['identifier_list'] = identifier_list,
    ['type'] = type,
  }
end

M.is_parameter_decl = function(node)
  return is_node_type(node, 'ParameterDecl')
end

M.get_parameter_decl_identifier_list = function(parameter_decl)
  return parameter_decl['identifier_list']
end

M.get_parameter_decl_type = function(parameter_decl)
  return parameter_decl['type']
end

-- Construct an identifier list with given identifiers.
-- https://go.dev/ref/spec#IdentifierList
-- TODO https://go.dev/ref/spec#identifier keep it as string for now at least.
M.identifier_list = function(identifiers)
  return {
    ['node_type'] = 'IdentifierList',
    ['identifiers'] = identifiers,
  }
end

M.is_identifier_list = function(node)
  return is_node_type(node, 'IdentifierList')
end

M.get_identifier_list_identifiers = function(identifier_list)
  return identifier_list['identifiers']
end

-- TODO define result
-- https://go.dev/ref/spec#Result

M.walk = function(node, fn)
  if M.is_function_decl(node) then
    M.walk(M.get_function_decl_function_name(node))
    M.walk(M.get_function_decl_signature(node))
  end
  if M.is_function_name(node) then
    fn(M.get_function_name_identifier(node))
  end
end

return M
