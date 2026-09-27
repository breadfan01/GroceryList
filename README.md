# Profession Materials 0.2.0

Profession material tracker for WoW Forever.

## Recipe database

This addon uses **LibProfessionDB** as its authoritative recipe database.
Do not copy recipe data into this addon.

The current LibProfessionDB Forever release is v1.8.0 and contains Forever's
dedicated recipe data tree with 2,511 recipes across 10 professions.

Install LibProfessionDB separately and enable it before Profession Materials.

## Tracking modes

### Learned recipes

Only recipes that the current character has learned are counted, subject to
the current profession skill.

`/gl learned`

### Available recipes

All LibProfessionDB recipes belonging to one of the character's professions
whose `requiredSkill` is at or below the character's current profession rank
are counted.

`/gl available`

## Tooltip

For a tracked material:

- Required
- Inventory
- Bank
- Total
- Still needed OR Surplus

The purpose of the surplus value is to make it easy to identify materials
that are not currently needed for the selected recipe set.

## Dependency

The `.toc` declares:

`## RequiredDeps: ProfessionDB`

The dependency must provide `LibProfessionDB-1.0`.

## Database architecture

There is intentionally no local recipe database in this addon. The adapter in
Database.lua isolates all LibProfessionDB calls, making a future library API
change localized to one file.
