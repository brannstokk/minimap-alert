local function createCheckButton(text, parent)
    local frame = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
    frame:SetSize(26, 26)
    
    frame.text = frame:CreateFontString()
    frame.text:SetFontObject('GameFontNormal')
    frame.text:SetText(text)
    frame.text:SetTextColor(1, 1, 1)
    frame.text:SetPoint('LEFT', frame, 'RIGHT', 4, 0)

    return frame    
end

local optionsFrame = CreateFrame('Frame', 'MinimapAlert_OptionsFrame', InterfaceOptionsFramePanelContainer)
optionsFrame.name = 'Minimap Alert'

local titleText = optionsFrame:CreateFontString()
titleText:SetPoint('TOPLEFT', 16, -16)
titleText:SetFontObject('GameFontNormalLarge')
titleText:SetText('Minimap Alert')

local subText = optionsFrame:CreateFontString()
subText:SetFontObject('GameFontHighlightSmall')
subText:SetText('Options for Minimap Alert')
subText:SetPoint('TOPLEFT', titleText, 'BOTTOMLEFT', 0, -4)

local cbo = {{'Flash World of Warcraft in the taskbar when a match is found', 'flashTaskbar'},
 {'Play a sound when a match is found', 'playSound'},
 {'Flash screen when a match is found', 'flashScreen'},
 {'Automatically resume tracking after finding a match and looting it', 'autoResumeAfterLoot'},
 {'Also search for a match while not moving (slower)', 'idleScan'}}
local checkButtons = {}
for i = 1, #cbo do
    local checkButton = createCheckButton(cbo[i][1], optionsFrame)
    if i == 1 then
        checkButton:SetPoint('TOPLEFT', subText, 'BOTTOMLEFT', 0, -16)
    else
        checkButton:SetPoint('TOPLEFT', checkButtons[i-1], 'BOTTOMLEFT', 0, 0)
    end
    
    checkButton:SetScript('OnClick', function()
        local param = cbo[i][2]
        minimapAlert.saveData.settings[param] = not minimapAlert.saveData.settings[param]
        checkButton:SetChecked(minimapAlert.saveData.settings[param])
    end)
    
    checkButtons[i] = checkButton
end

StaticPopupDialogs["MinimapAlert_AddCustomName"] = {
  text = "Enter the name or a part of it of the node you want to track.",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 26,
  OnAccept = function(self, ...)
    local text = self.editBox:GetText();
    optionsFrame.listFrame.addEntry(text)
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local text = self:GetParent().editBox:GetText();
    optionsFrame.listFrame.addEntry(text)
    self:GetParent():Hide()
  end,
  OnShow = function(self)
    self.editBox:SetText("");
    self.editBox:SetFocus();
  end,
  timeout = 0,
  exclusive = true,
  whileDead = true,
};

addButton = CreateFrame('Button', nil, optionsFrame, 'GameMenuButtonTemplate')
addButton:SetSize(100, 24) --128, 32
addButton:SetPoint('CENTER', 0, -64)
addButton:SetText('Add Custom')
addButton:SetScript('OnClick', function() 
StaticPopup_Show("MinimapAlert_AddCustomName")
end)

clearButton = CreateFrame('Button', nil, addButton, 'GameMenuButtonTemplate')
clearButton:SetSize(100, 24) --128, 32
clearButton:SetPoint('TOP', addButton, 'BOTTOM', 0, -8)
clearButton:SetText('Clear List')
clearButton:SetScript('OnClick', function() minimapAlert.saveData.trackingList = {} optionsFrame.listFrame.refreshList() end)

optionsFrame:SetScript('OnShow', function(self)
    for i = 1, #cbo do
        local param = cbo[i][2]
        checkButtons[i]:SetChecked(minimapAlert.saveData.settings[param])
    end
    self.trackableFrame.refreshList() 
    self.listFrame.refreshList() 
end)

InterfaceOptions_AddCategory(optionsFrame)