-- ========== Module: Main ==========

local panel = CreateFrame("Frame", "ChatSwitcherPanel", UIParent, "BackdropTemplate")
panel:SetSize(150, 22)
panel:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 4, 32)
panel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 4
})
panel:SetBackdropColor(0, 0, 0, 0.6)

-- panel:SetMovable(true)
-- panel:EnableMouse(true)
-- panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

ChatToolsSettings = ChatToolsSettings or {
    maxPM = 3,
    buttonSize = 17,
    showChannelLetters = true,
    orientation = "horizontal",
    panelPos = nil,
    channels = {
        { name = "SAY",  color = {1, 1, 1},  cmd = "SAY",  enabled = true },
        { name = "YELL", color = {1, 0, 0},  cmd = "YELL", enabled = true },
        { name = "GUILD", color = {0, 1, 0}, cmd = "GUILD", enabled = true },
        { name = "PARTY", color = {0.4, 0.2, 0.6}, cmd = "PARTY", enabled = true },
        { name = "RAID", color = {1, 0.5, 0}, cmd = "RAID", enabled = true },
        { name = "RAID WARNING", color = {1, 0, 0.5}, cmd = "RAID_WARNING", enabled = true },
        { name = "ROLL 100", color = {0.8, 0.8, 0.2}, cmd = "ROLL", enabled = false },
    }
}

RecentWhispersDB = RecentWhispersDB or {}

local function AddWhisper(name)
    if not name or name == "" then return end
    
    for i, n in ipairs(RecentWhispersDB) do
        if n == name then
            table.remove(RecentWhispersDB, i)
            break
        end
    end
    
    table.insert(RecentWhispersDB, 1, name)
    
    while #RecentWhispersDB > 10 do
        table.remove(RecentWhispersDB)
    end
    
    UpdateAllButtons()
end

local whisperFrame = CreateFrame("Frame")
whisperFrame:RegisterEvent("CHAT_MSG_WHISPER")
whisperFrame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
whisperFrame:SetScript("OnEvent", function(self, event, text, name)
    AddWhisper(name)
end)

local channelButtons = {}
local pmButtons = {}

function UpdateAllButtons()
    for _, btn in ipairs(channelButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    channelButtons = {}
    
    for _, btn in ipairs(pmButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    pmButtons = {}
    
    local buttonSize = ChatToolsSettings.buttonSize or 17
    local buttonSpacing = buttonSize + 3
    
    local offset = 6
    local panelHeight = buttonSize + 12
    panel:SetHeight(panelHeight)
    local yOffset = -((panelHeight - (buttonSize - 2)) / 2) - 2
    
    for i, info in ipairs(ChatToolsSettings.channels) do
        if info.enabled then
            local btn = CreateFrame("Button", nil, panel)
            btn:SetSize(buttonSize, buttonSize - 2)
            btn:SetPoint("LEFT", offset, 0)
            btn:SetPoint("TOP", 0, yOffset)
            
            local tex = btn:CreateTexture(nil, "BACKGROUND")
            tex:SetAllPoints()
            tex:SetColorTexture(info.color[1], info.color[2], info.color[3], 0.8)

            if ChatToolsSettings.showChannelLetters then
                local letterText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                letterText:SetPoint("CENTER")
                letterText:SetText(string.sub(info.name, 1, 1))
                letterText:SetTextColor(1, 1, 1)
                letterText:SetFont("Fonts\\FRIZQT__.TTF", buttonSize - 6, "OUTLINE")
            end
            
            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                GameTooltip:AddLine(info.name)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            
            btn:SetScript("OnClick", function()
                local cmd = info.cmd
                if cmd == "SAY" then
                    ChatFrame1EditBox:SetText("/s ")
                elseif cmd == "GUILD" then
                    ChatFrame1EditBox:SetText("/g ")
                elseif cmd == "PARTY" then
                    ChatFrame1EditBox:SetText("/p ")
                elseif cmd == "RAID" then
                    ChatFrame1EditBox:SetText("/raid ")
                elseif cmd == "RAID_WARNING" then
                    ChatFrame1EditBox:SetText("/rw ")
                elseif cmd == "YELL" then
                    ChatFrame1EditBox:SetText("/y ")
                elseif cmd == "ROLL" then
                    ChatFrame1.editBox:SetText("/roll")
                    ChatFrame1.editBox:Show()
                    ChatFrame1.editBox:SetFocus()
                    ChatEdit_SendText(ChatFrame1.editBox, 0)
                    return
                end
                
                ChatFrame1EditBox:Show()
                ChatFrame1EditBox:SetFocus()
                ChatFrame1EditBox:SetCursorPosition(999)
            end)
            
            btn:Show()
            table.insert(channelButtons, btn)
            offset = offset + buttonSpacing
        end
    end
    
    offset = offset + 5
    
    local maxPM = ChatToolsSettings.maxPM or 3
    for i = 1, math.min(maxPM, #RecentWhispersDB) do
        local name = RecentWhispersDB[i]
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(buttonSize, buttonSize - 2)
        btn:SetPoint("LEFT", offset + (i-1) * buttonSpacing, 0)
        btn:SetPoint("TOP", 0, yOffset)
        
        local tex = btn:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints()
        tex:SetColorTexture(1, 0.4, 0.7, 0.9)

        local numberText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        numberText:SetPoint("CENTER")
        numberText:SetText(tostring(i))
        numberText:SetTextColor(1, 1, 1)
        numberText:SetFont("Fonts\\FRIZQT__.TTF", buttonSize - 6, "OUTLINE")
        
        btn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
            GameTooltip:AddLine("PM: " .. name)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        btn:SetScript("OnClick", function()
            ChatFrame_OpenChat("/w " .. name .. " ", ChatFrame1)
            ChatFrame1EditBox:Show()
            ChatFrame1EditBox:SetFocus()
        end)
        
        btn:Show()
        table.insert(pmButtons, btn)
    end
    
    local totalWidth = 6 + (#channelButtons * buttonSpacing) + 5 + (#pmButtons * buttonSpacing) + 3
    panel:SetWidth(totalWidth)
end

SLASH_CTRESET1 = "/ctreset"
SlashCmdList["CTRESET"] = function()
    RecentWhispersDB = {}
    UpdateAllButtons()
    print("|cff00ff00The list of recent PMs has been cleared.|r")
end

C_Timer.After(1, function()
    print("|cff00ff00Loaded PM from save:", #RecentWhispersDB)
    UpdateAllButtons()
end)

ChatToolsUpdateButtons = UpdateAllButtons

print("|cff00ff00✅ Chat Tools is working|r")
print("|cff00ff00/ct - settings|r")
print("|cff00ff00/ctreset - reset PMs|r")