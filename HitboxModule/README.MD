### HitboxModule API Documentation

The HitboxModule provides functionality for creating and managing hitboxes in Roblox games. These hitboxes are used to detect collisions with specified objects and trigger events accordingly.

#### Constructor

##### `HitboxModule.new(WeldPart: BasePart, Offset: CFrame, Size: Vector3, Excluded: {Player}): HitboxModule`
- **Description**: Creates a new HitboxModule instance.
- **Parameters**:
  - `WeldPart` (BasePart): The part to which the hitbox will be attached.
  - `Offset` (CFrame): The offset position and rotation of the hitbox relative to the `WeldPart`.
  - `Size` (Vector3): The dimensions of the hitbox.
  - `Excluded` (optional, table): A table of players to exclude from collision detection initially.
- **Returns**: HitboxModule instance.

#### Methods

##### `HitboxModule:Blacklist(Character: Player)`
- **Description**: Adds a player to the exclusion list, preventing collision detection with them.
- **Parameters**:
  - `Character` (Player): The player to exclude from collision detection.
- **Returns**: None.

##### `HitboxModule:End()`
- **Description**: Terminates the hitbox instance and disconnects its event listeners.
- **Parameters**: None.
- **Returns**: None.

#### Events

##### `HitboxModule.HitEvent: BindableEvent`
- **Description**: Fired when the hitbox detects a collision with a player.
- **Parameters**:
  - `CharacterHit` (Player): The player who was hit by the hitbox.
- **Returns**: None.

#### Usage Example:

```lua
local HitboxModule = require(ReplicatedStorage.HitboxModule)

-- Create a hitbox attached to a part
local weldPart = workspace.Part
local offset = CFrame.new(0, 0, 0)
local size = Vector3.new(3, 6, 5)
local excludedPlayers = {}

local hitbox = HitboxModule.new(weldPart, offset, size, excludedPlayers)

-- Listen for hit events
hitbox.HitEvent.Event:Connect(function(characterHit)
    print("Player", characterHit.Name, "was hit!")
end)

-- Blacklist specific players
hitbox:Blacklist(game.Players.LocalPlayer)

-- End hitbox instance when no longer needed
hitbox:End()
```

This API documentation outlines the usage and functionality of the HitboxModule for creating and managing hitboxes in a Roblox game environment.
