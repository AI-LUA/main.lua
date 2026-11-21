--// ============================================================
--// RAYFIELD GEN2 MENU - FIXED AUTO DELIVERY & MONEY FARM
--// ============================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Plrs = game:GetService('Players')
local RunService = game:GetService('RunService')
local CS = game:GetService('CollectionService')
local RS = game:GetService('ReplicatedStorage')
local VU = game:GetService('VirtualUser')

local plr = Plrs.LocalPlayer

-- Anti-Idle
if getconnections then
    pcall(function()
        for _, v in ipairs(getconnections(plr.Idled)) do v:Disable() end
    end)
end
plr.Idled:Connect(function()
    pcall(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.zero)
    end)
end)

-- ==========================================
-- 1. DELIVERY MODULES (Có pcall an toàn)
-- ==========================================
local delivery, deliveryUtil, vehicles, vehicleUtil, towablesUtil, towables, towablesData, vehicleData, tpGuard
local modulesOk, modulesErr = pcall(function()
    delivery = require(RS.Modules.Client.Jobs.Tasks.DeliveryJobTask)
    deliveryUtil = require(RS.Modules.Shared.Jobs.Delivery.DeliveryUtil)
    vehicles = require(RS.Modules.Client.Vehicles.VehicleController)
    vehicleUtil = require(RS.Modules.Shared.Vehicles.VehicleUtil)
    towablesUtil = require(RS.Modules.Shared.Towables.TowablesUtil)
    towables = require(RS.Modules.Client.Towables.TowablesController)
    towablesData = require(RS.Modules.Shared.DataManager.Data.TowablesData)
    vehicleData = require(RS.Modules.Shared.DataManager.Data.VehicleData)
    tpGuard = require(RS.Modules.Client.Exploit.VehicleTeleportDetectionController)
end)

-- ==========================================
-- 2. BIẾN TOÀN CỤC CHO AUTO DELIVERY
-- ==========================================
local autoDeliveryEnabled = false
local hover, hoverPart
local carId, trailerId, checked, spawnAt, trailerAt
local curTarget, curLoc, curPhase, lastTick, lastFire, progressAt, lastTp, lastChar, lastState, retryAt

local function clearHover()
    if hover then hover:Destroy() end
    hover, hoverPart = nil, nil
end

local function getLoc(pos, skipLast, towing)
    local loc, dist
    for _, v in ipairs(CS:GetTagged('DeliveryLocation')) do
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
    if not checked then
        local owned = vehicleData.GetOwnedVehicleIds(plr, true)
        local capacity = 0
        for id, v in pairs(towablesUtil.GetEnabledTowables()) do
            if v.ChassisType == 'Generic' and (v.CargoCapacity or 0) > capacity
                and towablesData.IsTowableUnlocked(plr, id) then
                for _, vehicleId in ipairs(owned) do
                    if towablesUtil.CanVehicleTowTowable(vehicleId, id, plr) then
                        carId, trailerId, capacity = vehicleId, id, v.CargoCapacity
                        break
                    end
                end
            end
        end
        checked = true
    end

    if not carId then
        if hum.SeatPart then
            clearHover(); hum.Sit = false; hum.Jump = true; return false
        end
        return true
    end

    local model = vehicleUtil.GetPlayerSpawnedVehicle(plr)
    local carType = model and model:FindFirstChild('CarType')
    if not carType or carType.Value ~= carId then
        if state and ((state.ItemsCarried or 0) > 0 or state.IsDropping) then return false end
        if not spawnAt or tick() - spawnAt > 10 then
            clearHover()
            spawnAt, trailerAt = tick(), nil
            RS.Remotes.VehicleEvent:FireServer('Spawn', carId)
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
    if not trailer or trailer:GetAttribute('TowableId') ~= trailerId then
        if state and ((state.ItemsCarried or 0) > 0 or state.IsDropping) then return false end
        if not trailerAt or tick() - trailerAt > 10 then
            clearHover()
            trailerAt = tick()
            local ok, err = towables.AttemptToSpawnTowable(trailerId)
            if not ok then warn('[DE] ' .. tostring(err)) end
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

        hover = Instance.new('BodyVelocity')
        hover.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        hover.Velocity = Vector3.zero
        hover.Parent = car.WeightPart
        hoverPart = car.WeightPart

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
            hover = Instance.new('BodyVelocity')
            hover.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            hover.Velocity = Vector3.zero
            hover.Parent = hrp
            hoverPart = hrp
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
    return true
end

RunService.Heartbeat:Connect(function()
    if not autoDeliveryEnabled then return end
    local char = plr.Character
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    if hoverPart and (not hoverPart.Parent or not hrp or plr:GetAttribute('JobId') ~= 'Delivery'
        or (hoverPart ~= hrp and (not hum or not hum.SeatPart))) then
        clearHover()
    end
    if hrp then hrp.Anchored = false end
    if hum and hover and hover.Parent == hrp then
        hum:ChangeState(Enum.HumanoidStateType.Freefall)
    end
end)

RS.Remotes.DeliveryCompleted.OnClientEvent:Connect(function(result)
    if result and result.FailureReason then
        warn('[DE] delivery failed: ' .. tostring(result.FailureReason))
    end
end)

local function step()
    if not autoDeliveryEnabled or not modulesOk then return end
    local char = plr.Character
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    local hum = char and char:FindFirstChildOfClass('Humanoid')

    if char ~= lastChar then
        clearHover()
        curTarget, curLoc, curPhase, lastTick, lastFire, progressAt, lastTp, lastState = nil, nil, nil, nil, nil, nil, nil, nil
        lastChar = char
        spawnAt, trailerAt, retryAt = nil, nil, nil
    end

    if hrp and hum and hum.Health > 0 then
        if retryAt and tick() < retryAt then return end
        retryAt = nil

        local state = delivery.GetCurrentDeliveryState()
        if not setupVehicle(hum, state) then return end

        if plr:GetAttribute('JobId') ~= 'Delivery' then
            RS.Remotes.RequestStartJobSession:FireServer('Delivery', 'deliveryHub', 'HighRisk')
            clearHover()
            curTarget, curLoc, curPhase, lastTick, lastFire, progressAt, lastTp, lastState = nil, nil, nil, nil, nil, nil, nil, nil
            task.wait(0.5)
        else
            local target, phase
            local remaining = state and state.ExpirationTime and state.ExpirationTime - workspace:GetServerTimeNow()
            local newRoute = state and (not lastState or state.PickupPosition ~= lastState.PickupPosition
                or state.DestinationPosition ~= lastState.DestinationPosition
                or state.DeliveryStartTime ~= lastState.DeliveryStartTime)
            if newRoute then
                curTarget, curLoc, curPhase, lastFire = nil, nil, nil, nil
            end
            if not progressAt or newRoute or (state == nil) ~= (lastState == nil)
                or (state and lastState and (state.ItemsCarried ~= lastState.ItemsCarried
                    or state.PackagesRemainingAtPickup ~= lastState.PackagesRemainingAtPickup
                    or state.IsPlanned ~= lastState.IsPlanned)) then
                progressAt = tick()
            end
            lastState = state

            if state then
                lastTick = nil
                local carried = state.ItemsCarried or 0
                local cap = state.MaxCapacity or carried
                local full = carried >= cap
                local noMore = state.PackagesRemainingAtPickup == 0
                if state.IsDropping or curPhase == 'drop'
                    or carried > 0 and (full or noMore or remaining and remaining <= 5) then
                    phase = 'drop'; target = state.DestinationPosition
                else
                    phase = 'pickup'; target = state.PickupPosition
                end
            else
                lastTick = lastTick or tick()
                if tick() - lastTick > 0.25 then
                    local car = vehicleUtil.getPlayerData(plr)
                    local towing = car and towablesUtil.GetAttachedTrailerFromVehicle(car.Model) ~= nil or false
                    local loc = getLoc(hrp.Position, true, towing)
                    phase = 'new'; target = loc and loc.Position
                end
            end

            if target then
                local pos = target + Vector3.new(0, math.min(3.5, deliveryUtil.GetPickupRadius() / 2), 0)
                local part = hum.SeatPart or hrp
                if target ~= curTarget or phase ~= curPhase
                    or ((part.Position - pos).Magnitude > deliveryUtil.GetPickupRadius() / 2 and tick() - (lastTp or 0) > 2) then
                    if curLoc then RS.Remotes.DeliveryLocationLeft:FireServer(curLoc) end
                    if not tp(CFrame.new(pos)) then return end
                    curTarget, curPhase, lastTp = target, phase, tick()
                    curLoc, lastFire = nil, nil
                end
                if tick() - (lastTp or 0) < 0.5 then return end

                local loc = getLoc(target)
                if loc and (loc.Position - target).Magnitude < 1
                    and (part.Position - loc.Position).Magnitude <= deliveryUtil.GetPickupRadius() then
                    if loc ~= curLoc then progressAt = tick() end
                    local timeout = math.max(10, deliveryUtil.GetItemCollectTime(plr) * 3)
                    if phase == 'drop' and remaining then timeout = math.min(timeout, math.max(2, remaining / 2)) end
                    if loc == curLoc and tick() - progressAt > timeout then
                        RS.Remotes.DeliveryLocationLeft:FireServer(loc)
                        if not tp(CFrame.new(target + Vector3.new(deliveryUtil.GetPickupRadius() + 8, 3.5, 0))) then return end
                        curTarget, curLoc, lastFire = nil, nil, nil
                        progressAt, retryAt = tick(), tick() + 0.5
                        return
                    end
                    local busy = state and (phase == 'drop' and state.IsDropping or phase ~= 'drop' and state.IsCollecting)
                    if loc ~= curLoc or not busy and tick() - (lastFire or 0) > 2 then
                        RS.Remotes.DeliveryLocationInteracted:FireServer(loc)
                        curLoc, lastFire = loc, tick()
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if autoDeliveryEnabled then
            local ok, err = pcall(step)
            if not ok then
                curTarget, curLoc, curPhase, lastTick, lastFire, progressAt, lastTp, lastState = nil, nil, nil, nil, nil, nil, nil, nil
                clearHover()
                warn('[DE] ' .. tostring(err))
                task.wait(1)
            end
        end
    end
end)

-- ==========================================
-- 3. LOGIC MONEY FARM
-- ==========================================
local MoneyFarm = { Enabled = false, Amount = 100, Thread = nil }

local function startMoneyFarm()
    if MoneyFarm.Thread then return end
    MoneyFarm.Thread = task.spawn(function()
        while MoneyFarm.Enabled do
            pcall(function()
                -- ⚠️ THAY LOGIC FARM TIỀN CỦA GAME BẠN VÀO ĐÂY
                -- Ví dụ: RS.Remotes.ClaimMoney:FireServer(MoneyFarm.Amount)
                print("Farm tiền...", MoneyFarm.Amount)
            end)
            task.wait(0.5)
        end
        MoneyFarm.Thread = nil
    end)
end

local function stopMoneyFarm()
    MoneyFarm.Enabled = false
    if MoneyFarm.Thread then
        pcall(function() task.cancel(MoneyFarm.Thread) end)
        MoneyFarm.Thread = nil
    end
end

-- ==========================================
-- 4. RAYFIELD GEN2 UI
-- ==========================================
local Window = Rayfield:CreateWindow({
    name = "DE Menu",
    subtitle = "Money Farm + Auto Delivery",
    sidebarLayout = true,
})

--// TAB MONEY FARM
local MoneyTab = Window:CreateTab({ name = "Money Farm" })

MoneyTab:CreateToggle({
    name = "Bật Auto Farm Money",
    currentValue = false,
    callback = function(value)
        MoneyFarm.Enabled = value
        if value then startMoneyFarm() else stopMoneyFarm() end
    end,
})

MoneyTab:CreateInput({
    name = "Số tiền mỗi lần",
    placeholder = "100",
    currentValue = "100",
    removeTextAfterFocusLost = false,
    callback = function(text)
        local n = tonumber(text)
        if n then MoneyFarm.Amount = n end
    end,
})

--// TAB AUTO DELIVERY
local DeliveryTab = Window:CreateTab({ name = "Auto Delivery" })

DeliveryTab:CreateToggle({
    name = "Bật Auto Delivery",
    currentValue = false,
    callback = function(value)
        autoDeliveryEnabled = value
        if not value then
            -- Tắt: dừng toàn bộ và clear
            clearHover()
            curTarget, curLoc, curPhase, lastTick, lastFire, progressAt, lastTp, lastState = nil, nil, nil, nil, nil, nil, nil, nil
        end
    end,
})

Rayfield:Notify({
    title = "DE Menu",
    content = "Đã load thành công!",
    duration = 5,
})
