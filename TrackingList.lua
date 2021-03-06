local optionsFrame = _G['MinimapAlert_OptionsFrame']
local entryPool = {}

local listFrame = minimapAlert.f.createListFrame('Active Tracking List', 'List of names being tracked', 'Click to remove from tracking list', optionsFrame)
listFrame:SetPoint('BOTTOMRIGHT', -32, 48)

local function removeEntry(trackingListID)
    table.remove( minimapAlert.saveData.trackingList, trackingListID)
    listFrame.refreshList()
end

local function createEntryFrame(parent)
    local trackingEntry = CreateFrame('Button', nil, parent)
    trackingEntry:SetSize(parent:GetWidth()-8-16, 20)
    --trackingEntry:SetPoint('TOP', 0, -4)

    trackingEntry.bg = trackingEntry:CreateTexture(nil, 'BACKGROUND')
    trackingEntry.bg:SetAllPoints()
    
    trackingEntry.delete = trackingEntry:CreateTexture(nil, 'OVERLAY')
    trackingEntry.delete:SetSize(14, 14)
    trackingEntry.delete:SetTexture("Interface\\PetBattles\\DeadPetIcon")
    trackingEntry.delete:SetAlpha(0.8)
    trackingEntry.delete:SetPoint('LEFT', 4, 0)
    trackingEntry.delete:SetDesaturated(true)

    trackingEntry.text = trackingEntry:CreateFontString()
    trackingEntry.text:SetFontObject('GameFontNormal')
    trackingEntry.text:SetText('Peacebloom')
    trackingEntry.text:SetPoint('LEFT', trackingEntry.delete, 'RIGHT', 4, 0)

    trackingEntry:SetScript('OnEnter', function(self)  self.text:SetTextColor(1, 1, 1) trackingEntry.delete:SetDesaturated(false) end)
    trackingEntry:SetScript('OnLeave', function(self)  self.text:SetTextColor(0.99999779462814, 0.81960606575012, 0) trackingEntry.delete:SetDesaturated(true) end)
    trackingEntry:SetScript('OnClick', function(self)  removeEntry(self.trackingListID) end)
 
    return trackingEntry
end

for i = 1, 12 do
    entryPool[i] = createEntryFrame(listFrame.content)
    
    if i > 1 then
        entryPool[i]:SetPoint('TOP', entryPool[i-1], 'BOTTOM')
    else
        entryPool[i]:SetPoint('TOPLEFT', 4, 0)
    end
    
    entryPool[i]:Hide()
end

listFrame.refreshList = function()
    for i = 1, #entryPool do
        if i+listFrame.offset <= # minimapAlert.saveData.trackingList then
            local newText = minimapAlert.saveData.trackingList[listFrame.offset+i]
            entryPool[i].text:SetText(newText)
            entryPool[i].trackingListID = listFrame.offset+i
            if string.len(newText) <= 20 then
                entryPool[i].text:SetFontObject('GameFontNormal')
            else
                entryPool[i].text:SetFontObject('GameFontNormalSmall')
            end
            entryPool[i]:Show()
        else
            entryPool[i]:Hide()
        end
        
        if ((listFrame.offset+i)%2) == 0 then
            entryPool[i].bg:SetColorTexture(1, 1, 1, 0.05)
        else
            entryPool[i].bg:SetColorTexture(1, 1, 1, 0.125)
        end
    end
    
    local a = #minimapAlert.saveData.trackingList-#entryPool
    
    if a <= 0 then
        listFrame.slider:SetMinMaxValues(0, 0)
    else
        listFrame.slider:SetMinMaxValues(0, a)
    end
    
    
    if listFrame.offset == 0 then
        listFrame.slider.ScrollUpButton:Disable()
    else
        listFrame.slider.ScrollUpButton:Enable()
    end

    local _,maxValue = listFrame.slider:GetMinMaxValues()
    if listFrame.offset < maxValue then
        listFrame.slider.ScrollDownButton:Enable()
    else
        listFrame.slider.ScrollDownButton:Disable()
    end    
end


listFrame.addEntry = function(text)
    table.insert( minimapAlert.saveData.trackingList, text)
    listFrame.refreshList()
end

optionsFrame.listFrame = listFrame
