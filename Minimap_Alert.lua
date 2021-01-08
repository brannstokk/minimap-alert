minimapAlert = {}
local addonVersion = 6
local foundNode = false
local minimapSettings = {}
local timeElapsed = 0
local framesElapsed = 0
local mX, mY = -1, -1
local minimapAlertState = 'DISABLED'
local stateList = {}
local extraDelay = 0
local oldZoom = 0

local function switchState(newState)
    if stateList[newState] then
        minimapAlertState = newState
        stateList[newState]()
    end
end

local guiFrame = CreateFrame('Frame', "MinimapAlert_Interface", UIParent)
guiFrame:SetSize(148, 66)
guiFrame:SetBackdrop({
      bgFile = 'Interface/FrameGeneral/UI-Background-Rock',
      edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
      tile = true, tileSize = 192, edgeSize = 16,
      insets = {left = 4, right = 4, top = 4, bottom = 4}})
guiFrame:ClearAllPoints()
guiFrame:SetPoint('LEFT', 52, 0)
guiFrame:EnableMouse(true)
guiFrame:SetMovable(true)
guiFrame:SetScript('OnMouseDown', function(self)
    self:StartMoving()
end)

guiFrame:SetScript('OnMouseUp', function(self)
    self:StopMovingOrSizing()
end)

guiFrame.glow = guiFrame:CreateTexture(nil, 'OVERLAY')
--guiFrame.glow:SetColorTexture(0.2, 0.8, 0.2, 0.8)
guiFrame.glow:SetTexture('Interface/FrameGeneral/UI-Background-Rock')
--guiFrame.glow:SetVertexColor(0.2, 1, 0.2)
guiFrame.glow:SetBlendMode('ADD')
guiFrame.glow:SetPoint('TOPLEFT', 6, -6)
guiFrame.glow:SetPoint('BOTTOMRIGHT', -6, 6)
guiFrame.glow:SetAlpha(0)

guiFrame.glowAnimation = guiFrame.glow:CreateAnimationGroup()
guiFrame.glowAnimation[1] = guiFrame.glowAnimation:CreateAnimation("Alpha")
guiFrame.glowAnimation[1]:SetDuration(0.25)
guiFrame.glowAnimation[1]:SetFromAlpha(1)
guiFrame.glowAnimation[1]:SetToAlpha(0)
--[[
guiFrame.glowAnimation[2] = guiFrame.glowAnimation:CreateAnimation("Alpha")
guiFrame.glowAnimation[2]:SetDuration(0.25)
guiFrame.glowAnimation[2]:SetFromAlpha(1)
guiFrame.glowAnimation[2]:SetToAlpha(0)
guiFrame.glowAnimation[2]:SetStartDelay(0.25)
--]]
local optionsButton = CreateFrame('Button', nil, guiFrame, 'GameMenuButtonTemplate')
optionsButton:SetSize(64, 24)
optionsButton:ClearAllPoints()
optionsButton:SetPoint('BOTTOMRIGHT', -8, 8)
optionsButton:SetText('Config')
optionsButton:SetScript('OnClick', function()
    InterfaceOptionsFrame_OpenToCategory("Minimap Alert")
    InterfaceOptionsFrame_OpenToCategory("Minimap Alert")
end)

local startButton = CreateFrame('Button', nil, guiFrame, 'GameMenuButtonTemplate')
startButton:SetSize(64, 24)
startButton:ClearAllPoints()
startButton:SetPoint('BOTTOMLEFT', 8, 8)
startButton:SetText('Start')

local spinner = CreateFrame('Frame', nil, guiFrame, "LoadingSpinnerTemplate")
spinner:ClearAllPoints()
spinner:SetPoint('TOPLEFT', 2, 2)
spinner:SetScale(0.9, 0.9)
spinner.AnimFrame.Circle:SetVertexColor(0.3, 0.3, 0.3)

local statusText = guiFrame:CreateFontString()
statusText:SetFontObject("GameFontNormal")
statusText:SetText('Inactive')
statusText:ClearAllPoints()
statusText:SetPoint('LEFT', spinner, 'RIGHT', -4, 0)

local lootText = guiFrame:CreateFontString()
lootText:SetFontObject("GameFontNormalSmall")
lootText:SetText('Waiting for loot')
lootText:SetTextColor(1, 1, 1)
lootText:SetPoint('TOPLEFT', statusText, 'BOTTOMLEFT', 0, 0)
lootText.oldShow = lootText.Show
lootText.Show = function(self)
    statusText:ClearAllPoints()
    statusText:SetPoint('LEFT', spinner, 'RIGHT', -4, 5)
    self:oldShow()
end

lootText.oldHide = lootText.Hide
lootText.Hide = function(self)
    statusText:ClearAllPoints()
    statusText:SetPoint('LEFT', spinner, 'RIGHT', -4, 0)
    self:oldHide()
end
lootText:Hide()


local tabFrame = CreateFrame('Frame', nil, guiFrame)
tabFrame:SetSize(140, 16)
tabFrame:SetPoint('TOP', 0, 12)
tabFrame:SetFrameLevel(guiFrame:GetFrameLevel()-1)
tabFrame:EnableMouse(true)
tabFrame:SetScript('OnMouseDown', function()
    guiFrame:StartMoving()
end)

tabFrame:SetScript('OnMouseUp', function()
    guiFrame:StopMovingOrSizing()
end)

tabFrame.l = tabFrame:CreateTexture(nil, 'BACKGROUND')
tabFrame.l:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
tabFrame.l:SetSize(8, 1)
tabFrame.l:ClearAllPoints()
tabFrame.l:SetPoint('LEFT')
tabFrame.l:SetPoint('TOP')
tabFrame.l:SetPoint('BOTTOM')
tabFrame.l:SetTexCoord(0.03125, 0.140625, 0.28125, 1.0)

tabFrame.m = tabFrame:CreateTexture(nil, 'BACKGROUND')
tabFrame.m:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
tabFrame.m:SetSize(124, 1)
tabFrame.m:ClearAllPoints()
tabFrame.m:SetPoint('LEFT', tabFrame.l, 'RIGHT')
tabFrame.m:SetPoint('TOP')
tabFrame.m:SetPoint('BOTTOM')
tabFrame.m:SetTexCoord(0.140625, 0.859375, 0.28125, 1.0)

tabFrame.r = tabFrame:CreateTexture(nil, 'BACKGROUND')
tabFrame.r:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
tabFrame.r:SetSize(8, 1)
tabFrame.r:ClearAllPoints()
tabFrame.r:SetPoint('LEFT', tabFrame.m, 'RIGHT')
tabFrame.r:SetPoint('TOP')
tabFrame.r:SetPoint('BOTTOM')
tabFrame.r:SetTexCoord(0.859375, 0.96875, 0.28125, 1.0)

tabFrame.t = tabFrame:CreateFontString()
tabFrame.t:SetFontObject("GameFontNormalSmall")
tabFrame.t:SetPoint('TOP', 0, -3)
tabFrame.t:SetText('Minimap Alert')

tabFrame.closeButton = CreateFrame('Button', nil, tabFrame, "UIPanelCloseButton")
tabFrame.closeButton:SetSize(18, 18)
tabFrame.closeButton:SetPoint('TOPRIGHT', 0, 0)

local fullscreenGlow = CreateFrame('Frame', nil, UIParent)
fullscreenGlow:SetAllPoints()

fullscreenGlow.t = fullscreenGlow:CreateTexture(nil, 'BACKGROUND')
fullscreenGlow.t:SetAllPoints()
fullscreenGlow.t:SetTexture("Interface\\AddOns\\Minimap_Alert\\Fullscreen_Flash")
fullscreenGlow.t:SetBlendMode('ADD')
fullscreenGlow.t:SetVertexColor(0.6, 0.45, 1)
fullscreenGlow.t:SetAlpha(0)

fullscreenGlow.Anim = fullscreenGlow.t:CreateAnimationGroup()
fullscreenGlow.Anim[1] = fullscreenGlow.Anim:CreateAnimation("Alpha")
fullscreenGlow.Anim[1]:SetDuration(0.5)
fullscreenGlow.Anim[1]:SetFromAlpha(1)
fullscreenGlow.Anim[1]:SetToAlpha(0)

local function setSpinnerColor(r,g,b)
    spinner.AnimFrame.Circle:SetVertexColor(r,g,b)
end

local function startSpinner()
    setSpinnerColor(0.1, 1, 0.1)
    spinner.Anim:Play()
end

local function pauseSpinner()
    setSpinnerColor(1, 1, 0.1)
    spinner.Anim:Pause()
end

local function stopSpinner()
    setSpinnerColor(0.3, 0.3, 0.3)
    spinner.Anim:Stop()
end

local function updateAddonSettings()
    for k,v in pairs(minimapAlert.defaultData.settings) do
        if not minimapAlert.saveData.settings[k] then
            minimapAlert.saveData.settings[k] = v
        end
    end
end

--Ugly and temporary
local function updateCache()
    local t = {152507, 152510, 152505, 152511, 152509, 152506, 152508, 124101, 124102, 124103, 124104, 124105, 123918, 123919, 129039, 151564}
    for _,v in pairs(t) do
        if not minimapAlert.saveData.cachedNames[v] then
            GetItemInfo(v)
        end
    end
end

local mainFrame = CreateFrame('Frame')
mainFrame:SetScript('OnEvent', function(self, event, ...)
    if event == 'CHAT_MSG_LOOT' then
        local lootstring = ...
        local itemID = string.match(lootstring, "Hitem:(%d+):")
        local itemName = string.lower(string.match(lootstring, "%[(.+)%]"))
        for _, nodeName in pairs(minimapAlert.saveData.trackingList) do
            for w in string.gmatch(nodeName, "%S+") do
                if string.find(itemName, string.lower(w)) then
                        switchState('WAITING')
                    return
                end
            end
        end
    elseif event == 'ADDON_LOADED' then
        local name = ...
        if name == 'Minimap_Alert' then
            if MinimapAlert_Data then
                minimapAlert.saveData = MinimapAlert_Data

                if minimapAlert.saveData.addonVersion < addonVersion then
                    updateAddonSettings()
                end
            else
                minimapAlert.saveData = minimapAlert.defaultData
            end
            updateCache()
            mainFrame:UnregisterEvent('ADDON_LOADED')
        end
    elseif event == 'PLAYER_LOGOUT' then
        minimapAlert.saveData.addonVersion = addonVersion
        MinimapAlert_Data = minimapAlert.saveData
    end
end)
mainFrame:RegisterEvent('ADDON_LOADED')
mainFrame:RegisterEvent('PLAYER_LOGOUT')

local function prepareMinimap()
    Minimap:SetAlpha(0)
    Minimap:SetScale(0.15)
    local t = {Minimap:GetChildren()}
    Minimap.visibleChildren = {}
    for k,v in pairs(t) do if v:IsVisible() then table.insert(Minimap.visibleChildren, v) end end
end

local function setMinimapLoc(xOffset, yOffset)
    prepareMinimap()
    local xOffset = xOffset or 0
    local yOffset = yOffset or 0
    local x,y = GetCursorPosition()
    local uiScale = Minimap:GetEffectiveScale()
    Minimap:ClearAllPoints()
    Minimap:SetPoint('CENTER', nil, 'BOTTOMLEFT', xOffset + x/uiScale, yOffset + y/uiScale)
    GameTooltip:SetScale(9999)
end

local function restoreMinimap()
    local m = minimapSettings
    Minimap:SetAlpha(m.alpha)
    Minimap:SetScale(m.scale)
    Minimap:ClearAllPoints()
    Minimap:SetPoint(m.point, m.relativeTo, m.relativePoint, m.x, m.y)
    --Minimap:SetZoom(m.zoom)
    GameTooltip:SetScale(m.GameTooltipScale)
    for k,v in pairs(Minimap.visibleChildren) do v:Show() end
end

local function storeMinimap()
    local m = minimapSettings
    m.point, m.relativeTo, m.relativePoint, m.x, m.y = Minimap:GetPoint()
    m.parent = Minimap:GetParent()
    m.alpha = Minimap:GetAlpha()
    m.scale = Minimap:GetScale()
    --m.zoom = Minimap:GetZoom()
    m.GameTooltipScale = GameTooltip:GetScale()
end

local function isMatch()
    for i = 1, GameTooltip:NumLines() do
        local line = string.lower(_G['GameTooltipTextLeft'..i]:GetText())
        if line then
            for _, nodeName in pairs(minimapAlert.saveData.trackingList) do
                for w in string.gmatch(nodeName, "%S+") do
                    if string.find(line, string.lower(w), 1, true) then
                        statusText:SetText('[|cff00ff00'..nodeName..'|r]')
                        return true               
                    end
                end
            end 
        end
    end
    return false
end

local function nodeUpdate(self, elapsed)
    if minimapAlertState == 'WAITING' then
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.5 and not IsMouselooking() and not IsMouseButtonDown(1) then
            switchState('REPOSITION_MINIMAP')
        end
    elseif minimapAlertState == 'REPOSITION_MINIMAP' then
        if GetUnitSpeed('player') ~= 0 then
            switchState('TOOLTIP_CHECK')
        elseif minimapAlert.saveData.settings.idleScan then
            switchState('TOOLTIP_CHECK_SLOW')
        end
    elseif minimapAlertState == 'TOOLTIP_CHECK' or minimapAlertState == 'TOOLTIP_CHECK_SLOW' then
        local x, y = GetCursorPosition()

        if x == mX and y == mY then
            setMinimapLoc(math.random(-2, 2), math.random(-2, 2))
            mX = 9999
            mY = 9999
        else    
            setMinimapLoc()
            mX = x
            mY = y
        end

        if isMatch() then
            if minimapAlert.saveData.settings.flashScreen then fullscreenGlow.Anim:Play() end
            if minimapAlert.saveData.settings.flashTaskbar then FlashClientIcon() end
            if minimapAlert.saveData.settings.playSound then PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE) end
            guiFrame.glowAnimation:Play()
            foundNode = true
            switchState('RESET_STATE')
        else       
            if minimapAlertState == 'TOOLTIP_CHECK' then
                framesElapsed = framesElapsed + 1
                if framesElapsed >= 3 then
                    switchState('RESET_STATE')
                end
            else
                timeElapsed = timeElapsed + elapsed
                if timeElapsed >= 2 then
                    switchState('RESET_STATE')
                elseif GetUnitSpeed('player') ~= 0 then
                    --switchState('TOOLTIP_CHECK')
                    switchState('RESET_STATE')
                end            
            end
        end
    end
end

Minimap:HookScript('OnMouseDown', function(self, m)
    if (minimapAlertState == 'TOOLTIP_CHECK' or minimapAlertState == 'TOOLTIP_CHECK_SLOW') then
        if m == 'RightButton' then       
            MouselookStart()    
        elseif m == 'LeftButton' then
            extraDelay = 0.5
        end
        switchState('RESET_STATE')
    end
end)

local function startSearching()
    if #minimapAlert.saveData.trackingList > 0 then
        switchState('WAITING')
        mainFrame:SetScript('OnUpdate', nodeUpdate)
        startButton:SetText('Stop')
        oldZoom = Minimap:GetZoom()
        Minimap:SetZoom(0)
    else
        DEFAULT_CHAT_FRAME:AddMessage('Minimap Alert: Add atleast 1 thing to track before starting!')
    end
end

local function stopSearching()
    switchState('DISABLED')
    mainFrame:SetScript('OnUpdate', nil)
    --Minimap:SetZoom(oldZoom)
end

local function startStopSearching()
    if minimapAlertState == 'DISABLED' then
        startSearching()    
    else
        minimapAlertState = 'DISABLED'
        stopSearching()
    end
end

startButton:SetScript('OnClick', startStopSearching)
tabFrame.closeButton:SetScript('OnClick', function()
    stopSearching()
    guiFrame:Hide()
end)

SLASH_MINIMAPALERT1 = '/minimapalert'
SlashCmdList["MINIMAPALERT"] = function(message)
    guiFrame:Show()
end

stateList = {
    ['DISABLED'] = function()
        restoreMinimap()
        mainFrame:UnregisterEvent('CHAT_MSG_LOOT')
        lootText:Hide()
        stopSpinner()  
        statusText:SetText('Inactive')
        startButton:SetText('Start')
    end,
    ['WAITING'] = function()
        foundNode = false
        timeElapsed = 0
        if extraDelay ~= 0 then timeElapsed = -extraDelay extraDelay = 0 end
        framesElapsed = 0
        mainFrame:UnregisterEvent('CHAT_MSG_LOOT')
        lootText:Hide()
        startSpinner()
        statusText:SetText('Scanning...')
    end,
    ['REPOSITION_MINIMAP'] = function()
        storeMinimap()
        timeElapsed = 0        
    end,
    ['RESET_STATE'] = function() 
        restoreMinimap()
        
        if foundNode then
            if minimapAlert.saveData.settings.autoResumeAfterLoot then
                switchState('AWAITING_LOOT')
            else
                switchState('IDLE')
            end
        else
            switchState('WAITING')
        end    
    end,
    ['AWAITING_LOOT'] = function() 
        mainFrame:RegisterEvent('CHAT_MSG_LOOT')
        lootText:SetText('Waiting for loot')
        lootText:Show()
        pauseSpinner()
    end,
    ['TOOLTIP_CHECK'] = function() setMinimapLoc() end,
    ['TOOLTIP_CHECK_SLOW'] = function() setMinimapLoc() end,
    ['IDLE'] = function() lootText:SetText('Found match') lootText:Show() stopSpinner() mainFrame:SetScript('OnUpdate', nil) end
}

guiFrame:Hide()