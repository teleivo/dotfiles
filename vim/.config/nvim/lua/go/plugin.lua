-- This is my plugin for Go development I am loading via Lazy
-- TODO not sure if the plugin is loaded
-- TODO setup commands
return {
  setup = function()
    Print('called')
    local go = require('go')

    vim.api.nvim_create_user_command('GoAddImport', function(cmd)
      local import_path = cmd.fargs[1]
      go.add_import(import_path)
    end, {
      nargs = 1,
    })
  end,
}
