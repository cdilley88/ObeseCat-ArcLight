# HUD, potions and Wormhole — Tech Demo 0.8

## Accepted direction

Keep red Life/blue Mana orbs, level and XP. Remove persistent tutorial/control text. Add original menu icons with hotkey badges, extensible for future menus. Esc opens Pause/System; C stats; I inventory; V map; B Wormhole; Z health potion; X mana potion. Red/blue potion icons sit beside their orbs and show inventory counts out of 99. Town debug NPC gains potion maxing and waypoint unlock/reset.

## Implemented temporary rules

Potions are dedicated character-inventory stacks, not equipment-grid rectangles. Each stack caps at 99. Start with six Life and four Mana. Z restores max(40, 40% max Life); X restores max(30, 40% max Mana), clamped to the maximum. Separate one-second cooldowns count down during live simulation. Full resources, empty stacks, pause and death never consume a potion. Potions do not resurrect. The old H/two-repair-charge action is superseded; its field remains only for legacy regression fixtures.

Both existing vendors sell one of either potion for 8 Silicon. Wallet and stack capacity are checked before charging. Defeated supervisors and every third regular security index automatically recover one potion, alternating type by enemy-index parity; full stacks discard surplus. This deterministic supply experiment does not alter equipment RNG. Supplies survive travel and death recovery; garage visits refill resources but do not refill potion stacks. Numbers, drop cadence, dedicated-stack presentation and prices are temporary balance choices.

B in a combat floor creates/replaces one two-way Wormhole at the character's current position. Click it or E to enter the garage. A visible return portal appears in the garage; click/E or B returns to the exact cast position. No cost, consumable, casting delay or combat-proximity restriction in this prototype. It preserves normal floor snapshots, equipment, currency and supplies. Only one return location exists; casting elsewhere replaces it. Stairs/elevators do not remove it. NEW SORTIE, full reset and debug waypoint reset remove it so no return can enter an invalidated floor state. No disk persistence.

## HUD and system menu

Original SVG icons live in `prototype/assets/ui`: pet/stat markings, backpack, folded map, orbital Wormhole, gear, red/blue bottles. A shared icon-button helper supplies tooltip/hotkey badges; one menu entry list can accommodate later skills or other menus without adding unimplemented buttons now. Unspent character points tint its icon gold and appear in its tooltip.

The main HUD shows area/Silicon, brief notices, orbs, supply counts, XP/level and the menu strip. Circuit/status text is compact and hidden when irrelevant. Full control reference, sound/CRT toggles and confirmed character reset live under Esc/System. R/N no longer trigger accidental resets; same-seed/new-seed reset are explicit System actions. Esc closes an open panel; otherwise opens System. Menus pause simulation.

## Developer NPC

- POTIONS: MAX sets both stacks to 99.
- UNLOCK ALL WAYPOINTS authorizes all six main stops without inventing kills or XP.
- RESET WAYPOINTS + ENCOUNTERS clears keycards, tower snapshots/floor loot, act completion and Wormhole, while retaining character, equipment, Silicon, supplies and garage-floor items. Resetting encounters ensures keycard carriers can be fought again. The button and adjacent text disclose this scope.
- Existing level/attribute/point/Silicon Apply remains unchanged. Debug APIs require the actual garage debug menu.

Open: potion tiers and animations, ground potion drops vs automatic recovery, final stack storage, portal cost/cast interruption/return safety, save persistence, future skill menu. These are not silently decided by the prototype.
