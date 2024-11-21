-- This is my plugin for Go development I am loading via Lazy
-- specifically for filetype go
return {
  setup = function()
    require('go.plugin_common').setup()

    local go = require('go')

    vim.api.nvim_create_user_command('GoAddImport', function(cmd)
      local import_path = cmd.fargs[1]
      go.add_import(import_path)
    end, {
      nargs = 1,
    })

    vim.api.nvim_create_user_command('GoTest', go.run_test, {})
  end,
}
