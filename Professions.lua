local _, GL = ...

GL.professions = {}
GL.ownedProfessions = {}

-- Classic skill-line IDs. Only entries present in LibProfessionDB are shown.
GL.professionCatalog = {
    {171, 'Alchemy'}, {164, 'Blacksmithing'}, {185, 'Cooking'},
    {333, 'Enchanting'}, {202, 'Engineering'}, {129, 'First Aid'},
    {182, 'Herbalism'}, {165, 'Leatherworking'}, {186, 'Mining'},
    {393, 'Skinning'}, {197, 'Tailoring'}, {356, 'Fishing'},
}

local function normalize(name)
    if not name then return nil end
    return name:upper():gsub("[%s%-']", "_")
end

function GL:ScanProfessions()
    wipe(self.professions)
    wipe(self.ownedProfessions)

    -- Modern Forever profession/skill information.
    if GetProfessions and GetProfessionInfo then
        local slots = { GetProfessions() }

        for _, index in ipairs(slots) do
            if index then
                local name, icon, rank, maxRank, _, _, skillLine = GetProfessionInfo(index)

                if name and skillLine then
                    self.ownedProfessions[skillLine] = {
                        id = skillLine,
                        key = normalize(name),
                        name = name,
                        rank = rank or 0,
                        maxRank = maxRank or 0,
                        index = index,
                    }
                end
            end
        end
    end

    for id, owned in pairs(self.ownedProfessions) do
        if self.db.professions[tostring(id)] ~= false then
            self.professions[id] = owned
        end
    end
    for _, entry in ipairs(self.professionCatalog) do
        local id, name = entry[1], entry[2]
        if not self.ownedProfessions[id] and self.db.professions[tostring(id)] == true then
            local recipes = self:GetProfessionRecipes(id)
            if recipes and next(recipes) then
                local rank = math.floor(tonumber(self.db.plannedSkills[tostring(id)]) or 1)
                rank = math.max(1, math.min(300, rank))
                self.professions[id] = {
                    id = id, key = normalize(name), name = name,
                    rank = rank, maxRank = 300, virtual = true,
                }
            end
        end
    end

    return self.professions
end

function GL:GetProfessionOptions()
    local options = {}
    for _, entry in ipairs(self.professionCatalog) do
        local id = entry[1]
        local recipes = self:GetProfessionRecipes(id)
        if self.ownedProfessions[id] or (recipes and next(recipes)) then
            options[#options + 1] = {
                id = id, name = (self.ownedProfessions[id] and self.ownedProfessions[id].name) or entry[2],
                owned = self.ownedProfessions[id] ~= nil,
            }
        end
    end
    return options
end

function GL:GetCharacterProfessionIDs()
    local result = {}

    for skillLineID, profession in pairs(self.ownedProfessions) do
        result[skillLineID] = profession
    end

    return result
end

function GL:GetTrackedRecipes()
    local db = self:GetRecipeDatabase()
    if not db then return {} end

    local tracked = {}
    local mode = self.db and self.db.mode or "learned"

    for professionID, profession in pairs(self.professions) do
        local recipes = self:GetProfessionRecipes(professionID)

        if recipes then
            for recipeID, recipe in pairs(recipes) do
                recipe = type(recipe) == 'table' and recipe or self:GetRecipeInfo(recipeID, professionID)
                if recipe then
                local requiredSkill = recipe.requiredSkill
                    or self:GetRecipeRequiredSkill(recipeID, professionID)
                    or 0

                local skillOK = requiredSkill <= profession.rank
                local include = skillOK

                if mode == "learned" then
                    include = skillOK and not profession.virtual and self:IsKnownRecipe(recipeID)
                end

                if include then
                    tracked[#tracked + 1] = {
                        professionID = professionID,
                        professionName = profession.name,
                        recipeID = recipeID,
                        recipe = recipe,
                    }
                end
                end
            end
        end
    end

    return tracked
end
