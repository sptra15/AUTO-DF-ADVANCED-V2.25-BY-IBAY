-- ============== [[ AUTO DF SCRIPT BY IBAY ]] ============== --
-- Version: V2.25
-- Update: 02 September 2025
-- Author: IBAY
-- Discord: https://discord.gg/ibaysptr
-- Script ini dibuat oleh IBAY, Dilarang menjual ulang script ini tanpa izin pembuat.
-- Terimakasih sudah menggunakan script ini, semoga bermanfaat.
-- Jangan ubah apapun kecuali kamu tau apa yang kamu lakukan
-- Kalau ada error, silahkan lapor ke discord saya
-- Gunakan script ini dengan bijak, saya tidak bertanggung jawab jika akun terkena banned

-- ============== [[ PENGATURAN ]] ============== --
-- Ganti sesuai kebutuhan, pastikan world sudah ada & benar

WorldList = {"WORLD1", "WORLD2", "WORLD3", "WORLD4"} -- ganti sesuai kebutuhan
StoragePlat = "worldstorage|DoorID" -- World penyimpanan platform
worldsaveseed = "worldsave|DoorID" -- World penyimpanan seed
startWorldIndex = 1  -- index world pertama yang mau mulai
totalWorld = 3       -- total world yang mau dijalankan

 
-- ============= Jangan Diubah ============== --
sendDialog({
    title = "🚀 Script Pabrik By IBAY 🚀",
    message = "Fitur Lengkap Script:\n\n" ..
              "🌱 Auto Plant Seed (tanam seed otomatis)\n" ..
              "🪓 Auto Break Dirt & Lava (rusak block otomatis)\n" ..
              "🧹 Auto Clear Dirt (bersihkan dirt di area farming)\n" ..
              "🪴 Fill Empty Cave Tiles (isi tile kosong dengan dirt)\n" ..
              "🟫 Auto Collect Seed & Dirt (ambil seed & hasil harvest otomatis)\n" ..
              "🟦 Auto Place Platform (letakkan platform secara otomatis)\n" ..
              "🗑️ Trash Item Otomatis (buang item sesuai TrashID)\n" ..
              "💾 Auto Save State (menyimpan posisi & state script)\n" ..
              "🔄 Auto Reconnect (jika koneksi putus, balik ke world terakhir)\n" ..
              "🌍 Multi World Support (jalan otomatis ke world berikutnya & skip world yang sudah selesai)\n" ..
              "❌ Auto Disconnect (keluar world dengan aman setelah selesai)\n\n" ..
              "Catatan: Script dibuat karena gabut 😎",
    confirm = "Oke Gas!",
    url = "🔧 Dibuat oleh IBAY | Discord: https://discord.gg/ibaysptr",
    alias = "IBAY"
})

EditToggle("Antibounce", true)
EditToggle("ModFly", true)
EditToggle("Antilag", true)
EditToggle("Fast Trash", true)
EditToggle("Fast Drop", true)

TrashID = {2, 14, 4, 10}
SeedID = {3, 15, 5, 11}

function inv(itemID)
    for _, item in pairs(GetInventory()) do
        if item.id == itemID then
            return item.amount
        end
    end
    return 0
end

function tnjk1_3(x, y)
    local packet = {}
    packet.type = 3
    packet.state = 2592
    packet.value = 18
    packet.px = x
    packet.py = y
    packet.x = (GetLocal().posX)
    packet.y = (GetLocal().posY)
    SendPacketRaw(false, packet)
end

function trh1_3(x, y, id)
    local packet = {}
    packet.type = 3
    packet.value = id
    packet.px = x
    packet.py = y
    packet.x = (GetLocal().posX)
    packet.y = (GetLocal().posY)
    SendPacketRaw(false, packet)
end

function sdtr_11(object)
    local packet = {}
    packet.type = 11
    packet.value = object.id
    packet.x = object.posX
    packet.y = object.posY
    SendPacketRaw(false, packet)
end

function sdt_11(range)
    for _, object in pairs(GetObjectList()) do
        if math.abs(GetLocal().posX - object.posX) <= (32 * range) and math.abs(GetLocal().posY - object.posY) <
            (32 * range) and inv(object.itemid) < 200 then
            sdtr_11(object)
            sleep(15)
        end
    end
end

function findEmptyTile(radius)
    local px = GetLocal().posX // 32
    local py = GetLocal().posY // 32

    -- Cek area sekitar sesuai radius
    for x = -radius, radius do
        for y = -radius, radius do
            local tx = px + x
            local ty = py + y
            local tile = GetTile(tx, ty)

            if tile ~= nil then
                local dropCount = 0
                -- cek drop pakai GetObjectList()
                for _, obj in pairs(GetObjectList()) do
                    local ox = math.floor((obj.posX + 8) / 32)
                    local oy = math.floor(obj.posY / 32)
                    if ox == tx and oy == ty then
                        dropCount = dropCount + 1
                    end
                end

                -- Kalau tile kosong & belum ada drop
                if tile.fg == 0 and tile.bg == 0 and dropCount == 0 then
                    return {
                        x = tx,
                        y = ty
                    }
                end
            end
        end
    end

    -- Kalau semua penuh, cari ke samping lebih jauh
    for offset = 1, radius * 2 do
        local tx = px + offset
        local tile = GetTile(tx, py)
        if tile ~= nil then
            local dropCount = 0
            for _, obj in pairs(GetObjectList()) do
                local ox = math.floor((obj.posX + 8) / 32)
                local oy = math.floor(obj.posY / 32)
                if ox == tx and oy == py then
                    dropCount = dropCount + 1
                end
            end

            if tile.fg == 0 and tile.bg == 0 and dropCount == 0 then
                return {
                    x = tx,
                    y = py
                }
            end
        end
    end

    return nil
end

function cekSeed()
    local needDrop = false
    for _, id in pairs(SeedID) do
        if inv(id) >= 100 then
            needDrop = true
            break
        end
    end

    if needDrop then
        Sleep(200)
        LogToConsole("`0[`9Ibay`0]`4 Drop Seed...")
        Sleep(500)

        -- masuk world save seed
        SendPacket(3, "action|join_request\nname|" .. worldsaveseed)
        Sleep(6000)

        for _, id in pairs(SeedID) do
            local jumlah = inv(id)
            if jumlah >= 100 then
                -- cari tile kosong dengan radius 5
                local emptyTile = findEmptyTile(5)

                if emptyTile ~= nil then
                    -- pindah ke tile kosong
                    FindPath(emptyTile.x, emptyTile.y)
                    Sleep(1000)

                    -- drop seed
                    SendPacket(2, "action|drop\n|itemID|" .. id)
                    Sleep(100)
                    SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. id .. "|\ncount|" .. jumlah)
                    Sleep(2000)
                else
                    LogToConsole("`0[`9Ibay`0]`c Tidak ada tile kosong ditemukan untuk drop!")
                end
            end
        end

        -- balik lagi ke world farming
        SendPacket(3, "action|join_request\nname|" .. nameworld)
        Sleep(6000)
    end
end

function Trash()
    for _, id in ipairs(TrashID) do
        local jumlah = inv(id)
        if jumlah >= 50 then
            LogToConsole("`0[`9Ibay`0]`4 Trash Item")
            SendPacket(2, "action|trash\n|itemID|" .. id)
            Sleep(1000)
            SendPacket(2, "action|dialog_return\ndialog_name|trash_item\nitemID|" .. id .. "|\ncount|" .. jumlah)
            Sleep(1000)
        end
    end
end

function jn_w(world)
    LogToConsole("`0[`9Ibay`0]`4Join world: " .. world)
    SendPacket(3, "action|join_request\nname|" .. world)
    Sleep(6000) -- tunggu join world
end

function smpng_12()
    local function clearColumn(column)
        for tiley = 24, 53 do
            if GetTile(column, tiley).bg == 14 or GetTile(column + 1, tiley).bg == 14 then
                FindPath(column, tiley - 1)
                Sleep(1000)
                while GetTile(column, tiley).bg == 14 do
                    tnjk1_3(column, tiley)
                    Sleep(200)
                end
                while GetTile(column + 1, tiley).bg == 14 do
                    tnjk1_3(column + 1, tiley)
                    Sleep(200)
                end
                sdt_11(3)
            end
            cekSeed()
            Trash()
        end
    end
    clearColumn(0)
    clearColumn(98)
end

function plfS_15(world)
    if inv(102) < 52 then
        LogToConsole("`0[`9Ibay`0]`4 Mengambil Platform...")
        Sleep(2000)
        jn_w(StoragePlat)
        Sleep(1000)
        while inv(102) < 52 do
            for _, object in pairs(GetObjectList()) do
                if object.itemid == 102 then
                    FindPath(math.floor((object.posX + 8) / 32) - 1, math.floor(object.posY / 32))
                    Sleep(1000)
                    sdtr_11(object)
                    Sleep(500)
                    if inv(102) >= 52 then
                        break
                    end
                end
            end
        end
        jn_w(worldName)
        Sleep(2000)
    end
    for tiley = 2, 52, 2 do
        if GetTile(1, tiley).fg == 0 then
            FindPath(0, tiley)
            Sleep(200)
            while GetTile(1, tiley).fg == 0 do
                trh1_3(1, tiley, 102)
                Sleep(200)
            end
        end
    end
    for tiley = 2, 52, 2 do
        if GetTile(98, tiley).fg == 0 then
            FindPath(99, tiley)
            Sleep(200)
            while GetTile(98, tiley).fg == 0 do
                trh1_3(98, tiley, 102)
                Sleep(200)
            end
        end
    end
    Sleep(1000)
    KeepAlive("plfS_15")
    SendPacket(2, "action|respawn")
    Sleep(4000)
end

function clrd_down_15()
    for tiley = 27, 51, 12 do
        for tilex = 2, 97, 1 do
            if GetTile(tilex, tiley - 2).bg ~= 0 or GetTile(tilex, tiley).bg ~= 0 or GetTile(tilex, tiley + 2).bg ~= 0 then
                FindPath(tilex - 1, tiley)
                Sleep(200)
                for i = -2, 2, 2 do
                    while GetTile(tilex, tiley + i).bg ~= 0 do
                        tnjk1_3(tilex, tiley + i)
                        Sleep(200)
                    end
                    sdt_11(3)
                end
                cekSeed()
                Trash()
            end
        end
        if (tiley + 6) ~= 57 then
            for tilex = 97, 2, -1 do
                if GetTile(tilex, tiley + 4).bg ~= 0 or GetTile(tilex, tiley + 6).bg ~= 0 or
                    GetTile(tilex, tiley + 8).bg ~= 0 then
                    FindPath(tilex + 1, tiley + 6)
                    Sleep(200)
                    for i = 4, 8, 2 do
                        while GetTile(tilex, tiley + i).bg ~= 0 do
                            tnjk1_3(tilex, tiley + i)
                            Sleep(200)
                        end
                        sdt_11(3)
                    end
                    cekSeed()
                    Trash()
                end
            end
        end
        KeepAlive("clrd_down_15")
    end
end

function brkLv_12()
    -- cek dulu ada lava atau tidak
    local lavaExists = false
    for _, tile in pairs(GetTiles()) do
        if tile.fg == 4 then
            lavaExists = true
            break
        end
    end

    -- kalau tidak ada lava, langsung return
    if not lavaExists then
        LogToConsole("`0[`9Ibay`0]`4Tidak ada lava")
        Sleep(200)
        return
    end

    -- kalau lava ada, lanjut proses normal
    for _, tile in pairs(GetTiles()) do
        if tile.fg == 4 then
            FindPath(tile.x, tile.y - 1)
            Sleep(200)
            local currentTile = GetTile(tile.x, tile.y)

            while currentTile.fg == 4 do
                tnjk1_3(tile.x, tile.y)
                Sleep(200)
                currentTile = GetTile(tile.x, tile.y)
            end

            sdt_11(3)

            currentTile = GetTile(tile.x, tile.y)
            if currentTile.fg == 0 then
                while inv(2) == 0 do
                    ambilSeed(3, 50) -- ambil seed kalau block habis
                    plntDf_122() -- tanam dirt biar jadi block
                    Sleep(500)
                end

                -- setelah dipastikan ada block di inventory
                trh1_3(tile.x, tile.y, 2)
                Sleep(500)
            end
            KeepAlive("brkLv_12")
        end
    end
end

function plntDf_122()
    LogToConsole("`0[`9Ibay`0]`4Plant Seed")
    Sleep(2000)
    FindPath(2, 23)
    Sleep(500)

    local firstPlant = true -- cek apakah plant pertama

    while true do
        for tilex = 2, 25 do
            -- Ambil seed kalau habis
            if inv(3) == 0 then
                ambilSeed(3, 50)
                Sleep(200)
            end

            local tile = GetTile(tilex, 23)

            -- Harvest dirt ready
            if tile.fg == 3 and tile.readyharvest then
                FindPath(tilex, 23)
                Sleep(200)
                while GetTile(tilex, 23).fg == 3 and GetTile(tilex, 23).readyharvest do
                    tnjk1_3(tilex, 23)
                    Sleep(200)
                    trh1_3(tilex, 23, 3) -- langsung tanam lagi setelah tnjk
                    Sleep(200)
                end
                sdt_11(3)
            end

            -- Plant seed jika kosong
            if tile.fg == 0 and inv(3) > 0 then
                FindPath(tilex, 23)
                Sleep(200)
                while GetTile(tilex, 23).fg == 0 and inv(3) > 0 do
                    trh1_3(tilex, 23, 3)
                    Sleep(200)
                end
            end
        end

        -- stop kalau dirt sudah penuh
        if inv(2) > 100 then
            break
        end

        -- kalau baru pertama kali tanam → tunggu 25 detik
        if firstPlant then
            LogToConsole("`0[`9Ibay`0]`4Menunggu Harvest")
            Sleep(25000)
            firstPlant = false
        end

        KeepAlive("plntDf_122")
    end
end


function cE_15(x, y)
    for i = 1, 5 do
        if GetTile((x - 3) + i, y).fg == 0 then
            return true
        end
    end
    return false
end

function plnthrvst_2(x, y)
    while inv(2) < 100 do
        local hasHarvest = false
        for tilex = 2, 25 do
            local tile = GetTile(tilex, 23)
            if tile.readyharvest then
                hasHarvest = true
                FindPath(tilex, 23)
                Sleep(200)
                while tile.fg == 3 and tile.readyharvest do
                    tnjk1_3(tilex, 23)
                    Sleep(200)
                    tile = GetTile(tilex, 23)
                end
                sdt_11(3)
                while tile.fg == 0 do
                    if inv(3) == 0 then
                        break
                    end
                    trh1_3(tilex, 23, 3)
                    Sleep(200)
                    tile = GetTile(tilex, 23)
                end
                if inv(2) > 100 then
                    break
                end
            end
        end
        if not hasHarvest then
            break
        end
    end

    Sleep(600)
end

function plcDrt_2()
    for tiley = 24, 2, -2 do
        for tilex = 2, 97, 5 do
            if cE_15(tilex, tiley) then
                FindPath(tilex, tiley + 1)
                Sleep(300)
                for i = 1, 5 do
                    local tx = math.min((tilex - 3) + i, 98)  -- jangan melebihi 98
                    while inv(3) < 24 do
                        ambilSeed(3, 50)
                        Sleep(200)
                    end
                    if inv(2) == 0 then
                        plntDf_122()
                        Sleep(200)
                    end
                    if GetTile(tx, tiley).fg == 0 then
                        FindPath(tx, tiley + 1)
                        Sleep(200)
                        while GetTile(tx, tiley).fg == 0 do
                            trh1_3(tx, tiley, 2)
                            Sleep(200)
                        end
                    end
                end
            end
        end
        KeepAlive("plcDrt_2")
    end
end

function ambilSeed(id, jumlah)
    if inv(id) < jumlah then
        LogToConsole("`0[`9Ibay`0]`4 Mengambil Seed...")

        SendPacket(3, "action|join_request\nname|" .. worldsaveseed)
        Sleep(6000)

        for _, object in pairs(GetObjectList()) do
            if object.itemid == id then
                FindPath(math.floor((object.posX + 8) / 32) - 1, math.floor(object.posY / 32))
                Sleep(500)
                sdtr_11(object)
                Sleep(500)
                if inv(id) >= jumlah then
                    break
                end
            end
        end

        SendPacket(3, "action|join_request\nname|" .. nameworld)
        Sleep(6000)

    end
end

function fillEmptyCaveTiles()
    for _, tile in pairs(GetTiles()) do
        if tile.bg == 14 and tile.fg == 0 then
            -- jalan ke atas tile
            FindPath(tile.x, tile.y - 1)
            Sleep(200)

            -- pastikan ada dirt
            while inv(2) == 0 do
                ambilSeed(3, 50)
                plntDf_122()
                Sleep(200)
            end

            -- pasang dirt
            while GetTile(tile.x, tile.y).fg == 0 do
                trh1_3(tile.x, tile.y, 2)
                Sleep(200)
            end
        end
    end
end

function clearLeftoverSafe()
    LogToConsole("`0[`9Ibay`0]`4Cek sisa dirt & seed dengan cepat...")
    Sleep(1000)
    local localX = GetLocal().posX // 32
    local localY = GetLocal().posY // 32

    for tiley = 2, 24 do
        for tilex = 1, 98 do
            local tile = GetTile(tilex, tiley)

            -- Harvest dirt ready
            if tile.fg == 3 and tile.readyharvest then
                if math.abs(localX - tilex) > 5 or math.abs(localY - tiley) > 5 then
                    FindPath(tilex, tiley + 1)
                    Sleep(150)
                    localX, localY = tilex, tiley
                end
                while tile.fg == 3 and tile.readyharvest do
                    tnjk1_3(tilex, tiley)
                    Sleep(150)
                    tile = GetTile(tilex, tiley)
                end
                sdt_11(3) -- ambil hasil harvest
            end

            -- Ambil semua floating item di tile
            for _, obj in pairs(GetObjectList()) do
                local ox = math.floor((obj.posX + 8) / 32)
                local oy = math.floor(obj.posY / 32)
                if ox == tilex and oy == tiley then
                    sdtr_11(obj)
                    Sleep(150)
                end
            end

            -- Trash item sesuai TrashID
            Trash()
        end
        KeepAlive("clearLeftoverSafe")
    end

    LogToConsole("`0[`9Ibay`0]`4Sisa dirt & seed sudah dibersihkan dengan cepat!")
end

-- ======== [ MODULE: AUTOSAVE + AUTORECONNECT ] ========
local STATE_FILE = "last_state_ibay.txt"
local AUTO_RECONNECT = true
local INTENTIONAL_DISCONNECT = false
local SAVE_INTERVAL_MS = 1500
local REJOIN_COOLDOWN_MS = 4000

local lastSaveTime = 0

local function nowMs()
    return os.clock() * 1000 -- estimasi ms
end

local function safeWrite(path, text)
    local f = io.open(path, "w")
    if f then
        f:write(text or "");
        f:close();
        return true
    end
    return false
end

local function safeRead(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local all = f:read("*a");
    f:close()
    return all
end

function SaveState(tag)
    local w = "?"
    local lx, ly = 0, 0
    local me = GetLocal()
    if me then
        lx = math.floor(me.posX / 32)
        ly = math.floor(me.posY / 32)
        -- coba tebak world dari minimap; kalau tidak, pakai nameworld
        w = (GetCurrentWorld and GetCurrentWorld()) or nameworld or "?"
    else
        w = nameworld or "?"
    end
    local line = table.concat({w, tostring(lx), tostring(ly), tostring(tag or "-")}, "|")
    safeWrite(STATE_FILE, line)
end

function LoadState()
    local raw = safeRead(STATE_FILE)
    if not raw or raw == "" then
        return nil
    end
    local w, sx, sy, stag = raw:match("([^|]+)|([^|]+)|([^|]+)|([^|]*)")
    if not w then
        return nil
    end
    return {
        world = w,
        x = tonumber(sx) or 10,
        y = tonumber(sy) or 10,
        tag = stag or "-"
    }
end

-- panggil ini sering-sering di loop untuk autosave
function KeepAlive(tag)
    local now = nowMs()
    if now - lastSaveTime > SAVE_INTERVAL_MS then
        SaveState(tag or "autosave")
        lastSaveTime = now
    end
end

-- ======== [ EVENT AUTORECONNECT SESUAI API DOCS ] ========

function OnDisconnected()
    if AUTO_RECONNECT and not INTENTIONAL_DISCONNECT then
        LogToConsole("Koneksi terputus. Mencoba reconnect...")
        Sleep(5000)
        local st = LoadState() or {
            world = nameworld,
            x = 10,
            y = 10
        }
        SendPacket(3, "action|join_request\nname|" .. string.upper(st.world) .. "\ninvitedWorld|0")
    end
end

function OnConnected()
    if AUTO_RECONNECT and not INTENTIONAL_DISCONNECT then
        local st = LoadState()
        if st then
            LogToConsole("✅ Reconnect sukses. Balik ke world " .. st.world)

            -- respawn dulu biar aman
            SendPacket(2, "action|respawn")
            Sleep(1000)

            -- pindah ke posisi terakhir
            FindPath(st.x, st.y)
            Sleep(800)

            -- lanjutkan aksi terakhir
            AvoidError(mainDF)
        else
            -- kalau state kosong, fallback join ke world default
            SendPacket(3, "action|join_request\nname|" .. nameworld)
            Sleep(4000)
            AvoidError(mainDF)
        end
    end
end

-- ======== [ END EVENT AUTORECONNECT ] ========

-- ======== [ TRACK WORLD YANG SUDAH SELESAI ] ========
local FINISHED_FILE = "finished_worlds.txt"
local finishedWorlds = {}

-- simpan ke file
local function saveFinishedWorlds()
    local f = io.open(FINISHED_FILE, "w")
    if f then
        for name, done in pairs(finishedWorlds) do
            if done then
                f:write(name .. "\n")
            end
        end
        f:close()
    end
end

-- load dari file
local function loadFinishedWorlds()
    local f = io.open(FINISHED_FILE, "r")
    if not f then return end
    for line in f:lines() do
        finishedWorlds[line] = true
    end
    f:close()
end

-- tandai world selesai
local function markWorldDone(worldName)
    finishedWorlds[worldName] = true
    saveFinishedWorlds()
end

-- cek world sudah selesai atau belum
local function isWorldDone(worldName)
    return finishedWorlds[worldName] == true
end

-- load progress sebelumnya
loadFinishedWorlds()
-- ======== [ END TRACK WORLD YANG SUDAH SELESAI ] ========

-- ========== FUNCTION ERROR HANDLING ==========
function AvoidError(func, ...)
    local status, err = pcall(func, ...)
    if not status then
        LogToConsole("`0[`9Ibay`0]`4Error: " .. tostring(err) .. " , Restarting Script...")
        Sleep(2000)
        AvoidError(func, ...)
    end
end


-- Table untuk nyimpen status world yang sudah selesai
WorldDone = {}

function isWorldDone(world)
    return WorldDone[world] == true
end

function markWorldDone(world)
    WorldDone[world] = true
end

-- ========== MAIN FUNCTION ==========
function mainDF()
    LogToConsole("`0[`9Ibay`0]`4Memulai Script Auto Dirt Farm By IBAY")
    Sleep(2000)

    for i = startWorldIndex, startWorldIndex + totalWorld - 1 do
        local worldName = WorldList[i]
        nameworld = worldName

        -- kalau world sudah selesai → skip
        if isWorldDone(worldName) then
            LogToConsole("`0[`9Ibay`0]`c[SKIP] " .. worldName .. " sudah selesai sebelumnya, lanjut world berikutnya...")
        else
            -- join world
            jn_w(worldName)
            Sleep(2000)

            -- proses farming normal
            AvoidError(function()
                LogToConsole("`0[`9Ibay`0]`4Clear Side DIRT")
                smpng_12()
                Sleep(2000)

                LogToConsole("`0[`9Ibay`0]`4Place Plat")
                plfS_15(worldName)
                Sleep(2000)

                LogToConsole("`0[`9Ibay`0]`4Clear Dirt")
                clrd_down_15()
                Sleep(2000)

                LogToConsole("`0[`9Ibay`0]`4Break Lava")
                brkLv_12()
                Sleep(2000)

                LogToConsole("`0[`9Ibay`0]`4Plant Dirt Farm")
                plntDf_122()
                Sleep(2000)

                LogToConsole("`0[`9Ibay`0]`4Place Dirt")
                plcDrt_2()
                Sleep(2000)

                LogToConsole("`0[`9Ibay`0]`4Fill Empty Cave")
                fillEmptyCaveTiles()
                Sleep(2000)

                LogToConsole("`0[`9Ibay`0]`4Clear Sisa Seed/Dirt")
                clearLeftoverSafe()
                Sleep(2000)
            end)

            -- tandai selesai world ini
            markWorldDone(worldName)
            LogToConsole("`0[`9Ibay`0]`2Selesai di " .. worldName)
        end

        -- cek apakah masih ada world berikutnya
        if i < (startWorldIndex + totalWorld - 1) then
            LogToConsole("`0[`9Ibay`0]`2Lanjut world berikutnya...")
            Sleep(2000)
        else
            -- world terakhir → quit
            SendPacket(2, "action|input\n|text|`0[`9Ibay`0]`4UDAH SELESAI BOSQUEE, CAPE KERJA RODI")
            Sleep(1000)

            AUTO_RECONNECT = false
            INTENTIONAL_DISCONNECT = true
            SendPacket(2, "action|respawn")
            Sleep(3000)
            SaveState("exit")
            Sleep(1000)
            SendPacket(3, "action|quit")

            LogToConsole("`4[EXIT] Semua world sudah selesai, script berhenti.")
        end
    end
end

AvoidError(mainDF)


-- ============== [[ END OF SCRIPT BY IBAY ]] ============== --
-- Script ini dibuat oleh IBAY, Dilarang menjual ulang script ini tanpa izin pembuat.
-- Terimakasih sudah menggunakan script ini, semoga bermanfaat.
