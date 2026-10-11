# NeverYield changelog

Version rules: **minor** bump when an update adds commands, **patch** for fixes/tweaks, **major** for big rewrites.
Versions before 1.11.3 were reconstructed from the Desktop `.bakN` backups (one backup = one update).

| Version | Date | Commands | Change |
|---|---|---|---|
| 1.28.1 | 10-10 | 639 | Requiem: Begin card after teleports (game menus first), rpgspot / rpgspots |
| 1.28.0 | 10-10 | 637 | Requiem RPG map test: rpgmaps, rpgmap 1-7/here, unrpg (teleport to each Disc One game + test scene) |
| 1.27.2 | 10-10 | 634 | roomreset: closes the door first, empty save instead of delfile |
| 1.27.1 | 10-10 | 634 | House clock ambience only plays when the radio is off |
| 1.27.0 | 10-10 | 634 | House music + Retro Radio (11 stations, E/F); Agartha: 22 calm piano/harp tracks with reverb; more tracks for clowns, Diamond Rush, jingles and sound effects; music never keeps playing after you leave Agartha or the house |
| 1.26.1 | 10-10 | 634 | Light switches and other small items can be picked up in Edit mode (E-prompts hidden while decorating); Agartha pond: no more blocky terrain-water octagon, glass water with glints |
| 1.26.0 | 10-10 | 634 | 38 detailed furniture items (89 total); 16 curtain styles incl. match walls/floor, each window opens alone; 2 windows per room; inner doors fill their opening + door stops; wall effects avoid doorways; Agartha sitting pose works on AnimationConstraint rigs |
| 1.25.4 | 10-10 | 634 | Doors in every doorway between rooms (E to open/close, swing + creak); curtains slide shut per room (E at a window or Edit > Style), saved |
| 1.25.3 | 10-10 | 634 | Agartha: no bench; kas's avatar sits on the grass behind the cottage leaning on the stone base, posed by placing and anchoring every part (the bench pose was reset in-game) |
| 1.25.2 | 10-10 | 634 | Clowns stop getting lost: real stuck/lost/unreachable detection (the old check never fired), they return 30-45 studs away out of view where a path to you exists; slimmer pathing agent, truss climbing, faster re-pathing |
| 1.25.1 | 10-10 | 634 | 8 new floors + 9 new walls with real effects (fire, galaxy, diamond, rainbow, neon grid, void, clouds, water with fish, matrix, aquarium...), each unlocked by a rare achievement |
| 1.25.0 | 10-10 | 634 | The door opens into a 4-room house (living room, bedroom, game room, kitchen) each fully customizable; working light switches with click sound; 7 new placeable lights; 15 detailed furniture items; 3 new lighting moods; wall-snap fix |
| 1.24.7 | 10-10 | 634 | kas's own avatar sits on a garden bench behind the Agartha cottage, chilling with a Space Sandwich rebuilt from the Roblox catalog mesh |
| 1.24.6 | 10-10 | 634 | Eggs crack with sound while they shake before hatching (faster, louder cracks + crack lines on the shell), then an egg-break sound |
| 1.24.5 | 10-10 | 634 | Agartha fireplace back no longer clips through the cottage wall; portal command renamed to agartha (portal still works as an alias), agarthadebug likewise |
| 1.24.4 | 10-10 | 634 | Pet skins (400) and hats (250) come from roll machines instead of direct buys: Roll 1 / Roll 5, spin-and-reveal, 1-in-N odds, duplicate refunds; Luck Potion works on rolls and is a modest boost |
| 1.24.3 | 10-10 | 634 | Pet Hub previews (My Pets cards, detail page, hatch popup) show pets from the front instead of their backs |
| 1.24.2 | 10-10 | 634 | Agartha fireplace rebuilt: real recessed firebox, hearth, grate, logs on embers, Fire + flame/spark particles, crackle sound |
| 1.24.1 | 10-10 | 634 | Pet tails fixed: fox, dragon, cat and dog tail segments were tilted the wrong way and floated off the body; now one connected curve |
| 1.24.0 | 10-10 | 634 | 92 new achievements in every category (bronze to mythic) with 33 new trophy designs, all placeable in your room; new Secrets tab (hidden until unlocked); Completionist no longer needs secrets |
| 1.23.4 | 10-10 | 634 | Room door view really shows your room now: seen from the front the doorway's corners were mirrored on screen, so the window strips were 0 pixels wide (invisible); `doordebug` also shows the window width |
| 1.23.3 | 10-10 | 634 | Room door view: only solid visible parts (not effects, pets or players) hide the view; a failed view build is reported; new `doordebug` |
| 1.23.2 | 10-10 | 633 | Portal runs lighter: tiny details are left out of the window copies of Agartha (the island itself is unchanged) |
| 1.23.1 | 10-10 | 633 | Clowns stuck far away (behind walls, on roofs) come back near you so a round can always end |
| 1.23.0 | 10-10 | 633 | New `achievements` menu (Settings button): 113 achievements (IY basics, NeverYield commands, minigames, pets, playtime, games, people, 24 front-page games) each with its own trophy model + unlock popups; `door` now leads to your own cozy room you decorate (28 furniture items, 17 unlockable, trophies, floors/walls/lighting, saves; `roomreset`); clowns: waves with 5 s breaks, tougher every round, flying clowns from round 10, clown cash + Clown Shop (B), health bar, hold-to-fire gun held in the hand; pets: Secret tier (4 secret species), 14 random effects, 1-in-N odds, mystery skins/hats, hidden index; portal/door windows show the real map (terrain tiles, nearest parts) and the round window has no notches; horror Watcher hunts (sprints at you); Agartha pond always has water |
| 1.22.1 | 10-10 | 633 | Pets: 4 hatch jingles + 4 level-up jingles (random), Settings tab to mute celebration music / pet sounds, only one egg hatches at a time and the Pet Hub closes when hatching; Diamond Rush ends with one of 5 jingles |
| 1.22.0 | 10-10 | 633 | New `door`: old wooden door with an Open prompt into a dark dusty 90s marble study hall (see-through doorway, sittable chairs, flickering lights, CRTs, bookshelves); portal closes 5 s after you walk through (type portal again to return); Agartha pond water refills so it can't vanish |
| 1.21.3 | 10-10 | 631 | Portal opens 20 studs away and bigger; window is a near-circle inside the ring with a glowing swirling edge and a gradient sky; bigger home snapshot; `portaldebug` |
| 1.21.2 | 10-10 | 630 | `fuckoff` also resets WalkSpeed, JumpPower/JumpHeight, HipHeight, slope, gravity, FOV and camera zoom to the game's own values (taken from fresh spawns) |
| 1.21.1 | 10-10 | 630 | Agartha: portal view drawn on screen with a mirrored camera (true see-through window, both ways); pond is real terrain water; chairs, bench and armchair are sittable and the bed sleepable (E, jump to get up) |
| 1.21.0 | 10-10 | 630 | Clowns are real R6 characters (Humanoid + default walk animation, clown costume), use pathfinding and get faster (20 to 30); Clown Buster gun one-shots them; kills/survival saved; stats panel gets Minigames (Diamond Rush + Clowns) and Pets tabs |
| 1.20.0 | 10-10 | 630 | Frame styles around the panel (Neon Pulse default, Classic Lines, Marquee, HUD, Electric, Orbit, Chain, Halo Glow, RGB, None) + Theme Studio Frame tab + `frame`; Agartha portal window fixed (was empty: viewports don't render in CanvasGroups) with glass sheen and matched camera; cottage gets real glass windows, open door and a full interior |
| 1.19.0 | 10-10 | 629 | New `clown`: a growing crowd of part-built clowns chases you with creepy circus music; caught = HONK, you die, then server hop |
| 1.18.0 | 10-10 | 627 | New `portal`: sling-ring style see-through gateway to Agartha (floating island with cottage, yard, waterfall, view, peaceful music); old portal replay is now `reopen` |
| 1.17.1 | 10-10 | 625 | Moon rebuilt to look like the Zelda moon (sockets, bulging eyes, brows, hooked nose, clenched teeth); masked imp rebuilt (straw hat, poncho, spiky heart mask) |
| 1.17.0 | 10-10 | 625 | Theme outlines: 16 animated panel outlines (thunder, inferno, aura, frost, code, glitch, rainbow...), Theme Studio Outlines tab, theme-matched defaults, `outline` command |
| 1.16.0 | 10-10 | 624 | Pet Hub v2: chibi models with faces, 21 species (incl. mythic Phoenix), 9 eggs, potions, instant hatch, toy ball, 10 hats, slot/storage/incubator upgrades, shop sub-tabs |
| 1.15.1 | 10-10 | 624 | Breakdance is a real looping routine (toprock, windmill, headspin, freeze); lean pivots at the feet; headstand on the head; moonwalk slides its legs; crabwalk crab pose; blink stops at walls; dash is a real burst |
| 1.15.0 | 10-10 | 624 | New `moon`: angry-faced moon falls with a masked imp, countdown, quakes, impact fireball, then shop to a new server (`moon` alias moved off moongravity) |
| 1.14.1 | 10-10 | 623 | Horror 2.0: pitch-black fog, The Watcher hunts you (moves only when unseen), flashlight flicker, heartbeat/whispers/static, jumpscare that kills you (`horror safe` = no dying) |
| 1.14.0 | 10-10 | 623 | Pet Hub replaces the cube pet: 10 species, 11 skins, eggs + hatch popups, food, hunger/happiness, levels to 50, tricks, coins, breeding, index; Settings button |
| 1.13.2 | 10-10 | 621 | Diamond Rush: diamonds were invisible (only the hitbox moved to the sky, the glass stayed behind); whole model now moves together, glass slightly more solid |
| 1.13.1 | 10-10 | 621 | Review fixes: statsreset also resets this server's counters; stats save reports failed writes; lighting effects only cut short the fade of the properties they use; damaged stats backups get a timestamp |
| 1.13.0 | 10-10 | 621 | New `midas` (everything you touch turns gold) and `diamond` Diamond Rush mini-game (diamond models rain down, popups, music, score/timer, saved best); snow footsteps spaced out with 8 varied clips |
| 1.12.2 | 10-10 | 617 | `weather` with no type picks a random weather instead of always snow |
| 1.12.1 | 10-10 | 617 | THE END black hole revamp: black horizon, photon ring + lensing glow, swirling cloud accretion disk, spiralling light streams, polar jets, map parts heat up and glow, world dims, shockwave on collapse |
| 1.12.0 | 10-10 | 617 | Weather sounds vary: 3-6 verified loops per weather, crossfade to a new one every 1.5-2.5 min, plus one-shot accents (owls, wolves, distant thunder, coyotes, wind chimes, wood cracks); new `skipweather` |
| 1.11.3 | 10-10 | 616 | Stats button in Settings (under Theme Studio); NeverYield shows its own version number in the title |
| 1.11.3 | 10-10 02:02 | 616 | fixes / tweaks |
| 1.11.2 | 10-10 02:02 | 616 | Emoji/symbols written as ASCII escape codes so Theme Studio shows real emoji even when Volt loads the file as ANSI |
| 1.11.1 | 10-10 01:54 | 616 | Stats save once a minute; no double counting after unload + re-execute |
| 1.11.0 | 10-10 01:47 | 616 | Fixed all 12 review bugs (stuck snow/dark lighting, lighting restore order, END escape, respawn effects, helicopter hover, sprint key, custom rim, takeover header, weather textures, cleanup) + new lifetime stats tracker (stats, kd, mychats, statsexport, statssave, statsreset, chatlogging) |
| 1.10.6 | 10-10 01:41 | 609 | fixes / tweaks |
| 1.10.5 | 10-10 00:48 | 609 | fixes / tweaks |
| 1.10.4 | 10-10 00:28 | 609 | fixes / tweaks |
| 1.10.3 | 10-10 00:26 | 609 | fixes / tweaks |
| 1.10.2 | 10-10 00:23 | 609 | fixes / tweaks |
| 1.10.1 | 10-10 00:21 | 609 | fixes / tweaks |
| 1.10.0 | 10-10 00:20 | 609 | added 1 commands |
| 1.9.0 | 10-10 00:15 | 608 | added 1 commands |
| 1.8.2 | 10-10 00:09 | 607 | fixes / tweaks |
| 1.8.1 | 10-10 00:09 | 607 | fixes / tweaks |
| 1.8.0 | 10-10 00:01 | 607 | added 1 commands |
| 1.7.0 | 10-09 23:55 | 606 | added 1 commands |
| 1.6.5 | 10-09 23:53 | 605 | fixes / tweaks |
| 1.6.4 | 10-09 21:20 | 605 | fixes / tweaks |
| 1.6.3 | 10-09 21:16 | 605 | fixes / tweaks |
| 1.6.2 | 10-09 21:13 | 605 | fixes / tweaks |
| 1.6.1 | 10-09 21:11 | 605 | fixes / tweaks |
| 1.6.0 | 10-09 21:06 | 605 | added 1 commands |
| 1.5.2 | 10-09 21:02 | 604 | fixes / tweaks |
| 1.5.1 | 10-09 21:00 | 604 | fixes / tweaks |
| 1.5.0 | 10-09 20:45 | 604 | added 2 commands |
| 1.4.0 | 10-09 20:40 | 602 | added 90 commands |
| 1.3.0 | 10-09 20:26 | 512 | added 1 commands |
| 1.2.0 | 10-09 20:20 | 511 | added 4 commands |
| 1.1.1 | 10-09 20:16 | 507 | fixes / tweaks |
| 1.1.0 | 10-09 20:07 | 507 | added 25 commands |
| 1.0.0 | 10-09 19:39 | 482 | First NeverYield edit (branding, space look) |
