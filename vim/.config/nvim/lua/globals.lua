-- thank you :) https://github.com/tjdevries/config_manager/blob/6e48802a9c6acc9f8f2c9768fcb57d6ce1f05e00/xdg_config/nvim/lua/tj/globals.lua
Print = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(...)
  return require('plenary.reload').reload_module(...)
end


-- TODO move to rest once the config is fixed
UID = function()
  local digits = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  local alphabet = {
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  }
  local alphanumeric = { unpack(alphabet), unpack(digits) }
  local first = alphabet[math.random(1, #alphabet)]
  local uid = first
  for _ = 1, 10, 1 do
    uid = uid .. alphanumeric[math.random(1, #alphanumeric)]
  end
  return uid
end

R = function(name)
  RELOAD(name)
  return require(name)
end
