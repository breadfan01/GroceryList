local _, GL = ...

local function itemIDFromTooltip(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return nil end
    return tonumber(link:match("item:(%d+)"))
end

function GL:AddTooltipData(tooltip, itemID)
    if not itemID or not self.materials[itemID] then return end

    local data = self.materials[itemID]

    if not self.db.showZero and data.required == 0 then
        return
    end

    tooltip:AddLine(" ")
    tooltip:AddLine("|cff33ff99Grocery List|r")

    local modeText = ({planning = "Planning to 300 (estimate)", learned = "Learned recipes", available = "Available recipes"})[self.db.mode] or "Planning to 300"

    tooltip:AddLine("Tracking: " .. modeText, 0.75, 0.75, 0.75)

    tooltip:AddDoubleLine("Required", tostring(data.required), 1,1,1, 1,1,1)
    tooltip:AddDoubleLine("Inventory", tostring(data.inventory), 1,1,1, 1,1,1)

    if self.db.includeBank then
        tooltip:AddDoubleLine("Bank", tostring(data.bank), 1,1,1, 1,1,1)
        tooltip:AddDoubleLine("Total", tostring(data.total), 1,1,1, 1,1,1)
    end

    if data.shortage > 0 then
        tooltip:AddDoubleLine(
            "Still needed",
            tostring(data.shortage),
            1, 0.4, 0.4,
            1, 0.4, 0.4
        )
    elseif data.surplus > 0 then
        tooltip:AddDoubleLine(
            "Surplus",
            tostring(data.surplus),
            0.4, 1, 0.4,
            0.4, 1, 0.4
        )
    end

    tooltip:Show()
end

if TooltipDataProcessor and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(
        Enum.TooltipDataType.Item,
        function(tooltip)
            local data = tooltip:GetPrimaryTooltipData()
            local itemID = data and data.id

            if itemID then
                GL:AddTooltipData(tooltip, itemID)
            end
        end
    )
else
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        local itemID = itemIDFromTooltip(tooltip)
        if itemID then GL:AddTooltipData(tooltip, itemID) end
    end)

    ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        local itemID = itemIDFromTooltip(tooltip)
        if itemID then GL:AddTooltipData(tooltip, itemID) end
    end)
end
