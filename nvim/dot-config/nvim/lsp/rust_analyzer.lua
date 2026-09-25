-- https://rust-analyzer.github.io/manual.html#configuration

local rustup_home = vim.env.RUSTUP_HOME or (vim.env.HOME .. '/.rustup')
local cargo_home = vim.env.CARGO_HOME or (vim.env.HOME .. '/.cargo')
-- library code: the standard library source and dependencies fetched by cargo
local library_dirs = {
  rustup_home .. '/toolchains/',
  cargo_home .. '/registry/src/',
  cargo_home .. '/git/checkouts/',
}

--- Returns true if given file is library code.
--- @param fname string
--- @return boolean
local function is_library(fname)
  for _, dir in ipairs(library_dirs) do
    if vim.startswith(fname, dir) then
      return true
    end
  end
  return false
end

return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  -- Library code is analyzed as part of the workspace depending on it. Using its Cargo.toml as the
  -- root would start a rust-analyzer per crate which fails for the standard library as it needs a
  -- nightly cargo. Instead reuse the client of the buffer I navigated from or any other running
  -- one. Library code is not analyzed if no client is running.
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if not is_library(fname) then
      on_dir(vim.fs.root(bufnr, { 'Cargo.toml', 'rust-project.json' }))
      return
    end

    local alternate = vim.fn.bufnr('#')
    local client = alternate > 0
        and vim.lsp.get_clients({ name = 'rust_analyzer', bufnr = alternate })[1]
      or vim.lsp.get_clients({ name = 'rust_analyzer' })[1]
    if client and client.root_dir then
      on_dir(client.root_dir)
    end
  end,
  capabilities = {
    experimental = {
      -- makes experimental/externalDocs return file:// URLs to the sysroot and target/doc
      localDocs = true,
    },
  },
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = 'clippy',
      },
    },
  },
}
