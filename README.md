# ObeseCat ArcLight

Project started September 17, 2026. **TECH DEMO 0.15 is implemented** in Godot 4.7.2 / GDScript for local Windows play. A game in the ObeseCat universe. Production scope remains open.

**0.15 Opening FMV & ArcLight Title Screen:** Authentic PS1-era opening sequence with the developer splash video ("IntegralTec Studios Presents", skip with any key/click), dedicated Title Screen showcasing original vector ArcLight insignia over a live 3D garage diorama with CRT scanlines, live Continue badge from disk save (`user://arclight_save.json`), New Sortie with overwrite guard, System Options (CRT/Audio toggles, Seed controls, replay FMV), Mission Intel & Credits, and clean desktop quit. In-game System menu (`Esc`) adds Save & Return to Title.

## Play Tech Demo 0.15

Double-click [ObeseCat-ArcLight-0.15.exe](builds/windows/ObeseCat-ArcLight-0.15.exe), or run `./run.ps1` from PowerShell. The standalone executable needs no Godot installation. Press any key or click to skip the developer splash, then select **CONTINUE SORTIE** (or **NEW SORTIE**). Click NPCs to trade or use DEV / DEBUG. Take the Lobby stairs to start climbing. **V** opens the tower route; physical elevators travel to keycard-authorized stops. Defeat floor supervisors to unlock the way up to ObeseCat on floor 19. Three optional side areas branch from the main route.

Click to move/attack; WASD also moves; Space attacks nearby enemies. **I** opens gear, **C** stats, **E** interacts/collects, **Z / X** use Life/Mana potions, **B** opens a Wormhole, **Q** empowers the next hit for 10 Mana, and wheel zooms. **T** recovers to the garage after defeat. **Esc** opens System, including manual Save/Load and confirmed character/disk-save reset. To replay with your character intact, choose **NEW SORTIE** from the garage map/elevator. This repopulates floors and clears tower-floor loot while retaining keycards. Progress auto-saves to disk.

Read [the playtest guide](docs/PLAYTEST.md) for the Circuit recipe, what to try, and validation limits. `./run.ps1 -Editor` opens the project; `./run.ps1 -Test` runs the rules checks. `./build-windows.ps1` rebuilds the standalone executable.

**Act I:** Garage Refuge → Lobby/Concourse 1–3 → Maintenance & Housekeeping 4–6 → Research Lab 7–9 → Restaurant & Lounge 10–12 → Rooftop Gardens 13–15 → Penthouse 16–18 → ObeseCat 19. Six elevator destinations, seeded layout patterns, three optional branches and fixed floor difficulty. See [ArcLight Act I](docs/ARCLIGHT_ACT1.md) for the ChefBot quest, Unique hat and provisional rules.

**Vendor grids:** Shop and buyback parts now use illustrated spatial trays; the sell side shows your backpack layout. Hover for a card and price, select, then Buy/Sell.

**Garage refuge:** Weapon/armor vendors, Silicon, exact-item buyback, DEV / DEBUG, and future broker/style roles and Dispatch quests remain. Parking stripes, concrete pillars, service bays and lights replace the plaza. See [Hub and Silicon](docs/HUB.md).

**Inventory presentation:** Hover backpack or worn parts for illustrated item cards with damage/defense totals and concise bonuses. The inventory fitting bay shows your equipped character, updates immediately, and rotates with the arrow buttons. Full stats remain under C.

**Cybernetic salvage:** Eight equipment slots, light/heavy weapons, four locomotion forms, five randomized rarity tiers plus authored Unique gear, and six elemental damage/resistance channels. 45 randomized bases exist across Cybernetic, Draconic and Visceral; start with only a white Phase blade. Enemy drops are bounded; supervisors now award superchests, and field containers add supplies/gear.

**Inventory:** I opens a 12 x 8 backpack with illustrated items, varied rectangular footprints, drag-and-drop, separate worn slots, auto-pack, and recoverable dropping. Full-backpack loot stays on the ground.

**HUD and supplies:** Original menu icons carry hotkey badges. Potion counters beside the orbs cap at 99. Vendors sell refills; DEV maxes supplies and unlocks/resets waypoints. Wormholes allow a town trip and return to the cast location. [Rules and temporary choices](docs/HUD_AND_SUPPLIES.md).

**0.9 rewards and elements:** Progressive rarity glows, four container classes, boss superchests and a three-page character sheet. DEV can grant a test kit of all elements/rarities. [Current rules and affinity scope](docs/REWARDS_AND_ELEMENTS.md).

**0.10 weapons and test range:** DEV / DEBUG → ENTER DEBUG ARENA. The range operator grants weapon samples, spawns stationary/chasing/attacking targets, and clears/resets the room. Five endlessly restocking chest tiers test loot. Try blade swipes, the wide Phase cleaver and the missile launcher. [Rules and playtest limits](docs/WEAPONS_AND_ARENA.md).

**0.11 cybernetic salvage:** Space-style Survey helmet, Combat helmet rename, alternate amulets, Bracing/Mesh/Suit/Padding, Cyber Harness rename and all four locomotion drops. Rarity-weighted expanded bonuses include working discovery, regeneration, affinity modifiers and weapon geometry. C → Modifiers shows totals. Range Operator → Give Cybernetic Base Samples grants all wearable variants. [Rules and provisional balance](docs/SALVAGE_EXPANSION.md).

**0.12 world seeds:** Fresh seed each launch. DEV and Range Operator now offer editable WORLD SEED, Apply Seed and Randomize. Arena chests continue their rolls across re-entry; seeds drive independent chest/enemy loot and navigable enemy placements. Applying a seed clears generated field state but retains your character and keycards. [Generation rules and future floor extension](docs/WORLD_SEEDS.md).

## The idea

A deliberate, atmospheric action RPG inspired by the pacing and visual era of Diablo 1, with deep equipment decisions inspired by Diablo 2. A climb into glitched corruption through an Act I corporate tower in an alternate Cold War setting, with the user's 1990s Westwood Red Alert tonal reference: underlying comedy and brutally serious material. Four-legged pet heroes wear visible equipment that changes their appearance. Nuclear imagery, ITS colors, and CRT / late-1990s-to-2000s signal distortion establish the visual direction. ObeseCat is the proposed central antagonist and final boss.

The user approved Godot/GDScript, orthographic 3D, Windows first, and a `prototype/` subfolder for TECH DEMO 0.1. This is a playable laboratory, not full production. Temporary content and numbers are experiments, not final-game decisions.

## Start here

- [Act I route and fixed tiers](docs/ACT1.md): areas, branches, keycards, revisits and replay.
- [Direction and world](docs/CONCEPT.md): user brief, proposed identity, atmosphere, and campaign shape.
- [Loot and builds](docs/ITEMIZATION.md): equipment, rarity, socketables, recipes, and balance principles.
- [Decisions and open questions](docs/DECISIONS.md): distinguish user direction from proposals and unresolved choices.
- [Current state and next session](docs/STATUS.md): concise handoff, immediate next step, and evidence.
- [Tech Demo 0.1 plan](docs/TECH_DEMO_0_1.md): requested scope, proposed implementation, and playable acceptance checks.
- [Hub and Silicon](docs/HUB.md): contacts, trading, run travel, debug controls, and temporary economy.
- [Spatial inventory](docs/INVENTORY.md): grid size, original item art, controls, and safe placement rules.
- [Character progression](docs/PROGRESSION.md): XP, attributes, Life/Mana, and temporary formulas.
- [Playtest guide](docs/PLAYTEST.md): controls, experiment instructions, results, and current limitations.

## Implementation map

- `prototype/scripts/tower.gd`: authored area graph, fixed profiles, loot tiers and floor geometry.
- `prototype/scripts/hub.gd`, `hub_menu.gd`, `economy.gd`: town, contacts, trading UI, Silicon prices and stock.
- `prototype/scripts/main.gd`: room, movement/navigation, combat, drops, corruption, replay, and sound cues.
- `prototype/scripts/models.gd`: original placeholder pet, equipment, enemies, and environment geometry.
- `prototype/scripts/loot.gd`: small item dataset, random rolls, socket recipe, and derived stats.
- `prototype/scripts/backpack.gd`: spatial rules; `inventory_grid.gd`, `inventory_tile.gd`, and `equipment_slot.gd`: item interaction.
- `prototype/assets/items/`: 18 original cybernetic-part illustrations.
- `prototype/scripts/hud.gd`: UI, sockets, and controls; `item_card.gd`: concise hover cards; `character_preview.gd`: isolated live fitting-bay scene.
- `prototype/tests/`: rule tests, real-frame playthrough, and rendered captures. Export excludes these scripts.
- `artifacts/`: local test logs and screenshots; `builds/windows/`: generated standalone executable. Both are ignored by Git if initialized later.

Godot engine discovery defaults to the existing temporary portable installation, with `-Godot` available to override it. The export script caches a copy of an existing Godot 4.7.2 **x86_32** Windows release template under ignored `.godot/`; `-Template` overrides its source. The current executable is 32-bit; this is a packaging expedient, not a production architecture decision. No sibling project files are modified.

## How these notes work

Keep this README short: it is the index, not a transcript. Each topic has one authoritative document. Label ideas **User direction**, **Proposal**, or **Open**. When a choice is accepted, record the date and rationale in DECISIONS, update its topic document, and remove contradictory current guidance. Preserve superseded decisions in the decision log only when their rationale is useful.

At the end of a meaningful session, update STATUS with what changed, what remains undecided, and the next concrete step. Record actual test evidence when code exists; distinguish builds from interactive playtests. Never treat an assistant suggestion or silence as approval.

Project location: `G:\New folder`. A later rename can follow the chosen title. These files are project documentation, not edits to global assistant memory.




**Browser release:** [Play ObeseCat ArcLight](https://integraltec.ai/games/corruption-laboratory/). The original route remains stable after the rename. Use keyboard and mouse. Closing/reloading resets progress.
