--- My plugin for development in Rust. Navigates the code and docs of the standard library and
--- dependencies locally without needing internet access. Relies on the rustup components rust-src
--- (standard library source), rust-docs (standard library docs and books) and rust-analyzer.
local M = {}

--- Returns the rust-analyzer client for the given buffer.
--- @param bufnr integer? bufnr to get the client for, defaults to current buffer
--- @return vim.lsp.Client?
local function get_client(bufnr)
  local client = vim.lsp.get_clients({ name = 'rust_analyzer', bufnr = bufnr or 0 })[1]
  if not client then
    vim.notify('Rust: rust-analyzer is not attached to the buffer', vim.log.levels.ERROR)
  end
  return client
end

--- Sends an LSP request to rust-analyzer for the current buffer.
--- @param method string LSP method like 'experimental/externalDocs'
--- @param params fun(client: vim.lsp.Client): table creates the request params
--- @param handler fun(result: any, client: vim.lsp.Client) called with a successful result
local function request(method, params, handler)
  local bufnr = vim.api.nvim_get_current_buf()
  local client = get_client(bufnr)
  if not client then
    return
  end

  client:request(method, params(client), function(err, result)
    if err then
      vim.notify('Rust: ' .. method .. ' failed: ' .. err.message, vim.log.levels.ERROR)
      return
    end
    handler(result, client)
  end, bufnr)
end

--- @param client vim.lsp.Client
local function position_params(client)
  return vim.lsp.util.make_position_params(0, client.offset_encoding)
end

--- Returns the root directory of the project the current buffer belongs to. This is the root of the
--- rust-analyzer client so library code like the standard library source or dependencies resolve
--- to the project I navigated from. See lsp/rust_analyzer.lua.
--- @return string?
local function project_root()
  local client = vim.lsp.get_clients({ name = 'rust_analyzer', bufnr = 0 })[1]
  if client and client.root_dir then
    return client.root_dir
  end
  return vim.fs.root(0, 'Cargo.toml')
end

--- Returns the project root or notifies if there is none.
--- @return string?
local function cargo_root()
  local root = project_root()
  if not root then
    vim.notify('Rust: failed to find Cargo.toml', vim.log.levels.ERROR)
  end
  return root
end

--- @type table<string, string>
local sysroots = {}

--- Returns the sysroot of the Rust toolchain used in the current buffer. Respects a
--- rust-toolchain.toml by running rustc in the directory of the buffer.
--- @return string?
function M.sysroot()
  local dir = project_root() or vim.fn.expand('%:p:h')
  if sysroots[dir] then
    return sysroots[dir]
  end

  local result = vim.system({ 'rustc', '--print', 'sysroot' }, { cwd = dir, text = true }):wait()
  if result.code ~= 0 then
    vim.notify(
      "Rust: failed to retrieve sysroot using 'rustc': " .. (result.stderr or ''),
      vim.log.levels.ERROR
    )
    return
  end

  sysroots[dir] = vim.trim(result.stdout)
  return sysroots[dir]
end

--- @type string?
local host

--- Returns the target triple of the host like x86_64-unknown-linux-gnu.
--- @return string?
function M.host()
  if host then
    return host
  end

  local result = vim.system({ 'rustc', '-vV' }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(
      "Rust: failed to retrieve host using 'rustc': " .. (result.stderr or ''),
      vim.log.levels.ERROR
    )
    return
  end

  host = result.stdout:match('host: (%S+)')
  return host
end

--- @class (exact) Metadata The parts of 'cargo metadata' I need.
--- @field target_directory string The Cargo target directory.
--- @field packages table<string, string> Package name to its source directory. Packages present in
--- multiple versions are keyed by name@version.

--- @type table<string, Metadata>
local metadata_cache = {}

--- Returns the Cargo metadata of the package in the current buffer. Does not access the network so
--- dependencies need to be fetched beforehand.
--- @param opts { no_deps: boolean?, silent: boolean? }?
--- @return Metadata?
function M.metadata(opts)
  opts = opts or {}
  local root = project_root()
  if not root then
    if not opts.silent then
      vim.notify('Rust: failed to find Cargo.toml', vim.log.levels.ERROR)
    end
    return
  end

  -- invalidate the cache whenever the dependencies change. The Cargo.lock of a workspace is in the
  -- workspace root.
  local lock_dir = vim.fs.root(root, 'Cargo.lock')
  local lock = lock_dir and vim.uv.fs_stat(lock_dir .. '/Cargo.lock')
  local key = root .. (opts.no_deps and ':no-deps:' or ':') .. (lock and lock.mtime.sec or '')
  if metadata_cache[key] then
    return metadata_cache[key]
  end

  local cmd = { 'cargo', 'metadata', '--offline', '--format-version', '1' }
  if opts.no_deps then
    table.insert(cmd, '--no-deps')
  else
    -- dependencies of other platforms are not fetched by cargo build and would make cargo metadata
    -- fail offline
    local host = M.host()
    if host then
      vim.list_extend(cmd, { '--filter-platform', host })
    end
  end
  local result = vim.system(cmd, { cwd = root, text = true }):wait()
  if result.code ~= 0 then
    if not opts.silent then
      vim.notify(
        "Rust: failed to retrieve metadata using 'cargo metadata', run 'cargo fetch' if "
          .. 'dependencies are missing: '
          .. (result.stderr or ''),
        vim.log.levels.ERROR
      )
    end
    return
  end

  local decoded = vim.json.decode(result.stdout)
  local counts = {}
  for _, package in ipairs(decoded.packages) do
    counts[package.name] = (counts[package.name] or 0) + 1
  end
  local packages = {}
  for _, package in ipairs(decoded.packages) do
    local name = package.name
    if counts[name] > 1 then
      name = name .. '@' .. package.version
    end
    packages[name] = vim.fs.dirname(package.manifest_path)
  end

  metadata_cache[key] = {
    target_directory = decoded.target_directory,
    packages = packages,
  }
  return metadata_cache[key]
end

--- Returns the directory containing the Rust standard library source.
--- @return string?
function M.stdlib_src_dir()
  local sysroot = M.sysroot()
  if not sysroot then
    return
  end

  local dir = sysroot .. '/lib/rustlib/src/rust/library'
  if not vim.uv.fs_stat(dir) then
    vim.notify(
      "Rust: standard library source not found, it's part of the rustup component rust-src",
      vim.log.levels.ERROR
    )
    return
  end
  return dir
end

--- Returns the source directory of given package.
--- @param name string package name as listed by M.packages()
--- @return string?
function M.package_dir(name)
  local metadata = M.metadata()
  if not metadata then
    return
  end

  local dir = metadata.packages[name]
  if not dir then
    vim.notify("Rust: unknown package '" .. name .. "'", vim.log.levels.ERROR)
  end
  return dir
end

--- Returns the names of all packages including dependencies.
--- @return string[]
function M.packages()
  local metadata = M.metadata({ silent = true })
  if not metadata then
    return {}
  end

  local names = vim.tbl_keys(metadata.packages)
  table.sort(names)
  return names
end

--- Returns the directory containing the standard library docs and books.
--- @return string?
local function sysroot_doc_dir()
  local sysroot = M.sysroot()
  if not sysroot then
    return
  end
  return sysroot .. '/share/doc/rust/html'
end

--- Returns the names of directories in dir that contain an index.html.
--- @param dir string?
--- @return string[]
local function doc_dirs(dir)
  local names = {}
  if not dir or not vim.uv.fs_stat(dir) then
    return names
  end

  for name, type in vim.fs.dir(dir) do
    if type == 'directory' and vim.uv.fs_stat(dir .. '/' .. name .. '/index.html') then
      table.insert(names, name)
    end
  end
  return names
end

--- Returns the doc targets that can be passed to M.doc(). These are the standard library crates and
--- books shipped with the toolchain as well as crates documented in the Cargo target directory and
--- all dependencies (which might not have their docs built yet).
--- @return string[]
function M.doc_targets()
  local set = {}
  for _, name in ipairs(doc_dirs(sysroot_doc_dir())) do
    set[name] = true
  end

  local metadata = M.metadata({ silent = true })
  if metadata then
    for _, name in ipairs(doc_dirs(metadata.target_directory .. '/doc')) do
      set[name] = true
    end
    for name, _ in pairs(metadata.packages) do
      -- rustdoc uses the crate name which cannot contain dashes nor versions
      set[(name:gsub('@.*$', ''):gsub('-', '_'))] = true
    end
  end

  local names = vim.tbl_keys(set)
  table.sort(names)
  return names
end

--- Builds the docs of the package in the current buffer and its dependencies using 'cargo doc'. Asks
--- the user for confirmation first.
--- @param on_success fun() called once the docs are built
local function build_docs(on_success)
  local root = cargo_root()
  if not root then
    return
  end

  local choice =
    vim.fn.confirm("Rust: docs not found. Build them using 'cargo doc --offline'?", '&Yes\n&No', 1)
  if choice ~= 1 then
    return
  end

  vim.notify("Rust: running 'cargo doc --offline'", vim.log.levels.INFO)
  vim.system({ 'cargo', 'doc', '--offline' }, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        -- the error is at the end, after the compilation progress
        local lines = vim.split(vim.trim(result.stderr or ''), '\n')
        vim.notify(
          "Rust: 'cargo doc --offline' failed, run 'cargo fetch' if dependencies are missing:\n"
            .. table.concat(vim.list_slice(lines, math.max(1, #lines - 4)), '\n'),
          vim.log.levels.ERROR
        )
        return
      end
      on_success()
    end)
  end)
end

--- Opens given local file in the browser.
--- @param path string absolute path to an HTML file
--- @param query string? query string like '?search=Vec' or fragment like '#method.push'
local function open(path, query)
  local _, err = vim.ui.open(vim.uri_from_fname(path) .. (query or ''))
  if err then
    vim.notify('Rust: failed to open docs: ' .. err, vim.log.levels.ERROR)
  end
end

--- Opens the local docs of the symbol under the cursor. Offers to build the docs of dependencies if
--- they do not exist yet.
function M.doc_under_cursor()
  request('experimental/externalDocs', position_params, function(result)
    -- rust-analyzer returns a string with the web URL if the client lacks the capability localDocs
    if type(result) == 'string' then
      result = { web = result }
    end
    -- the URLs are JSON null (vim.NIL) if rust-analyzer cannot resolve the docs
    local url = result and result['local'] ~= vim.NIL and result['local'] or nil
    if not url then
      local web = result and result.web ~= vim.NIL and result.web or nil
      vim.notify(
        'Rust: no local docs found for symbol under cursor'
          .. (web and (', only web docs at ' .. web) or ''),
        vim.log.levels.INFO
      )
      return
    end

    local uri, fragment = url:match('^([^#]*)(.*)$')
    local path = vim.uri_to_fname(uri)
    if vim.uv.fs_stat(path) then
      open(path, fragment)
      return
    end

    build_docs(function()
      if not vim.uv.fs_stat(path) then
        vim.notify('Rust: docs still missing after build: ' .. path, vim.log.levels.ERROR)
        return
      end
      open(path, fragment)
    end)
  end)
end

--- Opens the local docs of given target. Offers to build the docs of crates if they do not exist
--- yet.
--- @param target string standard library crate like 'std', book like 'book' or 'reference' or crate
--- @param term string? search term like 'Vec'
function M.doc(target, term)
  local query = term and term ~= '' and ('?search=' .. vim.uri_encode(term, 'rfc2396')) or nil

  local doc_dir = sysroot_doc_dir()
  if doc_dir and vim.uv.fs_stat(doc_dir .. '/' .. target .. '/index.html') then
    open(doc_dir .. '/' .. target .. '/index.html', query)
    return
  end

  local metadata = M.metadata({ no_deps = true })
  if not metadata then
    return
  end

  local path = metadata.target_directory .. '/doc/' .. target:gsub('-', '_') .. '/index.html'
  if vim.uv.fs_stat(path) then
    open(path, query)
    return
  end

  build_docs(function()
    if not vim.uv.fs_stat(path) then
      vim.notify("Rust: no docs found for '" .. target .. "'", vim.log.levels.ERROR)
      return
    end
    open(path, query)
  end)
end

--- Expands the macro under the cursor recursively and shows the result in a scratch buffer.
function M.expand_macro()
  request('rust-analyzer/expandMacro', position_params, function(result)
    if not result or result == vim.NIL then
      vim.notify('Rust: no macro under cursor', vim.log.levels.INFO)
      return
    end

    vim.cmd('botright new')
    local bufnr = vim.api.nvim_get_current_buf()
    vim.bo[bufnr].buftype = 'nofile'
    vim.bo[bufnr].bufhidden = 'wipe'
    vim.bo[bufnr].swapfile = false
    local lines = { '// Recursive expansion of ' .. result.name }
    vim.list_extend(lines, vim.split(result.expansion, '\n'))
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].filetype = 'rust'
  end)
end

--- Jumps to given locations. Shows them in the quickfix list if there are multiple.
--- @param locations lsp.Location|lsp.Location[]|lsp.LocationLink[]|nil
--- @param client vim.lsp.Client
--- @param title string
local function jump(locations, client, title)
  if not locations or locations == vim.NIL or vim.tbl_isempty(locations) then
    vim.notify('Rust: no ' .. title .. ' found', vim.log.levels.INFO)
    return
  end

  if not vim.islist(locations) then
    locations = { locations }
  end
  if #locations == 1 then
    vim.lsp.util.show_document(locations[1], client.offset_encoding, { focus = true })
    return
  end

  local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
  vim.fn.setqflist({}, ' ', { title = title, items = items })
  vim.cmd('copen')
end

--- Jumps to the parent module of the current module.
function M.parent_module()
  request('experimental/parentModule', position_params, function(result, client)
    jump(result, client, 'parent module')
  end)
end

--- Opens the Cargo.toml of the package the current buffer belongs to.
function M.open_cargo_toml()
  request('experimental/openCargoToml', function()
    return { textDocument = vim.lsp.util.make_text_document_params(0) }
  end, function(result, client)
    jump(result, client, 'Cargo.toml')
  end)
end

return M
