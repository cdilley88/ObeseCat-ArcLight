# Hub and Silicon — Tech Demo 0.7

## Accepted user direction

The hub is the new spawn area. Give it the social/safe-town role of Diablo 2 towns with an original alternate-Cold-War presentation. Plan a different hub per act. Implement weapon/armor vendors, selling loot, a basic currency named **Silicon**, and a door/portal to start a new run. Include a developer NPC for changing stats, level, currency, and related test values. Future roles include gambling, special currency, cosmetics, and quest contacts.

## Current implementation — temporary choices

**Act I / Garage Refuge** is the underground parking-garage spawn requested for the tower climb. Concrete walls/pillars, parking stripes, fluorescent fixtures and low service bays replace the plaza. Its name, NPC identities and layouts remain temporary. Six pet contacts retain their roles:

| Contact | Current function |
| --- | --- |
| Weapons | Buy weapon stock; sell any backpack part; shared buyback |
| Armor | Buy body/Matrix/locomotion stock; sell any backpack part; shared buyback |
| Signal Broker | Clearly marked future gambling/special-currency role |
| Identity / Style | Clearly marked future cosmetics role |
| Dispatch | Run directions and future act quest role; no quest state/rewards yet |
| DEV / DEBUG | Set level, unspent points, Silicon, Strength, Dexterity, Vitality, Energy; refill resources |

Click a contact to walk over and interact automatically, or approach within about two meters and press E. Interaction endpoints avoid stall collision areas. Contacts have floating role labels. Vendor/dialog screens pause and close with Escape or CLOSE. Opening I/C closes the contact screen first. Combat damage cannot hurt the character in town.

## Run loop and retained state

Enter begins in the garage. The northern **STAIRS / LOBBY** enters Act I; the adjacent **KEYCARD ELEVATOR** travels to authorized stops. **V** opens the route screen, without remote travel. Defeat floor supervisors for keycards. **T** recovers to the garage only after defeat. Use stairs/elevators during normal exploration. Full travel rules and route are in ACT1.md.

Trips retain character, equipment, backpack, Silicon and buyback. Both garage and tower floor drops persist across visits; enemy damage/corpses persist too. Reaching the garage refills Life/Mana. Stairs between combat floors do not refill them. Queued attacks and statuses clear on travel. No death penalty yet.

**NEW SORTIE** in the garage map/elevator respawns tower encounters and clears their floor loot; character/keycards/garage-floor items remain. **System reset fully reset** character, tower, keycards and economy. Closing the app loses the session. Other acts/hubs are not implemented.

## Prototype economy

- Start with **80 Silicon** and the existing 18 white test bases.
- Fixed area rewards: regular units give tier + 2 Silicon; supervisors give tier × 3 + 9. The Lobby gives **30 per clear**. Dead enemies cannot pay twice. Currency has no backpack footprint.
- Sale value = 8 + (width x height x 2) + (rarity tier x 18) + (min(item level,12) x 2). Stock price is three times sale value. All numbers are temporary.
- Shops offer each relevant white base plus one green sample. Stock refreshes on entering Lobby from the garage or choosing NEW SORTIE, using the highest recovered keycard tier and an independent seeded RNG; reopening a shop does not reroll stock or consume combat RNG. Purchased stock entries disappear until restock.
- Vendors only list unequipped backpack items for sale. Unequip first to sell worn gear. Selling removes the exact owned item and credits its value once.
- Both vendors share session buyback at the exact sale price, preserving rolled bonuses and sockets. Buyback survives trips; there is no timed expiry or capacity limit in this small prototype.
- Purchases/buyback check wallet and spatial capacity before charging/removing stock. Failure preserves currency and item ownership. Repeated/stale transaction references are rejected. Buy/resell cannot generate profit.
- No alternate currency, gambling, cosmetic purchase, quest payout, merchant reputation, repair fees, or final economy balance yet.

## Debug operator

This is an explicitly labeled sandbox tool. Level range 1–99; attributes 1–999; unspent points 0–9,999; Silicon 0–999,999. Apply sets the entered values, resets current XP to zero, and refills Life/Mana. Level changes do not silently calculate a new point allocation: points and attributes are independent fields. Low Strength is guarded so bare damage cannot become negative and heal an enemy. Debug APIs only apply while speaking to the operator in the hub.

## Implementation / evidence

`hub.gd` builds the garage/contacts/gates; `economy.gd` owns deterministic stock and prices; `hub_menu.gd` owns vendor/dialog/debug presentation. `main.gd` owns area transitions, identity-based transactions, currency, interaction navigation and debug application. Current checks and artifact paths are in STATUS. ACT1.md owns the authored tower route; quests and other acts remain unimplemented.

## 0.8 supply and portal extension

Wormhole, dedicated potion stacks, vendor refills, debug waypoint controls and revised hotkeys are documented in [HUD_AND_SUPPLIES.md](HUD_AND_SUPPLIES.md). H repairs are superseded by Z/X potions; potion counts persist through travel and are not refilled by garage visits. Esc/System owns full resets.

## Vendor inventory presentation — 0.8.1

Accepted request: illustrate vendor inventory with item footprints, inspired by Diablo 2's shop grids. Implemented two spatial displays: a paged 10×8 merchant tray and the player's actual 12×8 backpack layout. Original item SVG art is drawn without transparent margins, retaining aspect ratio; rarity borders and hover/selection highlights distinguish parts. Worn parts remain excluded from sale. Hover updates the adjacent illustrated item card and Silicon price without selecting or transacting. Click selects; explicit Buy/Sell performs the existing guarded transaction. Buyback uses the same paged tray and exact-item records, with no artificial history cap. No drag-to-purchase, new stock, equipment, prices or economy changes.

`trade_grid.gd` owns display packing/paging/drawing and input. It does not modify item grid positions or ownership. Merchant layouts are presentation-only; player bag coordinates are preserved. Existing transaction APIs remain in `main.gd`. `render_vendor_grid.gd` validates hover, layout, sale, buyback, purchase and multi-page history through native input.


## 2026-09-18 — weapons and debug arena

User-authorized 0.10 direction and implemented temporary rules are recorded in [WEAPONS_AND_ARENA.md](WEAPONS_AND_ARENA.md). This supersedes four-tier chest descriptions: containers now have five tiers; CEO rewards a gold act-boss hoard. DEV opens a separate repeatable test range. Weapon families now include quick melee, wide heavy melee and traveling explosive missiles. Existing cannon and carbine remain.
