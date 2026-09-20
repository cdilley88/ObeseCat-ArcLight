# Rarity polish, containers, elements and affinities — 0.9

## Accepted user direction

Increasing rarity glow: Green border, blue/cyan bloom, increasing toward an animated Magenta halo. Randomized lockboxes with currency/potions, cases favoring basic equipment, chests with better equipment odds, glowing boss superchests with good loot; all may provide supplies. Retain the established currency name Silicon (the wishlist used gold generically).

Paged character sheet and six elements: Heat/orange, Cryogenic/cyan, Electromagnetic/yellow, Radiation/lime with spreading damage over time, Gravity/deep purple replacing Vacuum with percentage-based damage, Corruption/magenta with variable damage and stat lowering. Affinities are separate creature/equipment families: Cybernetic, Visceral and Draconic. Tentacles/teeth/organic mutation salvage and scales/wings/breath weapons are accepted content directions, not completed assets.

## Rarity presentation implemented

Original five-tier palette remains White, Green, Cyan, Violet, Magenta; no sixth blue rarity was introduced. Green keeps its border. Cyan/Violet use progressively broader soft edge glows; Magenta adds a pulsing halo and orbiting highlights. Shared `rarity_fx.gd` draws the effect on bag/worn tiles, trade grids and item cards. Ground drops gain additional colored rings and Magenta pulses. FX LOW stops halo animation while preserving readable rarity. These are lightweight Compatibility-renderer glow approximations, not HDR post-process bloom.

## Containers — temporary loot rules

Three containers per combat area, with types randomly selected and contents seeded by area/run. Spawn locations are authored reachable points; contents are independent of hero level. Every supervisor spawns one superchest at defeat, replacing its old direct equipment drop. Regular-enemy equipment budget remains at most two drops. Equipment from containers goes onto the ground for normal pickup; full bags cannot lose it. Silicon and potions recover automatically. Surplus potions at the 99 cap are discarded as with existing supply recovery.

| Container | Equipment | Prototype rarity roll before area cap |
| --- | --- | --- |
| Lockbox | None | Currency and optional potions |
| Case | One item | 80% White / 17% Green / 3% area's rarity ceiling |
| Chest | One item | 25% White / 40% Green / 35% area's ceiling |
| Boss superchest | Two items | 70% one tier below ceiling (minimum Green), 30% ceiling |

All rolls respect ACT1's ceilings. An early superchest guarantees Green rather than skipping to endgame gear. Lockboxes always award Silicon; other containers have a 65% currency chance. Currency range is area tier + 3 through tier × 3 + 12. All have 60% chance of 1–2 Life potions and 45% chance of one Mana potion. These rates and total loot volume are provisional and need playtesting.

Open with click or E within interaction distance. Open state, contents and floor drops survive stairs/elevator/Wormhole trips. A chest or dead supervisor cannot pay twice. New Sortie, full reset, and debug waypoint/encounter reset repopulate them. No disk persistence. `chests.gd` owns generation/models/payout; `main.gd` stores snapshots.

## Six-element prototype behavior

Physical remains the fallback damage channel; it is not a seventh elemental resistance. Each elemental resistance is independently rolled on eligible rare modifiers, shown on the Elements page and capped at 75%. All rolled weapons may receive any of the six elements, with an explicit element-prefixed name; the original white lab kit retains its familiar defaults. Projectile/beam colors use the element palette. Each main floor's six regular security units exercise the six channels; supervisors use Gravity.

| Element | Implemented temporary behavior |
| --- | --- |
| Heat | Direct hit plus three-second burn at 8% of the resisted initial hit per second on enemies |
| Cryogenic | 35% slow for 1.6s; every third player hit briefly freezes (0.55s regular, 0.25s boss). Enemy attacks slow and briefly freeze the player |
| Electromagnetic | Electrical hit varying from 80–120% base damage |
| Radiation | Three-second damage over time; first tick can infect nearby unburning enemies within 2.5m at half strength for two seconds. Secondary infections do not chain |
| Gravity | Flat hit plus 3% of maximum Life, with the added component capped at 50% of flat damage; resistance applies. Gravity strikes can be dodged; Spider dodge remains useful |
| Corruption | 50–150% damage and three seconds of weakening. Enemy attack damage falls 20%; player damage and armor fall 20%. Resistance shortens the weakening duration |

Burns refresh rather than stack. Player burn ticks retain existing armor/reduction mitigation. Status effects reset on area travel, as before. The old Vacuum three-hit behavior and Corruption slow/freeze identity are superseded in the live tower. Legacy chamber fixtures retain their old enemy follow-up scheduler for regression testing. Percent caps, ranges, timing and reductions are implementation assumptions, not final balance.

## Character pages and affinity boundary

C now has Attributes, Elements and Affinities tabs. Attributes retains level, points and allocation. Elements shows all six color-coded resistances and short behavior descriptions. Affinities reports counts of distinct worn parts, counting a two-slot weapon once.

Existing items and security enemies have a Cybernetic affinity field. Cards display the equipment family. Visceral/Draconic names and content direction are represented on the sheet, but **organic/draconic models, enemy families, drops, secondary-damage rules and family-specific bonuses are not implemented**. No arbitrary rock-paper-scissors or resistance bonuses were assigned. A later content pass should add visibly distinct equipped parts, not merely relabel metal gear.

DEV / DEBUG → GIVE ELEMENT / RARITY TEST KIT grants six white element test carbines and five graded amulets. Full bags spill samples onto the garage floor. This is an explicit laboratory override, not normal acquisition.

## Validation and next playtest

1,804 rule assertions passed, including chest content budgets/caps, distance/one-time payout, portal persistence, duplicate supervisor rewards, Radiation spread bounds, Gravity cap, Corruption expiry, all resistance caps and debug samples. Seven native GUI checks passed for the kit button, card rendering, tab clicks, panel bounds and E-opening a superchest. Composition screenshots use explicit test fixtures. The automated Lobby combat run cleared with 86.53 Life, level 2 and 21 total items after opening the boss reward. This is not full-act balance acceptance.

Next: judge halo readability, supply/gear frequency and chest discovery, then choose a focused Visceral or Draconic equipment/enemy set. Avoid claiming these affinity content families are already playable.


## 2026-09-18 — weapons and debug arena

User-authorized 0.10 direction and implemented temporary rules are recorded in [WEAPONS_AND_ARENA.md](WEAPONS_AND_ARENA.md). This supersedes four-tier chest descriptions: containers now have five tiers; CEO rewards a gold act-boss hoard. DEV opens a separate repeatable test range. Weapon families now include quick melee, wide heavy melee and traveling explosive missiles. Existing cannon and carbine remain.
