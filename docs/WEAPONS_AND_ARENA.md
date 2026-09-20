# Weapons and debug arena — Tech Demo 0.10

## Accepted user direction

Keep Laser carbine as one-handed ranged and retain alternating dual wielding. Phase blade becomes quick, short-range melee. Add a slow two-handed missile launcher attack with smoke, explosion and high damage, plus a slow, wide two-handed Phase cleaver. Town DEV provides access to a separate arena with an enemy-spawning NPC, clear/reset controls and endlessly restocking tier 1–5 chests. Chest size, ornament and white/cyan/violet/magenta/gold effects increase with tier; tier 5 is an act-boss hoard.

## Implemented

- Phase blade: 2.3-unit reach, 80-degree swipe, 0.58-second cadence; equipped blade swings and a brief trace shows its arc.
- Phase cleaver: 3.2-unit reach, 149-degree sweep, 1.45-second cadence, 38 base damage; hits multiple forward targets, occupies both hands, original equipment model and inventory icon.
- Reactor launcher: 42 base damage, 1.85-second cadence, 0.58-second windup; missile travels at 8 units/second to the launch-time target position, leaves smoke and explodes in a 2.1-unit radius. Enemies can move out before impact. Damage occurs on impact, not launch.
- Existing Collapse cannon retained. Laser carbine and alternating dual wield remain. Existing elemental resistance/status rules apply to all attacks. Cleaver is available from normal randomized salvage/vendors and the arena kit; the original 18-item starter loadout is preserved for backpack space.
- DEV / DEBUG → ENTER DEBUG ARENA. RANGE OPERATOR spawns stationary, chase-only or normal chasing/attacking targets, grants four white weapon samples, clears enemies/floor loot/effects, resets the room and refills Life/Mana, or returns to Garage.
- Arena targets have 500 Life, no resistance/dodge, and no kill XP, Silicon, potion, loot or keycard reward. Maximum 12 targets, including corpses until cleared. Chest rewards and granted gear remain yours on leaving. Overflow stays on the floor. Clear/reset explicitly removes arena floor items. Arena contents reset on entry; campaign floor snapshots and keycards remain intact.
- Five repeatable containers: white lockbox; cyan case; violet salvage chest; magenta superchest; gold act-boss hoard. A half-second debounce prevents double input; each use generates fresh rewards. Open lids stay open with RESTOCKED text. Upper tiers have animated halo rings when FX is enabled. Compatibility-renderer glow is layered geometry, not postprocessing bloom.
- Arena chest rolls use fixed level 10 / rarity cap 4. Hoards give three Violet/Magenta pieces (35% Magenta per piece). Superchests give two pieces; cases/chests one; lockboxes supplies/currency. Other containers retain existing probability budgets. Campaign CEO now awards tier 5; other supervisors retain tier 4, with area caps intact. Gold denotes a container, not a new equipment rarity.

## Temporary prototype choices / open questions

All numbers, target durability, spawn positions, angular hit tests and reward probabilities are playtest values. Arena has no obstacle course yet. Melee checks range/angle/line of sight on resolution; animation is illustrative, not per-frame blade collision. Launcher explosion gives full damage throughout radius. No decision about final weapon taxonomy, skill classes, authored uniques, save files or act bosses was made.

## Verification

1,847 rule assertions passed: 442 core, 52 hub, 954 tower, 37 supplies, 327 rewards, 35 arena/weapons. Arena tests cover repeat/restock, double-input guard, high-tier rewards, behavior modes, forward-only cleave, delayed missile damage, reward isolation, clear/reset and return. Native UI harness passed three checks: DEV entry, operator spawn and equipped cleaver movement. Captures 80–84 show menu bounds, all chests, smoke and swing. Ordinary Lobby playthrough still clears at 86.53 Life, level 2, 21 items, returning with 110 Silicon. Player acceptance and full-act balance remain unverified.


## 2026-09-19 — seed controls and encounter extension

[WORLD_SEEDS.md](WORLD_SEEDS.md) owns the 0.12 rules. DEV and Range Operator can apply/replay or randomize a seed, rebuilding generated field state while retaining the character and keycards. Fresh launches randomize; ordinary arena re-entry continues chest sequences. Enemy placements are now seeded inside validated regions; room geometry and fixed difficulty remain unchanged. Type pools and spawn regions are separate from layout, ready for future authored types/chunks.
