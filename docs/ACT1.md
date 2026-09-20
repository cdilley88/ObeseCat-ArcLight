> Current 0.13 additions and superseding route/Unique rules: [ObeseCat ArcLight](ARCLIGHT_ACT1.md).

# Act I: Ascent — Tech Demo 0.7

## Accepted user direction (2026-09-18)

Connected, large open areas with optional branches; increasing fixed difficulty and low-grade early loot. Revisiting early areas should demonstrate character growth. No dynamic scaling. Act I climbs a facility/corporate tower from an underground parking-garage hub toward a CEO office. Original PS1 Final Fantasy VII's Shinra building is a mood/structure reference, not copied geometry, assets or story. Elevator stops use keycards. User-suggested themes include shopping/lobby, maintenance/housekeeping, offices/labs, luxury dining/lounge and rooftop gardens/spa/pool.

## Implemented route — temporary names and layout

Garage Refuge → Lobby & Shopping → Maintenance & Housekeeping → Offices & Research → Restaurant & Lounge → Rooftop Gardens & Spa → CEO Suite.

- Lobby → Shuttered Concourse → Lobby.
- Maintenance → Utility Conduits → Maintenance.
- Research → Corrupted Archive → Research.

Six main combat floors, three optional annexes, one safe garage. Main floors are 34–46 by 30–38 world units; annexes 28–30 by 24–26, compared with the old 20 by 16 chamber. They use hand-authored open layouts and cover, not procedural generation or seamless streaming. The camera follows the player throughout the larger floors. South is entry/return, north is upward progression, east is the optional branch. Returns from upper floors and branches use matching doorways.

Each main floor has six security units and a supervisor; annexes have four units and a supervisor. Existing enemy models/behaviors are reused with fixed profiles. The CEO Suite's Executive Firewall is a placeholder encounter. It is not an approved CEO identity, ObeseCat encounter, or final story reveal. After defeating it, interact with CEO OFFICE to mark the prototype act complete.

Distinct prototype props/palettes: garage parking bays/pillars/stripes, shopping kiosks, maintenance pipes, research terminals, dining tables/chairs/plates, garden planters/pool, executive desks. The Archive reuses the warning-ring corruption hazard and displaced signal slabs. F reduces signal movement. These are blockout art and layout experiments, not final environments.

## Fixed area profiles

| Area | Tier | Regular / supervisor Life | Regular / supervisor XP | Highest random rarity |
| --- | --- | --- | --- | --- |
| Lobby | 1 | 34 / 105 | 12 / 40 | Green |
| Maintenance | 2 | 48 / 145 | 18 / 60 | Green |
| Research | 4 | 68 / 205 | 28 / 90 | Cyan |
| Dining | 6 | 92 / 280 | 38 / 120 | Violet |
| Gardens | 8 | 120 / 365 | 48 / 150 | Magenta |
| CEO Suite | 10 | 175 / 600 | 60 / 240 | Magenta |
| Concourse | 2 | 43 / 125 | 16 / 50 | Green |
| Conduits | 3 | 58 / 175 | 23 / 70 | Cyan |
| Archive | 5 | 80 / 245 | 32 / 110 | Violet |

Enemy health, damage, XP, Silicon and loot level derive from the area, never hero level. Regular Silicon = tier + 2; supervisor = tier × 3 + 9. Lobby clear gives 30 Silicon and 112 XP (level 2, 5 points from a fresh character). Regular damage increases 7/9/11/13/15/18 on the main route; supervisors add 3, before existing damage-type behavior. Exact values are temporary. Final campaign-length curves and violet-endgame balance remain unproven.

Regular kills have 30% equipment chance until two regular drops occur; supervisor now awards a two-item superchest. Three additional field containers may supply equipment. See REWARDS_AND_ELEMENTS.md for current 0.9 chest rates. Item level and rarity ceiling are fixed by area. Caps apply after the existing rarity roll: early high rolls collapse to Green rather than awarding endgame rarity. White bases remain fixed; colored affix budgets use the area's tier. Shops use highest recovered main-floor keycard tier, not player level.

## Travel, keycards and session state

Defeating a main-floor supervisor automatically records its keycard (no inventory cell). This authorizes that floor as an elevator destination and opens its upward stairs. You need not kill every remaining unit. Branches have no elevator/keycard and are optional. Garage is always an authorized destination. Physical elevators can return to already-authorized destinations even before the current floor's supervisor dies. Travel requires no living enemy within six units.

**V is a route screen, not remote teleportation.** Click a physical elevator (or approach and E) to enable Travel. Locked destinations are disabled. Stairs connect adjacent areas; no skipping forward without the current floor's keycard.

Enemy Life/positions/corpses, exact floor items/positions, drop budget and RNG state persist per visited area during the session. Revisits neither respawn enemies nor duplicate kill rewards. Combat status effects, windups and queued hits reset during transitions; enemy damage remains. Character items/stats/XP/Silicon/buyback persist. Stairs do not refill Life or Mana; reaching the garage does. Death allows T to recover there with no current penalty.

**NEW SORTIE**, available in the garage's V map or elevator menu, clears tower encounters and tower-floor loot, then refreshes shops. It retains the character, keycards, act completion and garage-floor items. Next entry rebuilds encounters at their original fixed strength. System reset reset everything; closing the game loses session state. This is not a disk-save system.

## Implementation and remaining questions

`tower.gd` owns data/geometry; `main.gd` owns state snapshots, route guards, dynamic navigation and camera follow; `hub_menu.gd` owns route/elevator UI. Floors use two MultiMesh checker batches to avoid thousands of tile nodes. The original chamber remains an isolated regression fixture, not part of the player route.

Open: floor density/size, more winding layouts and room clusters, navigation-map presentation, per-floor enemy families, boss mechanics, keycard acquisition alternatives, exact theme order, CEO identity, final names, persistent saves and difficulty/loot tuning. Do not infer approval for these from the blockout.

See STATUS for actual validation. First useful player questions: is upward progression readable; do floors feel different; are branches worth exploring; are elevators convenient; does returning with a stronger build feel satisfying?

## 0.8 supply and portal extension

Wormhole, dedicated potion stacks, vendor refills, debug waypoint controls and revised hotkeys are documented in [HUD_AND_SUPPLIES.md](HUD_AND_SUPPLIES.md). H repairs are superseded by Z/X potions; potion counts persist through travel and are not refilled by garage visits. Esc/System owns full resets.

## 0.9 additions

Container types/contents/open state now persist with each floor. Boss rewards are superchests. The six-element system replaces the earlier three-channel behavior; affinity content is still Cybernetic. REWARDS_AND_ELEMENTS.md owns those rules.


## 2026-09-19 — seed controls and encounter extension

[WORLD_SEEDS.md](WORLD_SEEDS.md) owns the 0.12 rules. DEV and Range Operator can apply/replay or randomize a seed, rebuilding generated field state while retaining the character and keycards. Fresh launches randomize; ordinary arena re-entry continues chest sequences. Enemy placements are now seeded inside validated regions; room geometry and fixed difficulty remain unchanged. Type pools and spawn regions are separate from layout, ready for future authored types/chunks.

