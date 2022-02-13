local _, E = ...

E.versions = {}


function E:GetAddonVersion()
    return GetAddOnMetadata(self.NAME, "Version")
end

function E:ShareVersionInfo()
    local version = self:GetAddonVersion()
    self:SendEvent("GUILD", self.EVENT.VERSION_INFO, version)
end

function E:ShareVersionInfoTo(playerName)
    local version = self:GetAddonVersion()
    self:SendEventTo(playerName, self.EVENT.VERSION_INFO, version)
end

function E:RequestVersionInfo()
    self:SendEvent("GUILD", self.EVENT.VERSION_INFO_REQUEST)
end

function E:RequestVersionInfoFrom(name)
    self:SendEventTo(name, self.EVENT.VERSION_INFO_REQUEST)
end



function E:GetAddonVersionNum(versionStr)
    local major, minor, patch = string.match(versionStr, "(%d+)%.(%d+)%.(%d+)")
    return tonumber(string.format("%02d", major)..string.format("%02d", minor)..string.format("%02d", patch))
end
function E:CanAnnounceNewVersion()
    return GetServerTime() - (self.lastVersionAnnounce or 0 ) > 1800
end
function E:VersionCheck()
    local tmp = {}
    for player, version in pairs(self.versions) do
        tmp[#tmp + 1] = {player = player, version = self:GetAddonVersionNum(version), versionTxt = version }
    end
    table.sort(tmp, function(a,b) return a.version > b.version end)
    if #tmp > 0 then
        local myVersion = self:GetAddonVersionNum(self:GetAddonVersion())
        if myVersion < tmp[1].version and self:CanAnnounceNewVersion() then
            self:Print(self:colorize(self.STRING.OUT_OF_DATE, self.COLOR.WHITE)..self:colorize(self:GetAddonVersion(), self.COLOR.RED).." -> ".. self:colorize(tmp[1].versionTxt, self.COLOR.GREEN))
            self.lastVersionAnnounce = GetServerTime()
        end
    end
end
