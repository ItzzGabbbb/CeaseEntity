getgenv().CeaseEncountered = getgenv().CeaseEncountered or false

---====== Load spawner ======---
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()
local RunService = game:GetService("RunService")
local Plr = game.Players.LocalPlayer

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

---====== Blue Lighting System (LOCKED) ======---

local saved = {}
local lightingConnection

local function makeBlue()
	saved.Lighting = {
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ColorShift_Top = Lighting.ColorShift_Top,
		ColorShift_Bottom = Lighting.ColorShift_Bottom
	}

	TweenService:Create(Lighting, TweenInfo.new(0.5), {
		Ambient = Color3.fromRGB(0, 80, 255),
		OutdoorAmbient = Color3.fromRGB(0, 80, 255)
	}):Play()

	if Lighting:FindFirstChild("MainColorCorrection") then
		TweenService:Create(Lighting.MainColorCorrection, TweenInfo.new(0.5), {
			TintColor = Color3.fromRGB(0, 120, 255),
			Contrast = 0.2
		}):Play()
	end

	-- 🔒 lock lighting (prevents DOORS override)
	lightingConnection = RunService.RenderStepped:Connect(function()
		Lighting.Ambient = Color3.fromRGB(0, 80, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(0, 80, 255)
		Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
		Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)

		if Lighting:FindFirstChild("MainColorCorrection") then
			Lighting.MainColorCorrection.TintColor = Color3.fromRGB(0, 120, 255)
		end
	end)
end

local function restoreLighting()
	if lightingConnection then
		lightingConnection:Disconnect()
	end

	if saved.Lighting then
		TweenService:Create(Lighting, TweenInfo.new(1), saved.Lighting):Play()
	end

	if Lighting:FindFirstChild("MainColorCorrection") then
		TweenService:Create(Lighting.MainColorCorrection, TweenInfo.new(1), {
			TintColor = Color3.fromRGB(255,255,255),
			Contrast = 0
		}):Play()
	end
end

task.spawn(function()
	makeBlue()
	task.wait(7)
	restoreLighting()
end)

wait(0)

---====== Create entity ======---

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
		Enabled = false,
		Range = 100,
		Values = {1.5, 20, 0.1, 1}
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
		Enabled = false,
		Range = 40,
		Amount = 125
	},
	Crucifixion = {
		Enabled = false,
		Range = 40,
		Resist = true,
		Break = true
	},
	Death = {
		Type = "Guiding",
		Hints = {
			"You died to Cease...",
			"It's Technique is to spawn after rush.",
			"The lights turn blue when hes coming.",
			"He senses every movement, so stay still until he's gone!"
		},
		Cause = "Cease"
	}
})

---====== Movement Kill Logic ======---

local movementConnection

entity:SetCallback("OnStartMoving", function()
	print("Cease is moving - Stay still!")

	movementConnection = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		local entModel = entity.Model

		if char and char:FindFirstChild("Humanoid") and entModel and entModel.PrimaryPart then
			local hud = char.Humanoid
			local root = char:FindFirstChild("HumanoidRootPart")

			if root then
				local dist = (root.Position - entModel.PrimaryPart.Position).Magnitude

				if dist <= 45 and hud.MoveDirection.Magnitude > 0 then
					hud.Health = 0

					if game.ReplicatedStorage:FindFirstChild("GameStats") then
						game.ReplicatedStorage.GameStats["Player_".. Plr.Name].Total.DeathCause.Value = "Cease"
					end
				end
			end
		end
	end)
end)

---====== Debug callbacks ======---

entity:SetCallback("OnSpawned", function()
	print("Entity has spawned")
end)

entity:SetCallback("OnReachedNode", function() end)

entity:SetCallback("OnLookAt", function(lineOfSight)
	if lineOfSight then
		print("Player is looking at entity")
	end
end)

entity:SetCallback("OnDespawning", function()
	if movementConnection then
		movementConnection:Disconnect()
	end
end)

entity:SetCallback("OnDespawned", function()
	print("Entity has despawned")

	-- ✅ ONE-TIME ACHIEVEMENT
	if not getgenv().CeaseEncountered then
		local player = game.Players.LocalPlayer

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

---====== Run entity ======---
entity:Run()