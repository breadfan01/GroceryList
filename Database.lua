local _, GL = ...

-- LibProfessionDB adapter.
--
-- LibProfessionDB v1.8.0 supplies the complete WoW Forever recipe database:
-- 2,511 recipes across 10 professions. This addon deliberately does not copy
-- recipe data; it consumes the library at runtime.

GL.RecipeDB = nil
GL.RecipeDBReady = false

function GL:InitializeRecipeDB()
    local lib = LibStub and LibStub("LibProfessionDB-1.0", true)
    if not lib then
        self.RecipeDB = nil
        self.RecipeDBReady = false
        return false
    end

    self.RecipeDB = lib
    self.RecipeDBReady = lib.IsReady and lib:IsReady() or false

    return self.RecipeDBReady
end

function GL:GetRecipeDatabase()
    if not self.RecipeDBReady then
        self:InitializeRecipeDB()
    end
    return self.RecipeDB
end

function GL:GetRecipeInfo(recipeID)
    local db = self:GetRecipeDatabase()
    if not db or not db.GetRecipe then return nil end
    return db:GetRecipe(recipeID)
end

function GL:GetRecipeReagents(recipeID)
    local db = self:GetRecipeDatabase()
    if not db or not db.GetReagents then return nil end
    return db:GetReagents(recipeID)
end

function GL:GetRecipeRequiredSkill(recipeID)
    local db = self:GetRecipeDatabase()
    if not db or not db.GetRequiredSkill then return nil end
    return db:GetRequiredSkill(recipeID)
end

function GL:GetRecipeName(recipeID)
    local db = self:GetRecipeDatabase()
    if not db or not db.GetName then return nil end
    return db:GetName(recipeID)
end

function GL:GetProfessionRecipes(professionID)
    local db = self:GetRecipeDatabase()
    if not db or not db.GetRecipes then return nil end
    return db:GetRecipes(professionID)
end

function GL:IsKnownRecipe(recipeID)
    -- LibProfessionDB contains the offline database, including recipes the
    -- character does not know. Character-specific learned state must therefore
    -- come from the live profession API.
    if C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo then
        local info = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if info then
            if info.learned ~= nil then
                return info.learned == true
            end
            if info.learnedByMe ~= nil then
                return info.learnedByMe == true
            end
        end
    end

    return false
end
