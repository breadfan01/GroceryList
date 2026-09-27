local _, GL = ...
-- Curated skill bands and suggested craft counts from Wowhead Classic 1-300 guides.
-- Each row: starting skill, ending skill, recipe name, suggested craft count.
-- Names are resolved against LibProfessionDB for this client's game data.
GL.guideRoutes = {
  COOKING = {url='https://www.wowhead.com/classic/guide/cooking-leveling-1-300-wow-classic', steps={
    {1,50,'Brilliant Smallfish',50},{50,100,'Longjaw Mud Snapper',50},
    {100,150,'Bristle Whisker Catfish',50},{150,175,'Bristle Whisker Catfish',70},
    {175,225,'Mithril Headed Trout',60},{225,275,'Spotted Yellowtail',70},
    {275,300,'Mightfish Steak',25}}},
  FIRST_AID = {url='https://www.wowhead.com/classic/guide/first-aid-leveling-1-300-wow-classic', steps={
    {1,40,'Linen Bandage',40},{40,80,'Heavy Linen Bandage',50},
    {80,115,'Wool Bandage',35},{115,150,'Heavy Wool Bandage',45},
    {150,180,'Silk Bandage',30},{180,210,'Heavy Silk Bandage',40},
    {210,240,'Mageweave Bandage',35},{240,260,'Heavy Mageweave Bandage',25},
    {260,290,'Runecloth Bandage',35},{290,300,'Heavy Runecloth Bandage',15}}},
  ALCHEMY = {url='https://www.wowhead.com/classic/guide/alchemy-leveling-1-300-wow-classic', steps={
    {1,60,'Minor Healing Potion',59},{60,110,'Lesser Healing Potion',59},{110,140,'Healing Potion',30},
    {140,155,'Lesser Mana Potion',15},{155,185,'Greater Healing Potion',30},{185,210,'Elixir of Agility',25},
    {210,215,'Elixir of Greater Defense',10},{215,230,'Superior Healing Potion',15},{230,231,"Philosophers' Stone",1},
    {231,250,'Elixir of Detect Undead',19},{250,265,'Elixir of Greater Agility',15},{265,285,'Superior Mana Potion',20},
    {285,300,'Major Healing Potion',18}}},
  BLACKSMITHING = {url='https://www.wowhead.com/classic/guide/blacksmithing-leveling-1-300-wow-classic', steps={
    {1,30,'Rough Sharpening Stone',40},{30,65,'Rough Grinding Stone',60},{65,75,'Coarse Sharpening Stone',25},
    {75,90,'Coarse Grinding Stone',35},{90,100,'Runed Copper Belt',10},{100,105,'Silver Rod',5},
    {105,110,'Runed Copper Belt',5},{110,125,'Rough Bronze Leggings',15},{125,140,'Heavy Grinding Stone',35},
    {140,150,'Patterned Bronze Bracers',10},{150,155,'Golden Rod',5},{155,165,'Green Iron Leggings',10},
    {165,190,'Green Iron Bracers',25},{190,200,'Golden Scale Bracers',10},{200,210,'Solid Grinding Stone',30},
    {210,225,'Heavy Mithril Gauntlet',15},{225,235,'Steel Plate Helm',10},{235,250,'Mithril Coif',15},
    {250,260,'Dense Sharpening Stone',20},{260,270,'Thorium Belt',10},{270,275,'Thorium Bracers',5},
    {275,290,'Imperial Plate Bracers',15},{290,300,'Thorium Boots',10}}},
  ENGINEERING = {url='https://www.wowhead.com/classic/guide/engineering-leveling-1-300-wow-classic', steps={
    {1,30,'Rough Blasting Powder',60},{30,50,'Handful of Copper Bolts',30},{50,51,'Arclight Spanner',1},
    {51,75,'Rough Copper Bomb',30},{75,90,'Coarse Blasting Powder',60},{90,100,'Coarse Dynamite',20},
    {100,105,'Silver Contact',5},{105,125,'Bronze Tube',25},{125,135,'Standard Scope',10},
    {135,145,'Heavy Blasting Powder',30},{145,150,'Whirring Bronze Gizmo',15},{150,160,'Bronze Framework',15},
    {160,175,'Explosive Sheep',15},{175,176,'Gyromatic Micro-Adjustor',1},{176,195,'Solid Blasting Powder',60},
    {195,200,'Mithril Tube',7},{200,215,'Unstable Trigger',20},{215,238,'Mithril Casing',40},
    {238,250,'Hi-Explosive Bomb',20},{250,260,'Dense Blasting Powder',30},{260,285,'Thorium Widget',35},
    {285,300,'Thorium Shells',15}}},
  ENCHANTING = {url='https://www.wowhead.com/classic/guide/enchanting-leveling-1-300-wow-classic', steps={
    {1,2,'Runed Copper Rod',1},{2,50,'Enchant Bracer - Minor Health',48},{50,90,'Enchant Bracer - Minor Health',60},
    {90,100,'Enchant Bracer - Minor Stamina',10},{100,101,'Runed Silver Rod',1},{101,110,'Greater Magic Wand',9},
    {110,135,'Enchant Cloak - Minor Agility',25},{135,155,'Enchant Bracer - Lesser Stamina',20},
    {155,156,'Runed Golden Rod',1},{156,185,'Enchant Bracer - Lesser Strength',40},
    {185,200,'Enchant Bracer - Strength',15},{200,201,'Runed Truesilver Rod',1},
    {201,220,'Enchant Bracer - Strength',25},{220,225,'Enchant Cloak - Greater Defense',5},
    {225,230,'Enchant Gloves - Agility',5},{230,235,'Enchant Boots - Stamina',5},
    {235,250,'Enchant Chest - Superior Health',25},{250,265,'Lesser Mana Oil',20},
    {265,294,'Enchant Shield - Greater Stamina',30},{294,295,'Runed Arcanite Rod',1},
    {295,300,'Enchant Cloak - Superior Defense',5}}},
  LEATHERWORKING = {url='https://www.wowhead.com/classic/guide/leatherworking-leveling-1-300-wow-classic', steps={
    {1,30,'Light Leather',30},{30,45,'Light Armor Kit',18},{45,55,'Cured Light Hide',10},
    {55,85,'Embossed Leather Gloves',30},{85,100,'Fine Leather Belt',15},{100,115,'Cured Medium Hide',15},
    {115,125,'Dark Leather Boots',10},{125,135,'Dark Leather Boots',12},{135,150,'Dark Leather Belt',15},
    {150,155,'Heavy Leather',5},{155,160,'Cured Heavy Hide',5},{160,180,'Heavy Armor Kit',22},
    {180,190,'Barbaric Shoulders',10},{190,200,'Guardian Gloves',10},{200,220,'Thick Armor Kit',20},
    {220,230,'Nightscape Headband',11},{230,250,'Nightscape Pants',20},{250,260,'Rugged Armor Kit',12},
    {260,290,'Wicked Leather Gauntlets',32},{290,300,'Wicked Leather Headband',10}}},
  TAILORING = {url='https://www.wowhead.com/classic/guide/tailoring-leveling-1-300-wow-classic', steps={
    {1,45,'Bolt of Linen Cloth',95},{45,70,'Linen Belt',25},{70,75,'Reinforced Linen Cape',5},
    {75,100,'Bolt of Woolen Cloth',45},{100,110,'Simple Kilt',15},{110,125,'Double-stitched Woolen Shoulders',15},
    {125,145,'Bolt of Silk Cloth',205},{145,160,'Azure Silk Hood',20},{160,170,'Silk Headband',10},
    {170,175,'Formal White Shirt',5},{175,185,'Bolt of Mageweave',100},{185,205,'Crimson Silk Vest',20},
    {205,215,'Crimson Silk Pantaloons',10},{215,220,'Orange Mageweave Shirt',5},
    {220,230,'Black Mageweave Gloves',10},{230,250,'Black Mageweave Headband',25},
    {250,260,'Bolt of Runecloth',155},{260,280,'Runecloth Belt',25},{280,300,'Runecloth Gloves',20}}},
}
