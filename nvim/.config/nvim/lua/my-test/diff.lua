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

local function create_floating_windows(expected, actual, filetype)
  local width = math.ceil(vim.o.columns * 0.3)
  local height = math.ceil(vim.o.lines * 0.8)
  local row = math.ceil((vim.o.lines - height) / 2)
  local col_left = math.ceil((vim.o.columns - 3 * width) / 4)
  local col_middle = col_left * 2 + width
  local col_right = col_left * 3 + 2 * width

  local left_buf = vim.api.nvim_create_buf(true, true)
  local left_win = vim.api.nvim_open_win(left_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col_left,
    style = 'minimal',
    border = 'rounded',
  })

  local right_buf = vim.api.nvim_create_buf(true, true)
  local right_win = vim.api.nvim_open_win(right_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col_right,
    style = 'minimal',
    border = 'rounded',
  })

  local diff_buf = vim.api.nvim_create_buf(true, true)
  local diff_win = vim.api.nvim_open_win(diff_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col_middle,
    style = 'minimal',
    border = 'rounded',
  })

  vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, vim.split(expected, '\n'))
  vim.bo[left_buf].filetype = filetype
  vim.api.nvim_buf_set_name(left_buf, 'expected')

  vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, vim.split(actual, '\n'))
  vim.bo[right_buf].filetype = filetype
  vim.api.nvim_buf_set_name(right_buf, 'actual')

  local diff_output = vim.diff(actual, expected)
  vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, vim.split(diff_output, '\n'))
  vim.bo[diff_buf].filetype = 'diff'
  vim.api.nvim_buf_set_name(diff_buf, 'diff')

  local wins = {
    { win = left_win, buf = left_buf },
    { win = diff_win, buf = diff_buf },
    { win = right_win, buf = right_buf },
  }

  -- close all floating windows with 'q'
  for _, win in ipairs(wins) do
    vim.keymap.set('n', 'q', function()
      for _, window in ipairs(wins) do
        pcall(vim.api.nvim_win_close, window.win, true)
      end
    end, { buffer = win.buf })
  end
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
  create_floating_windows(formatted_expected, formatted_actual, 'json')
end

-- TODO integrate that into the test plugin for java
-- TODO how to extract the AssertionFailedError lines? I could add a mapping to go to the
-- AssertionFailedError. How to then extract all lines as they are unfortunately split by newlines
-- parse the expected/actual and feed them into this code
-- TODO get a sample of assertEquals of a lombok class with equals implementation
