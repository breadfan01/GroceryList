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
    info:SetWidth(275)
    info:SetJustifyH("LEFT")
    info:SetText(
        "Recipe information is supplied by LibProfessionDB. " ..
        "The Available mode uses each recipe's required skill; " ..
        "Learned mode uses the character's live learned-recipe state. " ..
        "Planning Mode follows the selected route. Unowned professions use the starting skill at right. " ..
        "Learned mode counts only recipes the character actually knows."
    )

    local heading = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    heading:SetPoint("TOPLEFT", panel, "TOPLEFT", 320, -80)
    heading:SetText("Professions to track")

    local skillHeading = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    skillHeading:SetPoint("TOPLEFT", panel, "TOPLEFT", 520, -82)
    skillHeading:SetText("Start skill")

    self.professionControls = {}
    local options = self:GetProfessionOptions()
    for row, option in ipairs(options) do
        local id = option.id
        local checkbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", panel, "TOPLEFT", 315, -100 - (row - 1) * 27)
        checkbox.Text:SetText(option.name)
        checkbox:SetScript("OnClick", function(btn)
            self.db.professions[tostring(id)] = btn:GetChecked() and true or false
            self:Refresh()
        end)

        local level = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        level:SetSize(42, 20)
        level:SetPoint("LEFT", checkbox, "LEFT", 215, 0)
        level:SetAutoFocus(false)
        level:SetNumeric(true)
        level:SetMaxLetters(3)
        level:SetScript("OnEditFocusLost", function(box)
            local rank = math.max(1, math.min(300, tonumber(box:GetText()) or 1))
            if rank ~= (tonumber(self.db.plannedSkills[tostring(id)]) or 1) then
                self.db.plannedSkills[tostring(id)] = rank
                self:Refresh()
            end
        end)
        level:SetScript("OnEnterPressed", function(box) box:ClearFocus() end)
        level:SetScript("OnEscapePressed", function(box)
            box:SetText(tostring(self.db.plannedSkills[tostring(id)] or 1))
            box:ClearFocus()
        end)
        self.professionControls[#self.professionControls + 1] = {
            id = id, checkbox = checkbox, level = level,
        }
    end

    panel:SetScript("OnShow", function() self:UpdateProfessionControls() end)

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

function GL:UpdateProfessionControls()
    if not self.professionControls or not self.db then return end
    for _, control in ipairs(self.professionControls) do
        local id, checkbox, level = control.id, control.checkbox, control.level
        local owned = self.ownedProfessions[id]
        local selected = self.db.professions[tostring(id)]
        checkbox:SetChecked(selected == nil and owned ~= nil or selected == true)
        level:SetText(tostring(owned and owned.rank or self.db.plannedSkills[tostring(id)] or 1))
        level:SetEnabled(not owned)
    end
end
