local _, E = ...




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

function E:GetLatestVersion()
    local tmp = {}
    for player, version in pairs(BohemianConfig.versions) do
        tmp[#tmp + 1] = {player = player, version = self:GetAddonVersionNum(version), versionTxt = version }
    end
    table.sort(tmp, function(a,b) return a.version > b.version end)
    return #tmp > 0 and tmp[1].versionTxt or self:GetAddonVersion()
end

function E:VersionCheck()
    local latest = E:GetLatestVersion()
    local myVersion = self:GetAddonVersionNum(self:GetAddonVersion())
    if myVersion < self:GetAddonVersionNum(latest) and self:CanAnnounceNewVersion() then
        self:Print(self:colorize(self.STRING.OUT_OF_DATE, self.COLOR.WHITE)..self:colorize(self:GetAddonVersion(), self.COLOR.RED).." -> ".. self:colorize(latest, self.COLOR.GREEN))
        self.lastVersionAnnounce = GetServerTime()
    end
end

function E:GetPlayersVersion()
    local latest = E:GetLatestVersion()
    local latestNum = self:GetAddonVersionNum(latest)
    local data = {
        current = {},
        old = {},
        missing = {},
    }
    for player, data in pairs(E.guildRoster) do
        local version = BohemianConfig.versions[player]
        if not version then
            data.missing = player
        elseif self:GetAddonVersionNum(version) < latestNum then
            data.old = player
        else
            data.current = player
        end
    end
    return data
end
