---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 20:17
---
---
local AddonName, E = ...


Bohemian_AuctionConfig = {
    timerColors = {
        { 60, {r = 0, g = 0.6, b = 0.1}},
        { 40, {r = 0.9, g = 0.7, b = 0}},
        { 20, {r = 0.75, g = 0.27, b = 0}},
        { 0, {r = 0.8, g = 0.3, b = 0.22}},
    },
    timerMax = 10,
    minItemPrice = 20,
    channel = "RAID",
    bidCooldown = 1,
    minBid = 10,
    startingDKP = 100,
    itemPrices = {},
    startAuctionModifier = "ALT",
    showBidInfoInChat = true,
}
Bohemian_AuctionConfig.addToCurrentAmount = Bohemian_AuctionConfig.addToCurrentAmount or true

Bohemian.RegisterModule(AddonName, E, function()
    E:LoadDefaults()
    E.currentTime = Bohemian_AuctionConfig.timerMax
    E.frames = {}
    E:CreateAuctionFrame()
    E:HookLootFrame()

    E:AddConfigFrames(E.CORE:CreateModuleInterfaceConfig("Auction"))
    if IsAddOnLoaded("AdiBags") then
        E:HookAdiBags()
    end
    if IsAddOnLoaded("XLoot") then
        E:HookXLoot()
    end

end)

E.MODIFIERS = {
    ["ALT"] = IsAltKeyDown,
    ["SHIFT"] = IsShiftKeyDown,
    ["SHIFT+ALT"] = function()
        return IsAltKeyDown() and IsShiftKeyDown()
    end,
}

E.EVENT = {
    START_AUCTION = "START_AUCTION",
    END_AUCTION = "END_AUCTION",
    END_AUCTION_COUNTDOWN = "END_AUCTION_COUNTDOWN",
    END_AUCTION_COUNTDOWN_CANCEL = "END_AUCTION_COUNTDOWN_CANCEL",
    BID = "BID",
    BID_REQUEST = "BID_REQUEST",
    BID_COOLDOWN_END = "BID_COOLDOWN_END",
    INVALIDATE_HIGHEST_BID = "INVALIDATE_HIGHEST_BID",
    AUCTION_JOIN = "AUCTION_JOIN",
    AUCTION_JOIN_RESPONSE = "AUCTION_JOIN_RESPONSE",
    PASS_REQUEST = "PASS_REQUEST",
}

local C = E.CORE

function E:LoadDefaults()
    E.currentItem = nil
    E.bidInfo = {}
    E.rollInfo = {}
    E.bidHistory = {}
    E.passedHistory = {}
    E.conflicts = {}
    E.rollHistory = {}
end

function E:CanStartAuctionWithClick()
    return self.MODIFIERS[Bohemian_AuctionConfig.startAuctionModifier]()
end

function E:StartAuction(itemLink, quantity, itemFrame)
    if CanEditPublicNote() and not self.currentItem then
        local itemId = select(2, strsplit(":", itemLink, 3))
        local itemName = GetItemInfo(itemId)
        local auctionId = math.random()
        C:SendPriorityEvent(E:GetBroadcastChannel(), E.EVENT.START_AUCTION, C:GetPlayerName(true), itemId, quantity, E:GetItemMinPrice(itemName), auctionId, Bohemian_AuctionConfig.minBid)
        SendChatMessage(format("Auction for %s has started. Price: %d DKP.", itemLink, E:GetItemMinPrice(itemName)), E:GetBroadcastChannel())
        if self.lastItemFrame then
            ActionButton_HideOverlayGlow(self.lastItemFrame);
        end
        ActionButton_ShowOverlayGlow(itemFrame)
        self.lastItemFrame = itemFrame
        self.frames.auction.lootMasterFrame:Show()
        self:UpdateBidderTable()
        self.currentItemWinner = {}
        self:UpdateWinner()
        self.passedHistory = {}
    end
end

function E:LoadAuctionData(_, quantity, price, itemName, itemRarity, itemTexture)
    local color = ITEM_QUALITY_COLORS[itemRarity];
    local buttonName = "AuctionFrameItem"
    local text = _G[buttonName.."Text"]
    local buttonTexture = _G[buttonName.."IconTexture"]
    local count = _G[buttonName.."Count"]
    local priceValue = _G["AuctionItemPriceValue"]
    self:RefreshTotalDKP()
    priceValue:SetText(price)
    buttonTexture:SetTexture(itemTexture)
    count:SetText(quantity)
    if tonumber(quantity) > 1 then
        count:Show()
    else
        count:Hide()
    end
    local bidValue = _G["BidValue"]
    bidValue:SetText(not Bohemian_AuctionConfig.addToCurrentAmount and price or "0")
    text:SetVertexColor(color.r, color.g, color.b)
    text:SetText(itemName)
    self.currentTime = Bohemian_AuctionConfig.timerMax
    self.passed = false
    self:SetHighestBidder(nil)
    self.bidInfo = {}
    self.rollInfo = {}
    self.frames.auction:Show()
    if self:IsPlayerAuctionOwner() then
        AuctionDKPClose:Hide()
    else
        AuctionDKPClose:Show()
    end
    self.currentItem.price = tonumber(price)
    self:UpdatePassButtonState()
    self:UpdateBidButtonState()
end

function E:GetCurrentDKP(fullName)
    return C:GetModule("Bohemian_DKP"):GetCurrentDKP(fullName)
end


function E:GetBroadcastChannel()
    if IsInRaid() then
        return "RAID"
    end
    if IsInGroup() then
        return "PARTY"
    end
    return "GUILD"
end

function E:Bid(amount)
    if self.passed or not self.currentItem then
        return
    end
    if not Bohemian_AuctionConfig.addToCurrentAmount then
        amount = amount == 0 and amount or amount - (self.bidInfo.value or self.currentItem.price)
    end
    if not self.isBiddingEnabled or amount == nil or (self.bidInfo.name and (not amount or amount == 0)) then
        return
    end
    if amount > 0 and amount < self.currentItem.minBid then
        return
    end
    C:SendPriorityEvent(self:GetBroadcastChannel(), self.EVENT.BID_REQUEST, amount,  self.currentItem.auctionId, 0)
    E:Debug("Bidding", amount)
    self:EnableBidding(false)
end

function E:Pass()
    if self.passed or not self.currentItem then
        return
    end
    self.passed = true
    C:SendPriorityEvent(self:GetBroadcastChannel(), self.EVENT.PASS_REQUEST, self.currentItem.auctionId)
    E:Debug("Passing")
    self:EnableBidding(false)
    self.frames.auction.pass:Disable()
end

function E:EndAuction(force)
    if not self.currentItem or not self.currentItem.auctionId then
        self:Debug("Ignoring event. Auction has ended...")
        return
    end
    if not force and IsShiftKeyDown() then
        self.countdownActive = true
        self.frames.auction.lootMasterFrame.award:Disable()
        C:SendPriorityEvent(E:GetBroadcastChannel(), self.EVENT.END_AUCTION_COUNTDOWN, self.currentItem.auctionId, Bohemian_AuctionConfig.timerMax)
        return
    end
    local _, itemLink = GetItemInfo(self.currentItem.id)
    if not self.currentItemWinner then
        SendChatMessage(format("Auction was cancelled."), self:GetBroadcastChannel())
    else
        local currentDKP = self:GetCurrentDKP(self.currentItemWinner.name)
        local index = C.rosterIndex[self.currentItemWinner.name]
        if E.isRollMode then
             C:GetModule("Bohemian_DKP"):SaveDKP(index, currentDKP, nil, "roll "..self.currentItemWinner.roll.." "..itemLink)
            SendChatMessage(format("%s rolled %d and won %s.", strsplit("-", self.currentItemWinner.name), self.currentItemWinner.roll, itemLink), "GUILD")
        else
            C:GetModule("Bohemian_DKP"):SaveDKP(index, currentDKP - self.currentItemWinner.bid, nil, itemLink)
            SendChatMessage(format("%s awarded to %s for %d DKP.", itemLink, strsplit("-", self.currentItemWinner.name), self.currentItemWinner.bid), "GUILD")
        end

    end


    local winner = self.currentItemWinner or {}
    C:SendPriorityEvent(
            self:GetBroadcastChannel(),
            self.EVENT.END_AUCTION,
            self.currentItem.auctionId,
            winner.name, winner.bid
    )
    ActionButton_HideOverlayGlow(self.lastItemFrame);
    self.currentItemWinner = {}
end

function E:CancelAuctionCountdown()
    self:SendPriorityEvent(self:GetBroadcastChannel(), self.EVENT.END_AUCTION_COUNTDOWN_CANCEL, self.currentItem.auctionId)
    self.countdownActive = false
    self:UpdateWinner()
end

function E:GetItemMinPrice(itemName)
    return Bohemian_AuctionConfig.itemPrices[itemName] or Bohemian_AuctionConfig.minItemPrice
end

function E:IsPlayerAuctionOwner()
    return E.currentItem.owner == C:GetPlayerName(true)
end

function E:ValidateBidderDKP()
    local updateHighestBidder = false
    for k, v in pairs(self.bidHistory) do
        if v > self:GetCurrentDKP(k) then
            self.bidHistory[k] = nil
            if self.bidInfo.name == k then
                updateHighestBidder = true
            end
        end
    end
    self:UpdateBidderTable()
    self:UpdateWinner()
    if updateHighestBidder then
        local winner = self.currentItemWinner or {}
        C:SendPriorityEvent(self:GetBroadcastChannel(), self.EVENT.INVALIDATE_HIGHEST_BID, self.currentItem.auctionId, winner.name,  winner.bid)
    end
end

function E:ChatBid(msg, sender)
    local number = tonumber(msg)
    if self.currentItem and number then
        number = number - self.currentItem.price
        if number < 0 then
            return
        end
        E.EVENTS:BID_REQUEST(number, self.currentItem.auctionId, 1, sender)
    elseif msg == "pass" then
        self:Pass()
    end
end

function E:JoinExistingAuction()
    C:SendPriorityEvent(E:GetBroadcastChannel(), self.EVENT.AUCTION_JOIN)
end

function E:ProcessRoll(message)
    local _,_,name, roll, low, high = string.find(message, "(%a+) rolls (%d+) %((%d+)%-(%d+)%)$")

    if name then
        return name, tonumber(roll), tonumber(low), tonumber(high)
    end
end
