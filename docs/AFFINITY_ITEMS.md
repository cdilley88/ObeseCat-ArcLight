# Affinity equipment / Tech Demo 0.14

## Accepted direction
Affinity is a creature/item family, separate from elemental damage: Cybernetic, Draconic, Visceral. Draconic evokes scales, horns, teeth, wings and gothic armor. Visceral evokes biological mutation, eyes, exposed brains, flesh, tentacles and eldritch horror. Randomized equipment uses the existing White–Magenta rules; these families do not introduce set bonuses or new Unique items. All attacks should show their damage element's color.

New characters and full character resets now receive exactly one equipped white Cybernetic Phase blade (one-handed melee). Other equipment slots and the backpack start empty. Starting Silicon and potion supplies remain unchanged.

## Implemented bases
Draconic (13): Full Helm / Frill / Horns; Breast Plate / Scale Coat / Spines; Claws (1H melee), Fangs (2H melee), Breath (2H spread), Wand (1H ranged); Wings / Wyrm Legs / Greaves. Original SVG inventory icons and procedural worn meshes exist for each. Wings flap while moving; they do not enable flight or bypass terrain. Wyrm Legs replace the four native legs; Greaves cover them.

Visceral (6): Ocular third eye / Cranium exposed brain; Tentacle (1H melee), Tail (2H melee), Acid Spray (2H spread), Quills (1H ranged). All have original inventory icons and worn meshes. Neck/Harness/Matrix and other unlisted family slots retain current bases pending user direction. The remaining Visceral armor/locomotion designs are open.

There are 45 randomized bases: 26 Cybernetic, 13 Draconic, 6 Visceral, plus the separately authored ChefBot Unique. Both families use normal affix weighting, rarity caps, elemental rolls and discovery. Acid Spray defaults to Radiation (the existing DOT channel); rolled versions may use any existing element. No seventh Acid element added.

## Central pools and temporary rules
Loot.pick_base groups bases by affinity for the selected slot. Each slot category is equally likely. If the enemy's family is available, it receives 85% probability; the remaining 15% is split equally among other available families. If the family is unavailable, choose equally among available families. Within a family/slot, choose bases uniformly. Chests have no affinity preference. Thus slots without Draconic/Visceral designs remain Cybernetic; equal family weights do not imply equal overall drop counts. Authored Uniques are excluded from these pools.

Tower enemy deaths pass the enemy affinity to this selector. Chests use the same selector with no preference. Seed streams, rarity budgets, item counts, floor caps and discovery remain unchanged. Vendors list all white bases in their existing paged trays. Garage DEV has separate Draconic and Visceral sample buttons; samples drop at the player's feet and do not overwrite inventory. The existing Cybernetic sampler remains Cybernetic only.

Breath and Acid Spray currently use five visible pellet streams and apply one damage packet per target in a clear, short forward cone. This avoids multiplying damage by decorative particle count. Quills uses three colored traces and one damage packet. Melee sweeps, beams, missile exhaust/impact flashes and enemy weapon effects use elemental colors. Physical remains neutral tan. Animation detail, meshes, stats and these probabilities remain prototype choices.

## Validation and playtest
Use Garage DEV → DRACONIC SAMPLES or VISCERAL SAMPLES; pick up and equip, rotate the fitting bay, compare rarity cards. Tests cover all base icons/modifiers, seeded affinity distributions, minimal starting gear, cone inclusion/exclusion and sampler count. Native captures 120–121 show equipment swaps and family silhouettes. Automated fresh-starter Lobby clear: 72.11 Life, level 2, 5 items, 119 Silicon. This does not establish full-act balance or final animation quality.

