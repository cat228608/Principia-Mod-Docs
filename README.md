# Principia Modding README

This repository now contains a runtime modding prototype for Principia.

The goal of this system is simple:

- the game creates a `mods` folder automatically
- each mod lives in its own folder
- each mod can register objects through `info.json`
- each object can have its own icon, model, texture, physics shape and Lua logic
- Lua API extension mods can inject shared helper code into the `escript` environment

This document is written as a practical GitHub guide for mod authors.

## Current Status

What already works:

- automatic creation of the `mods` folder
- loading `info.json` from each mod folder
- a `Mods` category in the in-game object browser
- menu icons for mod objects
- spawning mod objects from the `Mods` category into the world
- basic object physics
- Lua logic attached to mod objects
- shared Lua API extensions through `escript.before.lua` and `escript.after.lua`

What is not fully finished yet:

- replacing compiled C++ source files at runtime is not supported
- `escript.cc.patch` does not replace the compiled engine file
- custom polygon collision is not implemented yet
- custom socket coordinates are not implemented yet
- a true native creature/NPC plugin API is not implemented yet

Important limitation:

The current "NPC mod" path is a scripted mod entity with AI-like Lua behavior.
It is not yet a full native built-in creature class like the game's hardcoded robots/animals.

## Where Mods Go

Mods are loaded from the user data folder.

Windows:

```text
%APPDATA%\Principia\mods
```

Typical real path:

```text
C:\Users\<YourName>\AppData\Roaming\Principia\mods
```

Portable-style build:

```text
userdata\mods
```

Each mod must be placed in its own folder:

```text
mods/
  my_mod/
    info.json
```

## Mod Types

The current system supports three practical mod styles.

### 1. Object Mod

An object mod adds one or more placeable entities to the `Mods` category inside the game.

Use this for:

- blocks
- mechanisms
- panels
- machines
- decorative objects
- scripted devices

### 2. Scripted NPC Mod

A scripted NPC mod is still technically an object mod, but its Lua script is written as behavior code rather than passive object logic.

Use this for:

- simple roaming bots
- scripted sentries
- interactive machines that react to the world
- pseudo-creatures implemented with object logic

Important:

This is not yet a true native creature API.
Think of it as "behavior-driven scripted entity" rather than "full hardcoded biological NPC class".

### 3. Lua API Patch Mod

A Lua API patch mod does not add placeable objects.
Instead, it injects helper code into the shared `escript` environment through:

- `escript.before.lua`
- `escript.after.lua`

Use this for:

- helper functions
- utility libraries
- shared constants
- common gameplay helpers for your object scripts

## Why `escript.cc.patch` Does Not Replace The Engine

This is important to explain clearly for users.

`escript.cc` is a C++ source file.
It is compiled into the game executable.

That means:

- you cannot replace `src/escript.cc` from a mod at runtime
- you cannot ship `escript.cc.patch` and expect the game to hot-recompile itself
- a runtime mod can only work with data, assets, and Lua scripts that are loaded by the executable

So the supported replacement for "engine patching" right now is:

- shared Lua injection with `escript.before.lua`
- shared Lua injection with `escript.after.lua`

## Required Mod Folder Structure

Minimal mod:

```text
mods/
  my_mod/
    info.json
```

Object mod:

```text
mods/
  my_mod/
    info.json
    objects/
      my_object.json
      my_object.lua
      my_object_icon.png
      my_object_model.3ds
      my_object_texture.png
```

Lua API patch mod:

```text
mods/
  my_script_patch/
    info.json
    escript.before.lua
    escript.after.lua
```

## `info.json`

Every mod starts with `info.json`.

Minimal object-mod example:

```json
{
  "name": "My Mod",
  "author": "YourName",
  "enabled": true,
  "objects": [
    "objects/my_object.json"
  ]
}
```

Fields:

- `name`: visible mod name
- `author`: mod author name
- `enabled`: whether the mod should load
- `objects`: list of object definition files relative to the mod root

Notes:

- if `enabled` is `false`, the mod is skipped
- if `objects` is omitted or empty, the mod can still be used as a Lua API patch mod

## Object Definition JSON

Each placeable object is described by its own JSON file.

Example:

```json
{
  "id": "my_object",
  "name": "My Object",
  "icon": "objects/my_object_icon.png",
  "script": "objects/my_object.lua",
  "model": "objects/my_object_model.3ds",
  "texture": "objects/my_object_texture.png",
  "material": "metal",
  "shape": "rect",
  "width": 0.5,
  "height": 0.5,
  "menu_scale": 1.0,
  "moveable": true,
  "allow_rotation": true,
  "allow_connections": false,
  "sockets_in": 0,
  "sockets_out": 0
}
```

## Object JSON Fields Explained

### Identity

- `id`
  - internal id for your mod object
  - should be unique inside your mod

- `name`
  - human-readable in-game name

### Visuals

- `icon`
  - menu icon path
  - should point to a separate menu image
  - do not rely on your main texture as the icon unless that is intentional

- `model`
  - `.3ds` model path
  - loaded at runtime from inside the mod folder

- `texture`
  - texture image path used by the material

- `material`
  - base material family used as the rendering template

Supported values right now:

- `iomisc`
- `metal`
- `wood`
- `plastic`
- `rubber`
- `stone`
- `item`
- `robot`
- `animal`
- `colored`
- `interactive`
- `edev`

Practical advice:

- start with `metal`, `wood` or `item`
- use `edev` for technical/electronic devices
- use `interactive` if the object is supposed to feel like an active interactable item

### Physics

- `shape`
  - `rect` or `circle`

- `width`
  - half-width for rectangular collision

- `height`
  - half-height for rectangular collision

- `radius`
  - radius for circular collision

Notes:

- for `rect`, use `width` and `height`
- for `circle`, use `radius`
- these values define the physics body, not the source model size

### Placement And Behavior

- `menu_scale`
  - how large the object appears in the build menu

- `scale`
  - extra entity scale multiplier

- `moveable`
  - whether the object is moveable

- `allow_rotation`
  - whether the object can rotate

- `allow_connections`
  - whether normal connection logic should be allowed

### Material Parameters

- `density`
- `friction`
- `restitution`

If omitted, defaults are used.

### Socket Counts

- `sockets_in`
- `sockets_out`

Current limitation:

Sockets are currently auto-placed in simple evenly spaced positions.
Custom socket coordinates are not yet implemented.

## Lua Object Script

Each object can have a Lua file.

Minimal example:

```lua
function init()
end

function step()
end
```

You can treat this as the object's behavior script.

Current implementation note:

Mod objects are currently backed by the built-in `escript`-style runtime object logic.

That means object mods are best thought of as:

- a visual/physical entity
- plus an attached Lua behavior script

## Recommended Beginner Workflow

If you are making your first mod:

1. Create a new mod folder.
2. Write `info.json`.
3. Create one object JSON file.
4. Add a separate icon image.
5. Add a simple Lua file with empty `init()` and `step()`.
6. Start with `shape: "rect"` and simple `width`/`height`.
7. Start with a single object before building a whole content pack.

## Example: Simple Placeable Object

```json
{
  "id": "metal_box",
  "name": "Metal Box",
  "icon": "objects/metal_box_icon.png",
  "script": "objects/metal_box.lua",
  "model": "objects/metal_box.3ds",
  "texture": "objects/metal_box_texture.png",
  "material": "metal",
  "shape": "rect",
  "width": 0.5,
  "height": 0.5,
  "menu_scale": 1.0,
  "moveable": true,
  "allow_rotation": true,
  "allow_connections": false,
  "sockets_in": 0,
  "sockets_out": 0
}
```

`metal_box.lua`:

```lua
function init()
end

function step()
end
```

## Example: Scripted NPC Skeleton

This is the current recommended pattern for an NPC-like mod.

`npc_bot.json`:

```json
{
  "id": "npc_bot",
  "name": "NPC Bot",
  "icon": "objects/npc_bot_icon.png",
  "script": "objects/npc_bot.lua",
  "model": "objects/npc_bot.3ds",
  "texture": "objects/npc_bot_texture.png",
  "material": "robot",
  "shape": "rect",
  "width": 0.35,
  "height": 0.6,
  "menu_scale": 1.0,
  "moveable": true,
  "allow_rotation": true,
  "allow_connections": false,
  "sockets_in": 0,
  "sockets_out": 0
}
```

`npc_bot.lua`:

```lua
local timer = 0.0

function init()
    timer = 0.0
end

function step()
    timer = timer + 1.0

    -- Put AI-like behavior here.
    -- Example ideas:
    -- move, animate, react to nearby entities,
    -- emit signals, trigger effects, patrol, etc.
end
```

Important:

This skeleton is for a scripted pseudo-NPC.
It is not yet a full native creature implementation.

## Example: Lua API Patch Mod

If you want to extend the shared Lua environment for all mod scripts, use:

- `escript.before.lua`
- `escript.after.lua`

Example `info.json`:

```json
{
  "name": "Shared Lua Helpers",
  "author": "YourName",
  "enabled": true
}
```

Example `escript.before.lua`:

```lua
function clamp(v, min_v, max_v)
    if v < min_v then
        return min_v
    end
    if v > max_v then
        return max_v
    end
    return v
end
```

Example `escript.after.lua`:

```lua
function approach(value, target, speed)
    if value < target then
        value = value + speed
        if value > target then
            value = target
        end
    elseif value > target then
        value = value - speed
        if value < target then
            value = target
        end
    end

    return value
end
```

Use this when you want many object scripts to share common helpers.

## Asset Guidelines

### Icons

Use a dedicated icon file for the menu.

Do:

- make a separate square PNG
- keep it readable at small sizes

Do not:

- reuse a large noisy texture as the menu icon unless that is intentional

### Models

Right now the runtime model loader expects:

- `.3ds` mesh files
- reasonable pivot/origin placement
- sane scale

Practical recommendation:

- export simple, clean meshes first
- test with a basic box-like asset before moving to complex models

### Textures

Use PNG for best results.

Recommended:

- power-of-two texture sizes if possible
- simple first-pass textures for debugging

## How To Test A Mod

1. Put the mod folder into `%APPDATA%\Principia\mods`.
2. Start the game.
3. Open the object browser.
4. Open the `Mods` category.
5. Spawn the object into the world.
6. Confirm:
   - the icon appears
   - the object can be dragged out
   - the object collides
   - the script loads

## Debugging Checklist

If the mod does not appear:

- check that the mod folder is inside `%APPDATA%\Principia\mods`
- check that `info.json` exists
- check that `"enabled": true`
- check that `objects` points to valid relative JSON paths

If the object appears in the menu but not in the world:

- check `shape`
- check `width`, `height` or `radius`
- check the model path
- check the texture path

If the object spawns but is invisible:

- check the `.3ds` file
- check the texture file
- check exported scale and pivot/origin
- try a simpler test model first

If the script does nothing:

- make sure the `script` path is correct
- start with a minimal `init()` and `step()`
- add behavior gradually

## Repository Examples

There are ready-to-copy examples in:

```text
examples/mods/
```

Included examples:

- `examples/mods/00_example_standard_object`
  - example object mod
  - built from standard game assets copied into a mod folder

- `examples/mods/01_object_skeleton`
  - minimal placeable object template

- `examples/mods/02_npc_skeleton`
  - scripted NPC-style template

- `examples/mods/03_lua_patch_skeleton`
  - shared Lua API patch template

Important note for GitHub readers:

Right next to this `README.md`, the repository already contains an example object mod based on standard Principia assets inside `examples/mods/00_example_standard_object`.

## Recommended Publishing Structure

If you publish a mod on GitHub, a clean layout is:

```text
MyPrincipiaMod/
  README.md
  my_mod/
    info.json
    objects/
      my_object.json
      my_object.lua
      my_object_icon.png
      my_object_model.3ds
      my_object_texture.png
```

That way users can copy the `my_mod` folder directly into:

```text
%APPDATA%\Principia\mods
```

## Roadmap Ideas

Suggested future upgrades for the modding system:

- polygon and compound collision shapes
- custom socket coordinates
- custom cable types
- per-mod enable/disable menu
- mod validation and error UI
- true native plugin interface
- full creature/NPC API

## Final Notes

This modding layer is already good enough for:

- custom placeable objects
- custom visuals
- custom Lua-driven behavior
- shared script helper mods

It is not yet the final full plugin architecture.
But it is a practical base that modders can already use, inspect, and extend.
