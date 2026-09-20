# TECH DEMO 0.1

## Accepted user request — 2026-09-17

Build the smallest useful playable laboratory for learning through play. One four-legged pet, visible equipped gear, movement and isometric camera, a small area, deliberate combat, one enemy family and stronger encounter, equipment drops, tiny randomized loot, distinct equipment bases, one Circuit experiment, a Signature item if reasonable, environmental corruption, alternate Cold War / CRT identity, and easy replay.

Exclude skill trees, multiple characters, campaign acts, large procedural systems, extensive lore, large item databases, final balance, and final UI. Placeholder content is acceptable. Begin with inspection and a minimum plan; ask before committing to the engine. Prototype choices do not establish final-game identity.

## Inspection

The workspace contains README and four design documents only. No game code, assets, project configuration, dependencies, or Git repository were present. Read all five documents before proposing implementation. No AGENTS.md was found at the workspace root or G: root.

## Approved prototype approach

The user approved this approach with "yes, go ahead". The demo is now implemented; README and PLAYTEST contain launch instructions, and STATUS records evidence and limitations. The detailed plan below is retained to distinguish initial hypotheses from measured results.

Godot 4 with GDScript, Compatibility rendering, simple 3D models, a fixed orthographic isometric camera, and a low-resolution world viewport with readable full-resolution UI. Target a local Windows playable demo first. No deployment or mobile commitment.

Use modular meshes for the pet and visible equipment attachments. This permits gear changes across movement directions without drawing every sprite/gear combination. Tradeoff: deliberate art treatment is needed to avoid a generic low-poly appearance; this is not a finished Diablo-era sprite pipeline.

Alternative: layered 2D sprites offer direct pixel-art control but require additional directional animation and equipment artwork. A browser implementation favors immediate link sharing but is less compelling for this local engine-based experiment. Neither warrants parallel implementation.

Approved structure: engine project under `prototype/`, existing documentation at root, and a root launch script. Scenes, gameplay scripts, item data, and shaders are separate. No plugin framework or production architecture.

## Temporary prototype choices — proposed, not approved canon

- Unnamed placeholder cat with a four-legged gait. No named pet/class assignment or imported sibling-project assets.
- One compact military test chamber with cover and a corrupted section; roughly 3–5 minutes per run.
- Click-to-move and click-to-attack, with WASD as an alternate input. Fixed camera angle, gentle follow, no camera rotation requirement.
- One short-range attack with readable windup and recovery. Health, enemy telegraphs, and deliberate repositioning; no skill tree or resource subsystem.
- One security-machine enemy family: several ordinary units and one tougher variant with an additional telegraphed attack. This is not an approved campaign faction or boss.
- Three experimental equipment slots: attack rig, harness, and power pack. Two visibly distinct bases per slot. A small affix pool and one or two rolled properties; temporary labels, no final rarity ladder.
- Pauseable compare/equip interface. Ensure each run provides a visible gear swap and access to the Circuit experiment rather than relying on lucky drops.
- One three-socket power pack and removable Capacitor / Relay / Ground components. Test the proposed Emergency Return recipe: standing still charges a pulse released when hit; moving cancels the charge. Show charge and cooldown. Circuit replaces standalone component benefits; no recursive triggers.
- One Signature rig, if the core loop is stable: a forked discharge replaces a single strike, trading focused damage for hitting a second nearby target. Distinct forked hardware makes the behavior identifiable on the pet.
- One corruption event: nearby machinery visually duplicates and stutters out of alignment while the floor displays a clearly telegraphed pulse hazard. Keep collision and controls consistent; offer reduced effects.
- New-run and same-seed restart controls. No persistent progression required.

## Build order after approval

1. Move the pet around the room; equip two items and confirm obvious physical appearance changes at gameplay distance.
2. Add combat, enemy family, stronger encounter, death/win states, and instant replay.
3. Add randomized drops, comparisons, and equipment stats; then the single Circuit experiment.
4. Add corruption, restrained CRT treatment, basic sound cues, and the Signature item if reasonable. Package the playable demo and document controls.

## Acceptance and learning

- Launch through a documented local command or executable.
- Move, attack, take damage, defeat enemies, collect loot, compare and equip it, and replay without restarting the application.
- Observe multiple physical gear changes during movement and attacks, without hiding the pet's identity.
- Assemble, activate, and dismantle the Circuit; verify the stated costs and benefits and prevent recursive triggering.
- Encounter recognizable corruption with readable danger cues.
- Check equipment-stat application, randomized loot validity, socket order, and restart resets with targeted automated tests.
- Separately perform interactive checks for movement, camera, attack feel, UI, gear clipping, and completion. Report any unverified interactive checks honestly.
- Ask after play: is movement deliberate or sluggish; is the pet recognizable; do drops create choices; does the Circuit change positioning; does corruption feel part of the world?

The playable experiment has been implemented. Approval of this prototype approach does not finalize engine choice for full production or approve the provisional lore, class roster, nine-slot inventory, or six item families. Actual pacing remains to be judged; the initial 3–5 minute estimate is not measured acceptance evidence.
