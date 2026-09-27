local _, GL = ...

function GL:CreateOptionsPanel()
    if self.optionsPanel then return self.optionsPanel end

    local panel = CreateFrame("Frame")
    panel.name = "Grocery List"
    panel:Hide()

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Grocery List")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure which profession recipes contribute to material totals.")

    local planning = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    planning:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -4, -24)
    planning.Text:SetText("Planning Mode: estimate an efficient route to 300")
    planning:SetChecked(self.db.mode == "planning")

    local learned = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    learned:SetPoint("TOPLEFT", planning, "BOTTOMLEFT", 0, -8)
    learned.Text:SetText("Track learned recipes only")
    learned:SetChecked(self.db.mode == "learned")

    local available = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    available:SetPoint("TOPLEFT", learned, "BOTTOMLEFT", 0, -8)
    available.Text:SetText("Track all recipes available at current skill")
    available:SetChecked(self.db.mode == "available")

    planning:SetScript("OnClick", function(btn)
        if btn:GetChecked() then
            self.db.mode = "planning"
            learned:SetChecked(false); available:SetChecked(false)
            self:Refresh()
        else btn:SetChecked(self.db.mode == "planning") end
    end)

    learned:SetScript("OnClick", function(btn)
        if btn:GetChecked() then
            self.db.mode = "learned"
            available:SetChecked(false); planning:SetChecked(false)
            self:Refresh()
        else
            btn:SetChecked(self.db.mode == "learned")
        end
    end)

    available:SetScript("OnClick", function(btn)
        if btn:GetChecked() then
            self.db.mode = "available"
            learned:SetChecked(false); planning:SetChecked(false)
            self:Refresh()
        else
            btn:SetChecked(self.db.mode == "available")
        end
    end)

    local bank = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    bank:SetPoint("TOPLEFT", available, "BOTTOMLEFT", 0, -8)
    bank.Text:SetText("Include bank contents")
    bank:SetChecked(self.db.includeBank)
    bank:SetScript("OnClick", function(btn)
        self.db.includeBank = btn:GetChecked()
        self:Refresh()
    end)

    local reagent = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    reagent:SetPoint("TOPLEFT", bank, "BOTTOMLEFT", 0, -8)
    reagent.Text:SetText("Include reagent bank")
    reagent:SetChecked(self.db.includeReagentBank)
    reagent:SetScript("OnClick", function(btn)
        self.db.includeReagentBank = btn:GetChecked()
        self:Refresh()
    end)

    local info = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    info:SetPoint("TOPLEFT", reagent, "BOTTOMLEFT", 4, -20)
    info:SetWidth(560)
    info:SetJustifyH("LEFT")
    info:SetText(
        "Recipe information is supplied by LibProfessionDB. " ..
        "The Available mode uses each recipe's required skill; " ..
        "Learned mode uses the character's live learned-recipe state. " ..
        "Planning Mode estimates skill gains from difficulty bands and counts crafts in /gl route."
    )

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        self.optionsPanel = panel
        self.optionsCategory = category
    else
        InterfaceOptions_AddCategory(panel)
        self.optionsPanel = panel
    end

    return panel
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    GL:CreateOptionsPanel()
end)
