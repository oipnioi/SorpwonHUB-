---@diagnostic disable
--!nocheck
--!nolint
--[[
    ═══════════════════════════════════════════════════════════
    RIDER WORLD - SORPWON HUB EDITION
    Redesigned with SorpwonHUB interface.
    ═══════════════════════════════════════════════════════════
]] --

-- Load SorpwonHUB UI Library
-- ★ THAY LINK GITHUB CỦA BẠN VÀO ĐÂY ★
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/oipnioi/SorpwonHUB-/refs/heads/main/SorpwonHUB.lua"

local SorpwonHUB
local libLoaded, loadedLib = pcall(function()
    -- Ưu tiên 1: Đọc file local trong workspace của executor
    if isfile and isfile("SorpwonHUB.lua") then
        return loadstring(readfile("SorpwonHUB.lua"))()
    elseif isfile and isfile("SorpwonHUB.luau") then
        return loadstring(readfile("SorpwonHUB.luau"))()
    end

    -- Ưu tiên 2: Load từ GitHub raw URL
    local code
    if game and game.HttpGet then
        code = game:HttpGet(GITHUB_RAW_URL)
    elseif httpget then
        code = httpget(GITHUB_RAW_URL)
    elseif request then
        code = request({Url = GITHUB_RAW_URL}).Body
    elseif http_request then
        code = http_request({Url = GITHUB_RAW_URL}).Body
    end

    if code and #code > 0 then
        return loadstring(code)()
    end
end)

if libLoaded and loadedLib then
    SorpwonHUB = loadedLib
else
    error("[SorpwonHUB] Failed to load UI Library!\n- Đặt SorpwonHUB.lua vào workspace của executor\n- Hoặc kiểm tra lại GITHUB_RAW_URL trong script")
end

-- Initialize Window
local Window = SorpwonHUB:CreateWindow({
    Title = "SorpwonHUB",
    Subtitle = "Rider World · v.Premium",
    Keybind = Enum.KeyCode.RightControl
})

-- Shared Global Variables
NPC_Teleport_Tab = {}
Player_In_The_Game = {}

pcall(function()
    local npcFolder = game:GetService("Workspace"):FindFirstChild("NPC")
    if npcFolder then
        for _, v in pairs(npcFolder:GetChildren()) do
            table.insert(NPC_Teleport_Tab, v.Name)
        end
    end
end)
if #NPC_Teleport_Tab == 0 then
    table.insert(NPC_Teleport_Tab, "No NPC Found")
end

pcall(function()
    for _, v in pairs(game:GetService("Players"):GetChildren()) do
        table.insert(Player_In_The_Game, v.Name)
    end
end)
if #Player_In_The_Game == 0 then
    table.insert(Player_In_The_Game, game:GetService("Players").LocalPlayer.Name)
end

_G.Is_Near = false
_G.Distance = 9
_G.Select_Fram_Mode = "Above"
_G.TeleportAroundAngle = 0
_G.TeleportAroundLastTime = 0
_G.Level = _G.Level or 1



-- ═══════════════════════════════════════════════════════════
-- TAB 1: MAIN FARM
-- ═══════════════════════════════════════════════════════════
local Tab_1 = Window:CreateTab({ Name = "Home", Icon = "🌾" })
local Card_MainFarm = Tab_1:CreateSection("Main Farm")
local Card_FarmSettings = Tab_1:CreateSection("Farm Settings")

local function TriggerProximityPrompt(cframePos)
    pcall(function()
        for _, prompt in pairs(game:GetService("Workspace"):GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local pos
                if prompt.Parent and prompt.Parent:IsA("BasePart") then
                    pos = prompt.Parent.Position
                elseif prompt.Parent and prompt.Parent:IsA("Attachment") then
                    pos = prompt.Parent.WorldPosition
                elseif prompt.Parent and prompt.Parent:IsA("Model") and prompt.Parent.PrimaryPart then
                    pos = prompt.Parent.PrimaryPart.Position
                end

                if pos then
                    local dist = (pos - cframePos.Position).Magnitude
                    if dist < 20 then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
    end)
end

local HttpService = game:GetService("HttpService")

-- Auto Farm (Dragon's Alliance) Toggle
Card_MainFarm:CreateToggle({
    Name = "Auto Farm (Dragon's Alliance)",
    Default = false,
    Callback = function(enabled)
        _G.AutoFarm_DragonsAlliance = enabled
        if enabled then
            task.spawn(function()
                -- Hàm click giao diện (Chống kẹt UI tuyệt đối)
                local function ForceClick(btnName)
                    local clicked = false
                    local attempts = 0
                    while not clicked and attempts < 10 and _G.AutoFarm_DragonsAlliance do
                        pcall(function()
                            local choiceContainer = game:GetService("Players").LocalPlayer.PlayerGui.Dialogue.Container
                                .ChoiceContainer
                            local btn = choiceContainer:FindFirstChild(btnName)

                            if btn and btn.Visible then
                                if getconnections then
                                    pcall(function() getconnections(btn.MouseButton1Click)[1]:Fire() end)
                                end

                                local VIM = game:GetService("VirtualInputManager")
                                local guiInset = game:GetService("GuiService"):GetGuiInset()
                                local posX = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2)
                                local posY = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2) + guiInset.Y

                                VIM:SendMouseButtonEvent(posX, posY, 0, true, game, 0)
                                task.wait(0.05)
                                VIM:SendMouseButtonEvent(posX, posY, 0, false, game, 0)

                                clicked = true
                            end
                        end)
                        if not clicked then
                            attempts = attempts + 1
                            task.wait(0.15)
                        end
                    end
                end

                -- Máy quét dữ liệu Quest ngầm
                -- hasQuestUI: QuestAlertFrame có "The Hunt Hunted" không (đã từng nhận quest)
                -- isDone: QuestClientValue Total >= Max (đã tiêu diệt đủ quái)
                local function GetQuestState()
                    local hasQuestUI = false
                    local isDone = false

                    pcall(function()
                        if game:GetService("Players").LocalPlayer.PlayerGui.Main.QuestAlertFrame.QuestGUI:FindFirstChild("The Hunt Hunted") then
                            hasQuestUI = true
                        end
                    end)

                    pcall(function()
                        local questValueObj = game:GetService("Players").LocalPlayer.PlayerGui.Main
                            :FindFirstChild("QuestClientValue")
                        if questValueObj and questValueObj:IsA("StringValue") and questValueObj.Value ~= "" then
                            local success, questData = pcall(function()
                                return HttpService:JSONDecode(questValueObj.Value)
                            end)

                            if success and questData and questData["The Hunt Hunted"] then
                                local currentTotal = questData["The Hunt Hunted"].Total or 0
                                local maxRequired = questData["The Hunt Hunted"].Max or 2
                                -- Total >= Max = đã tiêu diệt đủ số quái (vd: 2/2)
                                if currentTotal >= maxRequired then
                                    isDone = true
                                end
                            end
                        end
                    end)
                    return hasQuestUI, isDone
                end

                -- Hàm bấm phím 1 để toggle vũ khí (tốc độ cao)
                local function PressKey1()
                    pcall(function()
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, "One", false, game)
                        task.wait(0.01)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, "One", false, game)
                        task.wait(0.05)
                    end)
                end

                -- Cất vũ khí trước khi nói chuyện NPC
                local function UnequipBeforeNPC()
                    pcall(function()
                        if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Attack") then
                            PressKey1()
                        end
                    end)
                end

                -- Rút vũ khí sau khi nói chuyện NPC xong
                local function EquipAfterNPC()
                    pcall(function()
                        if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Attack") then
                            PressKey1()
                        end
                    end)
                end

                -- Vòng lặp Farm Chính
                while _G.AutoFarm_DragonsAlliance do
                    task.wait(0.5)
                    local questCFrame = CFrame.new(-979.680664, 25.5603523, 92.5501404, 0.651177168, 0, 0.758925676, 0, 1,
                        0, -0.758925676, 0, 0.651177168)
                    local darkDragonFallback = CFrame.new(-1027.51587, 25.6489792, 165.326736)
                    local gazelleFallback = CFrame.new(-1093.10388, 25.6511841, 178.868881)

                    local hasQuestUI, isDone = GetQuestState()

                    if isDone then
                        -- ═══ TRƯỜNG HỢP 1: Quest hoàn thành → Trả quest + nhận lại ═══
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = questCFrame
                        task.wait(0.4)
                        UnequipBeforeNPC()
                        task.wait(3) -- Đợi cất vũ khí xong hẳn rồi mới nói chuyện

                        TriggerProximityPrompt(questCFrame)
                        task.wait(0.2)
                        ForceClick("Yes, I've completed it.")
                        task.wait(0.3)
                        ForceClick("Can I get another quest?")
                        task.wait(0.2)
                        ForceClick("The Hunt Hunted")
                        task.wait(0.1)
                        ForceClick("Start 'The Hunt Hunted'")
                        task.wait(0.3)

                        EquipAfterNPC()
                    elseif not hasQuestUI then
                        -- ═══ TRƯỜNG HỢP 2: Chưa có quest (lần đầu) → Nhận quest mới ═══
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = questCFrame
                        task.wait(0.4)
                        UnequipBeforeNPC()
                        task.wait(1) -- Đợi cất vũ khí xong hẳn rồi mới nói chuyện

                        TriggerProximityPrompt(questCFrame)
                        task.wait(0.2)
                        ForceClick("I'm ready for the challenge!")
                        task.wait(0.1)
                        ForceClick("The Hunt Hunted")
                        task.wait(0.1)
                        ForceClick("Start 'The Hunt Hunted'")
                        task.wait(0.3)

                        EquipAfterNPC()
                    elseif hasQuestUI and not isDone then
                        -- ═══ TRƯỜNG HỢP 3: Có quest, chưa xong → Đi săn mob ═══
                        local function HuntMob(mobName, folderName, fallbackSpawn)
                            local startTime = os.clock()
                            local engaged = false

                            while _G.AutoFarm_DragonsAlliance do
                                task.wait()
                                if os.clock() - startTime > 60 then break end

                                local _hasQ, _isD = GetQuestState()
                                if _isD then return true end

                                local targetMob = nil

                                -- TÌM TRONG LIVES VÀ MOBS
                                if game:GetService("Workspace"):FindFirstChild("Lives") then
                                    for _, m in pairs(game:GetService("Workspace").Lives:GetChildren()) do
                                        if (string.find(m.Name, mobName) or string.find(m.Name, folderName)) and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
                                            targetMob = m
                                            break
                                        end
                                    end
                                end

                                if not targetMob and game:GetService("Workspace"):FindFirstChild("Mobs") then
                                    for _, m in pairs(game:GetService("Workspace").Mobs:GetChildren()) do
                                        if (string.find(m.Name, mobName) or string.find(m.Name, folderName)) and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
                                            targetMob = m
                                            break
                                        end
                                    end
                                end

                                local targetRoot = targetMob and
                                    (targetMob:FindFirstChild("HumanoidRootPart") or targetMob:FindFirstChild("RootPart") or targetMob.PrimaryPart)

                                if targetMob and targetRoot then
                                    engaged = true

                                    local mobHrp = targetRoot
                                    local playerHrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                                    local dist = _G.Distance or 9

                                    -- Dịch chuyển theo chế độ đã chọn và tự động khóa mục tiêu
                                    pcall(function()
                                        local targetPos
                                        if _G.Select_Fram_Mode == "Above" then
                                            targetPos = mobHrp.CFrame * CFrame.new(0, dist, 0)
                                        elseif _G.Select_Fram_Mode == "Behind" then
                                            targetPos = mobHrp.CFrame * CFrame.new(0, 0, dist)
                                        elseif _G.Select_Fram_Mode == "Under (Safe)" then
                                            targetPos = mobHrp.CFrame * CFrame.new(0, -dist, 0)
                                        elseif _G.Select_Fram_Mode == "Teleport Around" then
                                            if os.clock() - (_G.TeleportAroundLastTime or 0) >= 0.5 then
                                                _G.TeleportAroundAngle = (_G.TeleportAroundAngle or 0) + math.rad(45)
                                                _G.TeleportAroundLastTime = os.clock()
                                            end
                                            local offsetX = math.cos(_G.TeleportAroundAngle) * dist
                                            local offsetZ = math.sin(_G.TeleportAroundAngle) * dist
                                            targetPos = mobHrp.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                        end

                                        -- Dùng CFrame.lookAt để ép mặt nhân vật luôn nhìn thẳng vào quái
                                        playerHrp.CFrame = CFrame.lookAt(targetPos.Position, mobHrp.Position)
                                    end)

                                    pcall(function()
                                        local char = game:GetService("Players").LocalPlayer.Character
                                        local backpack = game:GetService("Players").LocalPlayer.Backpack
                                        if not char:FindFirstChild("Attack") and not char:FindFirstChildOfClass("Tool") then
                                            local tool = backpack:FindFirstChild("Attack") or
                                                backpack:FindFirstChild("Combat") or
                                                backpack:FindFirstChildOfClass("Tool")
                                            if tool then
                                                char.Humanoid:EquipTool(tool)
                                            end
                                        end
                                    end)
                                else
                                    if engaged == true then
                                        break
                                    end

                                    local campCFrame = fallbackSpawn
                                    local hasSpawnerInMobs = false
                                    pcall(function()
                                        local spawnerFolder = game:GetService("Workspace"):FindFirstChild("Mobs")
                                        if spawnerFolder then
                                            local spawnerNPC = spawnerFolder:FindFirstChild(folderName)
                                            local spawnerRoot = spawnerNPC and
                                                (spawnerNPC:FindFirstChild("HumanoidRootPart") or spawnerNPC:FindFirstChild("RootPart") or spawnerNPC.PrimaryPart)
                                            if spawnerNPC and spawnerRoot then
                                                hasSpawnerInMobs = true
                                                local dist = _G.Distance or 9
                                                local waitPos
                                                if _G.Select_Fram_Mode == "Above" then
                                                    waitPos = spawnerRoot.CFrame * CFrame.new(0, dist, 0)
                                                elseif _G.Select_Fram_Mode == "Behind" then
                                                    waitPos = spawnerRoot.CFrame * CFrame.new(0, 0, dist)
                                                elseif _G.Select_Fram_Mode == "Under (Safe)" then
                                                    waitPos = spawnerRoot.CFrame * CFrame.new(0, -dist, 0)
                                                elseif _G.Select_Fram_Mode == "Teleport Around" then
                                                    if os.clock() - (_G.TeleportAroundLastTime or 0) >= 0.5 then
                                                        _G.TeleportAroundAngle = (_G.TeleportAroundAngle or 0) + math.rad(45)
                                                        _G.TeleportAroundLastTime = os.clock()
                                                    end
                                                    local offsetX = math.cos(_G.TeleportAroundAngle) * dist
                                                    local offsetZ = math.sin(_G.TeleportAroundAngle) * dist
                                                    waitPos = spawnerRoot.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                                else
                                                    waitPos = spawnerRoot.CFrame * CFrame.new(0, dist, 0)
                                                end
                                                campCFrame = CFrame.lookAt(waitPos.Position, spawnerRoot.Position)
                                            end
                                        end
                                    end)

                                    if not hasSpawnerInMobs then
                                        return false
                                    end

                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = campCFrame
                                    pcall(function()
                                        game:GetService("Players").LocalPlayer.Character.Humanoid
                                            :ChangeState(11)
                                    end)
                                end
                            end
                            return false
                        end

                        local questCompleted = HuntMob("Dark Dragon User", "DarkDragonUser", darkDragonFallback)
                        task.wait(0.2)

                        local _qH, _qD = GetQuestState()
                        if not _qD and not questCompleted then
                            HuntMob("Gazelle User", "GazelleUser", gazelleFallback)
                        end
                        task.wait(0.5)
                    end
                end -- end while _G.AutoFarm_DragonsAlliance
            end)
        end
    end
})



Card_MainFarm:CreateToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(enabled)
        if enabled then
            _G.Kill_Aura = true

            task.spawn(function()
                while _G.Kill_Aura == true do
                    task.wait()
                    pcall(function()
                        if game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == true then
                            for _, v in pairs(game:GetService("Workspace").Lives:GetChildren()) do
                                if (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= 50 and v.Humanoid.Health > 0 and not game:GetService("Players"):FindFirstChild(v.Name) then
                                    repeat
                                        task.wait()
                                        if _G.Select_Fram_Mode == "Above" then
                                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                            .HumanoidRootPart.CFrame * CFrame.new(0, _G.Distance, 0) *
                                            CFrame.fromOrientation(300, 0, 0)
                                        elseif _G.Select_Fram_Mode == "Behind" then
                                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                            .HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.Distance) *
                                            CFrame.fromOrientation(0, 0, 0)
                                        elseif _G.Select_Fram_Mode == "Under (Safe)" then
                                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                            .HumanoidRootPart.CFrame * CFrame.new(0, _G.Distance - (_G.Distance * 2), 0) *
                                            CFrame.fromOrientation(900, 0, 0)
                                        elseif _G.Select_Fram_Mode == "Teleport Around" then
                                            if os.clock() - (_G.TeleportAroundLastTime or 0) >= 0.5 then
                                                _G.TeleportAroundAngle = (_G.TeleportAroundAngle or 0) + math.rad(45)
                                                _G.TeleportAroundLastTime = os.clock()
                                            end
                                            local offsetX = math.cos(_G.TeleportAroundAngle) * _G.Distance
                                            local offsetZ = math.sin(_G.TeleportAroundAngle) * _G.Distance
                                            local aroundPos = v.HumanoidRootPart.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(aroundPos.Position, v.HumanoidRootPart.Position)
                                        end

                                        if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Attack") then
                                            game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(game
                                            :GetService("Players").LocalPlayer.Backpack["Attack"])
                                        else
                                            game:GetService("ReplicatedStorage").Remote.Event.Action:FireServer({
                                                ["Input"] = "Mouse1", ["LightAttack"] = true })
                                        end

                                        setfflag("HumanoidParallelRemoveNoPhysics", "False")
                                        setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                                        game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)

                                        if _G.E == true and not game:GetService("Players").LocalPlayer:FindFirstChild("E") then
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                                        end
                                        if _G.R == true and not game:GetService("Players").LocalPlayer:FindFirstChild("R") then
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "R", false, game)
                                        end
                                        if _G.C == true and not game:GetService("Players").LocalPlayer:FindFirstChild("C") then
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false, game)
                                        end
                                        if _G.V == true and not game:GetService("Players").LocalPlayer:FindFirstChild("V") then
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "V", false, game)
                                        end
                                    until _G.Kill_Aura ~= true or v.Humanoid.Health == 0
                                end
                            end
                        end
                    end)
                end
            end)
        else
            _G.Kill_Aura = false
        end
    end
})

Card_MainFarm:CreateToggle({
    Name = "Auto Attack Nearest NPC",
    Default = false,
    Callback = function(enabled)
        _G.AutoAttackNearest = enabled
        if enabled then
            task.spawn(function()
                while _G.AutoAttackNearest do
                    task.wait()
                    pcall(function()
                        local player = game:GetService("Players").LocalPlayer
                        local character = player.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
                            return
                        end

                        local playerPos = character.HumanoidRootPart.Position
                        local nearestMob = nil
                        local nearestDist = math.huge
                        local nearestRoot = nil
                        local searchRange = _G.NearestSearchDistance or 100

                        -- Tìm mob gần nhất trong Lives và Mobs
                        local folders = {}
                        if game:GetService("Workspace"):FindFirstChild("Lives") then
                            table.insert(folders, game:GetService("Workspace").Lives)
                        end
                        if game:GetService("Workspace"):FindFirstChild("Mobs") then
                            table.insert(folders, game:GetService("Workspace").Mobs)
                        end

                        for _, folder in pairs(folders) do
                            for _, mob in pairs(folder:GetChildren()) do
                                -- Bỏ qua người chơi và NPC không có MaxHealth
                                -- Dùng recursive search (true) vì Humanoid nằm trong Rig
                                local mobHumanoid = mob:FindFirstChild("Humanoid", true)
                                if mobHumanoid and mob:FindFirstChild("MaxHealth") and mobHumanoid.Health > 0 and not game:GetService("Players"):FindFirstChild(mob.Name) then
                                    local root = mob:FindFirstChild("HumanoidRootPart", true) or mob:FindFirstChild("RootPart", true) or mob.PrimaryPart
                                    if root then
                                        local dist = (root.Position - playerPos).Magnitude
                                        if dist <= searchRange and dist < nearestDist then
                                            nearestDist = dist
                                            nearestMob = mob
                                            nearestRoot = root
                                        end
                                    end
                                end
                            end
                        end

                        -- Nếu tìm thấy mob → TP đến và đánh liên tục cho đến chết
                        if nearestMob and nearestRoot then
                            local targetHumanoid = nearestMob:FindFirstChild("Humanoid", true)
                            while _G.AutoAttackNearest and nearestMob.Parent and targetHumanoid and targetHumanoid.Health > 0 do
                                task.wait()
                                local dist = _G.Distance or 9
                                local targetPos
                                if _G.Select_Fram_Mode == "Above" then
                                    targetPos = nearestRoot.CFrame * CFrame.new(0, dist, 0)
                                elseif _G.Select_Fram_Mode == "Behind" then
                                    targetPos = nearestRoot.CFrame * CFrame.new(0, 0, dist)
                                elseif _G.Select_Fram_Mode == "Under (Safe)" then
                                    targetPos = nearestRoot.CFrame * CFrame.new(0, -dist, 0)
                                elseif _G.Select_Fram_Mode == "Teleport Around" then
                                    if os.clock() - (_G.TeleportAroundLastTime or 0) >= 0.5 then
                                        _G.TeleportAroundAngle = (_G.TeleportAroundAngle or 0) + math.rad(45)
                                        _G.TeleportAroundLastTime = os.clock()
                                    end
                                    local offsetX = math.cos(_G.TeleportAroundAngle) * dist
                                    local offsetZ = math.sin(_G.TeleportAroundAngle) * dist
                                    targetPos = nearestRoot.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                else
                                    targetPos = nearestRoot.CFrame * CFrame.new(0, dist, 0)
                                end

                                character.HumanoidRootPart.CFrame = CFrame.lookAt(targetPos.Position,
                                    nearestRoot.Position)

                                -- Equip vũ khí nếu chưa có
                                if not character:FindFirstChild("Attack") and not character:FindFirstChildOfClass("Tool") then
                                    local tool = player.Backpack:FindFirstChild("Attack") or
                                        player.Backpack:FindFirstChild("Combat") or player.Backpack:FindFirstChildOfClass("Tool")
                                    if tool then
                                        local charHumanoid = character:FindFirstChild("Humanoid")
                                        if charHumanoid then charHumanoid:EquipTool(tool) end
                                    end
                                end

                                pcall(function()
                                    local charHumanoid = character:FindFirstChild("Humanoid")
                                    if charHumanoid then charHumanoid:ChangeState(11) end
                                end)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

Card_MainFarm:CreateSlider({
    Name = "Search Distance (Nearest)",
    Min = 0,
    Max = 3000,
    Default = 100,
    Callback = function(val)
        _G.NearestSearchDistance = val
    end
})

-- ── Farm Settings (Column 2) ──
Card_FarmSettings:CreateDropdown({
    Name = "Pos Method",
    Options = { "Above", "Behind", "Under (Safe)", "Teleport Around" },
    Default = "Above",
    Callback = function(val)
        _G.Select_Fram_Mode = val
        if val == "Teleport Around" then
            _G.TeleportAroundAngle = 0
        end
    end
})

Card_FarmSettings:CreateSlider({
    Name = "Farm Distance",
    Min = 0,
    Max = 15,
    Default = 9,
    Callback = function(val)
        _G.Distance = val
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Safe Mode (Player Evasion)",
    Default = false,
    Callback = function(enabled)
        _G.Position = enabled
        if enabled then
            while _G.Position == true do
                task.wait(0.5)
                pcall(function()
                    for _, v in pairs(game:GetService("Players"):GetChildren()) do
                        if v.Name ~= game:GetService("Players").LocalPlayer.Name then
                            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 100 then
                                _G.Is_Near = true
                                repeat
                                    task.wait()
                                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                        .Character.HumanoidRootPart.CFrame * CFrame.new(0, 3000, 0)
                                    setfflag("HumanoidParallelRemoveNoPhysics", "False")
                                    setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                                    game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)
                                until (v.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 100 or _G.Position ~= true
                                _G.Is_Near = false
                            end
                        end
                    end
                end)
            end
        end
    end
})

-- ★ Khởi tạo giá trị mặc định cho các toggle (fix: _G không tự set khi Default = true)
_G.Auto_M1 = true
_G.Auto_M2 = false
_G.E = false
_G.R = false
_G.C = false
_G.V = false
_G.OnlyWhenFarming = false

-- Helper: kiểm tra xem có đang farm không (Kill Aura hoặc Auto Attack Nearest đang bật)
local function IsFarmingActive()
    return _G.Kill_Aura == true or _G.AutoAttackNearest == true
end

Card_FarmSettings:CreateToggle({
    Name = "Skills Only When Farming",
    Default = false,
    Callback = function(v)
        _G.OnlyWhenFarming = v
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Auto M1",
    Default = true,
    Callback = function(v)
        _G.Auto_M1 = v
        if _G.Auto_M1 then
            task.spawn(function()
                while _G.Auto_M1 do
                    -- Nếu bật "Only When Farming" thì chờ đến khi farm active
                    if _G.OnlyWhenFarming and not IsFarmingActive() then
                        task.wait(0.2)
                    else
                        local player = game:GetService("Players").LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local handlerEvent = character:WaitForChild("PlayerHandler"):WaitForChild("HandlerEvent")

                        local targetCFrame
                        local enemies = workspace:FindFirstChild("Lives") or workspace:FindFirstChild("Mobs")
                        if enemies then
                            for _, enemy in pairs(enemies:GetChildren()) do
                                if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy.Name ~= player.Name then
                                    targetCFrame = enemy.HumanoidRootPart.CFrame
                                    break
                                end
                            end
                        end

                        if not targetCFrame then
                            targetCFrame = character.HumanoidRootPart.CFrame + character.HumanoidRootPart.CFrame.LookVector *
                                5
                        end

                        local args = {
                            {
                                CombatAction = true,
                                LightAttack = true,
                                MouseData = targetCFrame
                            }
                        }
                        handlerEvent:FireServer(unpack(args))
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Auto M2",
    Default = false,
    Callback = function(v)
        _G.Auto_M2 = v
        if _G.Auto_M2 then
            task.spawn(function()
                while _G.Auto_M2 do
                    if _G.OnlyWhenFarming and not IsFarmingActive() then
                        task.wait(0.2)
                    else
                        local player = game:GetService("Players").LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local handlerEvent = character:WaitForChild("PlayerHandler"):WaitForChild("HandlerEvent")

                        local targetCFrame
                        local enemies = workspace:FindFirstChild("Lives") or workspace:FindFirstChild("Mobs")
                        if enemies then
                            for _, enemy in pairs(enemies:GetChildren()) do
                                if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy.Name ~= player.Name then
                                    targetCFrame = enemy.HumanoidRootPart.CFrame
                                    break
                                end
                            end
                        end

                        if not targetCFrame then
                            targetCFrame = character.HumanoidRootPart.CFrame + character.HumanoidRootPart.CFrame.LookVector *
                                5
                        end

                        local args = {
                            {
                                CombatAction = true,
                                AttackType = "Down",
                                HeavyAttack = true,
                                MouseData = targetCFrame
                            }
                        }
                        handlerEvent:FireServer(unpack(args))
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Auto Skill [E]",
    Default = false,
    Callback = function(v)
        _G.E = v
        if _G.E then
            task.spawn(function()
                while _G.E do
                    if _G.OnlyWhenFarming and not IsFarmingActive() then
                        task.wait(0.3)
                    else
                        task.wait(0.5)
                        pcall(function()
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
                        end)
                    end
                end
            end)
        end
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Auto Skill [R]",
    Default = false,
    Callback = function(v)
        _G.R = v
        if _G.R then
            task.spawn(function()
                while _G.R do
                    if _G.OnlyWhenFarming and not IsFarmingActive() then
                        task.wait(0.3)
                    else
                        task.wait(0.5)
                        pcall(function()
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "R", false, game)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, "R", false, game)
                        end)
                    end
                end
            end)
        end
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Auto Skill [C]",
    Default = false,
    Callback = function(v)
        _G.C = v
        if _G.C then
            task.spawn(function()
                while _G.C do
                    if _G.OnlyWhenFarming and not IsFarmingActive() then
                        task.wait(0.3)
                    else
                        task.wait(0.5)
                        pcall(function()
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false, game)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, "C", false, game)
                        end)
                    end
                end
            end)
        end
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Auto Skill [V]",
    Default = false,
    Callback = function(v)
        _G.V = v
        if _G.V then
            task.spawn(function()
                while _G.V do
                    if _G.OnlyWhenFarming and not IsFarmingActive() then
                        task.wait(0.3)
                    else
                        task.wait(0.5)
                        pcall(function()
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, "V", false, game)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, "V", false, game)
                        end)
                    end
                end
            end)
        end
    end
})

Card_FarmSettings:CreateToggle({
    Name = "Auto Henshin",
    Default = false,
    Callback = function(enabled)
        _G.AutoHenshin = enabled
        if enabled then
            task.spawn(function()
                while _G.AutoHenshin do
                    task.wait(2)
                    pcall(function()
                        local player = game:GetService("Players").LocalPlayer
                        local char = player.Character
                        if not char then return end

                        -- Kiểm tra đã henshin chưa (nếu có Henshin/Transformed thì bỏ qua)
                        if char:FindFirstChild("Henshin") or char:FindFirstChild("Transformed") then
                            return
                        end
                        if char:FindFirstChild("PlayerHandler") and char.PlayerHandler:FindFirstChild("Transformed") then
                            return
                        end

                        -- Gửi Henshin qua HandlerEvent
                        local handler = char:FindFirstChild("PlayerHandler")
                        local event = handler and handler:FindFirstChild("HandlerEvent")
                        if event then
                            event:FireServer({Henshin = true})
                        end
                    end)
                end
            end)
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB 2: AUTO DUNGEON
-- ═══════════════════════════════════════════════════════════
local Tab_2 = Window:CreateTab({ Name = "Auto Dungeon", Icon = "🏰" })
local Card_DungeonSetup = Tab_2:CreateSection("Dungeon Setup")
local Card_DungeonPhases = Tab_2:CreateSection("Trial Phases")

Card_DungeonSetup:CreateDropdown({
    Name = "Undead Race",
    Options = { "Human", "Stingray", "Tusked", "Beetle", "Steed" },
    Default = "Human",
    Callback = function(val)
        _G.Undead_Select_Fake = val
    end
})

Card_DungeonSetup:CreateButton({
    Name = "Confirm Undead (Trial Phase 1)",
    Callback = function()
        if _G.Undead_Select_Fake == "Human" then
            _G.Undead_Select = "1"
        elseif _G.Undead_Select_Fake == "Stingray" then
            _G.Undead_Select = "2"
        elseif _G.Undead_Select_Fake == "Tusked" then
            _G.Undead_Select = "3"
        elseif _G.Undead_Select_Fake == "Beetle" then
            _G.Undead_Select = "4"
        elseif _G.Undead_Select_Fake == "Steed" then
            _G.Undead_Select = "5"
        end
        Window:Notify({ Title = "Dungeon", Content = "Undead set to: " .. tostring(_G.Undead_Select_Fake), Duration = 3 })
    end
})

Card_DungeonSetup:CreateButton({
    Name = "Teleport To Dungeon (Odin)",
    Callback = function()
        if game:GetService("Workspace").NPC:FindFirstChild("Odin Dungeon") then
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").NPC
                ["Odin Dungeon"].CFrame
        end
    end
})

Card_DungeonSetup:CreateToggle({
    Name = "Auto Skill [E]",
    Default = false,
    Callback = function(v) _G.E_D = v end
})

Card_DungeonSetup:CreateToggle({
    Name = "Auto Skill [R]",
    Default = false,
    Callback = function(v) _G.R_D = v end
})

Card_DungeonSetup:CreateToggle({
    Name = "Auto Skill [C]",
    Default = false,
    Callback = function(v) _G.C_D = v end
})

Card_DungeonSetup:CreateToggle({
    Name = "Auto Skill [V]",
    Default = false,
    Callback = function(v) _G.V_D = v end
})

-- Trial Phases
Card_DungeonPhases:CreateToggle({
    Name = "Auto Dungeon Phase 1",
    Default = false,
    Callback = function(enabled)
        _G.Auto_Trial1 = enabled
        if enabled then
            while _G.Auto_Trial1 == true do
                task.wait(0.5)
                pcall(function()
                    if game:GetService("Players").LocalPlayer:FindFirstChild("Dungeon") then
                        if game:GetService("Players").LocalPlayer.Character.Humanoid.Health > 0 then
                            for _, v in pairs(game:GetService("Workspace").Lives:GetChildren()) do
                                if v.Humanoid.Health > 0 and v:FindFirstChild("Dungeon") and v.Humanoid.MaxHealth ~= 17000 and v.Humanoid.MaxHealth ~= 500 then
                                    repeat
                                        task.wait()
                                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                            .HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) *
                                            CFrame.fromOrientation(300, 0, 0)
                                        setfflag("HumanoidParallelRemoveNoPhysics", "False")
                                        setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                                        game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)

                                        if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Attack") then
                                            game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(game
                                                :GetService("Players").LocalPlayer.Backpack["Attack"])
                                        else
                                            game:GetService("ReplicatedStorage").Remote.Event.Action:FireServer({
                                                ["Input"] = "Mouse1", ["LightAttack"] = true })
                                        end

                                        if _G.E_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("E") then
                                            game:GetService("ReplicatedStorage").Remote.Event.Riders:FireServer({
                                                ["Key"] =
                                                "E",
                                                ["Skill"] = _G.E_D,
                                                ["MouseData"] = game:GetService("Players")
                                                    .LocalPlayer.Character.HumanoidRootPart.CFrame
                                            })
                                        end
                                        if _G.R_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("R") then
                                            game:GetService("ReplicatedStorage").Remote.Event.Riders:FireServer({
                                                ["Key"] =
                                                "R",
                                                ["Skill"] = _G.R_D,
                                                ["MouseData"] = game:GetService("Players")
                                                    .LocalPlayer.Character.HumanoidRootPart.CFrame
                                            })
                                        end
                                        if _G.C_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("C") then
                                            game:GetService("ReplicatedStorage").Remote.Event.Riders:FireServer({
                                                ["Key"] =
                                                "C",
                                                ["Skill"] = _G.C_D,
                                                ["MouseData"] = game:GetService("Players")
                                                    .LocalPlayer.Character.HumanoidRootPart.CFrame
                                            })
                                        end
                                        if _G.V_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("V") then
                                            game:GetService("ReplicatedStorage").Remote.Event.Riders:FireServer({
                                                ["Key"] =
                                                "V",
                                                ["Skill"] = _G.V_D,
                                                ["MouseData"] = game:GetService("Players")
                                                    .LocalPlayer.Character.HumanoidRootPart.CFrame
                                            })
                                        end
                                    until _G.Auto_Trial1 ~= true or v.Humanoid.Health == 0
                                elseif v.Name == "Odin_Human" and v.Humanoid.Health > 0 and v.Humanoid.MaxHealth == 17000 and not game:GetService("Workspace").Lives:FindFirstChild("Bulk Goon Lv.1") then
                                    if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SubGUI") and game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == false then
                                        game:GetService("ReplicatedStorage").Remote.Event.Activities:FireServer(
                                            "SubTransformed")
                                    elseif not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SubGUI") and game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == false then
                                        game:GetService("ReplicatedStorage").Remote.Function.Feedback:InvokeServer(
                                            "Henshin")
                                    elseif not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SubGUI") and game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == false then
                                        if game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI.Enabled == false then
                                            game:GetService("ReplicatedStorage").Remote.Event.Activities:FireServer(
                                                "SubTransformed")
                                        elseif game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI.Enabled == true then
                                            if not game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI.ScrollingFrame:FindFirstChild("UIGridLayout") then
                                                if not game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI:FindFirstChild(_G.Undead_Select) then
                                                    game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI.ScrollingFrame[_G.Undead_Select].Size =
                                                        UDim2.new(9000, 9000, 9000, 9000)
                                                    game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI.ScrollingFrame[_G.Undead_Select].Parent =
                                                        game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI
                                                elseif game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI:FindFirstChild(_G.Undead_Select) then
                                                    game:GetService("VirtualUser"):CaptureController()
                                                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                                                end
                                            elseif game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI.ScrollingFrame:FindFirstChild("UIGridLayout") then
                                                game:GetService("Players").LocalPlayer.PlayerGui.TransformGUI
                                                    .ScrollingFrame.UIGridLayout:Destroy()
                                            end
                                        end
                                    elseif game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SubGUI") and game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == false then
                                        repeat
                                            task.wait()
                                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                                .HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) *
                                                CFrame.fromOrientation(300, 0, 0)
                                            setfflag("HumanoidParallelRemoveNoPhysics", "False")
                                            setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                                            game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)

                                            if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Attack") then
                                                game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(game
                                                    :GetService("Players").LocalPlayer.Backpack["Attack"])
                                            else
                                                game:GetService("ReplicatedStorage").Remote.Event.Action:FireServer({
                                                    ["Input"] = "Mouse1", ["LightAttack"] = true })
                                            end

                                            if _G.E_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("E") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false,
                                                    game)
                                            end
                                            if _G.R_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("R") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "R", false,
                                                    game)
                                            end
                                            if _G.C_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("C") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false,
                                                    game)
                                            end
                                            if _G.V_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("V") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "V", false,
                                                    game)
                                            end
                                        until _G.Auto_Trial1 ~= true or v.Humanoid.Health == 0
                                    end
                                elseif v.Name == "Bulk Goon Lv.1" and v.Humanoid.Health > 0 and v.Humanoid.MaxHealth == 500 then
                                    if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SubGUI") and game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == false then
                                        game:GetService("ReplicatedStorage").Remote.Event.Activities:FireServer(
                                            "SubTransformed")
                                    elseif not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SubGUI") and game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == false then
                                        game:GetService("ReplicatedStorage").Remote.Function.Feedback:InvokeServer(
                                            "Henshin")
                                    elseif not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SubGUI") and game:GetService("Players").LocalPlayer.PlayerGui.RidersGUI.Enabled == true then
                                        repeat
                                            task.wait()
                                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                                .HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) *
                                                CFrame.fromOrientation(300, 0, 0)
                                            setfflag("HumanoidParallelRemoveNoPhysics", "False")
                                            setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                                            game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)

                                            if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Attack") then
                                                game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(game
                                                    :GetService("Players").LocalPlayer.Backpack["Attack"])
                                            else
                                                game:GetService("ReplicatedStorage").Remote.Event.Action:FireServer({
                                                    ["Input"] = "Mouse1", ["LightAttack"] = true })
                                            end

                                            if _G.E_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("E") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false,
                                                    game)
                                            end
                                            if _G.R_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("R") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "R", false,
                                                    game)
                                            end
                                            if _G.C_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("C") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false,
                                                    game)
                                            end
                                            if _G.V_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("V") then
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "V", false,
                                                    game)
                                            end
                                        until _G.Auto_Trial1 ~= true or v.Humanoid.Health == 0
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
})

Card_DungeonPhases:CreateToggle({
    Name = "Auto Dungeon Phase 2 [Attack Aura]",
    Default = false,
    Callback = function(enabled)
        _G.Auto_Trail2 = enabled
        if enabled then
            while _G.Auto_Trail2 == true do
                task.wait()
                pcall(function()
                    for _, v in pairs(game:GetService("Workspace").Lives:GetChildren()) do
                        if v.Humanoid.Health > 0 and v:FindFirstChild("Dungeon") and v.Humanoid.MaxHealth ~= 17000 then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v
                                .HumanoidRootPart.CFrame * CFrame.new(0, 9, 0) * CFrame.fromOrientation(300, 0, 0)

                            if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Attack") then
                                game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(game:GetService(
                                    "Players").LocalPlayer.Backpack["Attack"])
                            else
                                game:GetService("ReplicatedStorage").Remote.Event.Action:FireServer({
                                    ["Input"] =
                                    "Mouse1",
                                    ["LightAttack"] = true
                                })
                            end

                            if _G.E_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("E") then
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                            end
                            if _G.R_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("R") then
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "R", false, game)
                            end
                            if _G.C_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("C") then
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false, game)
                            end
                            if _G.V_D == true and not game:GetService("Players").LocalPlayer:FindFirstChild("V") then
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, "V", false, game)
                            end

                            setfflag("HumanoidParallelRemoveNoPhysics", "False")
                            setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                            game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)
                        end
                    end
                end)
            end
        end
    end
})

Card_DungeonPhases:CreateLabel("Phase 3: Coming Soon in next update")

-- ═══════════════════════════════════════════════════════════
-- TAB 3: PLAYERS
-- ═══════════════════════════════════════════════════════════
local Tab_3 = Window:CreateTab({ Name = "Players", Icon = "👥" })
local Card_PlayerTarget = Tab_3:CreateSection("Player Target")
local Card_PlayerVision = Tab_3:CreateSection("Spectate & Camera")

local PlayerDropdown = Card_PlayerTarget:CreateDropdown({
    Name = "Select Player",
    Options = Player_In_The_Game,
    Default = Player_In_The_Game[1] or "None",
    Callback = function(val)
        _G.Player_Select_Is = val
    end
})
_G.Player_Select_Is = Player_In_The_Game[1]

Card_PlayerTarget:CreateButton({
    Name = "🔄 Refresh Players List",
    Callback = function()
        Player_In_The_Game = {}
        for _, plr in pairs(game:GetService("Players"):GetChildren()) do
            table.insert(Player_In_The_Game, plr.Name)
        end
        PlayerDropdown:Refresh(Player_In_The_Game)
        Window:Notify({ Title = "Players", Content = "Player list refreshed (" .. #Player_In_The_Game .. " players)", Duration = 2 })
    end
})

Card_PlayerTarget:CreateButton({
    Name = "⚡ Teleport To Selected Player",
    Callback = function()
        if _G.Player_Select_Is and game:GetService("Players"):FindFirstChild(_G.Player_Select_Is) then
            local target = game:GetService("Players")[_G.Player_Select_Is]
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character
                    .HumanoidRootPart.CFrame
                Window:Notify({ Title = "Teleport", Content = "Teleported to " .. _G.Player_Select_Is, Duration = 2 })
            end
        end
    end
})

Card_PlayerVision:CreateButton({
    Name = "👁️ Spectate Selected Player",
    Callback = function()
        if _G.Player_Select_Is and game:GetService("Players"):FindFirstChild(_G.Player_Select_Is) then
            local target = game:GetService("Players")[_G.Player_Select_Is]
            if target.Character and target.Character:FindFirstChild("Humanoid") then
                game:GetService("Workspace").Camera.CameraSubject = target.Character.Humanoid
            end
        end
    end
})

Card_PlayerVision:CreateButton({
    Name = "🔙 Reset Camera (Unview)",
    Callback = function()
        if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
            game:GetService("Workspace").Camera.CameraSubject = game:GetService("Players").LocalPlayer.Character
                .Humanoid
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- TAB 4: TELEPORTS
-- ═══════════════════════════════════════════════════════════
local Tab_4 = Window:CreateTab({ Name = "Teleport", Icon = "📍" })
local Card_NPCTeleport = Tab_4:CreateSection("NPC Teleport")
local Card_AreaTeleport = Tab_4:CreateSection("World Areas")

Card_NPCTeleport:CreateDropdown({
    Name = "Select NPC",
    Options = NPC_Teleport_Tab,
    Default = NPC_Teleport_Tab[1] or "None",
    Callback = function(val)
        _G.Teleport_Select = val
    end
})
_G.Teleport_Select = NPC_Teleport_Tab[1]

Card_NPCTeleport:CreateButton({
    Name = "⚡ Teleport To NPC",
    Callback = function()
        local npcFolder = game:GetService("Workspace"):FindFirstChild("NPC")
        if _G.Teleport_Select and npcFolder and npcFolder:FindFirstChild(_G.Teleport_Select) then
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = npcFolder[_G.Teleport_Select]
                .CFrame
            Window:Notify({ Title = "Teleport", Content = "Teleported to " .. _G.Teleport_Select, Duration = 2 })
        end
    end
})

-- World Area Teleports
local AreaCoords = {
    ["Chaos Destruction"] = CFrame.new(17.149704, 4.24628067, -187.611725, -0.999873877, 2.06830197e-08, 0.0158827491,
        2.03122532e-08, 1, -2.35053204e-08, -0.0158827491, -2.31797408e-08, -0.999873877),
    ["Swamp Area"] = CFrame.new(18.6785889, 6.71245766, 1913.92004, 0.0184839498, 9.74236158e-09, -0.999829173,
        1.88849967e-08, 1, 1.00931556e-08, 0.999829173, -1.90683327e-08, 0.0184839498),
    ["Bloodthirsty Cave"] = CFrame.new(1177.64587, 29.3244324, 2162.28076, 0.0133611197, -8.98367674e-08, -0.999910712,
        -5.27628643e-08, 1, -9.05498254e-08, 0.999910712, 5.39680016e-08, 0.0133611197),
    ["Abandoned Zoo"] = CFrame.new(-1500.87415, 4.28945827, 2071.66748, -0.103258699, 3.3884497e-08, 0.994654536,
        -5.94138463e-08, 1, -4.02345677e-08, -0.994654536, -6.32508232e-08, -0.103258699),
    ["Bubble Beach"] = CFrame.new(-713.686157, 3.70666742, 336.344543, 0.334196568, -6.54094556e-09, 0.942503393,
        1.36935334e-08, 1, 2.08446305e-09, -0.942503393, 1.22095818e-08, 0.334196568),
    ["1st Village"] = CFrame.new(-2774.16187, 22.597702, 958.878906, -0.456249684, -1.11016139e-08, 0.889851809,
        7.64562529e-08, 1, 5.16768672e-08, -0.889851809, 9.16122858e-08, -0.456249684)
}

for areaName, cframe in pairs(AreaCoords) do
    Card_AreaTeleport:CreateButton({
        Name = areaName,
        Callback = function()
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
            Window:Notify({ Title = "Teleport", Content = "Teleported to " .. areaName, Duration = 2 })
        end
    })
end

-- ═══════════════════════════════════════════════════════════
-- TAB 5: MISC
-- ═══════════════════════════════════════════════════════════
local Tab_5 = Window:CreateTab({ Name = "Misc", Icon = "⚙️" })
local Card_MiscUtils = Tab_5:CreateSection("Utilities")
local Card_MiscVisuals = Tab_5:CreateSection("Visual Mods")

Card_MiscUtils:CreateToggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(enabled)
        _G.Anti_Afk = enabled
        if enabled then
            while _G.Anti_Afk == true do
                task.wait(300)
                pcall(function()
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                end)
            end
        end
    end
})

Card_MiscUtils:CreateToggle({
    Name = "Delete Effects (FPS Boost)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if game:GetService("Workspace"):FindFirstChild("EFX") then
                game:GetService("Workspace").EFX:Destroy()
            end
        else
            if not game:GetService("Workspace"):FindFirstChild("EFX") then
                local Effect = Instance.new("Folder", game.Workspace)
                Effect.Name = "EFX"
            end
        end
    end
})

Card_MiscUtils:CreateButton({
    Name = "💀 Reset Character",
    Callback = function()
        if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
            game:GetService("Players").LocalPlayer.Character.Humanoid.Health = 0
        end
    end
})

Card_MiscVisuals:CreateToggle({
    Name = "Cool Name Glitch",
    Default = false,
    Callback = function(enabled)
        _G.Auto_Hide_Name = enabled
        if enabled then
            while _G.Auto_Hide_Name == true do
                task.wait(0.05)
                pcall(function()
                    local symbols = { "!", "@", "#", "&", "%", "?" }
                    local r1 = symbols[math.random(1, #symbols)]
                    local r2 = symbols[math.random(1, #symbols)]
                    local r3 = symbols[math.random(1, #symbols)]
                    local r4 = symbols[math.random(1, #symbols)]
                    if _G.Auto_Hide_Name == true then
                        game:GetService("Players").LocalPlayer.Character.NAME_GUI.Box.Header.Text = "Fake X User Lv." ..
                            r1 .. r2 .. r3 .. r4
                    else
                        game:GetService("Players").LocalPlayer.Character.NAME_GUI.Box.Header.Text = "Fake X Hub User"
                    end
                end)
            end
        else
            pcall(function()
                game:GetService("Players").LocalPlayer.Character.NAME_GUI.Box.Header.Text = "Fake X Hub User"
            end)
        end
    end
})

-- ── Config Save/Load ──
local Card_MiscConfig = Tab_5:CreateSection("Config")

local CONFIG_FILE = "SorpwonHUB_RiderWorld_Config.json"

-- Danh sách tất cả _G settings cần lưu
local configKeys = {
    "Select_Fram_Mode", "Distance",
    "Auto_M1", "Auto_M2", "E", "R", "C", "V",
    "AutoHenshin", "Anti_Afk", "Auto_Hide_Name",
    "Kill_Aura", "AutoAttackNearest", "AutoFarm_DragonsAlliance",
    "Position"
}

Card_MiscConfig:CreateButton({
    Name = "💾 Save Config",
    Callback = function()
        pcall(function()
            local config = {}
            for _, key in pairs(configKeys) do
                config[key] = _G[key]
            end
            local json = HttpService:JSONEncode(config)
            writefile(CONFIG_FILE, json)
            Window:Notify({ Title = "Config", Content = "Config saved successfully!", Duration = 3 })
        end)
    end
})

Card_MiscConfig:CreateButton({
    Name = "📂 Load Config",
    Callback = function()
        pcall(function()
            if isfile and isfile(CONFIG_FILE) then
                local json = readfile(CONFIG_FILE)
                local config = HttpService:JSONDecode(json)
                for key, value in pairs(config) do
                    _G[key] = value
                end
                Window:Notify({ Title = "Config", Content = "Config loaded! Restart toggles to apply.", Duration = 4 })
            else
                Window:Notify({ Title = "Config", Content = "No config file found!", Duration = 3 })
            end
        end)
    end
})

Card_MiscConfig:CreateButton({
    Name = "🗑️ Delete Config",
    Callback = function()
        pcall(function()
            if isfile and isfile(CONFIG_FILE) then
                delfile(CONFIG_FILE)
                Window:Notify({ Title = "Config", Content = "Config deleted!", Duration = 3 })
            else
                Window:Notify({ Title = "Config", Content = "No config file to delete!", Duration = 3 })
            end
        end)
    end
})

-- Welcome Notification
Window:Notify({
    Title = "SorpwonHUB",
    Content = "Successfully loaded Rider World script with SorpwonHUB UI!",
    Duration = 5
})
