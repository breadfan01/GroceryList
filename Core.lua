local ADDON_NAME, GL = ...
_G.GroceryList = GL

GL.VERSION = "0.3.1"

local defaults = {
    mode = "planning", -- "planning", "learned", or "available"
    showZero = false,
    includeBank = true,
    includeReagentBank = true,
}

function GL:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Grocery List|r: " .. tostring(msg))
end

function GL:CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if dst[k] == nil then
            if type(v) == "table" then
                dst[k] = {}
                self:CopyDefaults(v, dst[k])
            else
                dst[k] = v
            end
        end
    end
end

function GL:InitializeDB()
    GroceryListDB = GroceryListDB or {}
    self:CopyDefaults(defaults, GroceryListDB)
    self.db = GroceryListDB
    if self.db.mode ~= "learned" and self.db.mode ~= "available" and self.db.mode ~= "planning" then self.db.mode = "planning" end
end

function GL:Refresh()
    if not self.db then return end

    if not self:InitializeRecipeDB() then return end
    self:ScanProfessions()
    self:Recalculate()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:RegisterEvent("TRADE_SKILL_CLOSE")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("BANKFRAME_CLOSED")
frame:RegisterEvent("BAG_UPDATE_DELAYED")

frame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == ADDON_NAME then
        GL:InitializeDB()
        GL:InstallSlashCommands()
        GL:InitializeRecipeDB()
    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(1, function()
            GL:Refresh()
        end)
    else
        if event == "BANKFRAME_OPENED" then
            GL.bankOpen = true
        elseif event == "BANKFRAME_CLOSED" then
            GL.bankOpen = false
            -- Keep the last bank snapshot; it is refreshed on the next bank visit.
        end

        if GL.db then GL:Refresh() end
    end
end)

function GL:InstallSlashCommands()
    SLASH_GROCERYLIST1 = "/gl"
    SLASH_GROCERYLIST2 = "/grocery"

    SlashCmdList.GROCERYLIST = function(msg)
        msg = (msg or ""):lower():match("^%s*(.-)%s*$")

        if msg == "planning" or msg == "plan" then
            self.db.mode = "planning"
            self:Refresh()
            self:Print("Planning route to 300; /gl route shows selected crafts.")
        elseif msg == "route" then
            self:PrintPlan()
        elseif msg == "available" or msg == "all" then
            self.db.mode = "available"
            self:Refresh()
            self:Print("Tracking materials for all recipes available at your profession skill.")

        elseif msg == "learned" then
            self.db.mode = "learned"
            self:Refresh()
            self:Print("Tracking materials for recipes you have learned.")

        elseif msg == "show" then
            self:OpenOptions()

        elseif msg == "refresh" then
            self:Refresh()
            self:Print("Material totals refreshed.")

        else
            self:Print("/gl planning - plan crafts to 300")
            self:Print("/gl route - show selected crafts")
            self:Print("/gl learned - learned recipes only")
            self:Print("/gl available - all recipes available at your skill")
            self:Print("/gl show - open options")
            self:Print("/gl refresh - refresh totals")
        end
    end
end

function GL:OpenOptions()
    if not self.optionsPanel then
        self:CreateOptionsPanel()
    end

    if Settings and self.optionsCategory then
        Settings.OpenToCategory(self.optionsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
    end
end
