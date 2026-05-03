getgenv().CeaseEncountered = getgenv().CeaseEncountered or false

---====== Services ======---
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Plr = Players.LocalPlayer

---====== Detect Rush Moving ======---

local function waitForRush()
	for _, v in pairs(Workspace:GetDescendants()) do
		if v.Name == "RushMoving" then
			return
		end
	end

	local found = false
	local connection
	connection = Workspace.DescendantAdded:Connect(function(obj)
		if obj.Name == "RushMoving" then
			found = true
			connection:Disconnect()
		end
	end)

	repeat task.wait() until found
end

---====== Blue Lighting ======---

local saved = {}
local lightingConnection

local function makeBlue()
	saved.Lighting = {
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient
	}

	TweenService:Create(Lighting, TweenInfo.new(0.5), {
		Ambient = Color3.fromRGB(0, 80, 255),
		OutdoorAmbient = Color3.fromRGB(0, 80, 255)
	}):Play()

	lightingConnection = RunService.RenderStepped:Connect(function()
		Lighting.Ambient = Color3.fromRGB(0, 80, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(0, 80, 255)
	end)
end

local function restoreLighting()
	if lightingConnection then
		lightingConnection:Disconnect()
	end

	if saved.Lighting then
		TweenService:Create(Lighting, TweenInfo.new(1), saved.Lighting):Play()
	end
end

---====== MAIN ENTITY FUNCTION ======---

local function spawnCease()

	-- start blue effect
	task.spawn(function()
		makeBlue()
		task.wait(7)
		restoreLighting()
	end)

	wait(0)

	local entity = spawner.Create({
		Entity = {
			Name = "Cease",
			Asset = "rbxassetid://12262854624",
			HeightOffset = 0
		},
		Lights = {
			Flicker = { Enabled = false },
			Shatter = false,
			Repair = false
		},
		CameraShake = {
			Enabled = false
		},
		Movement = {
			Speed = 51.5,
			Delay = 3.5,
			Reversed = false
		},
		Rebounding = {
			Enabled = false
		},
		Damage = {
			Enabled = false
		},
		Crucifixion = {
			Enabled = false,
			Resist = true,
			Break = true
		},
		Death = {
			Type = "Guiding",
			Hints = {
				"You died to Cease..",
				"He appears after Rush...",
				"Stand still when the room turns blue.",
				"If you move, you die."
			},
			Cause = "Cease"
		}
	})

	--- Movement Kill ---
	local movementConnection

	entity:SetCallback("OnStartMoving", function()
		movementConnection = RunService.Heartbeat:Connect(function()
			local char = Plr.Character
			local entModel = entity.Model

			if char and char:FindFirstChild("Humanoid") and entModel and entModel.PrimaryPart then
				local root = char:FindFirstChild("HumanoidRootPart")
				local hum = char.Humanoid

				if root then
					local dist = (root.Position - entModel.PrimaryPart.Position).Magnitude

					if dist <= 45 and hum.MoveDirection.Magnitude > 0 then
						hum.Health = 0

						game.ReplicatedStorage.GameStats["Player_".. Plr.Name].Total.DeathCause.Value = "Cease"
					end
				end
			end
		end)
	end)

	entity:SetCallback("OnDespawning", function()
		if movementConnection then
			movementConnection:Disconnect()
		end
	end)

	entity:SetCallback("OnDespawned", function()
		-- one-time achievement
		if not getgenv().CeaseEncountered then
			local player = Players.LocalPlayer

			if player.Character and player.Character:FindFirstChild("Humanoid") then
				if player.Character.Humanoid.Health > 0 then
					
					getgenv().CeaseEncountered = true

					local achievementGiver = loadstring(game:HttpGet("https://raw.githubusercontent.com/Voor-Pr00/Achivements/refs/heads/main/Voorpr0"))()

					achievementGiver({
						Title = "Dont Move",
						Desc = "Stay still for your life!",
						Reason = "Encounter Cease.",
						Image = "rbxassetid://120836589172474"
					})
				end
			end
		end
	end)

	entity:Run()
end

---====== FLOW ======---

task.spawn(function()
	waitForRush()

	local delayTime = math.random(10, 40)
	print("Cease spawning in:", delayTime)

	task.wait(delayTime)

	spawnCease()
end)
