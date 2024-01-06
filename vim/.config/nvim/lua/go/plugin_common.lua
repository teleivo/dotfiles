-- These are common commands for go and gomod files.
return {
  setup = function()
    local go = require('go')

    vim.api.nvim_create_user_command('GoModAdd', function(cmd)
      local module_path = cmd.fargs[1]
      local module_version = cmd.fargs[2]
      go.add_dependency(module_path, module_version)
    end, {
      nargs = '+',
    })

    vim.api.nvim_create_user_command('GoModTidy', function()
      go.mod_tidy()
    end, {
      nargs = 0,
    })
  end,
}
