local jdtls = require 'jdtls'
local M = {}

function M.start_jdt()
  local root_markers = {'gradlew', '.git', 'pom.xml', 'mvnw'}
  local root_dir = require('jdtls.setup').find_root(root_markers)
  local home = os.getenv('HOME')
  local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
  local config = {
    cmd = {'java-lsp', workspace_folder},
    root_dir = root_dir,
  }
  jdtls.start_or_attach(config)
end

return M
