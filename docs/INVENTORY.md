# Spatial inventory — Tech Demo 0.5

The accepted direction is illustrated items with differing footprints and generous capacity. The implemented temporary backpack is **12 x 8 / 96 cells**, fixed rectangles without rotation. Worn parts do not consume backpack cells. See ITEMIZATION for the current slot, rarity, and weapon rules.

## Controls and safety

I / Tab pauses and opens inventory. Click selects; drag rearranges or equips. Right-click/double-click/button equips or unequips. Drag a weapon to LEFT or RIGHT to select its side. The quick equip action prefers an empty left slot, otherwise right; heavy weapons always reserve both. A heavy item appears in both slot controls but exists only once.

Unequipping or dropping a heavy clears both slots. Replacement first plans the positions of every displaced item, considering the incoming item's freed footprint. If anything fails to fit, no ownership, equipment, or position changes occur. Existing backpack items are never silently moved by an equip operation. Auto-pack is a separate transactional largest-first arrangement, not an optimal solver; use it when ample cells are fragmented.

Invalid drops preserve the original position. Stale drag data is rejected by item identity. Full pickups stay on the ground. DROP SELECTED places the exact item on the floor, retaining rarity, bonuses, and sockets. If all equipment is dropped, the entire kit may not fit in the bag at once; remaining drops stay recoverable on the ground. Empty weapon slots use a small bare attack.

## Base footprints and art

| Category | Base footprints |
| --- | --- |
| Head | Survey helmet 2x2; Lead visor 2x2 |
| Neck | Signal amulet 1x1; Anchor pendant 1x2 |
| Barding | Field plating 2x3; Blast carapace 3x3 |
| Harness | Utility harness 2x1; Insulated belt 2x1 |
| Matrix | Targeting matrix 2x2; Circuit matrix 1x3 |
| Weapons | Laser carbine 1x3; Phase blade 1x3; Collapse cannon 2x4; Reactor launcher 2x4 |
| Locomotion | Paw servos 2x2; Crawler treads 3x2; Spider struts 3x3; Hover skirt 3x2 |

Each base has an original SVG illustration corresponding to its visible hardware. Rarity colors appear on tiles and world labels; selected tiles use an amber outline.

## Item cards and fitting bay (0.5)

Accepted request: Diablo 2-inspired hover cards with the graphic, total damage/defense and a concise breakdown of added bonuses; a live equipment preview inspired by the usefulness of Grim Dawn's layout, without copying it or adding a full stat sheet.

Hover either a backpack item or worn slot for 0.18 seconds. An illustrated card appears beside the inventory, clamped to the screen. It shows rarity/name/category, the item's inclusive damage and/or defense, nonzero bonuses, a short behavior summary, socket contents if present, and footprint/action hint. Weapon cadence is shown so slow heavy weapons remain distinguishable. No zero-value rows, primary/secondary labels, or exhaustive formula breakdown.

Damage/defense totals are the item's own values, including rolled direct bonuses and active loose socket contributions. The bonus list beneath is explanatory, not an additional amount to add to the total. Attribute bonuses stay explicit (+Strength etc.); their derived character effects are on C. Circuit activation replaces loose socket bonuses in cards just as it does in combat. Negative tradeoffs remain visible. Defense is the player-facing label for the existing armor stat; its formula is unchanged.

Cards do not intercept input and disappear on leaving, dragging, inventory close, refresh, or equipment changes. The former always-visible detailed comparison/delta sheet has been removed from inventory to reduce clutter. Selection still supports equip/unequip/drop actions. Side-specific weapon choices use drag-and-drop as before.

The fitting bay renders a separate pet using the same equipment model builder. Equipping, unequipping, dropping worn gear, socket changes, and restart update it immediately. Left/right arrow buttons rotate the preview without rotating the world character. It renders only while visible and has its own camera, lights, and world. The full character sheet stays under C.

Requirements are a documented proposal in ITEMIZATION, not an implemented lock. All white test bases remain usable immediately.

The beginner lab kit occupies 60 bag cells and seven worn slots, leaving the right weapon slot empty. It is deliberately rich in white bases for testing, not proposed campaign loot volume.

Stairs/elevators preserve inventory/layout/sockets/character/Silicon. T recovers to the garage after defeat. Garage vendors buy/sell backpack items; worn parts must be unequipped. Buyback retains exact items. Both garage and tower floor items persist across trips. NEW SORTIE clears tower-floor loot and encounters, retaining character/keycards; System reset fully reset. Closing the app does not save. No stash, stacking, item rotation, inventory expansion or disk saves. See HUB.md and ACT1.md.

## Implementation

`backpack.gd`: placement and atomic multi-slot swap plans. `inventory_grid.gd`, `inventory_tile.gd`, `equipment_slot.gd`: GUI. `loot.gd`: item definitions, rarity, illustrations and stats. `main.gd`: ownership transfers and visible model refresh. `item_card.gd`: compact item summaries and cards. `character_preview.gd`: separate fitting-bay rendering. Test evidence is in STATUS.md.

## 0.8 supply and portal extension

Wormhole, dedicated potion stacks, vendor refills, debug waypoint controls and revised hotkeys are documented in [HUD_AND_SUPPLIES.md](HUD_AND_SUPPLIES.md). H repairs are superseded by Z/X potions; potion counts persist through travel and are not refilled by garage visits. Esc/System owns full resets.
