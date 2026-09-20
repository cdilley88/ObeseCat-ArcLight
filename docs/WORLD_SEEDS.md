# World seeds and encounter generation — Tech Demo 0.12

## Accepted user direction — 2026-09-19

Fix identical test-range chest sequences on reload. Provide developer seed randomization/reset; seeds must influence chest contents, enemy drops and enemy placements. Leave an extension path for many enemy types and more complex floors. No request to implement a full procedural dungeon or new enemy roster in this increment.

## Implemented

- Every application launch chooses a fresh world seed from system entropy, in 1–2147483646. Seeded rule/UI fixtures explicitly pin their seed for repeatable tests.
- Town DEV and the Range Operator show the current WORLD SEED, an editable integer, APPLY SEED and RANDOMIZE. Applying the same seed restarts its generation sequence; Randomize guarantees a different seed.
- Applying a seed clears generated tower snapshots/floor loot, Wormhole, arena contents/open counters, visited-area records and the act-complete flag; resets sortie index; rebuilds the current safe hub or arena; regenerates vendor stock. Character level/stats, carried/equipped items, Silicon, potions, buyback, Garage floor items and unlocked keycards remain. Field loot must be collected before resetting. This explicit developer operation does not silently reset the character.
- Arena chest opening counters are kept on the game session, one per tier, so ordinary arena exit/re-entry or range reset continues the sequence instead of repeating its first rewards. Explicit seed application resets these counters. Separate launches have different seeds. No disk persistence yet.
- `world_random.gd` derives versioned independent streams from world seed, sortie, area, purpose and encounter/opening index. Combat RNG is separate from enemy loot, chest contents and placements. Combat draw count no longer shifts a future enemy reward. Existing loot-count limits, discovery effects, full affix/base pools and fixed area rarity caps remain.
- Normal enemy reward chance and rolled equipment use an enemy-specific stream. Boss and field chests use separate streams; campaign chest contents/opened state remain persistent on normal revisits. A seed does not guarantee every base appears in a short sample; every eligible base and modifier remains in the distribution. Low floors still exclude high rarity tiers.
- Campaign enemies now spawn at seeded, navigation-checked positions inside encounter regions. Arrival/exit clearance and inter-enemy spacing are checked. Current encounter counts and fixed-area power remain unchanged. Test-range manually spawned behavior targets keep predictable test positions.

## Extension path / temporary choices

`encounters.gd` separates a type registry, per-region pools, encounter regions and a seeded planner with an injected walkability/reachability predicate. Registry entries drive existing model family, affinity and behavior. The two current types are security and supervisor; adding genuinely new models/AI still requires authored content and their implementations.

Future room/chunk layouts can supply their own region descriptors and navigation predicate; encounter planning and loot streams need not know whether the floor is rectangular. Current authored floor geometry, cover layout, exits and chest locations are unchanged. Room graphs, corridors, branching layouts and procedural architecture remain future work. Region sizes/anchors, spacing, seed range and stream version are provisional. Bump generation version for intentional incompatible generation changes; exact replay is for this build and identical discovery/sortie/opening inputs, not promised across future versions.

## Verification

New seed tests cover permission scope/invalid input, preserved carried gear/currency/keycards, arena re-entry sequence continuation, exact replay and changed-seed chest content, combat/loot stream isolation, changed enemy loot, clearing stale world state, and repeatable/reachable/registered enemy plans across nine areas and four seeds. Existing persistence, ownership, rarity and discovery regressions remain in the full suite. Native UI tests click town Randomize, apply a chosen seed, and randomize from the range. Screenshots 100–101 show both menus. Ordinary seeded Lobby combat clears at 104.7 Life, level 2, 22 items, 117 Silicon after return. These are automated checks, not final encounter balance or player acceptance.
