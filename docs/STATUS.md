# Current state

Updated 2026-09-19. **TECH DEMO 0.14: Draconic and Visceral equipment.**

13 Draconic and 6 Visceral bases have inventory art, worn models and standard randomized itemization. Enemy affinity weighting and neutral chest pools are centralized. New characters start with only a white Phase blade. See AFFINITY_ITEMS.md for exact rules, temporary choices and playtest instructions.

## Historical 0.13 increment

Updated 2026-09-19. **TECH DEMO 0.13: ObeseCat ArcLight / 19-floor Act I.**

Play `builds/windows/ObeseCat-ArcLight-0.13.exe`. Six three-floor areas lead to ObeseCat on 19. Seeded layout patterns, weapon sentries, Dispatch's floor-10 quest, ChefBot on floor 12 and the fixed Unique ChefBot Hat are implemented. See ARCLIGHT_ACT1.md for accepted direction, temporary rules and limitations. The proposed Act II wasteland is not implemented; no disk saves.

Validation: rule suites, native quest/equipment rendering and ordinary Lobby combat. Full-act balance remains a player test. Evidence: artifacts/tests-0.13.log, arclight-gui-0.13.log, playthrough-0.13.log and captures 110–114.

## Historical 0.12 increment
Updated 2026-09-19. **TECH DEMO 0.12: world seed controls and seeded encounters.**

Play `builds/windows/CorruptionLab-0.12.exe`. Fresh launch seeds, DEV/Range Operator Apply Seed and Randomize, continued arena chest sequences, independent loot/combat/placement streams, and reachable seeded campaign spawn positions are implemented. See WORLD_SEEDS.md for exact reset/preservation semantics and future room/type extension points. Current floor geometry is unchanged.

Validation: 2,575 rule assertions, including 566 new seed/placement checks; three native seed-button checks; seeded Lobby combat regression passed (104.7 Life, level 2, 22 items, 117 Silicon). Logs: `artifacts/tests-0.12.log`, `seed-gui-0.12.log`, `playthrough-0.12.log`; screenshots 100–101. No disk saves or new enemy roster/room generator; full-act balance remains player-testing work.

## Historical 0.11 increment

Updated 2026-09-19. **TECH DEMO 0.11: cybernetic bases and weighted modifiers.**

Play `builds/windows/CorruptionLab-0.11.exe`. 26 bases now include Survey space helmet, two alternate amulets and four new barding designs. All four locomotion forms are verified in drops. Arena operator provides a wearable base sampler. Expanded weighted affixes are active, including Item/Silicon Discovery, regeneration, elemental/affinity modifiers and weapon geometry; C → Modifiers shows totals. SALVAGE_EXPANSION.md owns accepted direction and temporary formulas. Starter inventory remains 18 parts.

Validation: 2,009 rule assertions passed (498 core, 52 hub, 954 tower, 37 supplies, 327 rewards, 35 arena, 106 expanded salvage); three native UI checks passed, including the sampler button. Visually reviewed inventory/Survey-Mesh-Spider preview, all six barding models and modifier page; fixed an unsupported SVG Mesh pattern. Ordinary Lobby combat passed at 86.53 Life, level 2, 21 items, 110 Silicon. Evidence: `artifacts/tests-0.11.log`, `salvage-gui-0.11.log`, `playthrough-0.11.log`, captures 90–92. No disk saves; final balance and player feel remain unverified.

## Historical 0.10 increment

Updated 2026-09-18. **TECH DEMO 0.10: weapon attacks and debug arena.**

Play `builds/windows/CorruptionLab-0.10.exe`. DEV / DEBUG → ENTER DEBUG ARENA → RANGE OPERATOR → GIVE FOUR WEAPON SAMPLES. Phase blade swipes, Phase cleaver sweeps, launcher missiles travel/smoke/explode. Five repeatable chest tiers, three target behaviors, clear/reset, and Garage return are implemented. CEO reward is now a gold tier-5 hoard. See WEAPONS_AND_ARENA.md for accepted direction, provisional formulas, reward isolation and remaining limits.

Validation: 1,847 rules passed; three native UI/animation checks passed; Lobby combat regression passed at 86.53 Life, level 2, 21 items, 110 Silicon. Logs: `artifacts/tests-0.10.log`, `arena-gui-0.10.log`, `playthrough-0.10.log`; screenshots 80–84. User play feel and full-act balance remain unverified. No disk saves.

## Historical 0.9 increment

Updated 2026-09-18. **TECH DEMO 0.9: rarity halos, loot containers and six-element foundation.**

## Current increment

REWARDS_AND_ELEMENTS.md owns the new accepted direction, temporary formulas and remaining content scope. Implemented progressive rarity edge glows, animated Magenta halos, three seeded field containers per area, boss superchests, persistent opened state and payouts, six damage/resistance channels, paged character sheet and affinity metadata. Gravity replaces Vacuum. Actual Visceral/Draconic creatures and visibly organic/dragon parts are still future work; existing content is Cybernetic.

Play `builds/windows/CorruptionLab-0.9.exe`. DEV / DEBUG now grants six element weapons and five rarity samples for immediate comparisons. Field containers open by click/E; supervisor reward is a superchest. Existing vendors, Wormhole, potions, tower persistence and fixed difficulty remain.

Validation: **1,804 rules passed** (434 core, 52 hub, 954 tower, 37 supplies, 327 reward/element); **seven native GUI checks passed**, including tab layout, rarity card, test-kit button and superchest opening. Logs: `artifacts/tests-0.9.log`, `artifacts/rewards-gui-0.9.log`. Captures 70–74 show all three pages/effects/containers. Ordinary Lobby combat cleared at 86.53 Life, level 2, with 21 items after boss chest pickup (`artifacts/playthrough-0.9.log`). Payouts remain fixed-area; full-act balance and user feel are unverified. Windows 0.9 export and standalone startup passed; build hash/evidence is in `artifacts/BUILD-RECORD-0.9.txt`.

Next useful feedback: glow intensity/readability; loot and supply volume; whether the six elements are distinguishable; which Visceral or Draconic parts to author first. No disk saves. No final family bonus rules, new class/skill system, organic/dragon models or campaign-story commitment.

The following prior increment notes are historical evidence for retained systems, superseded by the 0.9 rules above where they conflict.

## Vendor presentation update

Weapon/armor vendor and buyback text lists are replaced by illustrated item-footprint grids. Merchant tray pages unlimited buyback entries; sell side preserves actual backpack coordinates. Hover previews existing cards with Silicon prices; click selects and explicit Buy/Sell transacts. Original SVG art, rarity borders and amber highlights preserve the project's visual identity. No economy or ownership-rule changes. HUB.md owns details.

Validation: all 1,450 rule checks passed (`artifacts/tests-vendor-grid.log`). Native vendor grid tests passed for bounds, hover without mutation, exact sale/buyback, armor purchase, complete paged history and page navigation (`artifacts/vendor-grid-gui.log`). Captures: `60-weapon-exchange.png` through `63-buyback-pages.png`. Earlier evidence below is historical for retained systems.

## Latest increment

HUD_AND_SUPPLIES.md owns the new rules. Original icons with C/I/V/B/Esc badges replace header buttons and tutorial footer. Life/Mana bottles near the orbs show counts /99; Z/X consume, vendors refill, enemies recover supplies. Wormhole B creates a field portal; click/E visits the garage; town B/return portal returns to its exact origin. DEV adds potion max, all-waypoint unlock and waypoint/encounter reset. Full reset is confirmed in System; H and direct R/N actions are superseded. All exact recovery, cost and portal rules are temporary.

Current validation: 1,450 rule checks pass (434 core, 52 hub, 927 tower, 37 supplies/portal). Includes hotkey dispatch, full/empty/dead/paused potion guards, caps, price checks, debug authorization, portal replacement/round trip and stale-state invalidation. 14 native GUI checks also passed, covering both potion buttons, menu switching, all three debug actions, vendor purchase/layout and Wormhole round trip (`artifacts/supplies-gui-0.8.log`). A GUI harness timing issue after rebuilding the debug controls was resolved by allowing the layout/input frame to settle before clicking the next contact. Lobby ordinary-combat regression passed: 94 Life, level 2, 19 items, 110 Silicon after return (`artifacts/playthrough-0.8.log`). Windows 0.8 export and standalone startup smoke passed, exit 0; hash and validation record are in `artifacts/BUILD-RECORD-0.8.txt`. Earlier 0.7 evidence below remains historical.

## Accepted direction and temporary choices

Act I climbs from a parking-garage refuge through connected open themed sections to a CEO office. Optional branches, fixed increasing enemy/loot tiers, weak early revisits and keycard elevator stops are accepted user direction. ACT1.md is the authoritative route/rules document. Names, layout sizes, order, encounter counts, stat/reward curves and the Executive Firewall are temporary prototype choices. No CEO/ObeseCat story identity has been assigned.

## Current loop

`builds/windows/CorruptionLab-0.8.1.exe`, or `./run.ps1`. Enter starts in Garage Refuge. Existing six contacts, Silicon, vendors/buyback and DEV / DEBUG remain. Lobby stairs begin the climb; V opens the route map; a physical elevator enables travel.

- Main route: Lobby → Maintenance → Research → Restaurant → Gardens/Spa → CEO Suite. Six larger authored floors, plus Concourse, Conduits and Archive branches.
- Supervisors grant their floor's keycard and upward access. Main-floor enemies/loot use fixed tiers 1/2/4/6/8/10, never hero level. Annexes use tiers 2/3/5.
- Distinct blockout palettes/props include kiosks, pipes, terminals, dining tables, pool/planters, executive desks. Archive has a live warned corruption pulse. Camera/navigation accommodate bigger spaces; floor tiles use MultiMesh batches.
- Floor Life/positions/corpses, exact loot and drop budgets persist across visits. No duplicate rewards on restored corpses. Character/build/currency/buyback persist too. Garage refills resources; stairs do not. Combat statuses/queued hits reset on transitions.
- NEW SORTIE in garage map/elevator resets tower encounters/loot, retains character/keycards/garage-floor drops. T recovers after death. Esc/System resets character and tower. No disk saves.
- One to three equipment drops per area. Early Green ceilings prevent high-level characters farming endgame items in the Lobby. Shops use recovered keycard progress. All 18 white experiment bases remain in the starter kit.

## Verification

- **1,413 rule assertions passed:** 434 core, 52 hub/economy, 927 tower (`artifacts/tests-0.7.log`). Tower coverage includes every spawn/exit navigation endpoint, fixed profiles and rarity ceilings, level-99 early revisit, forward locks, read-only map, elevator locks, corpse/damage/item persistence, duplicate rewards, resource retention, new-sortie behavior, full connected route, Archive hazard and CEO terminal gate.
- **Six native tower GUI checks passed** (`artifacts/tower-gui-0.7.log`): garage elevator click/navigation, map bounds, Lobby stairs, floor elevator and enabled Travel to garage. Native screenshots cover all nine areas plus garage/map. Captures include deliberate positioning; they are visual QA, not normal-play completions.
- **Lobby automated combat passed** (`artifacts/playthrough-0.7.log`), ordinary attacks/movement/pickups without stat overrides, existing cannon/Circuit white test kit: all seven enemies defeated, 94 Life remaining, 19 total items, level 2 / 5 points / 62 XP. Return gives 110 Silicon including initial 80. Fixed physics 60 FPS, accelerated headless execution. Full tower rule traversal uses test-only damage and is not a whole-act balance proof.
- **14 native garage regression checks passed** (`artifacts/hub-gui-0.7.log`): vendors, sell/buyback, debug Apply, armor purchase, all reserved contacts, Lobby entry and death recovery.
- **Windows 0.7 export and standalone headless smoke passed, exit 0** (`artifacts/export-0.7.log`, `artifacts/release-0.7-smoke.log`). SHA-256 recorded in `artifacts/BUILD-RECORD-0.7.txt`. Existing 32-bit release template retained. Sandbox Godot reports its pre-existing root-certificate-store warning; this offline prototype makes no network request.

## What to learn next

User playtest: route readability, scale/empty space, floor-theme distinction, branch value, elevator convenience and early-area power comparison. Then tune layout density and enemy variety based on play, rather than invent more production systems. This is a connected blockout, not final-sized Diablo-style zones or a balanced campaign.

Remaining: no disk save, no per-floor enemy families/new boss mechanics, no quest chains, no other acts, no gambling/cosmetic economy. Stat/level equipment requirements remain proposals in ITEMIZATION. Final names, CEO identity and corruption lore remain open. Existing hub and equipment systems are retained.

## Implementation handoff

`tower.gd`: authored graph/profile/loot/geometry. `main.gd`: zone snapshots, guarded travel, keycards, navigation/camera, combat/rewards. `hub.gd`: garage. `hub_menu.gd`: vendors/debug plus route/elevator UI. `run.ps1 -Test`: all three rule suites. Original chamber stays as a legacy core-test fixture, not the normal route. No version control repository has been initialized in this folder.


0.13 release validation: all 4,884 rule checks passed; Windows and Web exports passed; standalone Windows startup exited 0. Native quest/equipment checks and Lobby playthrough passed.

Published 0.13 to integraltec.ai; deploy 6aaf22ce0ac52196beaff4de. Live package SHA256 matches local export (artifacts/live-verification-0.13.txt). Browser launch and inventory/fitting bay verified. Portfolio retains the supplied screenshot and original stable game URL under the new title.

0.14 validation: all 5,301 rule checks passed. Native equipment swaps/model previews and DEV sample-row layout reviewed (captures 120–122). Fresh Phase-blade starter cleared Lobby at 72.11 Life, level 2, 5 items, 119 Silicon. Windows/Web exports complete; full-act balance remains a player test.

0.14 published via Netlify deploy 6aaf588596f1428ba1d586bd. Live package SHA256 matches local build; browser startup and empty backpack / sole equipped white Phase blade verified. Windows standalone startup exited 0. Logs: tests-0.14-final.log, playthrough-0.14.log, live-verification-0.14.txt.
