# Cybernetic bases and modifiers — Tech Demo 0.11

## Accepted direction — 2026-09-19

The cybernetic locomotion family includes Paw servos, Crawler treads, Spider struts and Hover skirt. Add an alternate inventory/model appearance for each amulet footprint. All helmets are 2×2; rename the existing Survey helmet to Combat helmet, and give a new space-style helmet the Survey name. Add medium Bracing/Mesh and light Suit/Padding barding. Rename Utility harness to Cyber Harness. All new equipment needs unique inventory art, visible worn attachments and regular rarity/itemization support.

Expand rarity-weighted modifiers to resources, attributes, resistances, speeds, damage, elemental damage, regeneration, flat damage mitigation, discovery, affinity offense/defense and weapon geometry. Item Discovery and Silicon Discovery must affect gameplay.

## Implemented bases

26 total bases, with the original 18-item starting loadout retained to avoid overflowing the backpack. New bases are available through vendors, randomized enemy/container salvage and RANGE OPERATOR → GIVE CYBERNETIC BASE SAMPLES. The sampler grants 19 head/neck/barding/harness/locomotion bases; overflow remains on the floor, removable by the arena's explicit clear/reset controls. This is a family of cybernetic parts, not an authored set-bonus system.

- Head: Combat helmet (existing military design), Lead visor, Survey helmet (transparent pressure dome and collar). All 2×2.
- Neck: Signal amulet and Relay amulet 1×1; Anchor pendant and Telemetry pendant 1×2. Alternate models use an amber diamond relay and a long segmented telemetry tag.
- Barding: existing heavy Field plating / Blast carapace; Cyber Bracing / Conductive Mesh 2×3; Interface Suit / Impact Padding 2×2. Bracing and Mesh use open lattice geometry with visible fur rather than opaque plates. Suit/Padding use thin studded surfaces and padded segments.
- Harness: Cyber Harness rename; Insulated belt retained.
- Locomotion: all four were already implemented and eligible for drops. No tread-only restriction existed. Seeded coverage now explicitly checks every base, and the sampler makes all forms immediately inspectable.

Inventory art is original SVG geometry; attachment changes also appear in the live inventory preview. Native inspection found unsupported patterned SVG fill for Mesh; replaced with explicit strand paths.

## Temporary affix rules

White has zero random modifiers. Green has one, Cyan two (secondary budget 40%), Violet/Magenta three with the third drawn from specialized modifiers. No repeated affix keys on an item. The catalog is `scripts/bonuses.gd`.

Common primary stats each have weight 8. Specialized modifiers have per-key weights 0.4 / 1 / 1.6 / 2.2 from Green through Magenta; speed/attack speed and resistances receive double that weight. The third Violet/Magenta roll is guaranteed specialized. Existing rarity budget multipliers 1 / 1.8 / 2.3 / 3.1 and bounded item-level growth remain. Thus higher rarity changes both strength and the likelihood of specialized effects. Numeric weights, budgets, caps, base names and dimensions beyond the requested helmet/amulet rules remain prototype choices.

Active modifiers include:

- Flat Life/Mana/attributes/damage; movement speed in units/sec; attack speed and six elemental resistances in percent.
- Individual elemental damage percentages, applied to matching outgoing damage. Affinity damage percentages multiply against matching enemy metadata.
- Life/Mana regeneration in points/sec. No regeneration while paused or dead; Mana bonuses add to existing attribute-derived regeneration.
- Existing percent damage reduction plus new flat Damage reduced by and flat Elemental damage reduced by. Flat reductions apply after armor/percent defenses and may reduce a hit to zero. Affinity defenses reduce incoming enemy damage before these defenses; hazards without an affinity do not receive a family reduction. Burn amounts inherit the source's initial affinity mitigation.
- Melee reach/arc percentage increases melee reach and angular width (width capped at 180 degrees). Projectile Range increases ranged targeting/attack reach. Explosion Radius increases launcher area of effect. Geometry bonuses cap at +100%; affinity defense caps at 50%; existing attack speed/resistance/reduction caps remain.

Cards list active modifiers and units; C → Modifiers shows current totals. All current creatures are Cybernetic; Visceral/Draconic bonuses are wired to metadata but their creature/part models remain future content. No final class, skill or set rules were introduced.

## Discovery

Item Discovery improves quality, not item count. Enemy rarity weights are multiplied by `1 + discovery/100 × tier/4`, then normalized. Existing area rarity caps remain absolute. Containers bias the quality roll upward with `1 - (1-u)^(1 + discovery/100)`; container counts and quality floors/caps remain unchanged. Discovery caps at 300% for these calculations.

Campaign chest contents are fixed when created, using then-equipped discovery; later equipment swaps do not reroll them. Arena restocks use discovery on each opening. Enemy drops use discovery at death. Silicon Discovery multiplies actual enemy/chest Silicon by `1 + discovery/100`, rounded down, also capped at 300%. Zero payouts remain zero. Sale/buyback prices and debug grants do not scale.

## Validation and open work

Seeded tests cover all 26 bases and every affix, unique icons, helmet dimensions, rarity weighting, discovery distribution and area caps, chest discovery/payouts, sale-price isolation, elemental/affinity hits, flat mitigation, actual regeneration, reach/radius and card units. Native renders cover new inventory art, the live Survey/Mesh/Spider preview, all six barding models and the Modifiers page. The sampler button is exercised through native UI input. Final balance, real player preference and organic/dragon content remain open; no disk saves.
