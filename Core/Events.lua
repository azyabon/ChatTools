local ChatTools = _G.ChatTools

--------------------------------------------------
-- WHISPERS
--------------------------------------------------

function ChatTools:CHAT_MSG_WHISPER(event, message, sender)

    self:AddWhisper(sender)
end

function ChatTools:CHAT_MSG_WHISPER_INFORM(event, message, sender)

    self:AddWhisper(sender)
end

--------------------------------------------------
-- ADD WHISPER
--------------------------------------------------

function ChatTools:AddWhisper(sender)
    local name = sender
    local whispers = self.db.profile.recentWhispers
    local maxPM = self.db.profile.maxPM

    for i, n in ipairs(whispers) do
        if n == name then
            table.remove(whispers, i)
            break
        end
    end

    table.insert(whispers, 1, name)

    while #whispers > maxPM do
        table.remove(whispers)
    end

    self:UpdatePanel()
end