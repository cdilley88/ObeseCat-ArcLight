> Current 0.13 additions and superseding route/Unique rules: [ObeseCat ArcLight](ARCLIGHT_ACT1.md).

# Cybernetic salvage — Tech Demo 0.4

## Accepted user direction (2026-09-18)

Loot represents salvaged cybernetic parts, with an Armored Core influence. The body slots are **Head** (helmet), **Neck** (amulet), **Barding** (chest), **Harness** (waist), and **Matrix** (special mod). Weapons use **Left / Right** slots: quick light weapons occupy one; slow heavy weapons occupy both. Visible equipped parts remain a core requirement.

The user authorized trying interchangeable locomotion if it fits cleanly. A **Locomotion** slot is implemented experimentally; treads, spider legs, and hovering are not a final replacement for the four-legged pet identity.

Enemy equipment drops should be selective, avoiding constant checking/swapping. The intended normal-playthrough endpoint is predominantly violet Rare gear, with magenta Rare Plus as lucky outliers. Authored unique and set equipment are future work.

| Tier | Color | Accepted bonus structure |
| --- | --- | --- |
| Basic | White | Base stats only; no random modifiers; early testing of forms/types |
| Magic | Green | One small damage/stat bonus |
| Magic Plus | Cyan | Larger primary bonus and small secondary bonus |
| Rare | Violet | Two primary bonuses and a special rare-tier bonus |
| Rare Plus | Magenta | Stronger bonuses than Rare |

Damage themes: **Radiation** (lasers/nuclear/burning damage over time), **Gravity** (collapse-like multi-strikes with avoidable hits and high full-hit potential), **Corruption** (glitch/hacking, slows and stops). Resistances correspond to these types. Ordinary physical contact remains a neutral damage channel in the prototype.

## Implemented temporary choices

There are 18 illustrated bases: two for each body slot, four weapons, four locomotion forms. All are supplied as white lab equipment at start; seven are worn and eleven are in the bag. This generous test kit is not a proposed campaign starting loadout. White bases have fixed stats, even at later item levels. Higher-tier affix budgets scale with item level up to level 12. White obsolescence around levels 2–3 and the normal-playthrough endpoint are design targets, not validated balance.

The old Rig/Harness/Pack schema and earlier nine-slot/six-family proposals are superseded. The Circuit experiment now lives on a **Circuit matrix**. The Matrix's special-mod identity is represented by the targeting-speed base and the Circuit behavior, not a new class skill system.

| Weapon base | Behavior before bonuses |
| --- | --- |
| Laser carbine | One slot; 12 Radiation damage; 0.52s cadence; 6m reach |
| Phase blade | One slot; 16 Corruption damage; 0.58s cadence; 2.3m reach |
| Collapse cannon | Both slots; 30 Gravity base; 1.65s cadence; 7.5m reach |
| Reactor launcher | Both slots; 42 Radiation damage; 1.85s cadence; 7m reach; 50% splash within 2.1m |

Two light weapons alternate on successive attacks. Each retains its own reach, windup, and cadence; there are no separate firing buttons yet. A heavy weapon is a single item referenced by both slots and counted once. The character readout reports average per-hit damage, not DPS. Weapon damage modifiers apply to that weapon; body damage bonuses and Strength apply to every attack.

Paw servos: +0.15 movement. Treads: -0.45 movement, 8% damage reduction. Spider struts: +0.35 movement, 8% dodge against Gravity strikes. Hover skirt: +0.75 movement, -1 armor. Models replace the visible legs with undercarriages; hover bobs and spider struts animate. All modes retain ground navigation/collision. No flight, terrain bypass, acceleration model, or new traversal system.

## Random bonus budgets and drop pacing

Primary pool: damage, Strength, Dexterity, Vitality, Energy, Life, Mana. Two primaries on an item cannot repeat. The third bonus on violet/magenta draws from movement speed, attack speed, damage reduction, or one of the six elemental resistances. Basic innate defenses on a white base are base stats, not random modifiers.

Prototype tier multipliers: 1 / 1.8 / 2.3 / 3.1, times (1 + min(level,12) x 0.18), with +/-15% variation. Cyan's secondary uses 40% budget. Life/Mana use x5, movement x0.10, percentages x2; other stats x1. Magenta uses the same three-bonus structure as violet with a larger budget. Gear attributes use the existing progression formulas. Attack speed caps at 60%, damage reduction 50%, resistances 75%, movement 1.5–6.0.

| Lab item level | White | Green | Cyan | Violet | Magenta |
| --- | --- | --- | --- | --- | --- |
| 1–3 | 45% | 38% | 13% | 3.5% | 0.5% |
| 4–7 | 15% | 35% | 30% | 19% | 1% |
| 8+ | 5% | 15% | 25% | 53% | 2% |

Tech Demo 0.9 retains fixed area loot tiers, never hero-level scaling. Regular enemy equipment remains capped at two drops per area; the supervisor now awards a two-item superchest instead of a direct drop. Three randomized field containers add basic gear and supply opportunities. All equipment respects the area's rarity ceiling. Full chest tables and pacing assumptions are in REWARDS_AND_ELEMENTS.md.

## Damage, rarity effects and affinity families (0.9)

Six elements/resistances now replace the earlier three-element experiment: Heat, Cryogenic, Electromagnetic, Radiation, Gravity (renamed Vacuum), Corruption. Cryogenic owns slow/freeze; Radiation spreads damage over time locally; Gravity uses a capped maximum-Life component; Corruption varies damage and temporarily weakens combat stats. See REWARDS_AND_ELEMENTS.md for exact temporary formulas and validation limits.

Rolled weapon variants may use any element; starter white bases keep the table above. All existing parts are tagged Cybernetic. Visceral and Draconic are accepted future equipment/enemy families; no organic/dragon models or family bonuses are silently implied. Item cards show affinity separately from element.

Rarity effects now progress from Green border through Cyan/Violet glow to animated Magenta halo, across inventory, worn slots, vendor grids and cards. World drops get tiered rings. FX LOW preserves color while stopping animation. The existing Cyan Magic Plus tier serves the requested blue/glow step; no extra rarity was added.

## Circuit and authored gear boundary

Capacitor > Relay > Ground remains the single Circuit. Stand still 1.5s; the next hit received emits 24 damage within 3.3m, with a five-second cooldown. It replaces the loose +2 damage / +0.15 speed / +1 armor bonuses. Components remain a reusable test kit, not loot. Effects/sockets follow item identity through moves and drops.

The previous Split Decision Signature helper remains tested but is removed from guaranteed enemy drops. Authored unique/set content, naming/color conventions, class interactions, and long-term balance are deferred as requested. Exact names, stat values, acquisition rates, and level bands above are implementation assumptions.

## Requirements — proposal for discussion (2026-09-18)

The user asked to start thinking about stat/level requirements. **No requirement thresholds or equip restrictions were approved or implemented in 0.5.** The current 18 white test bases remain immediately usable.

Proposed direction: requirements belong to a base/grade and its power budget, not rarity color alone. Keep entry-level white bases at level 1 with no attribute gate so players can test weapon and locomotion forms. Later heavy weapons/barding could emphasize Strength, precision/light gear Dexterity, and matrices/energy hardware Energy. Whether Vitality should gate any parts remains open. Do not add arbitrary requirements to every accessory merely for symmetry.

Before enabling gates, decide the thresholds and qualification policy. Suggested evaluation: character level plus allocated attributes and bonuses from other eligible worn parts, excluding the incoming item's own bonuses and every item it displaces (both weapons for a heavy swap). Prevent circular/self-supporting equipment chains. Removing prerequisite gear needs an explicit policy; prefer rejecting an invalid loadout transaction with a clear reason over silently dropping gear or allowing permanent invalid stats. Re-check all affected parts, and preserve the atomic inventory guarantees.

The future card should show only applicable requirements, coloring unmet values clearly; equip buttons and drag previews must use the same validator. These are proposals, not settled rules. Test early build freedom, attribute taxes, dual-weapon swaps, and full-backpack failure before enforcing them. Requirements should give progression meaning without making experimentation tedious.


## 2026-09-18 — weapons and debug arena

User-authorized 0.10 direction and implemented temporary rules are recorded in [WEAPONS_AND_ARENA.md](WEAPONS_AND_ARENA.md). This supersedes four-tier chest descriptions: containers now have five tiers; CEO rewards a gold act-boss hoard. DEV opens a separate repeatable test range. Weapon families now include quick melee, wide heavy melee and traveling explosive missiles. Existing cannon and carbine remain.


## 2026-09-19 — cybernetic base expansion and modifiers

Accepted direction and implementation are in [SALVAGE_EXPANSION.md](SALVAGE_EXPANSION.md). Survey now names the new space helmet; the earlier Survey base is Combat helmet. Alternate amulets, medium/light barding and Cyber Harness rename are implemented with individual art/models. All four locomotion forms are verified. The expanded affix catalog, discovery, regeneration, affinity and geometry effects are active; weights/formulas remain provisional. Test through the arena wearable sampler and C → Modifiers.


## 2026-09-19 / 0.14 affinity equipment
Accepted: Draconic and Visceral listed bases, existing random modifiers, affinity-favored enemy loot, neutral chests, elemental attack colors, only a white Cybernetic melee starter. See AFFINITY_ITEMS.md. 85% matching weight, base combat numbers, non-flying wings and cone damage rules are temporary prototype choices.
