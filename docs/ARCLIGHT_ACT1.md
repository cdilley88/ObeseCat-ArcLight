# ObeseCat ArcLight / Act I 0.13

## Accepted user direction
ObeseCat ArcLight is the title, in the ObeseCat universe. Garage Refuge remains town. Main route: Lobby/Concourse 1–3; Maintenance & Housekeeping 4–6; Research Lab 7–9; Restaurant & Lounge 10–12; Rooftop Gardens 13–15; Penthouse 16–18; ObeseCat showdown 19. Difficulty stays tied to floors, not player level. Sentries use lasers, rockets and energy blades with stationary, patrol and chase behavior.

Unique is an authored rarity above Magenta, with fixed stats and distinctive graphics. ChefBot Hat: 2 Defense, +20% Heat resistance, +5 flat Heat damage, +3 to all four attributes, -15 Life. It has a golden animated frame, chef-hat inventory art and a worn chef-hat model. ChefBot drops it. Dispatch gives the ChefBot quest after Restaurant floor 10 is entered.

## Implemented temporary choices
ChefBot occupies floor 12. Entering floor 10 makes Dispatch's quest available (!); accept in town, defeat ChefBot, then report back (?). Boss loot does not require quest acceptance. Reporting completes the quest without an additional currency/XP reward. A defeated boss cannot drop twice in the same floor state; new sorties allow farming. Quest progress survives sorties/seed changes but full character reset clears it.

There are six elevator destinations, at the first floor of each three-floor area. Floor supervisors award progression keycards; the first floor supervisor unlocks that area's elevator. All 19 main floors retain state during a sortie. The three existing optional annexes remain. Layout variation selects seeded authored partition/pod/cover patterns with navigable corridors, not arbitrary procedural dungeon topology. Each area's three floors select different patterns. Enemy placements and loot use the existing independent seeded streams.

Laser shots and blade attacks telegraph; rockets travel with smoke and impact explosions. Patrol/chase behavior and boss meshes are prototype content. ObeseCat on 19 ends Act I and emits a brief ArcLight pulse. No Act II is implemented. Combat numbers, floor reward curves, boss difficulty, quest UI and exact waypoint unlock rules remain provisional.

The nuclear ArcLight flash leading to a wasteland Act II is a user story proposal to develop later, not finalized lore. No disk saves yet.

## Try it
Play normally from Garage or use DEV to unlock waypoints and adjust level/resources. Visit Restaurant floor 10, return through a Wormhole, accept Dispatch's quest, climb to floor 12, defeat ChefBot, collect/equip the hat, then report to Dispatch. Check inventory hover and C → Modifiers. Try the same seed twice and then randomize it to compare floor layouts and sentries.

## Validation
0.13 rule suites and native screenshots are in artifacts. Native checks exercised quest acceptance and hat equipment; screenshots 110–114 cover route map, quest, ChefBot, Unique card/model and ObeseCat. Automated ordinary Lobby combat cleared with 75.17 Life, level 2, 22 inventory items and 117 Silicon. Full 19-floor balance and player feel still require playtesting.
