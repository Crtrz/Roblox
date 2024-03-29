local Workspace = game:WaitForChild("Workspace")
local Stages = Workspace:WaitForChild("Stages")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(PlayerAdded)
	local StatusEffectsFolder = Instance.new("Folder", PlayerAdded)
	StatusEffectsFolder.Name = "StatusEffectsFolder"
	
	local LeaderstatsStatsFolder = Instance.new("Folder", PlayerAdded)
	LeaderstatsStatsFolder.Name = "leaderstats"

	local CurrentStageValue = Instance.new("NumberValue", LeaderstatsStatsFolder)
	CurrentStageValue.Name = "CurrentStageValue"
	CurrentStageValue.Value = 0
end)

for _, Object in pairs(Stages:GetDescendants()) do
	task.spawn(function()
		if Object.Name ~= "Ignore" and Object:IsA("BasePart") and Object:FindFirstAncestor("ObbyParts") then
			
			if Object:FindFirstChild("StartingStallTime") then
				task.wait(Object:FindFirstChild("StartingStallTime").Value)
			end
			
			print("Finished", Object)
			
			local FadingSettings = Object:FindFirstChild("FadingSettings")
			local MoveSettings = Object:FindFirstChild("MoveSettings")
			local CurrentCollision = Object.CanCollide
			local CurrentTransparency = Object.Transparency
			
			local VisiblityInfo = TweenInfo.new(
				FadingSettings:FindFirstChild("Speed").Value,
				Enum.EasingStyle[FadingSettings:FindFirstChild("EasingStyle").Value],
				Enum.EasingDirection[FadingSettings:FindFirstChild("EasingDirection").Value],
				0,
				false,
				0
			)
			
			
			local InvisiblityTween = TweenService:Create(Object,VisiblityInfo,{Transparency = FadingSettings:FindFirstChild("Visibility").Value})
			local ReverseInvisiblityTween = TweenService:Create(Object,VisiblityInfo,{Transparency = CurrentTransparency})
			
			local StatusEffects = Object:FindFirstChild("StatusEffects")
			local DeathPart = Object:WaitForChild("DeathPart").Value
			local FadingEnabled = Object:WaitForChild("FadingEnabled").Value
			
			local StallingFade 
			if Object:FindFirstChild("LoopFadeEnabled").Value == true then
				
				task.spawn(function()
					for x = 1, math.huge do
						StallingFade = true
					

						InvisiblityTween:Play()
						InvisiblityTween.Completed:Wait()

						if FadingSettings:FindFirstChild("ToggleCollide").Value == true then
							Object.CanCollide = not Object.CanCollide
						end

						task.wait(FadingSettings:FindFirstChild("StallTime").Value/2)

						if FadingSettings:FindFirstChild("Reverse").Value then
							ReverseInvisiblityTween:Play(); 
							Object.CanCollide = CurrentCollision
							ReverseInvisiblityTween.Completed:Wait()
						else
							Object.CanCollide = CurrentCollision
							Object.Transparency = CurrentTransparency
						end

						task.wait(FadingSettings:FindFirstChild("StallTime").Value/2)
						StallingFade = false
					end
				end)
			end
			
			if (FadingEnabled) or (DeathPart) or (Object:WaitForChild("StatusEffects") and #StatusEffects:GetChildren() ~= 0) then
				local function onTouch(part)
					local Character = part.Parent
					local Player = Players:GetPlayerFromCharacter(Character)
					local Humanoid = Character:FindFirstChild("Humanoid")

					if not Humanoid or not Player then
						return
					end
					
					if FadingSettings:FindFirstChild("DisableTouch").Value and FadingSettings:FindFirstChild("Visibility").Value == Object.Transparency then
						return
					end
					
					local LeaderStats = Player:FindFirstChild("leaderstats")
					local CurrentStatusEffects = Player:FindFirstChild("StatusEffectsFolder")
					
					--//DeathPart Handeler\\--
					if DeathPart then
						Humanoid.Health = 0
					end
					
					--//Fade Handeler\\--
					if FadingEnabled and not StallingFade then
						StallingFade = true
						
						task.spawn(function()
							InvisiblityTween:Play()
							InvisiblityTween.Completed:Wait()

							if FadingSettings:FindFirstChild("ToggleCollide").Value == true then
								Object.CanCollide = not Object.CanCollide
							end
							
							task.wait(FadingSettings:FindFirstChild("StallTime").Value/2)
							
							if FadingSettings:FindFirstChild("Reverse").Value then
								ReverseInvisiblityTween:Play(); 
								Object.CanCollide = CurrentCollision
								ReverseInvisiblityTween.Completed:Wait()
							else
								Object.CanCollide = CurrentCollision
								Object.Transparency = CurrentTransparency
							end
							
							task.wait(FadingSettings:FindFirstChild("StallTime").Value/2)
							StallingFade = false
						end)
					end
					
					--//Status Effect Handeler\\--
					if #StatusEffects:GetChildren() ~= 0 then
						for _, Effect in pairs(StatusEffects:GetChildren()) do
							if not CurrentStatusEffects:FindFirstChild(Effect.Name) then
								
								if Effect:GetAttribute("Duration") then
									local FirstValue = nil
									local ClonedEffect = nil
									local NewEffect = nil
									local IsHumanoidChanger = Effect:GetAttribute("HumanoidChanger")
									local TargetParent = Effect:GetAttribute("Parent")
									local IsStackAble = Effect:GetAttribute("Stackable")
									
									if not IsStackAble then
										NewEffect = Instance.new("BoolValue", CurrentStatusEffects); NewEffect.Name = Effect.Name
									end
									
									if IsHumanoidChanger then -- and Humanoid[Effect.Name]
										FirstValue = Humanoid[Effect.Name]
										Humanoid[Effect.Name] = Effect.Value
									elseif TargetParent then
										ClonedEffect = Effect:Clone()
										
										if TargetParent ~= "Character" then
											ClonedEffect.Parent = Character[TargetParent]
										else
											ClonedEffect.Parent = Character
										end
									end
									
									
									task.spawn(function()
										task.wait(Effect:GetAttribute("Duration"))
											
										if IsHumanoidChanger then
											Humanoid[Effect.Name] = FirstValue
										end
											
										if ClonedEffect then
											ClonedEffect:Destroy()
										end
										
										if NewEffect then
											NewEffect:Destroy()
										end
									end)
									
								end
							end
						end
					end
				end

				Object.Touched:connect(onTouch)
			end
			
			if Object:WaitForChild("MovingEnabled").Value == true then
				local Distance = MoveSettings:WaitForChild("Distance").Value
				local Speed = MoveSettings:WaitForChild("Speed").Value
				local Rotation = MoveSettings:WaitForChild("Rotation").Value
				local EasingStyle = MoveSettings:WaitForChild("EasingStyle").Value
				local EasingDirection = MoveSettings:WaitForChild("EasingDirection").Value
				if MoveSettings:WaitForChild("AutoMove").Value == true then
					Object.Position = Object.Position - Distance/2
				end
				
				if MoveSettings:WaitForChild("AutoRotate").Value == true then
					Object.Rotation = Object.Rotation + Rotation/2
				end

				local tinfo = TweenInfo.new(

					Speed,
					Enum.EasingStyle[EasingStyle],
					Enum.EasingDirection[EasingDirection],
					math.huge,
					true,
					0
				)

				local prop = {
					CFrame = (Object.CFrame + Distance) * CFrame.fromEulerAnglesXYZ(math.rad(Rotation.X),math.rad(Rotation.Y),math.rad(Rotation.Z))

				}

				local tween = TweenService:Create(Object,tinfo,prop)
				tween:Play()
			end
			
			
		elseif Object.Name == "CheckPoint" and Object:IsA("BasePart") and Object:GetAttribute("Active") and Object:GetAttribute("Active") == true then
			Object.Touched:Connect(function(Touched)
				local Humanoid = Touched.Parent:FindFirstChild("Humanoid")
				local playerFromCharacter = Players:GetPlayerFromCharacter(Touched.Parent)
				
				if Humanoid and playerFromCharacter and playerFromCharacter:FindFirstChild("leaderstats"):FindFirstChild("CurrentStageValue").Value < Object:GetAttribute("StageValue") then
					playerFromCharacter:FindFirstChild("leaderstats"):FindFirstChild("CurrentStageValue").Value = Object:GetAttribute("StageValue")
				end
			end)
		end
	end)
end
