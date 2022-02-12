
local MAJOR, MINOR = "md5", 1

local checksum
if LibStub then
  checksum = LibStub:NewLibrary(MAJOR, MINOR)
  if not checksum then return end -- This version is already loaded.
else
  checksum = {}
end

return checksum
