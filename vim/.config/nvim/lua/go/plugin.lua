-- This is my plugin for Go development I am loading via Lazy
return {
  setup = function()
    local go = require('go')

    vim.api.nvim_create_user_command('GoAddImport', function(cmd)
      local import_path = cmd.fargs[1]
      go.add_import(import_path)
    end, {
      nargs = 1,
    })

    vim.api.nvim_create_user_command('GoAddDependency', function(cmd)
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
