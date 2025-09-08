-- thank you :) https://github.com/tjdevries/config_manager/blob/6e48802a9c6acc9f8f2c9768fcb57d6ce1f05e00/xdg_config/nvim/lua/tj/globals.lua
Print = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(...)
  return require('plenary.reload').reload_module(...)
end

Debounce = function(ms, fn)
  local timer = vim.uv.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

R = function(name)
  RELOAD(name)
  return require(name)
end
