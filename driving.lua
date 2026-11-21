--// ============================================================
--// MENU SCRIPT - HTTP GET + MONEY FARM + AUTO DELIVERY
--// ============================================================

if getgenv().DEMenuLoaded then
    -- Nếu đã load, chỉ toggle UI
    if getgenv().DEMenuGui then
        getgenv().DEMenuGui.Enabled = not getgenv().DEMenuGui.Enabled
    end
    return
end
getgenv().DEMenuLoaded = true

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer

--// ============================================================
--// DELIVERY MODULE REQUIRE (an toàn)
--// ============================================================
local delivery, deliveryUtil, vehicles, vehicleUtil, towablesUtil, towables, towablesData, vehicleData, tpGuard

local function loadDeliveryModules()
    local ok, err = pcall(function()
        delivery = require(ReplicatedStorage.Modules.Client.Jobs.Tasks.DeliveryJobTask)
        deliveryUtil = require(ReplicatedStorage.Modules.Shared.Jobs.Delivery.DeliveryUtil)
        vehicles = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
        vehicleUtil = require(ReplicatedStorage.Modules.Shared.Vehicles.VehicleUtil)
        towablesUtil = require(ReplicatedStorage.Modules.Shared.Towables.TowablesUtil)
        towables = require(ReplicatedStorage.Modules.Client.Towables.TowablesController)
        towablesData = require(ReplicatedStorage.Modules.Shared.DataManager.Data.TowablesData)
        vehicleData = require(ReplicatedStorage.Modules.Shared.DataManager.Data.VehicleData)
        tpGuard = require(ReplicatedStorage.Modules.Client.Exploit.VehicleTeleportDetectionController)
    end)
    return ok, err
end

local modulesOk, modulesErr = loadDeliveryModules()

--// ============================================================
--// ANTI-IDLE
--// ============================================================
if getconnections then
    pcall(function()
        for _, v in ipairs(getconnections(plr.Idled)) do
            v:Disable()
        end
    end)
end

plr.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end)
end)

--// ============================================================
--// AUTO DELIVERY LOGIC (từ script gốc)
--// ============================================================
local AutoDelivery = {
    Enabled = false,
    Running = false,
    Hover = nil,
    HoverPart = nil,
    CarId = nil,
    TrailerId = nil,
    Checked = false,
    SpawnAt = nil,
    TrailerAt = nil,
    CurTarget = nil,
    CurLoc = nil,
    CurPhase = nil,
    LastTick = nil,
    LastFire = nil,
    ProgressAt = nil,
    LastTp = nil,
    LastChar = nil,
    LastState = nil,
    RetryAt = nil,
}

local function clearHover()
    if AutoDelivery.Hover then
        pcall(function() AutoDelivery.Hover:Destroy() end)
    end
    AutoDelivery.Hover, AutoDelivery.HoverPart = nil, nil
end

local function getLoc(pos, skipLast, towing)
    local loc, dist
    for _, v in ipairs(CollectionService:GetTagged('DeliveryLocation')) do
        if v:IsA('BasePart') and v.Parent
            and (towing == nil or deliveryUtil.IsLocationAllowedForTrailer(v, towing)) then
            if not skipLast or not deliveryUtil.IsLastDeliveryLocation(plr, v) then
                local d = (v.Position - pos).Magnitude
                if not dist or d < dist then loc, dist = v, d end
            end
        end
    end
    return loc
end

local function setupVehicle(hum, state)
    if not AutoDelivery.Checked then
        local owned = vehicleData.GetOwnedVehicleIds(plr, true)
        local capacity = 0
        for id, v in pairs(towablesUtil.GetEnabledTowables()) do
            if v.ChassisType == 'Generic' and (v.CargoCapacity or 0) > capacity
                and towablesData.IsTowableUnlocked(plr, id) then
                for _, vehicleId in ipairs(owned) do
                    if towablesUtil.CanVehicleTowTowable(vehicleId, id, plr) then
                        AutoDelivery.CarId, AutoDelivery.TrailerId, capacity = vehicleId, id, v.CargoCapacity
                        break
                    end
                end
            end
        end
        AutoDelivery.Checked = true
    end

    if not AutoDelivery.CarId then
        if hum.SeatPart then
            clearHover()
            hum.Sit = false
            hum.Jump = true
            return false
        end
        return true
    end

    local model = vehicleUtil.GetPlayerSpawnedVehicle(plr)
    local carType = model and model:FindFirstChild('CarType')

    if not carType or carType.Value ~= AutoDelivery.CarId then
        if state and ((state.ItemsCarried or 0) > 0 or state.IsDropping) then return false end
        if not AutoDelivery.SpawnAt or tick() - AutoDelivery.SpawnAt > 10 then
            clearHover()
            AutoDelivery.SpawnAt, AutoDelivery.TrailerAt = tick(), nil
            ReplicatedStorage.Remotes.VehicleEvent:FireServer('Spawn', AutoDelivery.CarId)
        end
        return false
    end

    local car = vehicleUtil.getPlayerData(plr)
    if not car or car.Model ~= model then
        clearHover()
        local seat = model:FindFirstChild('VehicleSeat')
        if seat and not seat.Occupant then seat:Sit(hum) end
        return false
    end

    local trailer = towablesUtil.GetAttachedTrailerFromVehicle(model)
    if not trailer or trailer:GetAttribute('TowableId') ~= AutoDelivery.TrailerId then
        if state and ((state.ItemsCarried or 0) > 0 or state.IsDropping) then return false end
        if not AutoDelivery.TrailerAt or tick() - AutoDelivery.TrailerAt > 10 then
            clearHover()
            AutoDelivery.TrailerAt = tick()
            local ok, err = towables.AttemptToSpawnTowable(AutoDelivery.TrailerId)
            if not ok then warn('[Menu] ' .. tostring(err)) end
        end
        return false
    end

    return true
end

local function tp(cf)
    local char = plr.Character
    if not char then return false end

    local car = vehicleUtil.getPlayerData(plr)
    local chassis = vehicles.getActiveChassisController()

    if car and car.Model and car.WeightPart then
        if not car.Model.Parent or not car.WeightPart.Parent then return false end
        local trailer = towablesUtil.GetAttachedTrailerFromVehicle(car.Model)
        local offset = trailer and car.WeightPart.CFrame:ToObjectSpace(trailer:GetPivot())
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum and hum.SeatPart then cf = cf * hum.SeatPart.CFrame:ToObjectSpace(car.WeightPart.CFrame) end
        if chassis then chassis.Teleporting = true end

        task.defer(function()
            if chassis then chassis.Teleporting = false end
        end)

        tpGuard.AuthorizeNextTeleport()
        car.Model.PrimaryPart = car.WeightPart
        car.Model:SetPrimaryPartCFrame(cf)
        if trailer and trailer.Parent then trailer:PivotTo(cf * offset) end
        car.WeightPart.Anchored = false
        clearHover()

        AutoDelivery.Hover = Instance.new('BodyVelocity')
        AutoDelivery.Hover.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        AutoDelivery.Hover.Velocity = Vector3.zero
        AutoDelivery.Hover.Parent = car.WeightPart
        AutoDelivery.HoverPart = car.WeightPart

        for _, model in ipairs({car.Model, trailer}) do
            if model then
                for _, v in ipairs(model:GetDescendants()) do
                    if v:IsA('BasePart') then
                        v.AssemblyLinearVelocity = Vector3.zero
                        v.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        end
    else
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum and hum.SeatPart then return false end
        char:PivotTo(cf)

        local hrp = char:FindFirstChild('HumanoidRootPart')
        if hrp then
            clearHover()
            AutoDelivery.Hover = Instance.new('BodyVelocity')
            AutoDelivery.Hover.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            AutoDelivery.Hover.Velocity = Vector3.zero
            AutoDelivery.Hover.Parent = hrp
            AutoDelivery.HoverPart = hrp
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    return true
end

--// Reset state khi đổi character
RunService.Heartbeat:Connect(function()
    if not AutoDelivery.Enabled then return end

    local char = plr.Character
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    local hum = char and char:FindFirstChildOfClass('Humanoid')

    if AutoDelivery.HoverPart and (not AutoDelivery.HoverPart.Parent or not hrp
        or plr:GetAttribute('JobId') ~= 'Delivery'
        or (AutoDelivery.HoverPart ~= hrp and (not hum or not hum.SeatPart))) then
        clearHover()
    end

    if hrp then hrp.Anchored = false end
    if hum and AutoDelivery.Hover and AutoDelivery.Hover.Parent == hrp then
        hum:ChangeState(Enum.HumanoidStateType.Freefall)
    end
end)

--// Step function
local function deliveryStep()
    if not AutoDelivery.Enabled then return end
    if not modulesOk then return end

    local char = plr.Character
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    local hum = char and char:FindFirstChildOfClass('Humanoid')

    if char ~= AutoDelivery.LastChar then
        clearHover()
        AutoDelivery.CurTarget, AutoDelivery.CurLoc, AutoDelivery.CurPhase = nil, nil, nil
        AutoDelivery.LastTick, AutoDelivery.LastFire, AutoDelivery.ProgressAt, AutoDelivery.LastTp = nil, nil, nil, nil
        AutoDelivery.LastState, AutoDelivery.LastChar = nil, char
        AutoDelivery.SpawnAt, AutoDelivery.TrailerAt, AutoDelivery.RetryAt = nil, nil, nil
    end

    if hrp and hum and hum.Health > 0 then
        if AutoDelivery.RetryAt and tick() < AutoDelivery.RetryAt then return end
        AutoDelivery.RetryAt = nil

        local state = delivery.GetCurrentDeliveryState()
        if not setupVehicle(hum, state) then return end

        if plr:GetAttribute('JobId') ~= 'Delivery' then
            ReplicatedStorage.Remotes.RequestStartJobSession:FireServer('Delivery', 'deliveryHub', 'HighRisk')
            clearHover()
            AutoDelivery.CurTarget, AutoDelivery.CurLoc, AutoDelivery.CurPhase = nil, nil, nil
            AutoDelivery.LastTick, AutoDelivery.LastFire, AutoDelivery.ProgressAt, AutoDelivery.LastTp = nil, nil, nil, nil
            AutoDelivery.LastState = nil
            task.wait(0.5)
        else
            local target, phase
            local remaining = state and state.ExpirationTime and state.ExpirationTime - workspace:GetServerTimeNow()

            local newRoute = state and (not AutoDelivery.LastState
                or state.PickupPosition ~= AutoDelivery.LastState.PickupPosition
                or state.DestinationPosition ~= AutoDelivery.LastState.DestinationPosition
                or state.DeliveryStartTime ~= AutoDelivery.LastState.DeliveryStartTime)

            if newRoute then
                AutoDelivery.CurTarget, AutoDelivery.CurLoc, AutoDelivery.CurPhase, AutoDelivery.LastFire = nil, nil, nil, nil
            end

            if not AutoDelivery.ProgressAt or newRoute or (state == nil) ~= (AutoDelivery.LastState == nil)
                or (state and AutoDelivery.LastState and (state.ItemsCarried ~= AutoDelivery.LastState.ItemsCarried
                    or state.PackagesRemainingAtPickup ~= AutoDelivery.LastState.PackagesRemainingAtPickup
                    or state.IsPlanned ~= AutoDelivery.LastState.IsPlanned)) then
                AutoDelivery.ProgressAt = tick()
            end

            AutoDelivery.LastState = state

            if state then
                AutoDelivery.LastTick = nil
                local carried = state.ItemsCarried or 0
                local cap = state.MaxCapacity or carried
                local full = carried >= cap
                local noMore = state.PackagesRemainingAtPickup == 0

                if state.IsDropping or AutoDelivery.CurPhase == 'drop'
                    or carried > 0 and (full or noMore or remaining and remaining <= 5) then
                    phase = 'drop'
                    target = state.DestinationPosition
                else
                    phase = 'pickup'
                    target = state.PickupPosition
                end
            else
                AutoDelivery.LastTick = AutoDelivery.LastTick or tick()
                if tick() - AutoDelivery.LastTick > 0.25 then
                    local car = vehicleUtil.getPlayerData(plr)
                    local towing = car and towablesUtil.GetAttachedTrailerFromVehicle(car.Model) ~= nil or false
                    local loc = getLoc(hrp.Position, true, towing)
                    phase = 'new'
                    target = loc and loc.Position
                end
            end

            if target then
                local pos = target + Vector3.new(0, math.min(3.5, deliveryUtil.GetPickupRadius() / 2), 0)
                local part = hum.SeatPart or hrp
                if target ~= AutoDelivery.CurTarget or phase ~= AutoDelivery.CurPhase
                    or ((part.Position - pos).Magnitude > deliveryUtil.GetPickupRadius() / 2
                        and tick() - (AutoDelivery.LastTp or 0) > 2) then
                    if AutoDelivery.CurLoc then
                        ReplicatedStorage.Remotes.DeliveryLocationLeft:FireServer(AutoDelivery.CurLoc)
                    end
                    if not tp(CFrame.new(pos)) then return end
                    AutoDelivery.CurTarget, AutoDelivery.CurPhase, AutoDelivery.LastTp = target, phase, tick()
                    AutoDelivery.CurLoc, AutoDelivery.LastFire = nil, nil
                end

                if tick() - (AutoDelivery.LastTp or 0) < 0.5 then return end

                local loc = getLoc(target)
                if loc and (loc.Position - target).Magnitude < 1
                    and (part.Position - loc.Position).Magnitude <= deliveryUtil.GetPickupRadius() then
                    if loc ~= AutoDelivery.CurLoc then AutoDelivery.ProgressAt = tick() end

                    local timeout = math.max(10, deliveryUtil.GetItemCollectTime(plr) * 3)
                    if phase == 'drop' and remaining then
                        timeout = math.min(timeout, math.max(2, remaining / 2))
                    end

                    if loc == AutoDelivery.CurLoc and tick() - AutoDelivery.ProgressAt > timeout then
                        ReplicatedStorage.Remotes.DeliveryLocationLeft:FireServer(loc)
                        if not tp(CFrame.new(target + Vector3.new(deliveryUtil.GetPickupRadius() + 8, 3.5, 0))) then return end
                        AutoDelivery.CurTarget, AutoDelivery.CurLoc, AutoDelivery.LastFire = nil, nil, nil
                        AutoDelivery.ProgressAt, AutoDelivery.RetryAt = tick(), tick() + 0.5
                        return
                    end

                    local busy = state and (phase == 'drop' and state.IsDropping
                        or phase ~= 'drop' and state.IsCollecting)
                    if loc ~= AutoDelivery.CurLoc or not busy and tick() - (AutoDelivery.LastFire or 0) > 2 then
                        ReplicatedStorage.Remotes.DeliveryLocationInteracted:FireServer(loc)
                        AutoDelivery.CurLoc, AutoDelivery.LastFire = loc, tick()
                    end
                end
            end
        end
    end
end

--// Loop chạy delivery
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoDelivery.Enabled and modulesOk then
            local ok, err = pcall(deliveryStep)
            if not ok then
                AutoDelivery.CurTarget, AutoDelivery.CurLoc, AutoDelivery.CurPhase = nil, nil, nil
                AutoDelivery.LastTick, AutoDelivery.LastFire, AutoDelivery.ProgressAt, AutoDelivery.LastTp = nil, nil, nil, nil
                AutoDelivery.LastState = nil
                clearHover()
                warn('[Menu Delivery] ' .. tostring(err))
                task.wait(1)
            end
        end
    end
end)

--// ============================================================
--// MONEY FARM LOGIC
--// ============================================================
local MoneyFarm = {
    Enabled = false,
    Amount = 100,
}

-- Tự động click / farm tiền cơ bản
-- (Bạn có thể thay logic theo game cụ thể)
task.spawn(function()
    while true do
        task.wait(0.5)
        if MoneyFarm.Enabled then
            pcall(function()
                -- Ví dụ: fire remotes farm tiền nếu có
                -- ReplicatedStorage.Remotes.ClaimMoney:FireServer(MoneyFarm.Amount)
                -- Hoặc click button:
                -- VirtualUser:CaptureController()
                -- VirtualUser:ClickButton1(Vector2.new(400, 300))
            end)
        end
    end
end)

--// ============================================================
--// HTTP GET
--// ============================================================
local function httpGet(url)
    local ok, res = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if ok then
        return true, res
    else
        return false, tostring(res)
    end
end

local function httpGetJSON(url)
    local ok, res = httpGet(url)
    if not ok then return false, res end
    local ok2, decoded = pcall(function()
        return HttpService:JSONDecode(res)
    end)
    if ok2 then return true, decoded else return false, decoded end
end

--// ============================================================
--// UI LIBRARY
--// ============================================================
local function create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    if parent then obj.Parent = parent end
    return obj
end

local ScreenGui = create("ScreenGui", {
    Name = "DEMenuGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, plr:WaitForChild("PlayerGui"))

getgenv().DEMenuGui = ScreenGui

-- Main Frame
local Main = create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 420, 0, 320),
    Position = UDim2.new(0.5, -210, 0.5, -160),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
}, ScreenGui)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, Main)
create("UIStroke", { Color = Color3.fromRGB(60, 60, 70), Thickness = 1.5 }, Main)

-- Title bar
local TitleBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel = 0,
}, Main)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, TitleBar)

create("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚡ DE MENU",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TitleBar)

-- Nút minimize (thu nhỏ)
local MinimizeBtn = create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -70, 0, 5),
    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, TitleBar)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, MinimizeBtn)

-- Nút close
local CloseBtn = create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0, 5),
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, TitleBar)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, CloseBtn)

-- Tab bar
local TabBar = create("Frame", {
    Size = UDim2.new(1, -20, 0, 34),
    Position = UDim2.new(0, 10, 0, 48),
    BackgroundTransparency = 1,
}, Main)

local tabButtons = {}
local tabContents = {}
local activeTab = nil

local function createTab(name, index)
    local btn = create("TextButton", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, (index - 1) * 126, 0, 0),
        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
        Text = name,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        BorderSizePixel = 0,
    }, TabBar)
    create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

    local content = create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 90),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
    }, Main)

    tabButtons[name] = btn
    tabContents[name] = content

    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(tabButtons) do
            b.BackgroundColor3 = (n == name) and Color3.fromRGB(70, 130, 220) or Color3.fromRGB(45, 45, 55)
            b.TextColor3 = (n == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            tabContents[n].Visible = (n == name)
        end
        activeTab = name
    end)

    return btn, content
end

-- Hàm tiện ích tạo label/button/input
local function makeLabel(parent, text, y)
    return create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 24),
        Position = UDim2.new(0, 5, 0, y),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, parent)
end

local function makeTextBox(parent, placeholder, y)
    return create("TextBox", {
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, y),
        BackgroundColor3 = Color3.fromRGB(40, 40, 48),
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
    }, parent)
end

local function makeButton(parent, text, y, color)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 34),
        Position = UDim2.new(0, 5, 0, y),
        BackgroundColor3 = color or Color3.fromRGB(70, 130, 220),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
    }, parent)
    create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
    return btn
end

local function makeToggle(parent, text, y, defaultValue, callback)
    local frame = create("Frame", {
        Size = UDim2.new(1, -10, 0, 34),
        Position = UDim2.new(0, 5, 0, y),
        BackgroundColor3 = Color3.fromRGB(40, 40, 48),
        BorderSizePixel = 0,
    }, parent)
    create("UICorner", { CornerRadius = UDim.new(0, 6) }, frame)

    create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local toggle = create("TextButton", {
        Size = UDim2.new(0, 44, 0, 22),
        Position = UDim2.new(1, -54, 0, 6),
        BackgroundColor3 = defaultValue and Color3.fromRGB(70, 200, 120) or Color3.fromRGB(60, 60, 70),
        Text = "",
        BorderSizePixel = 0,
    }, frame)
    create("UICorner", { CornerRadius = UDim.new(0, 11) }, toggle)

    local dot = create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = defaultValue and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, toggle)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)

    local state = { value = defaultValue }

    local function update()
        TweenService:Create(toggle, TweenInfo.new(0.15), {
            BackgroundColor3 = state.value and Color3.fromRGB(70, 200, 120) or Color3.fromRGB(60, 60, 70),
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.15), {
            Position = state.value and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
        }):Play()
    end

    toggle.MouseButton1Click:Connect(function()
        state.value = not state.value
        update()
        if callback then callback(state.value) end
    end)

    return state
end

--// ============================================================
--// TAB 1: HTTP GET
--// ============================================================
local _, httpTab = createTab("HTTP GET", 1)

makeLabel(httpTab, "📡 Nhập URL để gửi GET request:", 5)
local urlBox = makeTextBox(httpTab, "https://raw.githubusercontent.com/daykits/Ui-banana.lua/refs/heads/main/ui%20BananaHub.lua.txt", 35)

local httpResult = create("ScrollingFrame", {
    Size = UDim2.new(1, -10, 0, 160),
    Position = UDim2.new(0, 5, 0, 120),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Text = "",
}, httpTab)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, httpResult)

local httpResultLabel = create("TextLabel", {
    Size = UDim2.new(1, -10, 0, 0),
    Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1,
    Text = "Kết quả sẽ hiển thị ở đây...",
    TextColor3 = Color3.fromRGB(180, 180, 190),
    TextSize = 12,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    AutomaticSize = Enum.AutomaticSize.Y,
}, httpResult)

local function setHttpResult(text, isError)
    httpResultLabel.Text = text
    httpResultLabel.TextColor3 = isError and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(180, 220, 180)
    httpResult.CanvasSize = UDim2.new(0, 0, 0, httpResultLabel.AbsoluteSize.Y + 15)
end

local sendBtn = makeButton(httpTab, "🚀 Gửi GET Request", 75)
sendBtn.MouseButton1Click:Connect(function()
    local url = urlBox.Text
    if url == "" then
        setHttpResult("⚠️ Vui lòng nhập URL!", true)
        return
    end
    setHttpResult("⏳ Đang gửi request...", false)
    task.spawn(function()
        local ok, res = httpGet(url)
        if ok then
            setHttpResult("✅ Thành công:\n\n" .. tostring(res), false)
        else
            setHttpResult("❌ Lỗi:\n\n" .. tostring(res), true)
        end
    end)
end)

local clearBtn = makeButton(httpTab, "🗑️ Xóa kết quả", 115, Color3.fromRGB(120, 60, 60))
clearBtn.MouseButton1Click:Connect(function()
    setHttpResult("Kết quả sẽ hiển thị ở đây...", false)
    httpResult.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

--// ============================================================
--// TAB 2: MONEY FARM
--// ============================================================
local _, moneyTab = createTab("💰 Money Farm", 2)

makeLabel(moneyTab, "💵 Tự động farm tiền", 5)
makeLabel(moneyTab, "Bật toggle bên dưới để bắt đầu farm tự động.", 30)

local moneyToggle = makeToggle(moneyTab, "Auto Farm Money", 60, false, function(v)
    MoneyFarm.Enabled = v
end)

makeLabel(moneyTab, "⚙️ Cấu hình Farm:", 110)

local amountBox = makeTextBox(moneyTab, "Số tiền mỗi lần (mặc định 100)", 140)
amountBox.Text = "100"
amountBox.FocusLost:Connect(function()
    local n = tonumber(amountBox.Text)
    if n then MoneyFarm.Amount = n end
end)

local farmLog = create("ScrollingFrame", {
    Size = UDim2.new(1, -10, 0, 80),
    Position = UDim2.new(0, 5, 0, 185),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
}, moneyTab)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, farmLog)

local farmLogLabel = create("TextLabel", {
    Size = UDim2.new(1, -10, 0, 0),
    Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1,
    Text = "Chưa hoạt động...",
    TextColor3 = Color3.fromRGB(180, 180, 190),
    TextSize = 12,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    AutomaticSize = Enum.AutomaticSize.Y,
}, farmLog)

-- Theo dõi log farm
task.spawn(function()
    local lastState = false
    while true do
        task.wait(0.5)
        if MoneyFarm.Enabled ~= lastState then
            lastState = MoneyFarm.Enabled
            farmLogLabel.Text = MoneyFarm.Enabled and "✅ Đang farm tiền..." or "⏸️ Đã dừng farm."
            farmLogLabel.TextColor3 = MoneyFarm.Enabled and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(180, 180, 190)
            farmLog.CanvasSize = UDim2.new(0, 0, 0, farmLogLabel.AbsoluteSize.Y + 15)
        end
    end
end)

--// ============================================================
--// TAB 3: AUTO DELIVERY
--// ============================================================
local _, deliveryTab = createTab("🚚 Auto Delivery", 3)

if not modulesOk then
    makeLabel(deliveryTab, "❌ Không thể load module Delivery:\n" .. tostring(modulesErr), 5)
else
    makeLabel(deliveryTab, "🚚 Tự động làm giao hàng (Delivery Job)", 5)

    local deliveryToggle = makeToggle(deliveryTab, "Auto Delivery", 35, false, function(v)
        AutoDelivery.Enabled = v
        if not v then
            clearHover()
        end
    end)

    makeLabel(deliveryTab, "📋 Trạng thái:", 80)

    local statusLabel = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 60),
        Position = UDim2.new(0, 5, 0, 105),
        BackgroundColor3 = Color3.fromRGB(35, 35, 42),
        Text = "⏸️ Chưa bật",
        TextColor3 = Color3.fromRGB(180, 180, 190),
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        BorderSizePixel = 0,
    }, deliveryTab)
    create("UICorner", { CornerRadius = UDim.new(0, 6) }, statusLabel)

    -- Cập nhật status realtime
    task.spawn(function()
        while true do
            task.wait(0.5)
            if AutoDelivery.Enabled then
                local state = delivery and delivery.GetCurrentDeliveryState and delivery.GetCurrentDeliveryState()
                local text = "▶️ Đang chạy"
                if state then
                    text = text .. "\n📦 Items: " .. tostring(state.ItemsCarried or 0) .. "/" .. tostring(state.MaxCapacity or "?")
                    if state.IsDropping then text = text .. "\n📤 Đang giao hàng..."
                    elseif state.IsCollecting then text = text .. "\n📥 Đang thu thập..."
                    end
                else
                    text = text .. "\n🔄 Đang tìm route..."
                end
                statusLabel.Text = text
                statusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
            else
                statusLabel.Text = "⏸️ Chưa bật"
                statusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
            end
        end
    end)

    makeLabel(deliveryTab, "ℹ️ Script sẽ tự động spawn xe + trailer,", 175)
    makeLabel(deliveryTab, "teleport đến điểm giao/nhận hàng.", 195)
end

--// ============================================================
--// TAB MẶC ĐỊNH
--// ============================================================
activeTab = "HTTP GET"
tabButtons["HTTP GET"].BackgroundColor3 = Color3.fromRGB(70, 130, 220)
tabButtons["HTTP GET"].TextColor3 = Color3.fromRGB(255, 255, 255)
tabContents["HTTP GET"].Visible = true

--// Nút minimize / close
MinimizeBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

--// Phím tắt mở menu: RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

--// Thông báo
print("[DE MENU] ✅ Đã load thành công!")
print("[DE MENU] Nhấn RightShift để bật/tắt menu.")
if not modulesOk then
    warn("[DE MENU] ⚠️ Module Delivery lỗi: " .. tostring(modulesErr))
end
