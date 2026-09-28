# Grocery List 0.4.0

Install the `GroceryList` folder in `Interface/AddOns` alongside the WoW Forever `ProfessionDB` addon (LibProfessionDB-1.0). Replace the previous GroceryList folder and reload the UI.

Open `/gl show` to select professions. Professions the character owns are tracked by default, and any listed profession can be toggled off. Professions the character does not own start off. Check one to add its materials; set its starting skill from 1 to 300 in the box beside it. An owned profession always uses its live skill level. Choices and planned levels persist for the character's saved addon settings.

Planning Mode is the default on a new install. Eight crafting profession routes use Wowhead Classic 1–300 skill bands and suggested craft counts: Alchemy, Blacksmithing, Engineering, Enchanting, Leatherworking, Tailoring, Cooking, and First Aid. `/gl route` shows planned crafts, recipes to learn, incomplete steps, and guide links. LibProfessionDB supplies reagents and produced items. An unowned profession uses the selected starting skill in Planning and Available modes. Learned mode counts only recipes known by the current character, so an unowned profession contributes no recipes in Learned mode.

Material totals combine the selected professions. A missing Forever recipe leaves its guide band unresolved; later matched bands remain in the plan. The tooltip withholds Surplus on materials affected by an incomplete route. The tooltip also shows owned reagents not needed by the remaining plan and counts the reagent bag as carried inventory. Bank counts reflect the last bank visit.

Planning quantities are estimates: yellow and green recipes may take extra crafts; outputs are credited at one item per craft when identified. Review `/gl route` and recipe availability before selling based on Surplus.

Commands: `/gl planning`, `/gl learned`, `/gl available`, `/gl route`, `/gl show`, `/gl refresh`. Preferences are saved in `GroceryListDB`.
