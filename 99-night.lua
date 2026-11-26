local unpack_ = unpack or table.unpack
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local _ = Players.LocalPlayer

if game.PlaceId == 79546208627805 then
	local ScreenGui = Instance.new("ScreenGui")

	ScreenGui.Name = "LobbyNoticePremium"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	ScreenGui.Parent = game:GetService("CoreGui")

	local BlurEffect = Instance.new("BlurEffect")

	BlurEffect.Size = 12
	BlurEffect.Parent = Lighting

	local Frame = Instance.new("Frame")

	Frame.Size = UDim2.new(0.6, 0, 0.25, 0)
	Frame.Position = UDim2.new(0.5, 0, -0.3, 0)
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
	Frame.BackgroundTransparency = 0
	Frame.Parent = ScreenGui
	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 20)
	Instance.new("UIGradient", Frame).Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 90)), ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 70)) })

	local Frame2 = Instance.new("Frame", Frame)

	Frame2.Size = UDim2.new(1.2, 0, 1.2, 0)
	Frame2.Position = UDim2.new(-0.1, 0, -0.1, 0)
	Frame2.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
	Frame2.BackgroundTransparency = 0.7
	Instance.new("UICorner", Frame2).CornerRadius = UDim.new(0, 20)
	Frame2.ZIndex = 0

	local TextLabel = Instance.new("TextLabel", Frame)

	TextLabel.Size = UDim2.new(1, -20, 1, -20)
	TextLabel.Position = UDim2.new(0, 10, 0, 10)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = "Please enter the Map to use the script! Dont Use In Lobby"
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextScaled = true
	TextLabel.TextWrapped = true
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextStrokeTransparency = 0.6
	spawn(function()
		while TextLabel.Parent do
			for i = 0, 1, 0.005 do
				TextLabel.TextColor3 = Color3.fromHSV(i, 0.9, 1)
				RunService.RenderStepped:Wait()
			end
		end
	end)

	local t1 = {}

	for _ = 1, 15 do
		local Frame3 = Instance.new("Frame", Frame)

		Frame3.Size = UDim2.new(0.03, 0, 0.03, 0)
		Frame3.Position = UDim2.new(math.random(), 0, math.random(), 0)
		Frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame3.BackgroundTransparency = 0.5
		Frame3.ZIndex = 5
		Instance.new("UICorner", Frame3).CornerRadius = UDim.new(0.5, 0)
		table.insert(t1, Frame3)
	end

	spawn(function()
		while Frame.Parent do
			for _, v in pairs(t1) do
				local uDim2 = UDim2.new(math.random(), 0, math.random(), 0)
				local InOut = Enum.EasingDirection.InOut
				local EasingStyle = Enum.EasingStyle

				v.TweenPosition(v, uDim2, InOut, EasingStyle.Quad, 2, true)
				v.BackgroundTransparency = math.random() * 0.7
			end

			wait(1.5)
		end
	end)
	TweenService:Create(Frame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()
	task.delay(5, function()
		TweenService:Create(Frame, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(TextLabel, TweenInfo.new(0.5), {
			TextTransparency = 1
		}):Play()

		for _, v in pairs(t1) do
			local v23 = TweenService
			local TweenInfo_ = TweenInfo

			v23.Create(v23, v, TweenInfo_.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
		end

		TweenService:Create(Frame2, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(BlurEffect, TweenInfo.new(0.5), {
			Size = 0
		}):Play()
		task.wait(0.6)
		ScreenGui:Destroy()
		BlurEffect:Destroy()
	end)

	return nil
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/sudaisontopxd/FeedBack/refs/heads/main/PF"))()

local lib = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local t2 = {
	Title = "CHAT-GPT | AI-LUA",
	Icon = "rbxassetid://79794145409508",
	IconThemed = true,
	Author = "AI LUA -99 Nights",
	Folder = "AI-LUA",
	Size = UDim2.fromOffset(580, 460),
	Transparent = true,
	Theme = "Dark",
	User = {
		Enabled = false
	},
	SideBarWidth = 200,
	ScrollBarEnabled = true,
	KeySystem = false
}
local v27 = lib.CreateWindow(lib, t2)

v27:CreateTopbarButton("MyCustomButton1", "bird", function()
	print("clicked 1!")
end, 990)
v27:CreateTopbarButton("MyCustomButton2", "droplet-off", function()
	print("clicked 2!")
end, 989)
v27:CreateTopbarButton("MyCustomButton3", "battery-plus", function()
	print("clicked 3!!")
end, 988)

local uDim = UDim.new(0, 16)
local colorSequenceNew = ColorSequence.new
local color3 = Color3.fromHex("FF0F7B")
local t3 = { Color3.fromHex("F89B29") }

v27.EditOpenButton(v27, {
	Title = "Open PhantomFlux UI",
	Icon = "monitor",
	CornerRadius = uDim,
	StrokeThickness = 2,
	Color = colorSequenceNew(color3, unpack_(t3)),
	Draggable = true
})

local t4 = {
	AboutTab = v27:Tab({
		Title = "About Us",
		Icon = "info"
	}),
	FarmTab = v27:Tab({
		Title = "Farm",
		Icon = "leaf"
	}),
	BringTab = v27:Tab({
		Title = "Bring",
		Icon = "arrow-down-from-line"
	}),
	PlayerTab = v27:Tab({
		Title = "Player",
		Icon = "user-plus"
	})
}

v27:SelectTab(1)
t4.AboutTab:Paragraph({
	Title = "Who Are We?",
	Icon = "user-circle",
	Desc = "PanScript is a script showcaser and very creative. Sudais is a Luau & C# dev. He makes scripts."
})
t4.AboutTab:Paragraph({
	Title = "Discord Invites",
	Icon = "discord",
	Desc = "Join our communities for updates and support!"
})

local AboutTab = t4.AboutTab

AboutTab.Button(AboutTab, {
	Title = "Sudais X Cheats Discord Link (Click to Copy)",
	Icon = "link",
	Callback = function()
		setclipboard("https://discord.gg/yzuWzSpCg7")
		lib:Notify({
			Title = "Copied!",
			Content = "Sudais X Cheats Discord link copied!",
			Duration = 3
		})
	end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players2 = game:GetService("Players")
local _ = Players2.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestConsumeItem = RemoteEvents:WaitForChild("RequestConsumeItem")
local RequestStartDraggingItem = RemoteEvents:WaitForChild("RequestStartDraggingItem")
local Items = workspace:WaitForChild("Items")
local LocalPlayer = Players2.LocalPlayer or Players2.PlayerAdded:Wait()
local v43 = nil

local function v44()
	local Character = v43.Character
	local HumanoidRootPart

	if Character then
		HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	else
		HumanoidRootPart = Character
	end

	if HumanoidRootPart then
		return Character.HumanoidRootPart
	else
		return nil
	end
end

v43 = LocalPlayer

local thread = nil
local thread2 = nil
local t5 = {}
local thread3 = nil

local function v51(p1)
	local v52 = v44()

	if not v52 then
		return
	end

	local v53 = v52.Position + Vector3.new(0, 3, 0)

	if p1:IsA("BasePart") then
		p1.Anchored = false
		p1.CFrame = CFrame.new(v53)

		return
	end

	if not p1:IsA("Model") then
		return
	end

	for _, descendant in ipairs(p1:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CFrame = CFrame.new(v53)
		end
	end
end
local function v56(p2)
	RequestStartDraggingItem:FireServer(p2)
	task.wait()
	RequestConsumeItem:InvokeServer(p2)
end
local function v57()
	local Character = v43.Character
	local HumanoidRootPart

	if Character then
		HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	else
		HumanoidRootPart = Character
	end

	if HumanoidRootPart then
		return Character.HumanoidRootPart
	else
		return nil
	end
end
local function v60(p3)
	local v61 = v57()
	local Inventory = v43:FindFirstChild("Inventory")
	local ipairs_, Characters, NPC, t6

	if not Inventory then
		if v61 and Inventory then
			ipairs_ = ipairs
			Characters = Workspace.Characters

			for _, child in ipairs_(Characters.GetChildren(Characters)) do
				NPC = child:FindFirstChild("NPC")

				if NPC then
					NPC = child:FindFirstChild("HumanoidRootPart")
				end

				if NPC and (child.HumanoidRootPart.Position - v61.Position).Magnitude <= p3 then
					t6 = {
						child,
						Inventory,
						"143_10641513132",
						v61.CFrame
					}
					ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(unpack_({ unpack(t6) }))
				end
			end
		end

		return
	end

	Inventory = Inventory:FindFirstChild("Old Axe")

	if v61 and Inventory then
		ipairs_ = ipairs
		Characters = Workspace.Characters

		for _, child in ipairs_(Characters.GetChildren(Characters)) do
			NPC = child:FindFirstChild("NPC")

			if NPC then
				NPC = child:FindFirstChild("HumanoidRootPart")
			end

			if NPC and (child.HumanoidRootPart.Position - v61.Position).Magnitude <= p3 then
				t6 = {
					child,
					Inventory,
					"143_10641513132",
					v61.CFrame
				}
				ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(unpack_({ unpack(t6) }))
			end
		end
	end
end
local function v71()
	local v72 = v57()
	local Inventory = v43:FindFirstChild("Inventory")
	local ipairs_, Characters, NPC, v77, t7

	if not Inventory then
		if v72 and Inventory then
			ipairs_ = ipairs
			Characters = Workspace.Characters

			for _, child in ipairs_(Characters.GetChildren(Characters)) do
				NPC = child:FindFirstChild("NPC")

				if NPC then
					NPC = child:FindFirstChild("HumanoidRootPart")
				end

				if NPC then
					child.HumanoidRootPart.CFrame = v72.CFrame + Vector3.new(0, 3, 0)
					v77 = ReplicatedStorage
					t7 = {
						child,
						Inventory,
						"143_10641513132",
						v72.CFrame
					}
					v77.RemoteEvents.ToolDamageObject:InvokeServer(unpack_({ unpack(t7) }))
				end
			end
		end

		return
	end

	Inventory = Inventory:FindFirstChild("Old Axe")

	if v72 and Inventory then
		ipairs_ = ipairs
		Characters = Workspace.Characters

		for _, child in ipairs_(Characters.GetChildren(Characters)) do
			NPC = child:FindFirstChild("NPC")

			if NPC then
				NPC = child:FindFirstChild("HumanoidRootPart")
			end

			if NPC then
				child.HumanoidRootPart.CFrame = v72.CFrame + Vector3.new(0, 3, 0)
				v77 = ReplicatedStorage
				t7 = {
					child,
					Inventory,
					"143_10641513132",
					v72.CFrame
				}
				v77.RemoteEvents.ToolDamageObject:InvokeServer(unpack_({ unpack(t7) }))
			end
		end
	end
end

local Players3 = game:GetService("Players")
local RunService2 = game:GetService("RunService")
local Characters = workspace:WaitForChild("Characters")
local LocalPlayer2 = Players3.LocalPlayer
local t8 = {}
local n1 = 0
local t9 = {
	Bunny = Color3.fromRGB(0, 255, 0),
	Wolf = Color3.fromRGB(255, 0, 0),
	["Alpha Wolf"] = Color3.fromRGB(255, 0, 0),
	["Artic Fox"] = Color3.fromRGB(255, 255, 255),
	Kids = Color3.fromRGB(0, 0, 255),
	Deer = Color3.fromRGB(160, 32, 240)
}

local function v90(p4)
	for k, v in pairs(t9) do
		if string.find(p4, k) then
			return v
		end
	end

	return Color3.fromRGB(255, 255, 0)
end
local function createTextLabel(p5, p6)
	local BillboardGui = Instance.new("BillboardGui")

	BillboardGui.Name = "ESPNameTag"
	BillboardGui.Adornee = p5:FindFirstChild("HumanoidRootPart") or p5.PrimaryPart
	BillboardGui.Size = UDim2.new(0, 150, 0, 50)
	BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
	BillboardGui.AlwaysOnTop = true
	BillboardGui.Parent = p5

	local TextLabel = Instance.new("TextLabel")

	TextLabel.Name = "NameLabel"
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1, 0, 0.5, 0)
	TextLabel.Position = UDim2.new(0, 0, 0, 0)
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 18
	TextLabel.TextColor3 = p6
	TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	TextLabel.TextStrokeTransparency = 0
	TextLabel.Text = p5.Name
	TextLabel.Parent = BillboardGui
	TextLabel.ZIndex = 3

	local TextLabel2 = Instance.new("TextLabel")

	TextLabel2.Name = "DistanceLabel"
	TextLabel2.BackgroundTransparency = 1
	TextLabel2.Size = UDim2.new(1, 0, 0.5, 0)
	TextLabel2.Position = UDim2.new(0, 0, 0.5, 0)
	TextLabel2.Font = Enum.Font.Gotham
	TextLabel2.TextSize = 14
	TextLabel2.TextColor3 = Color3.new(1, 1, 1)
	TextLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
	TextLabel2.TextStrokeTransparency = 0
	TextLabel2.Text = "Distance: --"
	TextLabel2.Parent = BillboardGui
	TextLabel2.ZIndex = 3

	return TextLabel2
end
local function v97(p7)
	if not t8[p7] then
		return
	end

	local ESPNameTag = p7:FindFirstChild("ESPNameTag")

	if ESPNameTag then
		ESPNameTag:Destroy()
	end

	if t8[p7].Highlight then
		t8[p7].Highlight:Destroy()
	end

	t8[p7] = nil
end

local v99 = nil

local function v100(p8)
	local v101 = v90(p8.Name)

	t8[p8] = {
		DistLabel = createTextLabel(p8, v101),
		Highlight = v99(p8, v101)
	}
end

v99 = function(p9, p10)
	if p9.FindFirstChild(p9, "Highlight") then
		return p9.Highlight
	else
		local Highlight = Instance.new("Highlight")

		Highlight.Adornee = p9
		Highlight.FillColor = p10
		Highlight.OutlineColor = Color3.new(1, 1, 1)
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.Parent = p9

		return Highlight
	end
end

local function v103()
	for k, _ in pairs(t8) do
		v97(k)
	end
end
local function v106(p11)
	n1 = n1 + p11 * 3

	for k, v in pairs(t8) do
		if k.Parent then
			local HumanoidRootPart = k:FindFirstChild("HumanoidRootPart") or k.PrimaryPart
			local Character

			if HumanoidRootPart then
				Character = LocalPlayer2.Character

				if Character then
					Character = LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
				end
			else
				Character = HumanoidRootPart
			end

			if Character then
				local Magnitude = (HumanoidRootPart.Position - LocalPlayer2.Character.HumanoidRootPart.Position).Magnitude

				v.DistLabel.Text = string.format("Distance: %.1f", Magnitude)

				local v112 = n1
				local v113 = (math.sin(v112) + 1) / 2 * 0.6 + 0.3

				v.Highlight.FillTransparency = 1 - v113
				v.Highlight.OutlineTransparency = 1 - v113
			else
				v.DistLabel.Text = "Distance: --"
				v.Highlight.FillTransparency = 0.7
				v.Highlight.OutlineTransparency = 0.7
			end
		else
			v97(k)
		end
	end
end

local v114 = nil

local function v115()
	v103()
end
local function v116()
	local v117 = Characters

	for _, child in ipairs(v117.GetChildren(v117)) do
		local isModel = child:IsA("Model")

		if isModel then
			isModel = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart")
		end

		if isModel then
			v100(child)
		end
	end

	Characters.ChildAdded:Connect(function(child)
		local isModel = child:IsA("Model")

		if isModel then
			isModel = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart")
		end

		if not isModel then
			return
		end

		v100(child)
	end)
	Characters.ChildRemoved:Connect(function(child)
		v97(child)
	end)
	RunService2.RenderStepped:Connect(v114)
end

v114 = v106

local Players4 = game:GetService("Players")
local RunService3 = game:GetService("RunService")
local Workspace2 = game:GetService("Workspace")
local LocalPlayer3 = Players4.LocalPlayer
local Part = nil
local connection = nil

local function v128(p12, p13)
	local vector3 = Vector3.new(p12, 5000, p13)
	local vector32 = Vector3.new(0, -10000, 0)
	local raycastParams = RaycastParams.new()

	raycastParams.FilterDescendantsInstances = { LocalPlayer3.Character, Part }
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local hit = Workspace2:Raycast(vector3, vector32, raycastParams)

	return not hit and 0 or hit.Position.Y
end

local v133 = nil

local function v134()
	local Parent = Part

	if Parent then
		Parent = Part.Parent
	end

	if Parent then
		Part:Destroy()
	end

	Part = Instance.new("Part")
	Part.Name = "SafePlatform"
	Part.Size = Vector3.new(50, 1, 50)
	Part.Transparency = 1
	Part.Anchored = true
	Part.CanCollide = false
	Part.Parent = Workspace2
	connection = RunService3.Heartbeat:Connect(function()
		local Character = LocalPlayer3.Character
		local HumanoidRootPart

		if Character then
			HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		else
			HumanoidRootPart = Character
		end

		if not HumanoidRootPart then
			return
		end

		local HumanoidRootPart2 = Character.HumanoidRootPart
		local v139 = v133(HumanoidRootPart2.Position.X, HumanoidRootPart2.Position.Z) + 50

		Part.Position = Vector3.new(HumanoidRootPart2.Position.X, v139, HumanoidRootPart2.Position.Z)
		HumanoidRootPart2.CFrame = CFrame.new(HumanoidRootPart2.Position.X, v139 + 3, HumanoidRootPart2.Position.Z)
	end)
end

v133 = v128

local function v140()
	if connection then
		connection:Disconnect()
	end

	local Parent = Part

	if Parent then
		Parent = Part.Parent
	end

	if not Parent then
		return
	end

	Part:Destroy()
end

t4.FarmTab:Section({
	Title = "Automation",
	Icon = "robot"
})

local FarmTab = t4.FarmTab
local t10 = {
	Title = "Auto Teleport & Kill All Enemies",
	Value = false,
	Callback = function(p14)
		if p14 then
			thread2 = task.spawn(function()
				while task.wait(0.2) do
					v71()
				end
			end)

			return
		end

		if not thread2 then
			return
		end

		task.cancel(thread2)
	end
}

FarmTab.Toggle(FarmTab, t10)

local FarmTab2 = t4.FarmTab
local t11 = {
	Title = "Kill Aura",
	Value = false,
	Callback = function(p15)
		if p15 then
			thread = task.spawn(function()
				while task.wait(0.1) do
					v60(25)
				end
			end)

			return
		end

		if not thread then
			return
		end

		task.cancel(thread)
	end
}

FarmTab2.Toggle(FarmTab2, t11)
t4.FarmTab:Paragraph({
	Title = "Tip",
	Icon = "lightbulb",
	Desc = "Hold Axe For Kill Aura To Work"
})

local BringTab = t4.BringTab
local t12 = {
	Title = "Select Items to Bring",
	Values = (function()
		local ipairs_ = ipairs
		local Items2 = Workspace:WaitForChild("Items")
		local t13 = {}

		for _, child in ipairs_(Items2.GetChildren(Items2)) do
			local Name = child.Name

			table.insert(t13, Name)
		end

		return t13
	end)(),
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(p16)
		t5 = p16
	end
}

BringTab.Dropdown(BringTab, t12)

local BringTab2 = t4.BringTab
local t14 = {
	Title = "Bring Selected Item",
	Value = false,
	Callback = function(p17)
		if p17 then
			thread3 = task.spawn(function()
				while task.wait(0.2) do
					local ipairs_ = ipairs
					local Items2 = Workspace.Items

					for _, child in ipairs_(Items2.GetChildren(Items2)) do
						if table.find(t5, child.Name) then
							v51(child)
						end
					end
				end
			end)

			return
		end

		if not thread3 then
			return
		end

		task.cancel(thread3)
	end
}

BringTab2.Toggle(BringTab2, t14)

local BringTab3 = t4.BringTab

BringTab3.Button(BringTab3, {
	Title = "Cook All Meat In Map",
	Callback = function()
		local vector3 = Vector3.new(1.87, 4.33, -3.67)
		local Items2 = Workspace2:WaitForChild("Items")
		local _ = game:GetService("Players").LocalPlayer

		local function v164()
			local v165 = Items2

			for _, child in ipairs(v165.GetChildren(v165)) do
				if (child:IsA("Model") or child:IsA("Part")) and (child.Name == "Morsel" or child.Name == "Steak") then
					local PrimaryPart = child:FindFirstChild("PrimaryPart") or (child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart"))

					if PrimaryPart then
						PrimaryPart.CFrame = CFrame.new(vector3)
					end
				end
			end
		end

		task.spawn(function()
			while task.wait(0.1) do
				v164()
			end
		end)
	end
})

local thread4 = nil
local BringTab4 = t4.BringTab
local t15 = {
	Title = "Auto Eat Cooked Food",
	Value = false,
	Callback = function(p18)
		if p18 then
			thread4 = task.spawn(function()
				while task.wait(0.2) do
					local v172 = Items

					for _, child in ipairs(v172.GetChildren(v172)) do
						if child.Name == "Cooked Morsel" or child.Name == "Cooked Steak" then
							v56(child)
						end
					end
				end
			end)

			return
		end

		if not thread4 then
			return
		end

		task.cancel(thread4)
	end
}

BringTab4.Toggle(BringTab4, t15)

local BringTab5 = t4.BringTab

BringTab5.Button(BringTab5, {
	Title = "Teleport to Campfire",
	Callback = function()
		local LocalPlayer4 = game:GetService("Players").LocalPlayer
		local Character = LocalPlayer4.Character

		if Character then
			Character = LocalPlayer4.Character:FindFirstChild("HumanoidRootPart")
		end

		if not Character then
			return
		end

		LocalPlayer4.Character.HumanoidRootPart.CFrame = CFrame.new(13.287, 3.999, 0.362)
	end
})
t4.PlayerTab:Section({
	Title = "Sliders",
	Icon = "adjustments"
})
t4.PlayerTab:Slider({
	Title = "WalkSpeed",
	Value = {
		Min = 1,
		Max = 1000,
		Default = 16
	},
	Step = 1,
	Callback = function(p19)
		local LocalPlayer4 = game:GetService("Players").LocalPlayer
		local Character = LocalPlayer4.Character or LocalPlayer4.CharacterAdded:Wait()
		local Humanoid = Character.FindFirstChildWhichIsA(Character, "Humanoid")

		if not Humanoid then
			return
		end

		Humanoid.WalkSpeed = p19

		local HumanModCons_ = HumanModCons

		if HumanModCons_ then
			HumanModCons_ = HumanModCons.wsLoop
		end

		if HumanModCons_ then
			HumanModCons.wsLoop:Disconnect()
		end

		HumanModCons = HumanModCons or {}
		HumanModCons.wsLoop = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if Humanoid.WalkSpeed == p19 then
				return
			end

			Humanoid.WalkSpeed = p19
		end)

		if HumanModCons.wsCA then
			HumanModCons.wsCA:Disconnect()
		end

		HumanModCons.wsCA = LocalPlayer4.CharacterAdded:Connect(function(character)
			Humanoid = character:WaitForChild("Humanoid")
			Humanoid.WalkSpeed = p19
			HumanModCons.wsLoop = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if Humanoid.WalkSpeed == p19 then
					return
				end

				Humanoid.WalkSpeed = p19
			end)
		end)
	end
})
t4.PlayerTab:Slider({
	Title = "Jump Height",
	Value = {
		Min = 1,
		Max = 1000,
		Default = 16
	},
	Step = 1,
	Callback = function(p20)
		local LocalPlayer4 = game.Players.LocalPlayer
		local Character = LocalPlayer4.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if Humanoid then
			if Humanoid.UseJumpPower then
				Humanoid.JumpPower = p20
			else
				Humanoid.JumpHeight = p20
			end
		end

		LocalPlayer4.CharacterAdded:Connect(function(character)
			local Humanoid2 = character:WaitForChild("Humanoid")

			if Humanoid2.UseJumpPower then
				Humanoid2.JumpPower = p20
			else
				Humanoid2.JumpHeight = p20
			end
		end)
	end
})

local PlayerTab = t4.PlayerTab

PlayerTab.Toggle(PlayerTab, {
	Title = "Safe Mode (If You Want To AFK Grind Must Use Anti Afk)",
	Value = false,
	Callback = function(p21)
		if p21 then
			v134()
		else
			v140()
		end
	end
})

local PlayerTab2 = t4.PlayerTab

PlayerTab2.Toggle(PlayerTab2, {
	Title = "Noclip",
	Value = false,
	Callback = function(p22)
		local RunService4 = game:GetService("RunService")
		local LocalPlayer4 = game:GetService("Players").LocalPlayer

		if p22 then
			Noclipping = RunService4.Stepped:Connect(function()
				local Character = LocalPlayer4.Character

				if not Character then
					return
				end

				local GetDescendants = Character.GetDescendants

				for _, v in ipairs(GetDescendants(Character)) do
					local isBasePart = v:IsA("BasePart")

					if isBasePart then
						isBasePart = v.CanCollide

						if isBasePart then
							isBasePart = v.Name ~= "HumanoidRootPart"
						end
					end

					if isBasePart then
						v.CanCollide = false
					end
				end
			end)

			return
		end

		if not Noclipping then
			return
		end

		Noclipping:Disconnect()
		Noclipping = nil
	end
})
t4.PlayerTab:Toggle({
	Title = "Esp Mobs",
	Value = false,
	Callback = function(p23)
		if p23 then
			v116()
		else
			v115()
		end
	end
})

local PlayerTab3 = t4.PlayerTab

PlayerTab3.Toggle(PlayerTab3, {
	Title = "Anti Afk",
	Value = false,
	Callback = function(p24)
		if p24 then
			wait(0.5)
			game:GetService("TweenService")

			local Players5 = game:GetService("Players")
			local VirtualUser = game:GetService("VirtualUser")
			local LocalPlayer4 = Players5.LocalPlayer
			local ScreenGui = Instance.new("ScreenGui")

			ScreenGui.Name = "AntiAFKGui"
			ScreenGui.Parent = game.CoreGui
			ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

			local Frame = Instance.new("Frame")

			Frame.Size = UDim2.new(0, 360, 0, 120)
			Frame.Position = UDim2.new(0.7, 0, 0.1, 0)
			Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
			Frame.BorderSizePixel = 0
			Frame.Parent = ScreenGui
			Frame.Active = true
			Frame.Draggable = true
			Frame.Name = "MainFrame"

			local UICorner = Instance.new("UICorner")

			UICorner.CornerRadius = UDim.new(0, 16)
			UICorner.Parent = Frame

			local UIGradient = Instance.new("UIGradient")

			UIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 48, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 36)) })
			UIGradient.Rotation = 90
			UIGradient.Parent = Frame

			local UIStroke = Instance.new("UIStroke")

			UIStroke.Color = Color3.fromRGB(0, 0, 0)
			UIStroke.Transparency = 0.75
			UIStroke.Thickness = 4
			UIStroke.Parent = Frame

			local TextLabel = Instance.new("TextLabel")

			TextLabel.Size = UDim2.new(1, -32, 0, 36)
			TextLabel.Position = UDim2.new(0, 16, 0, 12)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Font = Enum.Font.FredokaOne
			TextLabel.Text = "Anti AFK"
			TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
			TextLabel.TextSize = 28
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel.Parent = Frame

			local TextLabel2 = Instance.new("TextLabel")

			TextLabel2.Size = UDim2.new(1, -32, 0, 40)
			TextLabel2.Position = UDim2.new(0, 16, 0, 64)
			TextLabel2.BackgroundTransparency = 1
			TextLabel2.Font = Enum.Font.FredokaOne
			TextLabel2.Text = "Status: Active"
			TextLabel2.TextColor3 = Color3.fromRGB(0, 255, 255)
			TextLabel2.TextSize = 22
			TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel2.TextWrapped = true
			TextLabel2.Parent = Frame

			local thread5 = coroutine.create(function()
				while true do
					if not ScreenGui.Parent then
						return
					end

					for i = 0, 1, 0.02 do
						if not ScreenGui.Parent then
							break
						end

						local v208 = TextLabel2
						local color32 = Color3.fromHSV
						local v210 = i * 3.141592653589793 * 2

						v208.TextColor3 = color32(math.sin(v210) * 0.1 + 0.5, 1, 1)
						wait(0.03)
					end
				end
			end)

			coroutine.resume(thread5)

			local function v211()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(unpack_({ Vector2.new() }))
				TextLabel2.Text = "Roblox tried to kick you but failed!"
				wait(2)
				TextLabel2.Text = "Status: Active"
			end

			LocalPlayer4.Idled:Connect(v211)
		else
			if nil then
				(nil):Disconnect()
			end

			local AntiAFKGui = game.CoreGui:FindFirstChild("AntiAFKGui")

			if not AntiAFKGui then
				return
			end

			AntiAFKGui:Destroy()
		end
	end
})

local PlayerTab4 = t4.PlayerTab

PlayerTab4.Button(PlayerTab4, {
	Title = "FlyGUi",
	Callback = function()
		local ScreenGui = Instance.new("ScreenGui")
		local Frame = Instance.new("Frame")
		local TextButton = Instance.new("TextButton")
		local TextButton2 = Instance.new("TextButton")
		local TextButton3 = Instance.new("TextButton")
		local TextLabel = Instance.new("TextLabel")
		local TextButton4 = Instance.new("TextButton")
		local t16 = {
			value1 = Instance.new("TextLabel")
		}
		local TextButton5 = Instance.new("TextButton")

		ScreenGui.Name = "main"
		ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
		ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		Frame.Parent = ScreenGui
		Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
		Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
		Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
		Frame.Size = UDim2.new(0, 190, 0, 57)
		TextButton.Name = "up"
		TextButton.Parent = Frame
		TextButton.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
		TextButton.Size = UDim2.new(0, 44, 0, 28)
		TextButton.Font = Enum.Font.SourceSans
		TextButton.Text = "UP"
		TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.TextSize = 14
		TextButton2.Name = "down"
		TextButton2.Parent = Frame
		TextButton2.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
		TextButton2.Position = UDim2.new(0, 0, 0.491228074, 0)
		TextButton2.Size = UDim2.new(0, 44, 0, 28)
		TextButton2.Font = Enum.Font.SourceSans
		TextButton2.Text = "DOWN"
		TextButton2.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton2.TextSize = 14
		TextButton3.Name = "onof"
		TextButton3.Parent = Frame
		TextButton3.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
		TextButton3.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
		TextButton3.Size = UDim2.new(0, 56, 0, 28)
		TextButton3.Font = Enum.Font.SourceSans
		TextButton3.Text = "fly"
		TextButton3.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton3.TextSize = 14
		TextLabel.Parent = Frame
		TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
		TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
		TextLabel.Size = UDim2.new(0, 100, 0, 28)
		TextLabel.Font = Enum.Font.SourceSans
		TextLabel.Text = "gui by SudaisXCheats"
		TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.TextScaled = true
		TextLabel.TextSize = 14
		TextLabel.TextWrapped = true
		TextButton4.Name = "plus"
		TextButton4.Parent = Frame
		TextButton4.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
		TextButton4.Position = UDim2.new(0.231578946, 0, 0, 0)
		TextButton4.Size = UDim2.new(0, 45, 0, 28)
		TextButton4.Font = Enum.Font.SourceSans
		TextButton4.Text = "+"
		TextButton4.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton4.TextScaled = true
		TextButton4.TextSize = 14
		TextButton4.TextWrapped = true
		t16.value1.Name = "speed"
		t16.value1.Parent = Frame
		t16.value1.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
		t16.value1.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
		t16.value1.Size = UDim2.new(0, 44, 0, 28)
		t16.value1.Font = Enum.Font.SourceSans
		t16.value1.Text = "1"
		t16.value1.TextColor3 = Color3.fromRGB(0, 0, 0)
		t16.value1.TextScaled = true
		t16.value1.TextSize = 14
		t16.value1.TextWrapped = true
		TextButton5.Name = "mine"
		TextButton5.Parent = Frame
		TextButton5.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
		TextButton5.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
		TextButton5.Size = UDim2.new(0, 45, 0, 29)
		TextButton5.Font = Enum.Font.SourceSans
		TextButton5.Text = "-"
		TextButton5.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton5.TextScaled = true
		TextButton5.TextSize = 14
		TextButton5.TextWrapped = true
		speeds = 1
		t16.value2 = game:GetService("Players").LocalPlayer

		local Character = game.Players.LocalPlayer.Character

		if Character then
			Character:FindFirstChildWhichIsA("Humanoid")
		end

		nowe = false
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "GO SUB TO HIM",
			Text = "fly gui by SudaisXCheats",
			Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
		})
		Duration = 16
		Frame.Active = true
		Frame.Draggable = true
		TextButton3.MouseButton1Down:connect(function()
			if nowe == true then
				nowe = false
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
				t16.value2.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
			else
				nowe = true

				for _ = 1, speeds do
					spawn(function()
						local Heartbeat = game:GetService("RunService").Heartbeat

						tpwalking = true

						local Character2 = game.Players.LocalPlayer.Character
						local Humanoid

						if Character2 then
							Humanoid = Character2:FindFirstChildWhichIsA("Humanoid")
						else
							Humanoid = Character2
						end

						while true do
							local tpwalking_ = tpwalking

							if tpwalking_ then
								tpwalking_ = Heartbeat:Wait()

								if tpwalking_ then
									if Character2 then
										if Humanoid then
											tpwalking_ = Humanoid.Parent
										else
											tpwalking_ = Humanoid
										end
									else
										tpwalking_ = Character2
									end
								end
							end

							if not tpwalking_ then
								return
							end

							if Humanoid.MoveDirection.Magnitude > 0 then
								Character2:TranslateBy(Humanoid.MoveDirection)
							end
						end
					end)
				end

				game.Players.LocalPlayer.Character.Animate.Disabled = true

				local Character2 = game.Players.LocalPlayer.Character
				local Humanoid = Character2:FindFirstChildOfClass("Humanoid") or Character2:FindFirstChildOfClass("AnimationController")
				local GetPlayingAnimationTracks = Humanoid.GetPlayingAnimationTracks
				local next_ = next
				local v233, key = GetPlayingAnimationTracks(Humanoid)

				while true do
					local v235

					key, v235 = next_(v233, key)

					if not key then
						break
					end

					v235:AdjustSpeed(0)
				end

				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
				t16.value2.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
				t16.value2.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
			end

			if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
				local LocalPlayer4 = game.Players.LocalPlayer
				local Torso = LocalPlayer4.Character.Torso
				local t17 = {
					f = 0,
					b = 0,
					l = 0,
					r = 0
				}
				local t18 = {
					f = 0,
					b = 0,
					l = 0,
					r = 0
				}
				local n2 = 50
				local n3 = 0
				local BodyGyro = Instance.new("BodyGyro", Torso)

				BodyGyro.P = 90000
				BodyGyro.maxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
				BodyGyro.cframe = Torso.CFrame

				local BodyVelocity = Instance.new("BodyVelocity", Torso)

				BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
				BodyVelocity.maxForce = Vector3.new(9000000000, 9000000000, 9000000000)

				local v244, v245, v246, CoordinateFrame, cFrame, v249

				if nowe ~= true then
					while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
						game:GetService("RunService").RenderStepped:Wait()

						if t17.l + t17.r ~= 0 or t17.f + t17.b ~= 0 then
							n3 = n3 + 0.5 + n3 / n2

							if n2 < n3 then
								n3 = n2
							end
						else
							v244 = t17.l + t17.r == 0 and t17.f + t17.b == 0

							if v244 then
								v244 = n3 ~= 0
							end

							if v244 then
								v245 = n3 - 1
								n3 = v245 < 0 and 0 or v245
							end
						end

						if t17.l + t17.r ~= 0 or t17.f + t17.b ~= 0 then
							BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t17.f + t17.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t17.l + t17.r, (t17.f + t17.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n3
							t18 = {
								f = t17.f,
								b = t17.b,
								l = t17.l,
								r = t17.r
							}
						else
							v246 = t17.l + t17.r == 0

							if v246 then
								if t17.f + t17.b == 0 then
									v246 = n3 ~= 0
								else
									v246 = false
								end
							end

							if v246 then
								BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t18.f + t18.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t18.l + t18.r, (t18.f + t18.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n3
							else
								BodyVelocity.velocity = Vector3.new(0, 0, 0)
							end
						end

						CoordinateFrame = game.Workspace.CurrentCamera.CoordinateFrame
						cFrame = CFrame.Angles
						v249 = (t17.f + t17.b) * 50 * n3 / n2
						BodyGyro.cframe = CoordinateFrame * cFrame(-math.rad(v249), 0, 0)
					end

					BodyGyro:Destroy()
					BodyVelocity:Destroy()
					LocalPlayer4.Character.Humanoid.PlatformStand = false
					game.Players.LocalPlayer.Character.Animate.Disabled = false
					tpwalking = false

					return
				end

				LocalPlayer4.Character.Humanoid.PlatformStand = true

				while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
					game:GetService("RunService").RenderStepped:Wait()

					if t17.l + t17.r ~= 0 or t17.f + t17.b ~= 0 then
						n3 = n3 + 0.5 + n3 / n2

						if n2 < n3 then
							n3 = n2
						end
					else
						v244 = t17.l + t17.r == 0 and t17.f + t17.b == 0

						if v244 then
							v244 = n3 ~= 0
						end

						if v244 then
							v245 = n3 - 1
							n3 = v245 < 0 and 0 or v245
						end
					end

					if t17.l + t17.r ~= 0 or t17.f + t17.b ~= 0 then
						BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t17.f + t17.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t17.l + t17.r, (t17.f + t17.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n3
						t18 = {
							f = t17.f,
							b = t17.b,
							l = t17.l,
							r = t17.r
						}
					else
						v246 = t17.l + t17.r == 0

						if v246 then
							if t17.f + t17.b == 0 then
								v246 = n3 ~= 0
							else
								v246 = false
							end
						end

						if v246 then
							BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t18.f + t18.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t18.l + t18.r, (t18.f + t18.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n3
						else
							BodyVelocity.velocity = Vector3.new(0, 0, 0)
						end
					end

					CoordinateFrame = game.Workspace.CurrentCamera.CoordinateFrame
					cFrame = CFrame.Angles
					v249 = (t17.f + t17.b) * 50 * n3 / n2
					BodyGyro.cframe = CoordinateFrame * cFrame(-math.rad(v249), 0, 0)
				end

				BodyGyro:Destroy()
				BodyVelocity:Destroy()
				LocalPlayer4.Character.Humanoid.PlatformStand = false
				game.Players.LocalPlayer.Character.Animate.Disabled = false
				tpwalking = false
			else
				local LocalPlayer4 = game.Players.LocalPlayer
				local UpperTorso = LocalPlayer4.Character.UpperTorso
				local t19 = {
					f = 0,
					b = 0,
					l = 0,
					r = 0
				}
				local t20 = {
					f = 0,
					b = 0,
					l = 0,
					r = 0
				}
				local n4 = 0
				local n5 = 50
				local BodyGyro = Instance.new("BodyGyro", UpperTorso)

				BodyGyro.P = 90000
				BodyGyro.maxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
				BodyGyro.cframe = UpperTorso.CFrame

				local BodyVelocity = Instance.new("BodyVelocity", UpperTorso)

				BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
				BodyVelocity.maxForce = Vector3.new(9000000000, 9000000000, 9000000000)

				local v258, v259, v260, CoordinateFrame, cFrame, v263

				if nowe ~= true then
					while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
						wait()

						if t19.l + t19.r ~= 0 or t19.f + t19.b ~= 0 then
							n4 = n4 + 0.5 + n4 / n5

							if n5 < n4 then
								n4 = n5
							end
						else
							v258 = t19.l + t19.r == 0 and t19.f + t19.b == 0

							if v258 then
								v258 = n4 ~= 0
							end

							if v258 then
								v259 = n4 - 1
								n4 = v259 < 0 and 0 or v259
							end
						end

						if t19.l + t19.r ~= 0 or t19.f + t19.b ~= 0 then
							BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t19.f + t19.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t19.l + t19.r, (t19.f + t19.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n4
							t20 = {
								f = t19.f,
								b = t19.b,
								l = t19.l,
								r = t19.r
							}
						else
							v260 = t19.l + t19.r == 0

							if v260 then
								if t19.f + t19.b == 0 then
									v260 = n4 ~= 0
								else
									v260 = false
								end
							end

							if v260 then
								BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t20.f + t20.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t20.l + t20.r, (t20.f + t20.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n4
							else
								BodyVelocity.velocity = Vector3.new(0, 0, 0)
							end
						end

						CoordinateFrame = game.Workspace.CurrentCamera.CoordinateFrame
						cFrame = CFrame.Angles
						v263 = (t19.f + t19.b) * 50 * n4 / n5
						BodyGyro.cframe = CoordinateFrame * cFrame(-math.rad(v263), 0, 0)
					end

					BodyGyro:Destroy()
					BodyVelocity:Destroy()
					LocalPlayer4.Character.Humanoid.PlatformStand = false
					game.Players.LocalPlayer.Character.Animate.Disabled = false
					tpwalking = false

					return
				end

				LocalPlayer4.Character.Humanoid.PlatformStand = true

				while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
					wait()

					if t19.l + t19.r ~= 0 or t19.f + t19.b ~= 0 then
						n4 = n4 + 0.5 + n4 / n5

						if n5 < n4 then
							n4 = n5
						end
					else
						v258 = t19.l + t19.r == 0 and t19.f + t19.b == 0

						if v258 then
							v258 = n4 ~= 0
						end

						if v258 then
							v259 = n4 - 1
							n4 = v259 < 0 and 0 or v259
						end
					end

					if t19.l + t19.r ~= 0 or t19.f + t19.b ~= 0 then
						BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t19.f + t19.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t19.l + t19.r, (t19.f + t19.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n4
						t20 = {
							f = t19.f,
							b = t19.b,
							l = t19.l,
							r = t19.r
						}
					else
						v260 = t19.l + t19.r == 0

						if v260 then
							if t19.f + t19.b == 0 then
								v260 = n4 ~= 0
							else
								v260 = false
							end
						end

						if v260 then
							BodyVelocity.velocity = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (t20.f + t20.b) + (game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(t20.l + t20.r, (t20.f + t20.b) * 0.2, 0).p - game.Workspace.CurrentCamera.CoordinateFrame.p)) * n4
						else
							BodyVelocity.velocity = Vector3.new(0, 0, 0)
						end
					end

					CoordinateFrame = game.Workspace.CurrentCamera.CoordinateFrame
					cFrame = CFrame.Angles
					v263 = (t19.f + t19.b) * 50 * n4 / n5
					BodyGyro.cframe = CoordinateFrame * cFrame(-math.rad(v263), 0, 0)
				end

				BodyGyro:Destroy()
				BodyVelocity:Destroy()
				LocalPlayer4.Character.Humanoid.PlatformStand = false
				game.Players.LocalPlayer.Character.Animate.Disabled = false
				tpwalking = false
			end
		end)
		TextButton.MouseButton1Down:connect(function()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
		end)
		TextButton2.MouseButton1Down:connect(function()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -2, 0)
		end)
		game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(_)
			wait(0.7)
			game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
			game.Players.LocalPlayer.Character.Animate.Disabled = false
		end)
		TextButton4.MouseButton1Down:connect(function()
			speeds = speeds + 1
			t16.value1.Text = speeds

			if nowe ~= true then
				return
			end

			tpwalking = false

			for _ = 1, speeds do
				spawn(function()
					local Heartbeat = game:GetService("RunService").Heartbeat

					tpwalking = true

					local Character2 = game.Players.LocalPlayer.Character
					local Humanoid

					if Character2 then
						Humanoid = Character2:FindFirstChildWhichIsA("Humanoid")
					else
						Humanoid = Character2
					end

					while true do
						local tpwalking_ = tpwalking

						if tpwalking_ then
							tpwalking_ = Heartbeat:Wait()

							if tpwalking_ then
								if Character2 then
									if Humanoid then
										tpwalking_ = Humanoid.Parent
									else
										tpwalking_ = Humanoid
									end
								else
									tpwalking_ = Character2
								end
							end
						end

						if not tpwalking_ then
							return
						end

						if Humanoid.MoveDirection.Magnitude > 0 then
							Character2:TranslateBy(Humanoid.MoveDirection)
						end
					end
				end)
			end
		end)
		TextButton5.MouseButton1Down:connect(function()
			if speeds == 1 then
				t16.value1.Text = "can not be less than 1"
				wait(1)
				t16.value1.Text = speeds

				return
			end

			speeds = speeds - 1
			t16.value1.Text = speeds

			if nowe ~= true then
				return
			end

			tpwalking = false

			for _ = 1, speeds do
				spawn(function()
					local Heartbeat = game:GetService("RunService").Heartbeat

					tpwalking = true

					local Character2 = game.Players.LocalPlayer.Character
					local Humanoid

					if Character2 then
						Humanoid = Character2:FindFirstChildWhichIsA("Humanoid")
					else
						Humanoid = Character2
					end

					while true do
						local tpwalking_ = tpwalking

						if tpwalking_ then
							tpwalking_ = Heartbeat:Wait()

							if tpwalking_ then
								if Character2 then
									if Humanoid then
										tpwalking_ = Humanoid.Parent
									else
										tpwalking_ = Humanoid
									end
								else
									tpwalking_ = Character2
								end
							end
						end

						if not tpwalking_ then
							return
						end

						if Humanoid.MoveDirection.Magnitude > 0 then
							Character2:TranslateBy(Humanoid.MoveDirection)
						end
					end
				end)
			end
		end)
	end
})
