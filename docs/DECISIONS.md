# Decisions and open questions

## 2026-09-17 — initial user direction

**User direction:** Brainstorm an original retro action RPG with Diablo 1-era atmosphere and deliberate pacing, modern convenience and depth, and equipment design informed by Diablo 2. Avoid generic medieval / demon fantasy. Explore pet mascots, nuclear / Cold War themes, ITS colors, and CRT aesthetics. Consider mascot classes, skill trees, acts, bosses, and ObeseCat as final antagonist. Prioritize itemization and explore expanded rarities, socketables, and balanced recipe combinations.

**User direction:** Work in the open folder on the G: projects drive and maintain strong README-based project context.

**Status:** Documentation initialized. No engine, title, art pipeline, character roster, slot layout, rarity scheme, lore, or campaign scope has been approved.

## Highest-impact open decisions

1. Corruption: what is changing, how does it manifest physically, and what causes it?
2. World structure: a facility-centered descent, travel across an alternate Cold War world, or a combination?
3. Roster: which real pets are playable, what defines their personalities, and which supplied references should guide them?
4. ObeseCat's role: malicious antagonist, tragic containment subject, or an ambiguous force?
5. Campaign rarity balance and authored unique/set identity; the ranked ladder is accepted below.
6. Final art pipeline and broader delivery targets; Godot/Windows prototype approved below.

## Assistant proposals awaiting discussion

The company town / sealed facility premise; three campaign spaces; components forming Circuits; controlled rather than constant glitch effects. Full rationale lives in the linked topic documents. The earlier facility-focused campaign sketch must be reconsidered in light of the clarified setting.

## 2026-09-17 — setting clarification and character requirements

**Accepted, explicitly directed by the user:** The descent is into glitched corruption. The Cold War reference means an alternate Cold War with the tonal character the user associates with 1990s Westwood Red Alert: underlying comical elements and brutally serious material. It does not mean oppressive Soviet styling.

**Accepted, explicitly selected by the user:** Playable characters are four-legged. Equipment must be visible on their models and change their appearance. The user considers this a very important immersion detail.

**Rationale:** Establish an original corruption-driven identity and make equipment progression physically present on recognizable pet characters.

**Affected documents:** README, CONCEPT, ITEMIZATION, STATUS. Supersedes the open four-legged-versus-upright question and the earlier unresolved broad tonal choice. Exact lore, slot layout, art pipeline, and campaign structure remain proposals or open questions.

## 2026-09-17 — playable laboratory requested

**Accepted user direction:** Move from abstract brainstorming to TECH DEMO 0.1. Begin with project inspection and a minimum plan. Build a tiny playable loop after implementation direction is settled. Full requested scope and exclusions are captured in TECH_DEMO_0_1.md.

**At proposal time:** Godot and the implementation structure awaited approval. This is superseded by the explicit approval below.

**Prototype boundary:** Minor reversible implementation choices may be made after approval and documented as temporary. Material final-identity decisions still require discussion.

## 2026-09-17 — Tech Demo 0.1 implementation approved

**Accepted, explicitly approved by the user:** "yes, go ahead" in response to Godot/GDScript, orthographic 3D, Windows first, and the `G:\New folder\prototype` project location.

**Scope of approval:** Build the proposed small playable laboratory. This is not a commitment to full production or approval of permanent lore, named classes, equipment slots, rarity families, enemy factions, or campaign structure.

**Temporary implementation choices:** Unnamed tabby placeholder; three visible equipment slots / six bases; three sentries and one Warden; one Circuit and one Signature item; two field repairs; one small test chamber and pulse fault. These are now implemented experiments, not accepted final-game identity.

## 2026-09-17 — character progression requested

**Accepted user direction:** The first demo looks good to build on. Begin incremental systems development with a placeholder character stat screen, Life/Mana resources with red/blue orbs, and Strength/Dexterity/Vitality/Energy points awarded on level-up. Customize the system to the universe later.

**Implemented temporary choices:** Five points per level; 10 starting attributes; simple damage/armor/resource formulas; enemy XP and a short curve; Q empowered attack as a Mana sink; T to repeat a cleared chamber with the same character. No save system yet. Full rules and prototype boundaries are in PROGRESSION.md.

## 2026-09-17 — spatial inventory requested

**Accepted user direction:** Add a Diablo 1-style inventory with actual item graphics, differently shaped item footprints, and generous capacity.

**Temporary implementation choices:** A 12 x 8 backpack, fixed rectangular footprints, separate equipment slots, original hardware illustrations, drag-and-drop, right-click equip, auto-pack, and recoverable item dropping. These do not finalize full-game capacity or equipment slots. See INVENTORY.md for actual behavior and evidence.

## 2026-09-18 — cybernetic salvage direction and implementation

**Accepted user direction:** Armored Core influence; enemy salvage as cybernetic parts. Head, Neck, Barding, Harness, Matrix; Left/Right weapon slots with quick light weapons and slower two-slot heavy weapons. White base-only, green small primary, cyan larger primary/small secondary, violet two primaries/rare bonus, magenta stronger rare. Normal playthrough should end predominantly violet with magenta lucky outliers. Minimize constant loot swapping. Future authored unique/set content.

**Accepted themes:** Radiation with burning damage over time; Vacuum with avoidable multi-strikes and high full-hit potential; Corruption with slows/stops/hacking identity. Stat/Life/Mana bonuses, movement and attack speed, damage reduction, and resistances.

**Authorized experiment:** Add interchangeable locomotion if it slots in cleanly. Implemented a separate slot with paws, treads, spider struts, hover. This does not settle final pet anatomy, traversal, or permanent replacement of the four-legged direction.

**Temporary implementation:** 18 white starter lab bases, alternating one-slot weapons, eight equipped positions, common ground collision across locomotion modes, bounded 1–2 drops/chamber, level-band rarity weights, capped affix budgets, specific damage/status formulas and defenses. Earlier Rig/Harness/Pack placeholders and nine-slot/six-family proposals are superseded. The Circuit moves to Matrix; the old Signature remains a tested helper but is no longer guaranteed loot. Full rules in ITEMIZATION and INVENTORY. No authored unique/set database or production campaign added.

## 2026-09-18 — hover cards and live inventory preview

**Accepted user direction:** Illustrated hover cards inspired by Diablo 2: total damage/defense followed by concise added bonuses. Avoid exhaustive clutter. Add an equipment-updated player preview in inventory, informed by Grim Dawn's usefulness without copying its layout. Keep the full character stats menu separate. Begin considering requirements.

**Implemented temporary choices:** Cards for bag and worn parts; short hover delay; screen-clamped placement beside inventory; zero rows/formula labels omitted; fitting bay with independent 3D scene and rotation buttons. Existing equipment art/models reused. Persistent comparison sheet replaced by hover information and compact selection actions. Defense is a presentation label for armor, not a formula change.

**Proposal only:** Stat/level requirement policy in ITEMIZATION. No thresholds, locks, automatic unequipping, or balance changes introduced. The test kit remains usable.

## 2026-09-18 — hub, Silicon, vendors and developer NPC

**Accepted user direction:** Hub is the new spawn; safe-town atmosphere inspired by Diablo 2; distinct hub per act eventually. Weapon/armor vendors with loot selling, basic currency called Silicon, and a run entrance. Include developer controls for stats/levels/currency. Reserve roles for gambling, special currency, cosmetics, and quests.

**Temporary implementation:** One Act I prototype map called Relay Commons; six placeholder pet contacts; gate to existing chamber, return after clear/defeat, shared exact-item buyback, small white/green vendor stock, 80 starting Silicon, 42 from a full chamber, and provisional prices. Debug levels/attributes/points/wallet are independently editable. T returns to hub instead of instantly repeating; R/N still reset everything. No persistence or production act/quest system. HUB.md owns these rules. Hub naming, NPC identities, buildings and prices are not final canon.

**Future boundaries:** Gambling/special-currency/style/quest roles are labeled placeholders. The accepted per-act hub direction does not mean multiple hubs or act transitions exist yet.

## 2026-09-18 — Act I climbs the tower

**Accepted user direction:** large connected open sections with optional branches, fixed increasing difficulty and low-grade early loot on revisits; no dynamic scaling. Parking-garage refuge and upward facility/corporate-tower climb toward CEO office, with keycard elevator waypoints. Shopping/lobby, maintenance, offices/research, dining/lounge, garden/spa/pool themes; original PS1 FFVII Shinra-building inspiration.

**Implemented temporary choices:** six authored main floors plus three annexes; reused security family with fixed profiles; supervisor automatically grants floor keycard and forward access; physical elevator required to teleport; V opens read-only route. Per-floor corpses/damage/loot persist in-session. NEW SORTIE at garage resets tower encounters/loot but retains character/keycards; T is death recovery; R/N fully reset. Garage presentation replaces Relay Commons plaza. Exact names, order, dimensions, rewards, loot caps, encounter counts and Executive Firewall are placeholders. ACT1.md owns the implementation.

**Superseded:** single-chamber live loop; player-level-based salvage; discarded combat-floor loot on travel; T returning after clear. Old chamber remains only for regression fixtures. No final CEO identity, ObeseCat story, production campaign scale or disk-save format approved.

## Future decision entry format

Date — decision — status — who approved it — rationale — affected documents — any superseded decision. Keep facts, assumptions, and proposals distinct.

## 2026-09-18 — HUD, supplies and Wormhole

Accepted: town portal, less tutorial text, retain orbs/level/XP, potion icons/counts capped at 99, reusable menu icons/hotkey overlays, Esc/C/I/V/B/Z/X bindings, debug max potions and unlock/reset waypoints.

Temporary implementation: dedicated potion stacks, six/four starting supplies, 40% recovery with 40/30 floors, one-second per-type cooldown, 8 Silicon refills, deterministic automatic enemy supply recovery; free two-way Wormhole with one replaceable return point. Debug waypoint reset also resets tower encounters/loot so carriers can be defeated again; clearly labeled. System menu owns confirmed character resets; R/N direct resets and H field repairs are superseded. No skill menu or final potion/portal economy approved. HUD_AND_SUPPLIES.md owns details.

## 2026-09-18 — illustrated vendor inventories

Accepted: more visually engaging vendor screens with item graphics in inventory grids, using Diablo 2 as a presentation reference. Temporary implementation: merchant 10×8 paged trays, player 12×8 actual backpack positions, side card on hover, rarity/selection borders, explicit purchase/sale actions and exact-item buyback. Original art and terminal palette retained; no economy changes or drag-to-trade semantics introduced.

## 2026-09-18 — rarity glow, containers, six elements and affinities

Accepted wishlist: increasing rarity glow up to animated Magenta; supply lockboxes, basic cases, better chests and boss superchests; paged character sheet; Heat/Cryogenic/Electromagnetic/Radiation/Gravity/Corruption palettes and behavior identities; Cybernetic/Visceral/Draconic creature and equipment families. Gravity supersedes Vacuum; Cryogenic receives the old slow/freeze identity.

Implemented temporary choices: shared Compatibility-renderer edge glow, three seeded field containers, two-item supervisor superchests under fixed-area ceilings, bounded one-hop Radiation infection, capped 3%-maximum-Life Gravity, variable Corruption damage and -20% damage/armor weakening, three character tabs, Cybernetic metadata and developer sample kit. Exact rates/numbers, rolled weapon variants and percentages are prototype choices. Existing Silicon remains currency. Visceral/Draconic assets, enemies and equipment content remain a future focused pass, not completed work. REWARDS_AND_ELEMENTS.md owns current specifics.


## 2026-09-18 — weapons and debug arena

User-authorized 0.10 direction and implemented temporary rules are recorded in [WEAPONS_AND_ARENA.md](WEAPONS_AND_ARENA.md). This supersedes four-tier chest descriptions: containers now have five tiers; CEO rewards a gold act-boss hoard. DEV opens a separate repeatable test range. Weapon families now include quick melee, wide heavy melee and traveling explosive missiles. Existing cannon and carbine remain.


## 2026-09-19 — cybernetic base expansion and modifiers

Accepted direction and implementation are in [SALVAGE_EXPANSION.md](SALVAGE_EXPANSION.md). Survey now names the new space helmet; the earlier Survey base is Combat helmet. Alternate amulets, medium/light barding and Cyber Harness rename are implemented with individual art/models. All four locomotion forms are verified. The expanded affix catalog, discovery, regeneration, affinity and geometry effects are active; weights/formulas remain provisional. Test through the arena wearable sampler and C → Modifiers.


## 2026-09-19 — seed controls and encounter extension

[WORLD_SEEDS.md](WORLD_SEEDS.md) owns the 0.12 rules. DEV and Range Operator can apply/replay or randomize a seed, rebuilding generated field state while retaining the character and keycards. Fresh launches randomize; ordinary arena re-entry continues chest sequences. Enemy placements are now seeded inside validated regions; room geometry and fixed difficulty remain unchanged. Type pools and spawn regions are separate from layout, ready for future authored types/chunks.

## 2026-09-19 — ObeseCat ArcLight
User approved title, 19-floor area ranges, sentry assortment, Unique rarity, exact ChefBot Hat stats and Dispatch quest availability at floor 10. See ARCLIGHT_ACT1.md. ChefBot on 12, keycard timing, layout templates and combat numbers are temporary implementation choices. ArcLight flash / Act II wasteland is a story proposal, not implemented campaign content. This supersedes earlier open-title and six-floor route notes.

## 2026-09-19 / 0.14 affinity equipment
Accepted: Draconic and Visceral listed bases, existing random modifiers, affinity-favored enemy loot, neutral chests, elemental attack colors, only a white Cybernetic melee starter. See AFFINITY_ITEMS.md. 85% matching weight, base combat numbers, non-flying wings and cone damage rules are temporary prototype choices.

## 2026-10-20 — Tech Demo 0.15: persistent disk saves
Accepted user direction: Add persistent saves for playtesting instead of restarting from the beginning every launch.
Implementation: SaveManager (`save_manager.gd`) serializes full game state to JSON at `user://arclight_save.json`.
- Character: level, xp, points, attributes, hp, mana, potions, Silicon.
- Gear: full backpack items (with Vector2i grid_pos), equipped item slots (preserves two-handed dual references and worn identity).
- Meta & World: run seed, run number, keycards, visited areas, act completion, Dispatch ChefBot quest, shops, buyback, hub ground drops, wormhole, and per-visited-floor zone snapshots (enemy corpses/positions/hp, floor drops, chest states).
- UX: Intro screen displays saved character summary with `CONTINUE GAME [ENTER]` and `START NEW GAME`. System menu (`Esc`) provides explicit `SAVE GAME` and `LOAD GAME` buttons. Auto-saves occur on entering Garage Refuge, floor transitions, new sorties, point spending, trades, and window close.
- Reset: Confirmed reset in System menu wipes the disk save.

## 2026-10-21 — Tech Demo 0.15: Developer Splash FMV & Dedicated ArcLight Title Screen
Accepted user direction: Build a proper PS1-era opening sequence and title screen ("IntegralTec Studios Presents", old developer FMV sequence like Take-Two/989 Studios/Westwood, and a proper ObeseCat ArcLight title screen with New Game, Continue, Options, Credits, etc.). User authored original assets:
- `ITS Presents Arclight.mp4`: Short developer video exported from Adobe Premiere Pro CS6.
- `Arclight Logo.png`: Original high-res vector insignia.
Implementation details:
- Transcoded MP4 master to native Godot 4 `res://assets/video/its_presents_arclight.ogv` via FFmpeg (Theora video + Vorbis audio), compressed from 5.8 MB to 1.28 MB with zero stutter.
- Created `prototype/scripts/title_screen.gd` managing the dual-layer transition:
  1. Opening Developer Splash: Fullscreen `VideoStreamPlayer` with instant PS1-era skip on any keypress (`Space`, `Enter`, `Esc`) or mouse click. Fast-bypassed in headless mode for CI/test suite performance.
  2. Main Title Menu: Showcases user's `arclight_logo.png` over a live 3D Garage Refuge camera view with gentle ambient drift and CRT scanlines.
  3. Action Matrix: `CONTINUE SORTIE` (with live dossier badge of saved level/silicon/area), `NEW SORTIE` (with overwrite guard modal), `SYSTEM OPTIONS` (CRT/Audio toggles, seed control, replay FMV), `MISSION INTEL & CREDITS` (dossier), and `QUIT TO DESKTOP`.
  4. In-Game Return: System Menu (`Esc`) adds `SAVE & RETURN TO TITLE` with auto-save before returning to title screen.
- 5,386 automated test assertions pass with 0 failures (`test_title.gd` adds 43 assertions). Both Windows (`ObeseCat-ArcLight-0.15.exe`) and Web targets built and verified.
