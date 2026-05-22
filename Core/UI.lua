local ChatTools = _G.ChatTools

--------------------------------------------------
-- BUTTON POOLS
--------------------------------------------------

ChatTools.channelButtons = {}
ChatTools.pmButtons = {}

--------------------------------------------------
-- PANEL
--------------------------------------------------

function ChatTools:CreatePanel()

    self.panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

    -- self.panel:SetWidth(120)

    self.panel:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 4, 30)

    self.panel:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=4
    })

    self.panel:SetBackdropColor(0,0,0,0.6)

    -- self.panel:SetMovable(true)
    -- self.panel:EnableMouse(true)
    -- self.panel:RegisterForDrag("LeftButton")

    -- self.panel:SetScript("OnDragStart", function()
    --     self.panel:StartMoving()
    -- end)

    -- self.panel:SetScript("OnDragStop", function()

    --     self.panel:StopMovingOrSizing()

    --     local point, _, _, x, y = self.panel:GetPoint()

    --     self.db.profile.panelPos = {
    --         point = point,
    --         x = x,
    --         y = y
    --     }
    -- end)

    if self.db.profile.panelPos then

        local p = self.db.profile.panelPos

        self.panel:ClearAllPoints()
        self.panel:SetPoint(p.point, UIParent, "BOTTOMLEFT", p.x, p.y)
    end

    self:UpdatePanel()
end

--------------------------------------------------
-- BUTTON FACTORY
--------------------------------------------------

function ChatTools:CreateBaseButton()

    local btn = CreateFrame("Button", nil, self.panel)

    btn.tex = btn:CreateTexture(nil,"BACKGROUND")
    btn.tex:SetAllPoints()

    btn.text = btn:CreateFontString(nil,"OVERLAY","GameFontNormal")
    btn.text:SetPoint("CENTER")

    return btn
end

--------------------------------------------------
-- GET CHANNEL BUTTON
--------------------------------------------------

function ChatTools:GetChannelButton(index)

    local btn = self.channelButtons[index]

    if not btn then
        btn = self:CreateBaseButton()
        self.channelButtons[index] = btn
    end

    btn:Show()

    return btn
end

--------------------------------------------------
-- GET PM BUTTON
--------------------------------------------------

function ChatTools:GetPMButton(index)

    local btn = self.pmButtons[index]

    if not btn then
        btn = self:CreateBaseButton()
        self.pmButtons[index] = btn
    end

    btn:Show()

    return btn
end

--------------------------------------------------
-- GET CLEAR PANEL
--------------------------------------------------

function ChatTools:GetClearButton()
    if not self.clearButton then
        local btn = CreateFrame("Button", nil, self.panel)
        btn:SetSize(12, 12)
        
        btn.tex = btn:CreateTexture(nil, "BACKGROUND")
        btn.tex:SetAllPoints()
        
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btn.text:SetPoint("CENTER")
        
        self.clearButton = btn
    end
    
    self.clearButton:Show()
    return self.clearButton
end

--------------------------------------------------
-- UPDATE PANEL
--------------------------------------------------

function ChatTools:UpdatePanel()

    if not self.panel then return end

    local size = self.db.profile.buttonSize
    local spacing = size + 4
    local offset = 6

    local panelHeight = size + 8
    self.panel:SetHeight(panelHeight)

    --------------------------------------------------
    -- CHANNELS
    --------------------------------------------------

    local channelIndex = 1

    for _,channel in ipairs(self.db.profile.channels) do
        if channel.enabled then
            local btn = self:GetChannelButton(channelIndex)

            btn:SetSize(size, size-2)
            btn:SetPoint("LEFT", offset, 0)

            btn.tex:SetColorTexture(
                channel.color[1],
                channel.color[2],
                channel.color[3],
                0.8
            )

            if self.db.profile.showChannelLetters then
                btn.text:SetText(string.sub(channel.name,1,1))
                btn.text:SetTextColor(1, 1, 1)
                btn.text:SetFont("Fonts\\FRIZQT__.TTF", size-6, "OUTLINE")
            else
                btn.text:SetText("")
            end

            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(channel.name)
                GameTooltip:Show()
            end)

            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btn:SetScript("OnClick", function()
                if channel.type == "execute" then
                    ChatFrame1.editBox:SetText(channel.cmd)
                    ChatEdit_SendText(ChatFrame1.editBox, 0)
                    return
                end

                ChatFrame_OpenChat(channel.cmd, ChatFrame1)
            end)

            offset = offset + spacing
            channelIndex = channelIndex + 1
        end
    end

    for i = channelIndex, #self.channelButtons do
        self.channelButtons[i]:Hide()
    end

    --------------------------------------------------
    -- GAP
    --------------------------------------------------

    local hasChannels = false
    for _,channel in ipairs(self.db.profile.channels) do
        if channel.enabled then
            hasChannels = true
            break
        end
    end

    local hasPM = self.db.profile.maxPM > 0 and #self.db.profile.recentWhispers > 0

    if hasChannels and hasPM then
        offset = offset + 6
    end

    --------------------------------------------------
    -- WHISPERS
    --------------------------------------------------

    local pmIndex = 1

    for i,name in ipairs(self.db.profile.recentWhispers) do
        if i <= self.db.profile.maxPM then
            local btn = self:GetPMButton(pmIndex)

            btn:SetSize(size,size-2)
            btn:SetPoint("LEFT", offset, 0)

            btn.tex:SetColorTexture(1,0.4,0.7,0.9)
            btn.text:SetFont("Fonts\\FRIZQT__.TTF", size-6, "OUTLINE")
            btn.text:SetText(tostring(i))
            btn.text:SetTextColor(1, 1, 1)

            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("PM: " .. name)
                GameTooltip:Show()
            end)

            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            btn:SetScript("OnClick", function()
                ChatFrame_OpenChat("/w "..name.." ", ChatFrame1)
            end)

            offset = offset + spacing
            pmIndex = pmIndex + 1
        end
    end

    for i = pmIndex, #self.pmButtons do
        self.pmButtons[i]:Hide()
    end

    --------------------------------------------------
    -- PANEL SIZE
    --------------------------------------------------

    local rightPadding = 2
    local newWidth = offset + rightPadding

    self.panel:SetWidth(math.max(20, newWidth))
end