---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 17:28
---
local _, E = ...

E.FRAMES = {}
E.MODULES = {}
E.EVENTS = {}
E.REQUIRED_ADDONS = {}
E.DETAIL_FRAME_HEIGHTS = 0
E.MODULE_QUEUE = {}

E.updateQueue = {}

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(_, elapsed)
    for _, item in pairs(E.updateQueue) do
        item(elapsed)
    end
end)

function E:Load()
    BohemianConfig.debug = BohemianConfig.debug == nil and false or BohemianConfig.debug
    BohemianConfig.cpsLimit = BohemianConfig.cpsLimit or 2000
    BohemianConfig.requiredModules = BohemianConfig.requiredModules or {}
    BohemianConfig.versions = BohemianConfig.versions or {}

    E.onlineSince = GetServerTime()
    E.FRIENDS_FRAME_DEFAULT_WIDTH = FriendsFrame:GetWidth()
    E:FixGuildOfflineState()
    E:AdjustGuildInfo()
    E:UpdateLFGFrame()
    E:AddGuildColumnsToExistingHeaders()
    E:AdjustGuildFrameControlButtons()
    E:AddVersionColumn()
    E:CreateInterfaceConfig()
    C_Timer.After(20, function()
        E.stopIgnoringOffline = true
    end)
    E:CacheRaid()
end

function E:AddToUpdateQueue(cb)
    local id = E:uuid()
    E:Debug("Added new task to update queue", id)
    E.updateQueue[id] = function(elapsed)
        cb(id, elapsed)
    end
    return id
end

function E:RemoveFromUpdateQueue(id)
    E.updateQueue[id] = nil
    E:Debug("Removed", id, "from update queue")
end

function E:FixGuildOfflineState()
    SetGuildRosterShowOffline(BohemianConfig.showOffline)
    GuildFrameLFGButton:SetChecked(BohemianConfig.showOffline)
end

function E:RepeatAfter(duration, cb)
    cb()
    C_Timer.After(duration, function () BohemkaDKP:RepeatAfter(duration, cb) end)
end

function E:RegisterAddon(addonName)
    self.REQUIRED_ADDONS[addonName] = {
        loaded = false
    }
end

function E:RegisterModule(moduleName, module, onLoad)
    module.CORE = self
    module.EVENTS = {}
    module.NAME = moduleName
    module.Print = function(self, ...)
        self.CORE:debugMessage(self.NAME, ...)
    end
    module.Debug = function(self, ...)
        if not BohemianConfig.debug then
            return
        end
        self.CORE:debugMessage(self.NAME, ...)
    end
    self.MODULES[moduleName] = { ["module"] = module, OnLoad = onLoad }
    self:Debug("Registered module", moduleName)
end

function E:RegisterEvent(event)
    self.EventFrame:RegisterEvent(event)
    self:Debug("Registered event", event)
end


function E:UnregisterEvent(event)
    self.EventFrame:UnregisterEvent(event)
    self:Debug("Unregistered event", event)
end


function E:ExecuteEvent(frame, event, ...)
    if frame.EVENTS[event] then
        frame.EVENTS[event](frame, ...)
    end
end

function E:QueueEvent(...)
    E.QUEUE[#E.QUEUE + 1] = {...}
end

function E:QueueModuleEvent(module, ...)
    if not E.MODULE_QUEUE[module.NAME] then
        E.MODULE_QUEUE[module.NAME] = {}
    end
    E.MODULE_QUEUE[module.NAME][#E.MODULE_QUEUE[module.NAME] + 1] = {...}
end

function E:ProcessModuleQueue(module)
    if not E.MODULE_QUEUE[module.NAME] then
        return
    end
    local i = #E.MODULE_QUEUE[module.NAME]
    while #E.MODULE_QUEUE[module.NAME] > 0 do
        local event = table.remove(E.MODULE_QUEUE[module.NAME], i)
        E:ExecuteEvent(module, unpack(event))
        i = i - 1
    end
end

function E:OnEvent(event, ...)
    local args = { ... }
    self:ExecuteEvent(self, event, ...)
    self:CallModules(function(module)
        if module.isLoaded then
            self:ExecuteEvent(module, event, unpack(args))
        else
            E:QueueModuleEvent(module, event, unpack(args))
        end
    end)
end

function E:CallModules(cb)
    for _, m in pairs(self.MODULES) do
        cb(m.module)
    end
end

function E:LoadModules()
    for _, name in pairs(self.AVAILABLE_MODULES) do
        self:Debug("Loading module", name)
        local module = self.MODULES[name]
        if module then
            if module.OnLoad then
                module.OnLoad(module.module)
            end
            module.module.isLoaded = true
            E:OnEvent("MODULE_LOADED", module.module)
            E:ProcessModuleQueue(module.module)
            E:GuildStatus_UpdateHook()
        end
    end
    E:OnEvent("MODULES_LOADED")
end

function E:GetModule(name)
    if self.MODULES[name] then
        return self.MODULES[name].module
    end
end

function E:LoadDataWhenReady()
    if GetNumGuildMembers() == 0 then
        C_Timer.After(1, function ()
            E:LoadDataWhenReady()
        end)
    else
        E:CacheGuildRoster()
        E.firstLoad = true
        E.EventFrame:SetScript('OnEvent', function(_, ...)
            E:OnEvent(...)
        end)
        E:OnEvent(E.EVENT.READY)
        E:GuildStatus_UpdateHook()
    end
end

function E:ProcessQueue()
    local i = #E.QUEUE
    while #E.QUEUE > 0 do
        E:OnEvent(unpack(table.remove(E.QUEUE, i)))
        i = i - 1
    end
    E:Debug("Queue processed")
end

function E:CreateFrame(type, ...)
    local frame = CreateFrame(type, ...)
    local frameName = frame:GetName()
    type = string.lower(type)
    if not E.FRAMES[type] then
        E.FRAMES[type] = {}
    end
    E.FRAMES[type][frameName] = frame
    E:OnEvent("FRAME_CREATED", frameName, type)
    return frame
end

function E:SendRequiredModules(sender)
    local data = {}
    for name, required in pairs(BohemianConfig.requiredModules) do
        if required then
            data[#data + 1] = name
        end
    end
    if #data > 0 then
        data = table.concat(data, ",")
        local lastUpdate = BohemianConfig.requiredModulesLastUpdate or GetServerTime()
        if sender then
            E:SendPriorityEventTo(sender, "REQUIRED_MODULES", data, lastUpdate)
        else
            E:SendPriorityEvent("GUILD", "REQUIRED_MODULES", data, lastUpdate)
        end

    end
end

function E:SaveOptions()
    for _, name in pairs(self.AVAILABLE_MODULES) do
        self:Debug("Saving options for module", name)
        local module = self.MODULES[name]
        if module and 
    	   (name == "Auction" or
    	    name == "DKP" or
    	    name == "Log" or
    	    name == "Raid") then
            BohemkaDKPInterfaceOptionsPanel[name.."_okay"]()
        end
    end
end

function E:CancelOptions()
    for _, name in pairs(self.AVAILABLE_MODULES) do
        self:Debug("Cancelling options for module", name)
        local module = self.MODULES[name]
        if module and 
    	   (name == "Auction" or
    	    name == "DKP" or
    	    name == "Log" or
    	    name == "Raid") then
            BohemkaDKPInterfaceOptionsPanel[name.."_cancel"]()
        end
    end
end

function E:Init()
    if E.disabled or E.initialized then
        return
    end
    E.initialized = true
    E:LoadModules()
    E:InitialSync()
end
