local ChatTools = LibStub("AceAddon-3.0"):NewAddon(
    "ChatTools",
    "AceConsole-3.0",
    "AceEvent-3.0"
)

_G.ChatTools = ChatTools

--------------------------------------------------
-- DEFAULTS
--------------------------------------------------

local defaults = {
    profile = {

        showChannelLetters = true,

        panelPos = nil,

        buttonSize = 17,

        maxPM = 3,

        recentWhispers = {},

        channels = {
            { type = "chat", name = "SAY",  color = {1,1,1}, cmd="/s ", enabled=true },
            { type = "chat", name = "YELL", color = {1,0,0}, cmd="/y ", enabled=true },
            { type = "chat", name = "GUILD", color = {0,1,0}, cmd="/g ", enabled=true },
            { type = "chat", name = "PARTY", color = {0.6,0.4,1}, cmd="/p ", enabled=true },
            { type = "chat", name = "RAID", color = {1,0.5,0}, cmd="/raid ", enabled=true },
            { type = "chat", name = "RAID WARNING", color = {1,0,0.6}, cmd="/rw ", enabled=true },
            { type = "execute", name = "ROLL 100", color = {1,1,0}, cmd="/roll 100", enabled=true },
        }
    }
}

--------------------------------------------------
-- INIT
--------------------------------------------------

function ChatTools:OnInitialize()

    self.db = LibStub("AceDB-3.0"):New("ChatToolsDB", defaults, true)

    self:RegisterChatCommand("ct", "SlashCommand")
end

--------------------------------------------------
-- ENABLE
--------------------------------------------------

function ChatTools:OnEnable()

    self:CreatePanel()

    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
end

--------------------------------------------------
-- SLASH
--------------------------------------------------

function ChatTools:SlashCommand(msg)

    if msg == "reset" then
        self.db.profile.recentWhispers = {}
        self:UpdatePanel()
        return
    end

    LibStub("AceConfigDialog-3.0"):Open("ChatTools")
    InterfaceOptionsFrame_OpenToCategory("ChatTools")
end