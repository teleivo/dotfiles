---Returns the Go module path as passed to go mod init https://go.dev/ref/mod#go-mod-init.
---@return string go module path
local function module_path()
	local result = vim.system({ "go", "list", "-m" }):wait()
	if result.code ~= 0 then
		error("failed to retrieve Go module path using 'go list': " .. (result.stderr or ""))
	end

	return result.stdout:match("[^\r\n]+")
end

local module = module_path()

-- TODO add docs for the package format and use it in return
local function list_packages()
	local result = vim.system({ "go", "list", "-f", "'{{.ImportPath}} {{.Standard}}'", "all" }):wait()
	if result.code ~= 0 then
		error("failed to retrieve Go import paths: " .. (result.stderr or ""))
	end

	local packages = {}
	for line in result.stdout:gmatch("[^\r\n]+") do
		local import_path, is_stdlib = line:match("^'([^']+)%s([^']+)'$")
		is_stdlib = (is_stdlib == "true")
		local is_own = import_path:match("^" .. module) ~= nil
		-- TODO add flag for is_internal
		-- TODO filter is_internal and not is_own
		-- TODO sort? only if that makes the completion experience better
		table.insert(packages, { import_path = import_path, is_stdlib = is_stdlib, is_own = is_own })
	end
	return packages
end

Print(list_packages())
