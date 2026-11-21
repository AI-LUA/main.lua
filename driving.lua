--// ============================================================
--// RAYFIELD MENU - HTTP GET + MONEY FARM + AUTO DELIVERY
--// ============================================================

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer

-- Anti-Idle
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
--// DELIVERY MODULES (Safe Load)
--// ============================================================
local delivery, deliveryUtil, vehicles, vehicleUtil, towablesUtil, towables, towablesData, vehicleData, tpGuard
local modulesOk, modulesErr = pcall(function()
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

--// ============================================================
--// DELIVERY LOGIC (từ script gốc)
--// ============================================================
local AutoDelivery = {
    Enabled = false,
    Hover = nil, HoverPart = nil,
    CarId = nil, TrailerId = nil, Checked = false,
    SpawnAt = nil, TrailerAt = nil,
    CurTarget = nil, CurLoc = nil, CurPhase = nil,
    LastTick = nil, LastFire = nil, ProgressAt = nil,
    LastTp = nil, LastChar = nil, LastState = nil, RetryAt = nil,
}

local function clearHover()
    if AutoDelivery.Hover then pcall(function() AutoDelivery.Hover:Destroy() end) end
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
        if hum.SeatPart then clearHover(); hum.Sit = false; hum.Jump = true; return false end
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
            if not ok then warn('[Rayfield] ' .. tostring(err)) end
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
        task.defer(function() if chassis then chassis.Teleporting = false end end)
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

local function deliveryStep()
    if not AutoDelivery.Enabled or not modulesOk then return end
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
                    phase = 'drop'; target = state.DestinationPosition
                else
                    phase = 'pickup'; target = state.PickupPosition
                end
            else
                AutoDelivery.LastTick = AutoDelivery.LastTick or tick()
                if tick() - AutoDelivery.LastTick > 0.25 then
                    local car = vehicleUtil.getPlayerData(plr)
                    local towing = car and towablesUtil.GetAttachedTrailerFromVehicle(car.Model) ~= nil or false
                    local loc = getLoc(hrp.Position, true, towing)
                    phase = 'new'; target = loc and loc.Position
                end
            end
            if target then
                local pos = target + Vector3.new(0, math.min(3.5, deliveryUtil.GetPickupRadius() / 2), 0)
                local part = hum.SeatPart or hrp
                if target ~= AutoDelivery.CurTarget or phase ~= AutoDelivery.CurPhase
                    or ((part.Position - pos).Magnitude > deliveryUtil.GetPickupRadius() / 2
                        and tick() - (AutoDelivery.LastTp or 0) > 2) then
                    if AutoDelivery.CurLoc then ReplicatedStorage.Remotes.DeliveryLocationLeft:FireServer(AutoDelivery.CurLoc) end
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
                    if phase == 'drop' and remaining then timeout = math.min(timeout, math.max(2, remaining / 2)) end
                    if loc == AutoDelivery.CurLoc and tick() - AutoDelivery.ProgressAt > timeout then
                        ReplicatedStorage.Remotes.DeliveryLocationLeft:FireServer(loc)
                        if not tp(CFrame.new(target + Vector3.new(deliveryUtil.GetPickupRadius() + 8, 3.5, 0))) then return end
                        AutoDelivery.CurTarget, AutoDelivery.CurLoc, AutoDelivery.LastFire = nil, nil, nil
                        AutoDelivery.ProgressAt, AutoDelivery.RetryAt = tick(), tick() + 0.5
                        return
                    end
                    local busy = state and (phase == 'drop' and state.IsDropping or phase ~= 'drop' and state.IsCollecting)
                    if loc ~= AutoDelivery.CurLoc or not busy and tick() - (AutoDelivery.LastFire or 0) > 2 then
                        ReplicatedStorage.Remotes.DeliveryLocationInteracted:FireServer(loc)
                        AutoDelivery.CurLoc, AutoDelivery.LastFire = loc, tick()
                    end
                end
            end
        end
    end
end

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
                warn('[Rayfield Delivery] ' .. tostring(err))
                task.wait(1)
            end
        end
    end
end)

--// ============================================================
--// MONEY FARM
--// ============================================================
local MoneyFarm = { Enabled = false, Amount = 100 }
task.spawn(function()
    while true do
        task.wait(0.5)
        if MoneyFarm.Enabled then
            pcall(function()
                -- ⚠️ Thay logic farm tiền của game bạn vào đây
                -- Ví dụ: ReplicatedStorage.Remotes.ClaimMoney:FireServer(MoneyFarm.Amount)
            end)
        end
    end
end)

--// ============================================================
--// HTTP GET
--// ============================================================
local function httpGet(url)
    local ok, res = pcall(function() return HttpService:GetAsync(url) end)
    return ok, ok and res or tostring(res)
end

--// ============================================================
--// RAYFIELD UI
--// ============================================================
local Window = Rayfield:CreateWindow({
    Name = "DE Menu",
    LoadingTitle = "DE Menu",
    LoadingSubtitle = "HTTP + Farm + Delivery",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

--// TAB 1: HTTP GET
local HttpTab = Window:CreateTab("HTTP GET", 4483362458)
local HttpSection = HttpTab:CreateSection("Gửi Request")

local urlInput = HttpSection:CreateInput({
    Name = "URL",
    PlaceholderText = "https://your-api.com/endpoint",
    RemoveTextAfterFocusLost = false,
    Flag = "HttpUrl",
    Callback = function(text) end,
})

local httpResultLabel = HttpSection:CreateLabel("Kết quả sẽ hiển thị ở đây...")

HttpSection:CreateButton({
    Name = "🚀 Gửi GET Request",
    Callback = function()
        local url = urlInput.CurrentValue
        if url == "" then
            Rayfield:Notify({ Title = "Lỗi", Content = "Vui lòng nhập URL!", Duration = 3 })
            return
        end
        httpResultLabel:Set("⏳ Đang gửi request...")
        task.spawn(function()
            local ok, res = httpGet(url)
            if ok then
                httpResultLabel:Set("✅ Thành công:\n" .. tostring(res))
            else
                httpResultLabel:Set("❌ Lỗi:\n" .. tostring(res))
            end
        end)
    end,
})

--// TAB 2: MONEY FARM
local MoneyTab = Window:CreateTab("Money Farm", 4483362458)
local MoneySection = MoneyTab:CreateSection("Auto Farm")

MoneySection:CreateToggle({
    Name = "Bật Auto Farm Money",
    CurrentValue = false,
    Flag = "MoneyFarmToggle",
    Callback = function(v) MoneyFarm.Enabled = v end,
})

MoneySection:CreateInput({
    Name = "Số tiền mỗi lần",
    CurrentValue = "100",
    PlaceholderText = "100",
    RemoveTextAfterFocusLost = false,
    Flag = "MoneyAmount",
    Callback = function(text)
        local n = tonumber(text)
        if n then MoneyFarm.Amount = n end
    end,
})

MoneySection:CreateLabel("⚠️ Cần thay logic farm tiền của game bạn vào script.")

--// TAB 3: AUTO DELIVERY
local DeliveryTab = Window:CreateTab("Auto Delivery", 4483362458)

if not modulesOk then
    DeliveryTab:CreateSection("Lỗi")
    DeliveryTab:CreateLabel("❌ Không load được module Delivery:\n" .. tostring(modulesErr))
else
    local DeliverySection = DeliveryTab:CreateSection("Điều khiển")
    DeliverySection:CreateToggle({
        Name = "Bật Auto Delivery",
        CurrentValue = false,
        Flag = "DeliveryToggle",
        Callback = function(v)
            AutoDelivery.Enabled = v
            if not v then clearHover() end
        end,
    })

    local StatusSection = DeliveryTab:CreateSection("Trạng thái")
    local statusLabel = StatusSection:CreateLabel("⏸️ Chưa bật")

    task.spawn(function()
        while true do
            task.wait(0.5)
            if AutoDelivery.Enabled then
                local state = delivery and delivery.GetCurrentDeliveryState and delivery.GetCurrentDeliveryState()
                local text = "▶️ Đang chạy"
                if state then
                    text = text .. " | Items: " .. tostring(state.ItemsCarried or 0) .. "/" .. tostring(state.MaxCapacity or "?")
                    if state.IsDropping then text = text .. " | Đang giao..."
                    elseif state.IsCollecting then text = text .. " | Đang thu thập..." end
                else
                    text = text .. " | Đang tìm route..."
                end
                statusLabel:Set(text)
            else
                statusLabel:Set("⏸️ Chưa bật")
            end
        end
    end)

    DeliveryTab:CreateSection("Thông tin")
    DeliveryTab:CreateLabel("Script tự động spawn xe + trailer và teleport đến điểm giao/nhận.")
end

--// Thông báo load thành công
Rayfield:Notify({
    Title = "DE Menu",
    Content = "Đã load thành công! Nhấn K để bật/tắt UI.",
    Duration = 5,
})
