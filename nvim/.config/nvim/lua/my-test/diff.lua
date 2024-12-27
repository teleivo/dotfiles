local output = [[
[ERROR] org.hisp.dhis.webapi.controller.tracker.export.event.EventsExportControllerTest.getEventByPathIsIdenticalToQueryParam -- Tim
e elapsed: 1.170 s <<< FAILURE!
org.opentest4j.AssertionFailedError: the event JSON must be identical ==> expected: <{"event":"ggU5IQu70Ey","dataValues":[]}> but wa
s: <{"event":"ggU5IQu70Ey","status":"ACTIVE","program":"prabcdefghA","programStage":"pgabcdefghA","enrollment":"WscFt9uc3tV","tracke
dEntity":"SoU8J5EjCdO","orgUnit":"ouabcdefghA","relationships":[{"relationship":"r8vm2PpoOFd","relationshipName":"RelationshipType_G
3d4YwQrsbn","relationshipType":"G3d4YwQrsbn","createdAt":"2024-12-27T12:17:55.747","updatedAt":"2024-12-27T12:17:55.747","bidirectio
nal":false,"from":{"event":{"event":"ggU5IQu70Ey","status":"ACTIVE","program":"prabcdefghA","programStage":"pgabcdefghA","enrollment
":"WscFt9uc3tV","orgUnit":"ouabcdefghA","followUp":false,"deleted":false,"createdAt":"2024-12-27T12:17:55.742","createdAtClient":"20
24-12-27T12:17:55.742","updatedAt":"2024-12-27T12:17:55.744","updatedAtClient":"2024-12-27T12:17:55.744","attributeOptionCombo":"Hll
vX50cXC0","attributeCategoryOptions":"xYerKDKCefk","dataValues":[],"notes":[{"note":"oqXG28h988k","storedAt":"2024-12-27T12:17:55.74
3","value":"my notes","createdBy":{"uid":"M5zQapPyTZI","username":"admin","firstName":"FirstNameadmin","surname":"Surnameadmin","dis
playName":"FirstNameadmin Surnameadmin"},"storedBy":"userabcdefowner"}],"followup":false}},"to":{"trackedEntity":{"trackedEntity":"S
oU8J5EjCdO","trackedEntityType":"kXvPNMyFdqL","createdAt":"2024-12-27T12:17:55.739","createdAtClient":"2024-12-27T12:17:55.739","upd
atedAt":"2024-12-27T12:17:55.739","updatedAtClient":"2024-12-27T12:17:55.739","orgUnit":"ouabcdefghA","inactive":false,"deleted":fal
se,"potentialDuplicate":false,"attributes":[],"enrollments":[],"programOwners":[]}}}],"followUp":false,"deleted":false,"createdAt":"
2024-12-27T12:17:55.742","createdAtClient":"2024-12-27T12:17:55.742","updatedAt":"2024-12-27T12:17:55.744","updatedAtClient":"2024-1
2-27T12:17:55.744","attributeOptionCombo":"HllvX50cXC0","attributeCategoryOptions":"xYerKDKCefk","dataValues":[],"notes":[{"note":"o
qXG28h988k","storedAt":"2024-12-27T12:17:55.743","value":"my notes","createdBy":{"uid":"M5zQapPyTZI","username":"admin","firstName":
"FirstNameadmin","surname":"Surnameadmin","displayName":"FirstNameadmin Surnameadmin"},"storedBy":"userabcdefowner"}],"followup":fal
se}>]]
local assertion_line = [[
org.opentest4j.AssertionFailedError: the event JSON must be identical ==> expected: <{"event":"ggU5IQu70Ey","dataValues":[]}> but wa
s: <{"event":"ggU5IQu70Ey","status":"ACTIVE","program":"prabcdefghA","programStage":"pgabcdefghA","enrollment":"WscFt9uc3tV","tracke
dEntity":"SoU8J5EjCdO","orgUnit":"ouabcdefghA","relationships":[{"relationship":"r8vm2PpoOFd","relationshipName":"RelationshipType_G
3d4YwQrsbn","relationshipType":"G3d4YwQrsbn","createdAt":"2024-12-27T12:17:55.747","updatedAt":"2024-12-27T12:17:55.747","bidirectio
nal":false,"from":{"event":{"event":"ggU5IQu70Ey","status":"ACTIVE","program":"prabcdefghA","programStage":"pgabcdefghA","enrollment
":"WscFt9uc3tV","orgUnit":"ouabcdefghA","followUp":false,"deleted":false,"createdAt":"2024-12-27T12:17:55.742","createdAtClient":"20
24-12-27T12:17:55.742","updatedAt":"2024-12-27T12:17:55.744","updatedAtClient":"2024-12-27T12:17:55.744","attributeOptionCombo":"Hll
vX50cXC0","attributeCategoryOptions":"xYerKDKCefk","dataValues":[],"notes":[{"note":"oqXG28h988k","storedAt":"2024-12-27T12:17:55.74
3","value":"my notes","createdBy":{"uid":"M5zQapPyTZI","username":"admin","firstName":"FirstNameadmin","surname":"Surnameadmin","dis
playName":"FirstNameadmin Surnameadmin"},"storedBy":"userabcdefowner"}],"followup":false}},"to":{"trackedEntity":{"trackedEntity":"S
oU8J5EjCdO","trackedEntityType":"kXvPNMyFdqL","createdAt":"2024-12-27T12:17:55.739","createdAtClient":"2024-12-27T12:17:55.739","upd
atedAt":"2024-12-27T12:17:55.739","updatedAtClient":"2024-12-27T12:17:55.739","orgUnit":"ouabcdefghA","inactive":false,"deleted":fal
se,"potentialDuplicate":false,"attributes":[],"enrollments":[],"programOwners":[]}}}],"followUp":false,"deleted":false,"createdAt":"
2024-12-27T12:17:55.742","createdAtClient":"2024-12-27T12:17:55.742","updatedAt":"2024-12-27T12:17:55.744","updatedAtClient":"2024-1
2-27T12:17:55.744","attributeOptionCombo":"HllvX50cXC0","attributeCategoryOptions":"xYerKDKCefk","dataValues":[],"notes":[{"note":"o
qXG28h988k","storedAt":"2024-12-27T12:17:55.743","value":"my notes","createdBy":{"uid":"M5zQapPyTZI","username":"admin","firstName":
"FirstNameadmin","surname":"Surnameadmin","displayName":"FirstNameadmin Surnameadmin"},"storedBy":"userabcdefowner"}],"followup":fal
se}>]]

assertion_line = assertion_line:gsub('\n', '')
local expected_string = assertion_line:match('expected: <(.-)>')
local actual_string = assertion_line:match('but was: <(.-)>')

local function create_tab()
  vim.cmd('tabnew')
  local tabnr = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_tabpage_set_var(tabnr, 'tabname', 'test-diff')

  -- Opening a new tab without a file will create an empty buffer that I do not want. I don't know
  -- of a way to disable that behavior. So for now track its handle and delete it after opening
  -- other buffers. If I would delete it right away I would close the tab.
  local empty_buf = vim.api.nvim_win_get_buf(0)

  local right_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(right_buf)

  vim.cmd('vsplit')

  local left_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(left_buf)

  vim.api.nvim_buf_delete(empty_buf, { force = true })

  return {
    tabnr = tabnr,
    bufs = {
      left = left_buf,
      right = right_buf,
    },
  }
end

local function is_json(str)
  local ok, result = pcall(vim.fn.json_decode, str)
  return ok and result ~= nil
end

local function format_json(str)
  local result = vim.system({ 'jq' }, { text = true, stdin = str }):wait()
  return result.stdout
end

if is_json(expected_string) and is_json(actual_string) then
  local formatted_expected = format_json(expected_string)
  local formatted_actual = format_json(actual_string)
  local tab = create_tab()

  vim.api.nvim_buf_set_lines(tab.bufs.left, 0, -1, false, vim.split(formatted_expected, '\n'))
  vim.bo[tab.bufs.left].filetype = 'json'
  vim.api.nvim_buf_set_name(tab.bufs.left, 'expected')

  vim.api.nvim_buf_set_lines(tab.bufs.right, 0, -1, false, vim.split(formatted_actual, '\n'))
  vim.bo[tab.bufs.right].filetype = 'json'
  vim.api.nvim_buf_set_name(tab.bufs.right, 'actual')

  vim.cmd('windo diffthis')

  Print(tab)
  for _, buf in pairs(tab.bufs) do
    vim.keymap.set('n', 'q', function()
      vim.cmd('tabclose')
      for _, buf_inner in pairs(tab.bufs) do
        vim.api.nvim_buf_delete(buf_inner, { force = true })
      end
    end, { buffer = buf })
  end
end

-- TODO integrate that into the test plugin for java
-- TODO how to extract the AssertionFailedError lines? I could add a mapping to go to the
-- AssertionFailedError. How to then extract all lines as they are unfortunately split by newlines
-- parse the expected/actual and feed them into this code
-- TODO reuse the diff tab?
-- TODO get a sample of assertEquals of a lombok class with equals implementation
