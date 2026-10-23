# Lumenfall: Shardfront

A 3D arena roguelite for Roblox. Survive three waves of alien enemies, pick an upgrade after each wave, then take down the Rift Warden. Shards earned from each run buy permanent Vitality ranks.

## What lives where

This repo holds the game's **scripts only**. The arena, enemy models, sounds, lighting and remote events stay in the Roblox place file and are edited in Studio as usual.

| File | Roblox location | Role |
|---|---|---|
| `src/server/ShardfrontServer.server.luau` | ServerScriptService › ShardfrontServer | Entry point: player join/leave, remote events, game loop |
| `src/server/ShardfrontGame.luau` | ServerScriptService › ShardfrontGame | Runs, waves, enemy AI, combat, upgrades, saving |
| `src/shared/ShardfrontView.luau` | ReplicatedStorage › ShardfrontView | UI, input, sounds, visual effects |
| `src/client/ShardfrontClient.client.luau` | StarterPlayerScripts › ShardfrontClient | Starts the UI |

`docs/original-spec.md` is the design brief the game was first built from.

The place file must contain these, which the scripts expect:
- `ReplicatedStorage/ShardfrontRemotes` with RemoteEvents `Command`, `State`, `Effect`
- `ReplicatedStorage` sounds `MusicBed`, `HitSfx`, `ShotSfx`
- `ServerStorage` models `SkitterTemplate`, `SporeTemplate`, `WardenTemplate`
- `Workspace` folders `Arena`, `EnemyVisuals`, `Projectiles`

## Syncing into Studio with Rojo

**Easy way (Windows):** double-click `start-rojo.bat`. The first time, it downloads Rojo and installs the Studio plugin (restart Studio afterwards). After that it just starts syncing. Then in Studio: **Plugins › Rojo › Connect**.

Manual way:
1. Install the **Rojo** plugin in Studio (Creator Store, search "Rojo").
2. Download the Rojo program from <https://github.com/rojo-rbx/rojo/releases> (the Windows `.zip`), and put `rojo.exe` in this folder.
3. Run `rojo serve` in this folder, then in Studio: **Plugins › Rojo › Connect**.

To get new changes: in GitHub Desktop, **Fetch origin** › **Pull**. Studio updates automatically while Rojo is connected.

While connected, edit the four scripts above **only in this repo**. Changes made to them in Studio get overwritten. Everything else in the place is still edited in Studio; remember to publish the place as usual.
