local _, GL = ...

local function difficultyAt(recipe, rank)
    local d = recipe.difficulty
    if type(d) ~= "table" then return nil end
    local orange = tonumber(d.orange or d[1])
    local yellow = tonumber(d.yellow or d[2])
    local green = tonumber(d.green or d[3])
    local grey = tonumber(d.grey or d[4])
    if not orange or not yellow or not green or not grey then return nil end
    if rank < orange then return 1 end
    if rank < yellow then return 0.75 end
    if rank < green then return 0.4 end
    if rank < grey then return 0.15 end
    return 0
end

-- Greedy estimate: reagent units per expected skill-up. No market prices are assumed.
-- Re-plan after each skill change; difficulty is probabilistic outside orange.
local function normalize(s)
    return s and s:upper():gsub("[^%w]", "") or ""
end

function GL:GuidePlan(profession)
    local guide = self.guideRoutes[profession.key]
    if not guide then return nil end
    local recipes = self:GetProfessionRecipes(profession.id) or {}
    local byName = {}
    for recipeID, recipe in pairs(recipes) do
        local name = recipe.name or self:GetRecipeName(recipeID)
        if name then byName[normalize(name)] = {recipeID = recipeID, recipe = recipe} end
    end
    local steps, unresolved = {}, nil
    local rank = tonumber(profession.rank) or 0
    for _, row in ipairs(guide.steps) do
        if rank < row[2] then
            local found = byName[normalize(row[3])]
            if not found or not (found.recipe.reagents or self:GetRecipeReagents(found.recipeID)) then
                unresolved = row[1]
                break -- never silently replace a guide step with a different route
            end
            local fraction = (row[2] - math.max(rank, row[1])) / (row[2] - row[1])
            steps[#steps + 1] = {recipeID = found.recipeID, recipe = found.recipe,
                professionID = profession.id, professionName = profession.name,
                known = self:IsKnownRecipe(found.recipeID),
                reagents = found.recipe.reagents or self:GetRecipeReagents(found.recipeID),
                crafts = math.max(1, math.ceil(row[4] * fraction)),
                fromSkill = math.max(rank, row[1]), toSkill = row[2]}
        end
    end
    return {name = profession.name, fromSkill = rank, target = 300,
        steps = steps, unresolved = unresolved, guideURL = guide.url,
        needsTraining = (tonumber(profession.maxRank) or 0) < 300}
end

function GL:BuildPlan()
    self.plan = {}
    local bagCounts = self:ScanInventory()
    local bankCounts = self.db.includeBank and self.bankCounts or {}
    local reserved = {}
    local professions = {}
    for id, profession in pairs(self.professions) do
        professions[#professions + 1] = profession
    end
    table.sort(professions, function(a, b) return a.id < b.id end)

    for _, profession in ipairs(professions) do
        local guided = self:GuidePlan(profession)
        if guided then
            self.plan[profession.id] = guided
        elseif profession.key == 'MINING' or profession.key == 'HERBALISM' or profession.key == 'SKINNING' or profession.key == 'FISHING' then
            self.plan[profession.id] = {name = profession.name, fromSkill = profession.rank,
                target = 300, steps = {}, gathering = true}
        else
        local rank = math.floor(tonumber(profession.rank) or 0)
        local target = math.min(300, tonumber(profession.maxRank) or 300)
        if target < 300 then target = 300 end -- show trainer-cap gaps as unresolved
        local recipes = self:GetProfessionRecipes(profession.id) or {}
        local steps = {}
        local unresolved
        local iterations = 0
        while rank < target and iterations < 300 do
            iterations = iterations + 1
            local best, bestScore, bestProbability
            for recipeID, recipe in pairs(recipes) do
                if type(recipe) == "table" and not (self.RecipeDB.IsHiddenRecipe and self.RecipeDB:IsHiddenRecipe(recipeID)) then
                    local required = tonumber(recipe.requiredSkill or self:GetRecipeRequiredSkill(recipeID))
                    local reagentMap = recipe.reagents or self:GetRecipeReagents(recipeID)
                    if required and required <= rank and type(reagentMap) == "table" and next(reagentMap) then
                        local probability = difficultyAt(recipe, rank)
                        if probability and probability > 0 then
                            local units, missing, valid = 0, 0, true
                            for itemID, quantity in pairs(reagentMap) do
                                local q = tonumber(quantity)
                                if type(itemID) ~= "number" or not q or q <= 0 then valid = false; break end
                                units = units + q
                                missing = missing + math.max(0, q - math.max(0, (bagCounts[itemID] or 0) + (bankCounts[itemID] or 0) - (reserved[itemID] or 0)))
                            end
                            if valid and units > 0 then
                                local known = self:IsKnownRecipe(recipeID)
                                local score = (units + missing * 0.5) / probability * (known and 1 or 1.5)
                                if not bestScore or score < bestScore or (score == bestScore and recipeID < best.recipeID) then
                                    best = {recipeID = recipeID, recipe = recipe, professionID = profession.id,
                                        professionName = profession.name, known = known, reagents = reagentMap}
                                    bestScore, bestProbability = score, probability
                                end
                            end
                        end
                    end
                end
            end
            if not best then
                unresolved = rank
                break
            end
            local crafts = math.min(1000, math.max(1, math.ceil(1 / bestProbability)))
            local last = steps[#steps]
            if last and last.recipeID == best.recipeID then
                last.crafts = last.crafts + crafts
                last.toSkill = rank + 1
            else
                best.crafts = crafts
                best.fromSkill = rank
                best.toSkill = rank + 1
                steps[#steps + 1] = best
            end
            for itemID, q in pairs(best.reagents) do
                reserved[itemID] = (reserved[itemID] or 0) + q * crafts
            end
            rank = rank + 1
        end
        self.plan[profession.id] = {name = profession.name, fromSkill = profession.rank,
            target = target, steps = steps, unresolved = unresolved,
            needsTraining = (tonumber(profession.maxRank) or 0) < target,
            unsupportedGuide = true}
        end
    end
    return self.plan
end

function GL:PrintPlan()
    for _, plan in pairs(self.plan or {}) do
        if plan.gathering then self:Print(plan.name .. ": level by gathering; no craft materials planned") end
        if plan.unsupportedGuide then self:Print(plan.name .. ": no curated guide route; heuristic estimate shown") end
        self:Print(('%s: %d/%d%s'):format(plan.name, plan.fromSkill, plan.target,
            plan.needsTraining and ' (train the next rank when capped)' or ''))
        for _, step in ipairs(plan.steps) do
            self:Print(('%d-%d: %s x%d%s'):format(step.fromSkill, step.toSkill,
                step.recipe.name or self:GetRecipeName(step.recipeID) or tostring(step.recipeID),
                step.crafts, step.known and '' or ' (recipe to learn)'))
        end
        if plan.unresolved then self:Print('Guide recipe unavailable in Forever data at skill ' .. plan.unresolved .. '; later materials excluded') end
        if plan.guideURL then self:Print(plan.guideURL) end
    end
end
