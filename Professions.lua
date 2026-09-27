local _, GL = ...

GL.professions = {}

local function normalize(name)
    if not name then return nil end
    return name:upper():gsub("[%s%-']", "_")
end

function GL:ScanProfessions()
    wipe(self.professions)

    -- Modern Forever profession/skill information.
    if GetProfessions and GetProfessionInfo then
        local slots = { GetProfessions() }

        for _, index in ipairs(slots) do
            if index then
                local name, icon, rank, maxRank, _, _, skillLine = GetProfessionInfo(index)

                if name and skillLine then
                    self.professions[skillLine] = {
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

    return self.professions
end

function GL:GetCharacterProfessionIDs()
    local result = {}

    for skillLineID, profession in pairs(self.professions) do
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
                    include = skillOK and self:IsKnownRecipe(recipeID)
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
