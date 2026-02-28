-- ========== Module: Settings ==========

local configFrame = CreateFrame("Frame", "ChatToolsConfig", UIParent, "BackdropTemplate")
configFrame:SetSize(400, 400)
configFrame:SetPoint("CENTER")
configFrame:SetFrameStrata("DIALOG")
configFrame:SetFrameLevel(1000)

configFrame:SetMovable(true)
configFrame:EnableMouse(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
configFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

configFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16
})
configFrame:SetBackdropColor(0, 0, 0, 0.9)
configFrame:Hide()

local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("Settings Chat Tools")
title:SetTextColor(1, 1, 0)

-- ========== SETTING THE NUMBER OF PMs ==========

local pmCountText = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pmCountText:SetPoint("TOPLEFT", 50, -60)
pmCountText:SetText("Number of saved PMs:")
pmCountText:SetTextColor(1, 1, 1)

local pmCountSlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
pmCountSlider:SetPoint("TOPLEFT", 50, -80)
pmCountSlider:SetWidth(200)
pmCountSlider:SetHeight(20)
pmCountSlider:SetMinMaxValues(0, 10)
pmCountSlider:SetValueStep(1)
pmCountSlider:SetObeyStepOnDrag(true)
pmCountSlider:SetValue(ChatToolsSettings.maxPM or 3)

local pmCountValue = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pmCountValue:SetPoint("LEFT", pmCountSlider, "RIGHT", 10, 0)
pmCountValue:SetText(tostring(pmCountSlider:GetValue()))
pmCountValue:SetTextColor(1, 1, 0)

pmCountSlider:SetScript("OnValueChanged", function(self, value)
    value = floor(value)
    pmCountValue:SetText(tostring(value))
    ChatToolsSettings.maxPM = value
    
    if ChatToolsUpdateButtons then
        ChatToolsUpdateButtons()
    end
end)

local pmCountHint = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pmCountHint:SetPoint("TOPLEFT", 50, -110)
pmCountHint:SetText("0 - disable display of PMs")
pmCountHint:SetTextColor(0.8, 0.8, 0.8)
pmCountHint:SetFontObject(GameFontNormalSmall)

-- ========== SETTING THE BUTTON SIZE ==========
local sizeText = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sizeText:SetPoint("TOPLEFT", 50, -140)
sizeText:SetText("Button size:")
sizeText:SetTextColor(1, 1, 1)

local sizeSlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", 50, -160)
sizeSlider:SetWidth(200)
sizeSlider:SetHeight(20)
sizeSlider:SetMinMaxValues(14, 24)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
sizeSlider:SetValue(ChatToolsSettings.buttonSize or 17)

local sizeValue = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sizeValue:SetPoint("LEFT", sizeSlider, "RIGHT", 10, 0)
sizeValue:SetText(tostring(sizeSlider:GetValue()))
sizeValue:SetTextColor(1, 1, 0)

sizeSlider:SetScript("OnValueChanged", function(self, value)
    value = floor(value)
    sizeValue:SetText(tostring(value))
    ChatToolsSettings.buttonSize = value
    
    if ChatToolsUpdateButtons then
        ChatToolsUpdateButtons()
    end
end)

-- ========== SETTING UP THE DISPLAY OF LETTERS ==========

local lettersCheckbox = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
lettersCheckbox:SetPoint("TOPLEFT", 50, -210)
lettersCheckbox:SetSize(24, 24)
lettersCheckbox:SetChecked(ChatToolsSettings.showChannelLetters)

local lettersText = lettersCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lettersText:SetPoint("LEFT", lettersCheckbox, "RIGHT", 5, 0)
lettersText:SetText("Show letters on channel buttons")
lettersText:SetTextColor(1, 1, 1)

lettersCheckbox:SetScript("OnClick", function(self)
    ChatToolsSettings.showChannelLetters = self:GetChecked()
    if ChatToolsUpdateButtons then
        ChatToolsUpdateButtons()
    end
end)

-- ========== CHANNEL SETUP ==========
local channelsTitle = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
channelsTitle:SetPoint("TOPLEFT", 50, -250)
channelsTitle:SetText("Included channels:")
channelsTitle:SetTextColor(1, 1, 0)

local channelCheckboxes = {}
local channelY = -270

for i, channel in ipairs(ChatToolsSettings.channels) do
    local checkbox = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 50, channelY)
    checkbox:SetSize(24, 24)
    checkbox:SetChecked(channel.enabled)
    
    local text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    text:SetText(channel.name)
    text:SetTextColor(1, 1, 1)
    
    local colorBox = checkbox:CreateTexture(nil, "OVERLAY")
    colorBox:SetSize(16, 16)
    colorBox:SetPoint("LEFT", text, "RIGHT", 10, 0)
    colorBox:SetColorTexture(channel.color[1], channel.color[2], channel.color[3], 0.8)
    
    checkbox.channelIndex = i
    
    checkbox:SetScript("OnClick", function(self)
        ChatToolsSettings.channels[self.channelIndex].enabled = self:GetChecked()
        if ChatToolsUpdateButtons then
            ChatToolsUpdateButtons()
        end
    end)
    
    table.insert(channelCheckboxes, checkbox)
    channelY = channelY - 25
end

local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
closeBtn:SetSize(80, 25)
closeBtn:SetPoint("BOTTOM", 0, 10)
closeBtn:SetText("Close")
closeBtn:SetScript("OnClick", function()
    configFrame:Hide()
end)

local category = Settings.RegisterCanvasLayoutCategory(configFrame, "Chat Tools")
Settings.RegisterAddOnCategory(category)

-- ========== SETTINGS UPDATES ==========
local function UpdateConfigUI()
    pmCountSlider:SetValue(ChatToolsSettings.maxPM or 3)
    pmCountValue:SetText(tostring(ChatToolsSettings.maxPM) or 3)
    
    sizeSlider:SetValue(ChatToolsSettings.buttonSize or 17)
    sizeValue:SetText(tostring(ChatToolsSettings.buttonSize) or 17)
    
    lettersCheckbox:SetChecked(ChatToolsSettings.showChannelLetters)
    
    for i, checkbox in ipairs(channelCheckboxes) do
        if ChatToolsSettings.channels[i] then
            checkbox:SetChecked(ChatToolsSettings.channels[i].enabled)
        end
    end
end

SLASH_CT1 = "/ct"
SlashCmdList["CT"] = function()
    UpdateConfigUI()
    Settings.OpenToCategory(category:GetID())
end

local origShow = configFrame.Show
configFrame.Show = function(self, ...)
    UpdateConfigUI()
    if origShow then
        origShow(self)
    end
end