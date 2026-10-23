> Current 0.13 additions and superseding route/Unique rules: [ObeseCat ArcLight](ARCLIGHT_ACT1.md).

# Playtest — Tech Demo 0.16

Run `builds/windows/ObeseCat-ArcLight-0.15.exe`, or `./run.ps1`.
- **Opening Developer Splash:** Authentic 90s-era "IntegralTec Studios Presents" FMV intro. Press any key (`Space`, `Enter`, `Escape`) or mouse click anywhere to skip directly to the Title Screen.
- **ArcLight Title Screen:** Displays the original high-resolution ArcLight hero insignia over a live 3D garage diorama. Select **CONTINUE GAME** or **NEW GAME**. Use **OPTIONS** for CRT/Audio toggles, seed adjustments, save file management/deletion, or the new **CUSTOMIZE KEYBOARD CONTROLS** modal.
- **Diablo-Style Combat Rhythm:**
  - **Left-Click:** Move or physical attack with equipped weapon.
  - **Right-Click:** Cast your currently assigned active skill at mouse target.
  - **Hotbar Evolution:** Symmetrical Left-Click Weapon Slot (`L-CLK`) and Right-Click Skill Slot (`R-CLK`) flank the bottom console. Live cooldowns, active color borders, and tooltips are displayed. Clicking them opens Inventory (`[I]`) and Skill Matrix (`[K]`).
- **Skill Matrix & Progression (`[K]`):**
  - Earn **1 Skill Point per Level Up**.
  - Spend points to unlock or rank up 4 core archetypes: **Directed Projectile** (Tier 1), **Point-Blank Nova** (Tier 2), **Ground Hazard** (Tier 3), and **Tactical Overdrive** (Tier 4).
  - Assign any unlocked spell to Right-Click via `[ ASSIGN TO R-CLICK ]`.
  - **Affinity Synergy & Resonance:** Your equipped gear dictates spell element and behavior (Plasma/Shock for Cybernetic, Acid/Tendrils for Visceral, Fire/Breath for Draconic). Equipping 4+ matching affinity pieces triggers **Affinity Resonance** (+25% damage, -20% mana cost, bonus procs).
- **Keyboard Customization:** Remap any of the 14 actions in the in-game System Menu (`Esc` → `CUSTOMIZE KEYBOARD CONTROLS...`) or from Title Screen Options. Settings persist to `user://settings.json`.
- **Persistent Saves:** Auto-saves upon floor transitions, garage visits, point allocations, or quitting. Manual Save/Load in System menu (`Esc`).

- Click / WASD: move. Click an enemy: approach to weapon range and attack. Hold Space: attack nearby targets. Wheel: zoom.
- I / Tab: paused inventory. Hover bag/worn parts for item cards. Fitting-bay arrows rotate your live equipment preview. Drag items to rearrange or equip; right-click/double-click equips or unequips. Drag light weapons onto LEFT or RIGHT. Heavy weapons occupy both.
- C: character attributes and resistances. Five spendable points per level.
- Q: arm/cancel next-hit empowerment, costing 10 Mana on a connected hit. Z: Life potion. X: Mana potion. Each stack caps at 99; vendors sell refills.
- E: interact with a nearby contact or collect salvage. Click salvage: collect. Full backpack leaves salvage on the ground. AUTO-PACK can resolve fragmentation; DROP SELECTED leaves the item recoverable.
- V: tower route. Physical elevators enable travel to unlocked stops. T: recover to garage after defeat. Esc/System: manual save/load and confirmed character/disk-save reset. Esc: pause/close panels. F: reduced effects. M: sound.

## Try rarity, containers and elements (0.9)

1. DEV / DEBUG → GIVE ELEMENT / RARITY TEST KIT. Hover the five graded amulets in I and compare glow intensity. FX LOW stops animation. Try them equipped and in the vendor sell tray.
2. C → Attributes, Elements, Affinities. Inspect all six resistances. Current gear is Cybernetic; organic and Draconic equipment are future content, not active bonuses.
3. Enter a floor and click/E a container. Lockboxes supply Silicon/potions; cases and chests drop equipment. Defeat a supervisor and open its glowing superchest.
4. Use a Wormhole and revisit: the container should stay open and its uncollected equipment remain. NEW SORTIE resets containers.
5. Equip each test carbine. Observe Heat burn, Cryogenic slow/freeze, Electromagnetic variation, spreading Radiation, capped percentage Gravity and Corruption weakening. Exact formulas remain provisional.

## Try the new HUD and Wormhole

1. Use the bottom icons or C/I/V/Esc. Hover an icon for its label. The control reference is in System, not across the main HUD.
2. Take damage or spend Mana, then use Z/X or click the corresponding bottle. Counts should fall once; full resources consume nothing. Visit either vendor for refills.
3. Press B on a floor, then click the Wormhole or press E to visit town. Use the town return portal or B to resume at your original location. Defeated enemies and floor loot stay as you left them.
4. Visit DEV / DEBUG: max both potion stacks, unlock all six waypoints, or reset waypoints plus tower encounters. The latter clears tower-floor loot and Wormhole but keeps your build.

## Try the tower climb

1. In the garage, visit vendors or DEV / DEBUG as before. Open V to see the route. The garage elevator initially has no combat destinations unlocked; use the Lobby stairs.
2. Explore the Lobby and optional east-door Concourse. Main upward exits are on the north side. Defeat the Lobby supervisor for its keycard, then take the Maintenance stairs or return to the south-side elevator.
3. Follow Maintenance → Research → Restaurant → Gardens → CEO Suite. Try the Conduits and Archive branches. The Archive's magenta ring warns before a corruption pulse. After the Executive Firewall, interact with CEO OFFICE.
4. Use a physical elevator to return to the garage or an authorized floor. V by itself cannot teleport. Trading and recovery remain available in the garage.
5. Revisit a partly cleared floor: corpses, remaining enemy damage and floor loot should remain. Collect, sell, and upgrade. There is no automatic respawn on entry.
6. From the garage's map/elevator choose **NEW SORTIE** to repopulate the tower and clear its floor loot while keeping your build and keycards. Revisit the Lobby with stronger gear/stats: its enemies and item tiers stay weak. System reset instead resets everything.

For a quick progression comparison, use DEV / DEBUG to increase Strength/Vitality, start a new sortie and return to the same early floor. These are deliberate test overrides, not rewards. Shops use keycard progress rather than debug character level.

Weapon/armor shops still support selling and exact-item buyback. Worn gear must be unequipped before sale. Full-bag/no-funds purchases should not charge you. Stock refreshes on garage-to-Lobby entry/new sortie. Dispatch gives route directions; Broker/Style are reserved future systems.

## Retained equipment experiments

1. Open I. Hover an item for its graphic, damage/defense total, and concise bonuses. Equip different parts and rotate the fitting-bay model; C remains the separate full stat sheet. All 18 bases are supplied as white parts, seven worn and eleven in the bag. Compare the helmet, amulet, armor, harness and matrix silhouettes.
2. Drag Phase blade to RIGHT to pair it with the left Laser carbine. Attacks alternate; the blade needs close range.
3. Equip Collapse cannon or Reactor launcher. Both light weapons must fit back into the bag. The cannon has capped percentage-of-Life Gravity damage; the launcher has Radiation splash and burn. Heavies wind up and fire more slowly.
4. Swap Paw servos for treads, spider struts, or hover gear. Zoom in and move to inspect the undercarriage. Treads trade speed for reduction, spider struts add a little Gravity dodge, hover trades armor for speed. None bypasses walls, pool collision or the Archive fault.
5. Equip Circuit matrix and cycle sockets to Capacitor > Relay > Ground. Hold still 1.5 seconds; receiving a hit discharges the pulse. Loose socket bonuses are replaced, not added on top.
6. Fight security units with Radiation, physical and Corruption attacks, and supervisors with avoidable Gravity follow-ups. Enemy Life/damage and rewards are fixed by area.
7. Collect equipment from enemies and containers. Early floors cap at Green; later floors unlock higher rarity bands. Returning at high character level does not improve early loot. Map/elevator travel preserves floor items; NEW SORTIE deletes tower-floor leftovers.

## What feedback matters

Does climbing feel more distinctive than descending? Can you find the upward exit, branches and elevator without confusion? Are the open sections too empty, too small or too similar? Are optional annexes worthwhile? Does revisiting early enemies with stronger equipment communicate growth?

This is a playable **Act I blockout**, with shared enemy behaviors and provisional floor bosses. Exact size, encounter density, names, curves, art and loot rates remain temporary. The new route is playable; a balanced full campaign is not established. Unique/set content, new enemy families, quests, persistent saves and final art remain future work.

## Validation boundary

`./run.ps1 -Test` imports and runs core, hub and tower rule suites. `render_tower.gd` checks native mouse navigation/elevator UI and captures all themes; its composition tour and route unlocks use explicit test overrides. `render_hub.gd` checks vendor/buyback/debug input and garage transitions. Earlier fitting-bay and inventory render harnesses remain for those systems. `playthrough.gd` drives the Lobby through real physics frames, ordinary attacks, repairs and pickups without stat overrides (the existing white lab kit includes a cannon and Circuit matrix). STATUS records actual results. Automated rule/render evidence is not manual player acceptance or a full-act balance pass.

Stat/level requirements are proposals in ITEMIZATION.md and are not enforced in this build.


## 2026-09-18 — weapons and debug arena

User-authorized 0.10 direction and implemented temporary rules are recorded in [WEAPONS_AND_ARENA.md](WEAPONS_AND_ARENA.md). This supersedes four-tier chest descriptions: containers now have five tiers; CEO rewards a gold act-boss hoard. DEV opens a separate repeatable test range. Weapon families now include quick melee, wide heavy melee and traveling explosive missiles. Existing cannon and carbine remain.


## 2026-09-19 — cybernetic base expansion and modifiers

Accepted direction and implementation are in [SALVAGE_EXPANSION.md](SALVAGE_EXPANSION.md). Survey now names the new space helmet; the earlier Survey base is Combat helmet. Alternate amulets, medium/light barding and Cyber Harness rename are implemented with individual art/models. All four locomotion forms are verified. The expanded affix catalog, discovery, regeneration, affinity and geometry effects are active; weights/formulas remain provisional. Test through the arena wearable sampler and C → Modifiers.


## 2026-09-19 — seed controls and encounter extension

[WORLD_SEEDS.md](WORLD_SEEDS.md) owns the 0.12 rules. DEV and Range Operator can apply/replay or randomize a seed, rebuilding generated field state while retaining the character and keycards. Fresh launches randomize; ordinary arena re-entry continues chest sequences. Enemy placements are now seeded inside validated regions; room geometry and fixed difficulty remain unchanged. Type pools and spawn regions are separate from layout, ready for future authored types/chunks.


## 2026-09-19 / 0.14 affinity equipment
Accepted: Draconic and Visceral listed bases, existing random modifiers, affinity-favored enemy loot, neutral chests, elemental attack colors, only a white Cybernetic melee starter. See AFFINITY_ITEMS.md. 85% matching weight, base combat numbers, non-flying wings and cone damage rules are temporary prototype choices.
