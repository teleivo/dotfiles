local M = {}

-- Return a new DHIS2 UID as defined by
-- https://github.com/dhis2/dhis2-core/blob/d2d5028d9a935fe5c85f9394d8ca0cd39dc8bdd8/dhis-2/dhis-api/src/main/java/org/hisp/dhis/common/CodeGenerator.java#L64
M.uid = function()
  local digits = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  -- stylua: ignore start
  local alphabet = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
    'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
    's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
    'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
    'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  }
  -- stylua: ignore end
  local alphanumeric = { unpack(alphabet), unpack(digits) }
  local first = alphabet[math.random(1, #alphabet)]
  local uid = first
  for _ = 1, 10, 1 do
    uid = uid .. alphanumeric[math.random(1, #alphanumeric)]
  end
  return uid
end

return M
