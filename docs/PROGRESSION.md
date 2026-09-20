# Character progression — current through Tech Demo 0.9

## Accepted user direction

The user liked the first playable demo and requested adding systems incrementally toward a full game. This increment is a **placeholder level-up and stat progression system**: Life and Mana resources, red/blue orbs, a character stat screen, and spendable Strength, Dexterity, Vitality, and Energy. The intended next step is to customize these mechanics to the universe after testing them.

## Implemented temporary rules

All exact numbers, the XP curve, attribute effects, and the test attack below are provisional implementation choices. They are not final balance or class identity.

- Start at level 1, with 10 in each attribute, 100 base Life, 50 base Mana, and 3 Mana regenerated per second. Starter harness/amulet make the initial equipped totals 105 Life / 55 Mana.
- XP rewards are fixed by area (ACT1.md). Lobby units give 12 and its supervisor 40. XP required for the next level is current level x 50. Overflow carries forward, including multiple levels from one award.
- Every level awards 5 spendable stat points. Clearing the Lobby reaches level 2 with 5 points and 62 XP toward level 3.
- Level-up restores Life and Mana if alive. It cannot resurrect a dead character.
- Character screen: C, or the top CHARACTER button. The button highlights unspent points. Simulation pauses; +1 spends one point immediately. No point debt or negative allocations.

| Attribute | Effect per point above starting value |
| --- | --- |
| Strength | +0.5 attack damage |
| Dexterity | +0.2 armor |
| Vitality | +5 maximum Life |
| Energy | +5 maximum Mana and +0.1 Mana regeneration per second |

Allocating Vitality/Energy adds new resource capacity to the current value, preserving the amount missing. Gear comparison includes attributes on both sides, so the displayed delta is only the equipment change. Dexterity remains armor for this placeholder. Spider locomotion now provides dodge against Gravity strikes; it is separate from Dexterity.

Equipment can grant all four attributes, direct Life/Mana, attack speed, reduction, and resistances. The character screen shows combined attributes. Removing capacity clamps current resources; equipping higher-capacity gear does not refill Life/Mana. Gear effects and caps live in ITEMIZATION.md.

## Mana experiment

Q arms or cancels **Empowered strike**, a temporary modifier to the existing attack. A connected strike spends 10 Mana and deals 1.75x damage. Empty targets, blocked attacks, and out-of-range attempts do not charge Mana. Basic attacks remain free. The Signature's secondary hit shares the damage modifier without a second Mana charge. Regeneration is active during live play, including after a clear, but stops while paused or dead.

This is a resource-use test, not an approved skill, class ability, or skill tree.

## Continue versus reset

- **Travel:** stairs/elevators retain the character and floor state. Garage visits refill resources/repairs; floor-to-floor travel does not. **T** recovers to the garage after defeat. **NEW SORTIE** in the garage respawns fixed-tier encounters and clears tower-floor loot while retaining character/keycards. See ACT1.md.
- **System reset:** full character reset to level 1, with same-seed and new-seed choices.
- **Closing the game:** no progression is saved yet. Persistence, respec, level caps, the long-term fixed difficulty curve, and death penalties are unresolved future work.

## Developer operator (0.6)

The hub DEV / DEBUG contact sets exact level, allocated attributes, unspent points and Silicon, resets XP to zero, and refills resources. This is a sandbox override, not a progression reward or respec economy. See HUB.md for limits. Damage has a minimum of 1 so unusually low debug Strength cannot heal targets.

## Implementation and verification

`prototype/scripts/progression.gd` owns the XP curve, attributes, allocation, and derived stats. `main.gd` integrates enemy XP, resource recovery, Mana use, and repeat/reset. `hud.gd` provides allocation and numeric readouts; `shaders/orb.gdshader` draws the original resource orbs.

The current rule suite covers XP overflow, invalid grants/allocations, gear attribute derivation, capacity removal, pause/regeneration boundaries, empowered hit/miss cost, duplicate kill rewards, death behavior, and repeat/reset. Rendered current stats and automated combat verify integration; see STATUS for exact results. This is not a manual feel/balance playtest.

## 0.8 supply and portal extension

Wormhole, dedicated potion stacks, vendor refills, debug waypoint controls and revised hotkeys are documented in [HUD_AND_SUPPLIES.md](HUD_AND_SUPPLIES.md). H repairs are superseded by Z/X potions; potion counts persist through travel and are not refilled by garage visits. Esc/System owns full resets.

## Character sheet pages (0.9)

C contains Attributes, Elements and Affinities. Six independent resistances replace the old three-row readout. Affinities count distinct worn parts and document the future families; they do not currently grant bonuses. Corruption temporarily reduces damage and armor, marked on Attributes. See REWARDS_AND_ELEMENTS.md.
