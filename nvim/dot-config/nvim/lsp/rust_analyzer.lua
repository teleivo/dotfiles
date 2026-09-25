-- https://rust-analyzer.github.io/manual.html#configuration
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
  single_file_support = true,
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
