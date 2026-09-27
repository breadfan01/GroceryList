# Grocery List 0.3.1

Install the `GroceryList` folder in `Interface/AddOns` alongside the WoW Forever `ProfessionDB` addon (LibProfessionDB-1.0). Remove the old `ProfessionMaterials` addon folder, then reload the UI.

Planning Mode is the default on a new install. Eight crafting profession routes use Wowhead Classic 1–300 skill bands and suggested craft counts: Alchemy, Blacksmithing, Engineering, Enchanting, Leatherworking, Tailoring, Cooking, and First Aid. `/gl route` shows the planned crafts, unlearned recipes, incomplete steps, and guide link. LibProfessionDB supplies reagents and produced items. A missing Forever recipe leaves that skill band unresolved, but later matched bands remain in the plan. While any band is unresolved, the tooltip hides the Surplus label for that profession's materials.

The tooltip also shows owned reagents that the remaining route does not need, including carried items in the reagent bag. Bank quantities are the last snapshot taken when visiting the bank. Planning quantities are estimates: yellow and green recipes may need extra crafts; outputs are credited at one item per craft when a crafted item ID is available. Review the route before selling based on Surplus.

Commands: `/gl planning`, `/gl learned`, `/gl available`, `/gl route`, `/gl show`, `/gl refresh`. Learned and Available modes retain their one-craft-per-recipe behavior. Grocery List stores preferences in `GroceryListDB`.
