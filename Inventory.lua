local _, GL = ...
GL.materials = {}
GL.bankOpen = false
GL.bankCounts = {}

local function scanBag(counts, bag)
    if not bag or not C_Container then return end
    for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID then
            counts[info.itemID] = (counts[info.itemID] or 0) + (info.stackCount or 0)
        end
    end
end

function GL:ScanInventory()
    local counts = {}
    for bag = 0, (NUM_BAG_SLOTS or 4) do scanBag(counts, bag) end
    -- ReagentBag is separate from the four ordinary bag slots.
    local reagentBag = Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag
    if reagentBag and reagentBag > (NUM_BAG_SLOTS or 4) then scanBag(counts, reagentBag) end
    return counts
end

function GL:ScanBank()
    if not self.bankOpen then return end -- retain last observed snapshot until next visit
    wipe(self.bankCounts)
    scanBag(self.bankCounts, BANK_CONTAINER)
    for bag = (NUM_BAG_SLOTS or 4) + 1, (NUM_BAG_SLOTS or 4) + (NUM_BANKBAGSLOTS or 7) do
        if not (Enum and Enum.BagIndex and bag == Enum.BagIndex.ReagentBag) then
            scanBag(self.bankCounts, bag)
        end
    end
    if self.db.includeReagentBank then scanBag(self.bankCounts, REAGENTBANK_CONTAINER) end
end

function GL:Recalculate()
    wipe(self.materials)
    if not self.RecipeDBReady then return end
    self:ScanBank()
    local bagCounts = self:ScanInventory()
    local tracked
    if self.db.mode == 'planning' then
        self:BuildPlan()
        tracked = {}
        for _, plan in pairs(self.plan) do
            for _, step in ipairs(plan.steps) do tracked[#tracked + 1] = step end
        end
    else
        self.plan = {}
        tracked = self:GetTrackedRecipes()
    end
    local produced = {}
    for _, entry in ipairs(tracked) do
        if self.db.mode == "planning" then
            local output = entry.recipe.craftedItemId
            if not output and self.RecipeDB.GetCraftedItemID then
                output = self.RecipeDB:GetCraftedItemID(entry.professionID, entry.recipeID)
            end
            if type(output) == "number" then produced[output] = (produced[output] or 0) + entry.crafts end
        end
        local reagents = entry.reagents or entry.recipe.reagents or self:GetRecipeReagents(entry.recipeID, entry.professionID)
        for itemID, quantity in pairs(reagents or {}) do
            if type(itemID) == 'number' and tonumber(quantity) then
                local data = self.materials[itemID] or {required = 0}
                self.materials[itemID] = data
                data.required = data.required + quantity * (entry.crafts or 1)
            end
        end
    end
    -- Keep material tooltips for owned profession reagents even when the
    -- remaining leveling route needs none of them. An incomplete guide must
    -- never imply that its uncounted materials are safe to sell.
    if self.db.mode == 'planning' then
        for professionID, profession in pairs(self.professions) do
            local plan = self.plan[professionID]
            local incomplete = plan and (plan.unresolved or plan.unsupportedGuide)
            for recipeID, recipe in pairs(self:GetProfessionRecipes(professionID) or {}) do
                recipe = type(recipe) == 'table' and recipe or self:GetRecipeInfo(recipeID, professionID)
                local reagents = recipe and (recipe.reagents or self:GetRecipeReagents(recipeID, professionID))
                for itemID in pairs(reagents or {}) do
                    if type(itemID) == 'number' and
                        ((bagCounts[itemID] or 0) > 0 or (self.bankCounts[itemID] or 0) > 0) then
                        local data = self.materials[itemID] or {required = 0}
                        self.materials[itemID] = data
                        if incomplete then data.incomplete = true end
                    end
                end
            end
        end
    end
    for itemID, data in pairs(self.materials) do
        if self.db.mode == "planning" then
            data.required = math.max(0, data.required - (produced[itemID] or 0))
        end
        data.inventory = bagCounts[itemID] or 0
        data.bank = self.db.includeBank and (self.bankCounts[itemID] or 0) or 0
        data.total = data.inventory + data.bank
        data.shortage = math.max(0, data.required - data.total)
        data.surplus = math.max(0, data.total - data.required)
    end
end
