local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HitboxModule = {}
HitboxModule.__index = HitboxModule

--//HitboxModule\\--
function HitboxModule.new(WeldPart, Offset, Size, Excluded)
	local self = {}

	--//Creating The Hitbox\\--
	local HitEvent = Instance.new("BindableEvent")
	HitEvent.Name = "HitEvent"

	local Hitbox = Instance.new("Part")
	Hitbox.Size = Size
	Hitbox.Parent = workspace
	Hitbox.CanCollide = false
	Hitbox.Massless = true
	Hitbox.Transparency = 1

	Hitbox.BrickColor = BrickColor.new("Really red")

	local Weld = Instance.new("Weld", Hitbox)
	Weld.Part0 = WeldPart
	Weld.Part1 = Hitbox
	Weld.C0 = Offset

	local OverlapParams = OverlapParams.new()
	OverlapParams.FilterType = Enum.RaycastFilterType.Include
	OverlapParams.FilterDescendantsInstances = {workspace}

	local AlreadyIncluded = Excluded

	local HitboxConnection = RunService.Stepped:Connect(function()
		for _, Object in pairs(workspace:GetPartsInPart(Hitbox, OverlapParams)) do
			local CharacterHit = Object:FindFirstAncestorOfClass("Model")
			if not CharacterHit or table.find(AlreadyIncluded, CharacterHit) then
				continue
			end

			HitEvent:Fire(CharacterHit)
			break
		end
	end)

	--//Passing Important\\--
	self.HitEvent = HitEvent
	self.Hitbox = Hitbox
	self.HitboxConnection = HitboxConnection

	self.AlreadyCollidedWith = AlreadyIncluded

	return setmetatable(self, HitboxModule)
end

function HitboxModule:Blacklist(Character)
	table.insert(self.AlreadyCollidedWith, Character)
end

function HitboxModule:End()
	self.HitboxConnection:Disconnect()
	self.Hitbox:Destroy()
	self.HitEvent:Destroy()
end

return HitboxModule
