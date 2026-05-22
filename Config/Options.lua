local ChatTools = _G.ChatTools

local function getChannels()
    if ChatTools and ChatTools.db and ChatTools.db.profile then
        return ChatTools.db.profile.channels
    end
    return {}
end

local options = {

    name = "ChatTools",
    type = "group",

    args = {

        generalHeader = {
            type = "header",
            name = "General Settings",
            order = 1,
        },

        size = {

            type = "range",
            name = "Button Size",
            desc = "Size of channel and PM buttons",
            min = 14,
            max = 24,
            step = 1,
            order = 2,

            get = function()
                return ChatTools.db.profile.buttonSize
            end,

            set = function(_,val)

                ChatTools.db.profile.buttonSize = val

                ChatTools:UpdatePanel()
            end
        },

        maxPM = {

            type = "range",
            name = "Max whispers",
            desc = "Number of recent whispers to show (0 = hide)",
            min = 0,
            max = 10,
            step = 1,
            order = 3,

            get = function()
                return ChatTools.db.profile.maxPM
            end,

            set = function(_,val)
                ChatTools.db.profile.maxPM = val
                ChatTools:UpdatePanel()
            end
        },

        showLetters = {
            type = "toggle",
            name = "Show channel letters",
            desc = "Display first letter on channel buttons",
            order = 4,

            get = function()
                return ChatTools.db.profile.showChannelLetters
            end,
            
            set = function(_, val)
                ChatTools.db.profile.showChannelLetters = val
                ChatTools:UpdatePanel()
            end,
        },

        channelsHeader = {
            type = "header",
            name = "Channels",
            order = 10,
        }
    }
}

for i = 1, 7 do
    options.args["channel" .. i] = {
        type = "toggle",
        name = function()
            local channels = getChannels()
            return channels[i] and channels[i].name or "Channel " .. i
        end,
        desc = function()
            local channels = getChannels()
            return channels[i] and ("Show/hide " .. channels[i].name .. " button") or ""
        end,
        order = 10 + i,
        get = function()
            local channels = getChannels()
            return channels[i] and channels[i].enabled or false
        end,
        set = function(_, val)
            if ChatTools and ChatTools.db and ChatTools.db.profile then
                ChatTools.db.profile.channels[i].enabled = val
                ChatTools:UpdatePanel()
            end
        end,
    }
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("ChatTools", options)

LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ChatTools", "ChatTools")