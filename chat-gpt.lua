--// ============================================================
--// GAME CHECKER - TỰ ĐỘNG CHẠY SCRIPT THEO GAME
--// ============================================================

local PlaceId = game.PlaceId

--// ============================================================
--// 1. BLOX FRUITS (ID: 2753915549)
--// ============================================================
local function runBloxFruits()
    print("[Hệ thống] Đã nhận diện: Blox Fruits")
    https://raw.githubusercontent.com/AI-LUA/main.lua/refs/heads/main/bloxfruits.lua
end

--// ============================================================
--// 2. DRIVING EMPIRE (ID: 3351674303)
--// ============================================================
local function runDrivingEmpire()
    print("[Hệ thống] Đã nhận diện: Driving Empire")
    https://raw.githubusercontent.com/AI-LUA/main.lua/refs/heads/main/driving.lua
end

--// ============================================================
--// 3. MEME SEA (ID: 10260193230)
--// ============================================================
local function runMemeSea()
    print("[Hệ thống] Đã nhận diện:memesea
    https://raw.githubusercontent.com/AI-LUA/main.lua/refs/heads/main/memesea.lua
end

--// ============================================================
--// 4. LETHAL APE (ID: 117713779364528)
--// ============================================================
local function runLethalApe()
    print("[Hệ thống] Đã nhận diện: Lethal Ape")
    https://raw.githubusercontent.com/AI-LUA/main.lua/refs/heads/main/lethalape.lua
end

--// ============================================================
--// BỘ ĐIỀU HƯỚNG (KHÔNG SỬA PHẦN NÀY)
--// ============================================================
if PlaceId == 2753915549 then
    runBloxFruits()
elseif PlaceId == 3351674303 then
    runDrivingEmpire()
elseif PlaceId == 10260193230 then
    runMemeSea()
elseif PlaceId == 117713779364528 then
    runLethalApe()
else
    warn("[Hệ thống] Game hiện tại (PlaceId: " .. tostring(PlaceId) .. ") không có trong danh sách hỗ trợ!")
end
