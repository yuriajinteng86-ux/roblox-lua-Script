-- ========================================
-- OrionLib 読み込み
-- ========================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion')))()

local Window = OrionLib:MakeWindow({
    Name = "katsura hub",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "KatsuraHubConfig"
})

-- ========================================
-- サービス・変数
-- ========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Player = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local RemoteSetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local RemoteDestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine")
local RemoteCreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine")
local SpawnToyRF = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")

-- アンチ用リモート
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local PlayerEvents = ReplicatedStorage:WaitForChild("PlayerEvents")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local RagdollRemote = CharacterEvents:FindFirstChild("RagdollRemote")

-- 状態管理
local Config = {
    PlayerList = {},
    DriftKickT = false,
    SpamKickBlobActive = false,
    SelectedPlayer = nil,
    DriftMode = "drift kick",
    AntiGrab        = false,
    AntiBlob        = false,
    AntiKick        = false,
    AntiKickKunai   = false,
    AntiLag         = false,
    AutoAntiLag     = false,
    AntiInputLag    = false,
    KillBypass      = false,
    AntiBlobRagdoll = false,
    AntiBlobKill    = false,
    AntiVoid        = false,
    SelectedToy     = "PoopPile",
    beam_count      = 0,
    originalVoidHeight = nil,
    isHeld          = nil,
    struggleRef     = nil,
}

-- 👤2 タブ用
local BlobKillConfig = {
    isSelectedKill = false,
    currentBlobman = nil,
    selectedPlayer = nil,
    selectedKillThread = nil,
    selectedMode = "blob kill",
    TP_WAIT = 0.02,
    GRAB_WAIT = 0.01,
    RETRY_WAIT = 0.01,
    MAX_RETRIES = 5,
    MAX_BLOBMAN_DISTANCE = 500,
}

-- blob kill v2 用
local Imokill = {
    isSelectedKill = false,
    selectedPlayer = nil,
    currentBlobman = nil,
    selectedPlayerConnection = nil,
    selectedKillAuraConnection = nil,
    RETRY_WAIT = 0.005,
    MAX_RETRIES = 5,
    MAX_BLOBMAN_DISTANCE = 500,
    SELECTED_AURA_RANGE = 40,
}

-- プレイヤータブ用 (FTAP Light)
local Settings = {
    WalkspeedEnabled = false,
    WalkspeedValue = 5,
    InfiniteJump = false,
    JumpPower = 16,
    ThirdPerson = false,
    ThirdPersonDistance = 12,
    FOV = 70,
    Connections = {},
}

-- toys タブ用 (フェザー)
local FeatherConfig = {
    Enabled = false,
    spacing = 3,
    heightOffset = 2,
    backwardOffset = 3,
    maxSparklers = 20,
    tiltAngle = 45,
    waveSpeed = 2,
    baseAmplitude = 1,
    followPlayer = true,
    rotationOffset = 0,
}
local FeatherToys = {}
local FeatherRowPoints = {}
local FeatherAssignedToys = {}
local FeatherLoopConn = nil
local FeatherTime = 0
local AvailableObjects = { "PalletLightBrown", "GlassBoxGray", "FireworkSparkler" }
local ObjectSet = {}
for _, id in ipairs(AvailableObjects) do ObjectSet[id] = true end

-- その他タブ用 (冷笑ボット)
local AutoReplyConfig = {
    enabled = false,
    replyPatterns = {
        "うおwwやめとけってww🤣😅",
        "お、おうwwやめろww🤣😅",
        "おうwwなんかごめんww🤣😅"
    }
}

-- グローバル変数
local orbitAngle = 0
local orbitHeight = 12
local orbitRadius = 15
local orbitRadiusNormal = 20
local orbitSpeed = 10
local currentBlobman = nil

local BlobConfigV2 = {
    orbitRunning = false,
    driftRadius = 30,
    driftSpeed = 5,
    driftHeightOffset = 0,
    driftAngle = 0,
    currentDriftLoopId = 0,
}

-- ========================================
-- ヘルパー関数
-- ========================================
local function GetPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            table.insert(list, string.format("%s (@%s)", plr.DisplayName, plr.Name))
        end
    end
    if #list == 0 then list = { "No Players" } end
    return list
end

local function GetPlayerFromSelection(selection)
    if not selection or selection == "No Players" then return nil end
    local name = selection:match("@([%w_]+)%)")
    if name then return Players:FindFirstChild(name) end
    return nil
end

local function sno(part)
    if not part or not part.Parent then return end
    pcall(function() RemoteSetNetworkOwner:FireServer(part, part.CFrame) end)
end

local function spawnBlobman()
    local char = Player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local spawnRemote = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
    if not spawnRemote then return false end
    local success, err = pcall(function()
        spawnRemote:InvokeServer("CreatureBlobman", hrp.CFrame * CFrame.new(0, 0, 5), Vector3.zero)
    end)
    if not success then
        OrionLib:MakeNotification({ Name = "エラー", Content = "ブロブマンのスポーンに失敗: " .. tostring(err), Time = 3 })
        return false
    end
    local timeout = tick() + 5
    while tick() < timeout do
        local toysFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
        if toysFolder then
            for _, obj in ipairs(toysFolder:GetChildren()) do
                if obj.Name == "CreatureBlobman" then
                    currentBlobman = obj
                    return true
                end
            end
        end
        task.wait(0.1)
    end
    return false
end

local function findBlobman()
    local toys = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
    return toys and toys:FindFirstChild("CreatureBlobman") or nil
end

local function ensureBlobman()
    local b = findBlobman()
    if b then return b end
    spawnBlobman()
    for _ = 1, 11 do
        task.wait(0.3)
        b = findBlobman()
        if b then return b end
    end
    return nil
end

local function sitOnBlobman()
    if not currentBlobman or not currentBlobman.Parent then return false end
    local seat = currentBlobman:FindFirstChild("Seat") or currentBlobman:FindFirstChild("BlobmanSeat") or currentBlobman:FindFirstChild("VehicleSeat")
    if not seat then
        for _, child in ipairs(currentBlobman:GetChildren()) do
            if child:IsA("Seat") or child.Name:find("Seat") then seat = child; break end
        end
    end
    if not seat then return false end
    local char = Player.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    pcall(function()
        hum.Sit = true
        hum.SeatPart = seat
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = seat.CFrame * CFrame.new(0, 0, 0) end
    end)
    task.wait(0.5)
    return hum.SeatPart == seat
end

-- ========================================
-- キック処理群
-- ========================================
local function StartDriftKick(target)
    Config.DriftKickT = true
    orbitAngle = 0
    task.spawn(function()
        local GE = ReplicatedStorage:WaitForChild("GrabEvents")
        local blob = currentBlobman
        if not blob then return end
        local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
        local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
        local R_Det = blob:FindFirstChild("RightDetector")
        local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
        local SavedPos = blobRoot.CFrame
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if tRoot and blobRoot then
            local bringStart = tick()
            while tick() - bringStart < 0.35 do
                if not Config.DriftKickT then break end
                blobRoot.CFrame = tRoot.CFrame
                blobRoot.Velocity = Vector3.zero
                pcall(function()
                    if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                end)
                RunService.Heartbeat:Wait()
            end
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
            task.wait(0.05)
        end
        local packetTimer = 0
        while Config.DriftKickT do
            if not target or not target.Parent or not target.Character then break end
            if not blobRoot or not blobRoot.Parent then break end
            tChar = target.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local lockPos = SavedPos * CFrame.new(0, 23, 0)
                tRoot.CFrame = lockPos
                tRoot.Velocity = Vector3.zero
                tRoot.RotVelocity = Vector3.zero
                tHum.PlatformStand = true
                tHum.Sit = true
                orbitAngle = orbitAngle + (RunService.Heartbeat:Wait() * orbitSpeed)
                local orbitX = math.cos(orbitAngle) * orbitRadiusNormal
                local orbitZ = math.sin(orbitAngle) * orbitRadiusNormal
                local orbitCFrame = lockPos * CFrame.new(orbitX, 0, orbitZ)
                local lookAtCFrame = CFrame.lookAt(orbitCFrame.Position, lockPos.Position)
                blobRoot.CFrame = lookAtCFrame
                blobRoot.Velocity = Vector3.zero
                if tick() - packetTimer > 0.05 then
                    packetTimer = tick()
                    pcall(function()
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                        if R_Det then
                            local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                            if weld then CD:FireServer(weld) end
                        end
                        GE.DestroyGrabLine:FireServer(tRoot)
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    end)
                end
            else
                if blobRoot and blobRoot.Parent then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                end
            end
            RunService.Heartbeat:Wait()
        end
        Config.DriftKickT = false
        if blobRoot and blobRoot.Parent then
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
        end
    end)
end

local function StartReverseDriftKick(target)
    Config.DriftKickT = true
    orbitAngle = 0
    task.spawn(function()
        local GE = ReplicatedStorage:WaitForChild("GrabEvents")
        local blob = currentBlobman
        if not blob then return end
        local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
        local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
        local R_Det = blob:FindFirstChild("RightDetector")
        local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
        local SavedPos = blobRoot.CFrame
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if tRoot and blobRoot then
            local bringStart = tick()
            while tick() - bringStart < 0.35 do
                if not Config.DriftKickT then break end
                blobRoot.CFrame = tRoot.CFrame
                blobRoot.Velocity = Vector3.zero
                pcall(function()
                    if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                end)
                RunService.Heartbeat:Wait()
            end
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
            task.wait(0.05)
        end
        local packetTimer = 0
        while Config.DriftKickT do
            if not target or not target.Parent or not target.Character then break end
            if not blobRoot or not blobRoot.Parent then break end
            tChar = target.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local lockPos = SavedPos * CFrame.new(0, 23, 0)
                tRoot.CFrame = lockPos
                tRoot.Velocity = Vector3.zero
                tRoot.RotVelocity = Vector3.zero
                tHum.PlatformStand = true
                tHum.Sit = true
                orbitAngle = orbitAngle + (RunService.Heartbeat:Wait() * orbitSpeed)
                local orbitX = math.cos(orbitAngle) * orbitRadius
                local orbitZ = math.sin(orbitAngle) * orbitRadius
                local orbitY = math.sin(orbitAngle) * orbitHeight
                local orbitCFrame = lockPos * CFrame.new(orbitX, orbitY, orbitZ)
                local lookAtCFrame = CFrame.lookAt(orbitCFrame.Position, lockPos.Position)
                blobRoot.CFrame = lookAtCFrame
                blobRoot.Velocity = Vector3.zero
                if tick() - packetTimer > 0.05 then
                    packetTimer = tick()
                    pcall(function()
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                        if R_Det then
                            local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                            if weld then CD:FireServer(weld) end
                        end
                        GE.DestroyGrabLine:FireServer(tRoot)
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    end)
                end
            else
                if blobRoot and blobRoot.Parent then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                end
            end
            RunService.Heartbeat:Wait()
        end
        Config.DriftKickT = false
        if blobRoot and blobRoot.Parent then
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
        end
    end)
end

local function StartLoopKickV1(target)
    Config.DriftKickT = true
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat or seat.Parent.Name ~= "CreatureBlobman" then
        OrionLib:MakeNotification({ Name = "エラー", Content = "Blobmanに乗ってください", Time = 3 })
        Config.DriftKickT = false
        return
    end
    local blob = seat.Parent
    local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
    local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
    local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
    local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
    local R_Det = blob:FindFirstChild("RightDetector")
    local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
    local SavedPos = blobRoot.CFrame
    task.spawn(function()
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if tRoot and blobRoot then
            local bringStart = tick()
            while tick() - bringStart < 0.35 and Config.DriftKickT do
                blobRoot.CFrame = tRoot.CFrame
                pcall(function()
                    if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                    GrabEvents.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                end)
                RunService.Heartbeat:Wait()
            end
        end
        local packetTimer = 0
        while Config.DriftKickT do
            if not target or not target.Parent or not target.Character then break end
            tChar = target.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                blobRoot.CFrame = SavedPos
                local lockPos = SavedPos * CFrame.new(0, 23, 0)
                tRoot.CFrame = lockPos
                if tick() - packetTimer > 0.05 then
                    packetTimer = tick()
                    pcall(function()
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        GrabEvents.SetNetworkOwner:FireServer(tRoot, lockPos)
                        if R_Det then CD:FireServer(R_Det:FindFirstChildWhichIsA("Weld")) end
                        GrabEvents.DestroyGrabLine:FireServer(tRoot)
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GrabEvents.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    end)
                end
            end
            RunService.Heartbeat:Wait()
        end
        blobRoot.CFrame = SavedPos
        Config.DriftKickT = false
    end)
end

local function StartLoopKickV2(target)
    Config.DriftKickT = true
    local targetName = target.Name
    local REMOTE_DELAY = 0.002
    task.spawn(function()
        local currentTarget = Players:FindFirstChild(targetName)
        if not currentTarget then Config.DriftKickT = false return end
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local seat = hum.SeatPart
        if not seat or seat.Parent.Name ~= "CreatureBlobman" then
            OrionLib:MakeNotification({ Name = "Loop kickv2", Content = "Blobmanに乗ってからONにしてください", Time = 5 })
            Config.DriftKickT = false
            return
        end
        local blob = seat.Parent
        local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        local scriptObj = blob:WaitForChild("BlobmanSeatAndOwnerScript")
        local CG = scriptObj:WaitForChild("CreatureGrab")
        local CD = scriptObj:WaitForChild("CreatureDrop")
        local R_Det = blob:WaitForChild("RightDetector")
        local savedPos = blobRoot.CFrame
        local dragging = false
        local grabStartTime = 0
        local lastRemote = 0
        while Config.DriftKickT do
            local ct = Players:FindFirstChild(targetName)
            if not ct then break end
            char = Player.Character
            hum = char and char:FindFirstChild("Humanoid")
            seat = hum and hum.SeatPart
            if not seat or seat.Parent.Name ~= "CreatureBlobman" then
                OrionLib:MakeNotification({ Name = "Loop kickv2", Content = "Blobから降りました。停止します。", Time = 4 })
                break
            end
            blob = seat.Parent
            blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local tChar = ct.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 and blobRoot then
                tRoot.Velocity = Vector3.zero
                if not dragging then
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.Velocity = Vector3.zero
                    if tick() - lastRemote >= REMOTE_DELAY then
                        lastRemote = tick()
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GrabEvents.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                            GrabEvents.DestroyGrabLine:FireServer(tRoot)
                        end)
                    end
                    if grabStartTime == 0 then grabStartTime = tick() end
                    if tick() - grabStartTime > 0.35 then
                        dragging = true
                        grabStartTime = 0
                        blobRoot.CFrame = savedPos
                        blobRoot.Velocity = Vector3.zero
                    end
                else
                    blobRoot.CFrame = savedPos
                    blobRoot.Velocity = Vector3.zero
                    local lockPos = savedPos * CFrame.new(0, 23, 0)
                    tRoot.CFrame = lockPos
                    tHum.PlatformStand = true
                    tHum.Sit = true
                    if tick() - lastRemote >= REMOTE_DELAY then
                        lastRemote = tick()
                        pcall(function()
                            GrabEvents.SetNetworkOwner:FireServer(tRoot, lockPos)
                            GrabEvents.DestroyGrabLine:FireServer(tRoot)
                            local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                            if weld then
                                CD:FireServer(weld)
                                CG:FireServer(R_Det, tRoot, weld)
                            end
                        end)
                    end
                end
            else
                dragging, grabStartTime = false, 0
            end
            RunService.Heartbeat:Wait()
        end
        if blobRoot then
            blobRoot.CFrame = savedPos
            blobRoot.Velocity = Vector3.zero
        end
        Config.DriftKickT = false
    end)
end

local function StartSpamKickBlob(target)
    Config.SpamKickBlobActive = true
    local targetName = target.Name
    task.spawn(function()
        if not targetName then Config.SpamKickBlobActive = false return end
        local blob = findBlobman()
        if not blob then Config.SpamKickBlobActive = false return end
        local char = Player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then Config.SpamKickBlobActive = false return end
        local RightDetector = blob:FindFirstChild("RightDetector")
        if not RightDetector then Config.SpamKickBlobActive = false return end
        local RightWeld = RightDetector:FindFirstChild("RightWeld")
        local BlobmanScript = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if not (RightWeld and BlobmanScript) then Config.SpamKickBlobActive = false return end
        local CreatureGrab = BlobmanScript:FindFirstChild("CreatureGrab")
        local CreatureRelease = BlobmanScript:FindFirstChild("CreatureRelease")
        if not (CreatureGrab and CreatureRelease) then Config.SpamKickBlobActive = false return end
        local oldCF = char:GetPivot()
        local targetPlayer = Players:FindFirstChild(targetName)
        local targetChar = targetPlayer and targetPlayer.Character
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then Config.SpamKickBlobActive = false return end
        local targetRoot = targetChar.HumanoidRootPart
        pcall(function()
            char:PivotTo(targetRoot.CFrame)
            task.wait(0.18)
            CreatureGrab:FireServer(RightDetector, targetRoot, RightWeld)
            task.wait(0.18)
            CreatureRelease:FireServer(RightWeld, targetRoot)
            task.defer(function()
                local BodyPos = Instance.new("BodyPosition")
                BodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BodyPos.Position = oldCF.Position + Vector3.new(math.random(-15, 15), math.random(-10, 10), math.random(-15, 15))
                BodyPos.Parent = targetRoot
                BodyPos.P = 45000
                BodyPos.D = 500
            end)
        end)
        task.wait(0.18)
        pcall(function() char:PivotTo(oldCF) end)
        task.wait(0.18)
        while Config.SpamKickBlobActive do
            targetPlayer = Players:FindFirstChild(targetName)
            if not targetPlayer then Config.SpamKickBlobActive = false break end
            if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(0.18) continue
            end
            targetRoot = targetPlayer.Character.HumanoidRootPart
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            pcall(function()
                sno(targetRoot)
                if targetHead then sno(targetHead) end
                RemoteDestroyGrabLine:FireServer(targetRoot)
                CreatureGrab:FireServer(RightDetector, targetRoot, RightWeld)
                if targetHead then GrabEvents.CreateGrabLine:FireServer(targetHead, targetHead.CFrame) end
                GrabEvents.CreateGrabLine:FireServer(targetRoot, targetRoot.CFrame)
                CreatureRelease:FireServer(RightWeld, targetRoot)
            end)
            task.wait()
        end
        Config.SpamKickBlobActive = false
    end)
end

local function StartBothHandKick(target)
    Config.DriftKickT = true
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat or seat.Parent.Name ~= "CreatureBlobman" then
        OrionLib:MakeNotification({ Name = "エラー", Content = "ブロブマンに座ってください", Time = 3 })
        Config.DriftKickT = false
        return
    end
    task.spawn(function()
        local GE = ReplicatedStorage:WaitForChild("GrabEvents")
        local blob = seat.Parent
        local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
        local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
        local R_Det = blob:FindFirstChild("RightDetector")
        local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
        local L_Det = blob:FindFirstChild("LeftDetector")
        local L_Weld = L_Det and (L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld"))
        local SavedPos = blobRoot.CFrame
        local rightHandPos = SavedPos
        local leftHandPos = SavedPos
        if R_Det then rightHandPos = R_Det.CFrame * CFrame.new(0, 15, -3) end
        if L_Det then leftHandPos = L_Det.CFrame * CFrame.new(0, 15, -3) end
        rightHandPos = rightHandPos * CFrame.new(5, 3, 0)
        leftHandPos = leftHandPos * CFrame.new(-5, 3, 0)
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if tRoot and blobRoot then
            local bringStart = tick()
            while tick() - bringStart < 0.35 and Config.DriftKickT do
                blobRoot.CFrame = tRoot.CFrame
                blobRoot.Velocity = Vector3.zero
                pcall(function()
                    if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                end)
                RunService.Heartbeat:Wait()
            end
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
            task.wait(0.05)
        end
        local teleportIndex = 0
        local packetTimer = 0
        while Config.DriftKickT do
            if not target or not target.Parent or not target.Character then break end
            tChar = target.Character
            tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                teleportIndex = (teleportIndex + 1) % 2
                local targetPos, currentDet, currentWeld
                if teleportIndex == 0 then
                    targetPos, currentDet, currentWeld = rightHandPos, R_Det, R_Weld
                else
                    targetPos, currentDet, currentWeld = leftHandPos, L_Det, L_Weld
                end
                tRoot.CFrame = targetPos
                tRoot.Velocity = Vector3.zero
                tRoot.RotVelocity = Vector3.zero
                if tick() - packetTimer > 0.01 then
                    packetTimer = tick()
                    pcall(function()
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        GE.SetNetworkOwner:FireServer(tRoot, targetPos)
                        if R_Det then
                            local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                            if weld then CD:FireServer(weld) end
                        end
                        if L_Det then
                            local weld = L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld")
                            if weld then CD:FireServer(weld) end
                        end
                        GE.DestroyGrabLine:FireServer(tRoot)
                        if CG and currentDet then CG:FireServer(currentDet, tRoot, currentWeld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        for i = 1, 3 do
                            if CG and currentDet then CG:FireServer(currentDet, tRoot, currentWeld) end
                            task.wait(0.002)
                        end
                    end)
                end
            else
                if blobRoot and blobRoot.Parent then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                end
                break
            end
            RunService.Heartbeat:Wait()
        end
        Config.DriftKickT = false
        if blobRoot and blobRoot.Parent then
            blobRoot.CFrame = SavedPos
            blobRoot.Velocity = Vector3.zero
        end
    end)
end

local function StartDriftKickV2(target)
    local FIXED_SPEED = 5
    local FIXED_RADIUS = 30
    local blobman = findBlobman()
    if not blobman then
        spawnBlobman()
        blobman = ensureBlobman()
    end
    if not blobman then
        OrionLib:MakeNotification({ Name = "エラー", Content = "Blobmanを召喚できませんでした", Time = 3 })
        Config.DriftKickT = false
        return
    end    currentBlobman = blobman
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum and not hum.SeatPart then
        local seat = blobman:FindFirstChild("VehicleSeat") or blobman:FindFirstChild("Seat")
        if seat then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.2)
                seat:Sit(hum)
                task.wait(0.4)
            end
        end
    end
    local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript", true)
    if not scriptObj then
        OrionLib:MakeNotification({ Name = "エラー", Content = "スクリプトが見つかりません", Time = 3 })
        Config.DriftKickT = false
        return
    end
    local grabRemote = scriptObj:FindFirstChild("CreatureGrab")
    local dropRemote = scriptObj:FindFirstChild("CreatureDrop")
    local lDet = blobman:FindFirstChild("LeftDetector")
    local rDet = blobman:FindFirstChild("RightDetector")
    local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChild("RigidConstraint"))
    local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChild("RigidConstraint"))
    if not (grabRemote and dropRemote and ((lDet and lWeld) or (rDet and rWeld))) then
        OrionLib:MakeNotification({ Name = "エラー", Content = "Detector/Weldが見つかりません", Time = 3 })
        Config.DriftKickT = false
        return
    end
    BlobConfigV2.driftRadius = FIXED_RADIUS
    BlobConfigV2.driftSpeed = FIXED_SPEED
    BlobConfigV2.driftAngle = 0
    BlobConfigV2.currentDriftLoopId = BlobConfigV2.currentDriftLoopId + 1
    local myLoopId = BlobConfigV2.currentDriftLoopId
    BlobConfigV2.orbitRunning = true
    Config.DriftKickT = true
    local Det = rDet or lDet
    local Weld = rWeld or lWeld
    task.spawn(function()
        while BlobConfigV2.orbitRunning and Config.DriftKickT do
            if myLoopId ~= BlobConfigV2.currentDriftLoopId then break end
            if not target or not target.Parent then break end
            local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
            if not blobRoot then break end
            local tChar = target.Character
            local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tChar and tRoot and tHum and tHum.Health > 0 then
                local bringStart = tick()
                while tick() - bringStart < 0.35 do
                    if myLoopId ~= BlobConfigV2.currentDriftLoopId then break end
                    if not BlobConfigV2.orbitRunning or not Config.DriftKickT then break end
                    if not blobman or not blobman.Parent then break end
                    local curTChar = target.Character
                    local curTRoot = curTChar and curTChar:FindFirstChild("HumanoidRootPart")
                    if curTRoot then
                        blobRoot.CFrame = curTRoot.CFrame
                        blobRoot.AssemblyLinearVelocity = Vector3.zero
                        pcall(function()
                            if Det then grabRemote:FireServer(Det, curTRoot, Weld) end
                            RemoteCreateGrabLine:FireServer(curTRoot, Vector3.zero, curTRoot.Position, false)
                            RemoteSetNetworkOwner:FireServer(curTRoot, blobRoot.CFrame)
                        end)
                    end
                    RunService.Heartbeat:Wait()
                end
                if myLoopId ~= BlobConfigV2.currentDriftLoopId then break end
                if not BlobConfigV2.orbitRunning or not Config.DriftKickT then break end
                if not blobman or not blobman.Parent then break end
                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                if tChar and tRoot and tHum and tHum.Health > 0 then
                    local SavedPos = tRoot.CFrame
                    local targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)
                    local lastTime = tick()
                    local lastDropTime = tick()
                    local dropCount = 0
                    while BlobConfigV2.orbitRunning and Config.DriftKickT and blobman and blobman.Parent do
                        if myLoopId ~= BlobConfigV2.currentDriftLoopId then break end
                        if not target or not target.Parent then break end
                        tChar = target.Character
                        tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                        tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                        if not tChar or not tRoot or not tHum or tHum.Health <= 0 then break end
                        if dropCount < 2 and (tick() - lastDropTime) > 0.8 then
                            dropCount = dropCount + 1
                            pcall(function()
                                local rightWeld = blobman:FindFirstChild("RightDetector") and blobman.RightDetector:FindFirstChild("RightWeld")
                                if rightWeld then dropRemote:FireServer(rightWeld) end
                                RemoteDestroyGrabLine:FireServer(tRoot)
                            end)
                            blobRoot.CFrame = SavedPos
                            blobRoot.AssemblyLinearVelocity = Vector3.zero
                            RunService.Heartbeat:Wait()
                            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                local curTRoot = target.Character.HumanoidRootPart
                                blobRoot.CFrame = curTRoot.CFrame
                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                                pcall(function()
                                    if Det then grabRemote:FireServer(Det, curTRoot, Weld) end
                                    RemoteCreateGrabLine:FireServer(curTRoot, Vector3.zero, curTRoot.Position, false)
                                    RemoteSetNetworkOwner:FireServer(curTRoot, blobRoot.CFrame)
                                end)
                            end
                            lastTime = tick()
                            lastDropTime = tick()
                        else
                            if tRoot and tHum and tHum.Health > 0 and blobRoot then
                                local currentTime = tick()
                                local dt = currentTime - lastTime
                                lastTime = currentTime
                                BlobConfigV2.driftAngle = BlobConfigV2.driftAngle + (BlobConfigV2.driftSpeed * dt)
                                local offsetX = math.cos(BlobConfigV2.driftAngle) * BlobConfigV2.driftRadius
                                local offsetZ = math.sin(BlobConfigV2.driftAngle) * BlobConfigV2.driftRadius
                                local blobPos = targetCenterCFrame.Position + Vector3.new(offsetX, BlobConfigV2.driftHeightOffset, offsetZ)
                                blobRoot.CFrame = CFrame.new(blobPos, targetCenterCFrame.Position)
                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                                blobRoot.AssemblyAngularVelocity = Vector3.zero
                                tRoot.CFrame = targetCenterCFrame
                                tRoot.AssemblyLinearVelocity = Vector3.zero
                                tRoot.AssemblyAngularVelocity = Vector3.zero
                                pcall(function()
                                    tHum.PlatformStand = true
                                    tHum.Sit = true
                                    RemoteSetNetworkOwner:FireServer(tRoot, targetCenterCFrame)
                                    local rightWeld = blobman:FindFirstChild("RightDetector") and blobman.RightDetector:FindFirstChild("RightWeld")
                                    if rightWeld then dropRemote:FireServer(rightWeld) end
                                    RemoteDestroyGrabLine:FireServer(tRoot)
                                    if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                                    RemoteCreateGrabLine:FireServer(tRoot, Vector3.zero, targetCenterCFrame.Position, false)
                                end)
                            else
                                break
                            end
                        end
                        RunService.Heartbeat:Wait()
                    end
                end
            end
            task.wait(0.5)
        end
        if myLoopId == BlobConfigV2.currentDriftLoopId then
            BlobConfigV2.orbitRunning = false
            Config.DriftKickT = false
        end
    end)
end

local function StopDriftKickV2()
    BlobConfigV2.currentDriftLoopId = BlobConfigV2.currentDriftLoopId + 1
    BlobConfigV2.orbitRunning = false
    Config.DriftKickT = false
end

local function RunSelectedKick()
    local target = Config.SelectedPlayer and Players:FindFirstChild(Config.SelectedPlayer)
    if not target then
        OrionLib:MakeNotification({ Name = "エラー", Content = "先にターゲットを選択してください", Time = 3 })
        Config.DriftKickT = false
        Config.SpamKickBlobActive = false
        return
    end
    local mode = Config.DriftMode or "drift kick"
    Config.DriftKickT = false
    Config.SpamKickBlobActive = false
    StopDriftKickV2()
    task.wait(0.1)
    if mode == "Loop kickv1" then StartLoopKickV1(target); return
    elseif mode == "Loop kickv2" then StartLoopKickV2(target); return
    elseif mode == "両手キック" then StartBothHandKick(target); return
    elseif mode == "drift kick v2" then StartDriftKickV2(target); return
    elseif mode == "spam kick blob" then
        local blob = findBlobman()
        if not blob then spawnBlobman(); blob = ensureBlobman() end
        if not blob then Config.SpamKickBlobActive = false; return end
        currentBlobman = blob
        StartSpamKickBlob(target); return
    end
    local toysFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
    if toysFolder then
        for _, obj in ipairs(toysFolder:GetChildren()) do
            if obj.Name == "CreatureBlobman" and obj.Parent then
                currentBlobman = obj
                break
            end
        end
    end
    if not currentBlobman or not currentBlobman.Parent then
        local success = spawnBlobman()
        if not success then Config.DriftKickT = false; return end
        task.wait(0.5)
    end
    sitOnBlobman()
    if mode == "Reverse drift kick" then StartReverseDriftKick(target)
    else StartDriftKick(target) end
end

-- =====================================================
-- 🛡️ アンチ機能
-- =====================================================
local function getChar() return Player.Character end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function EnableAntiGrab()
    Config.AntiGrab = true
    task.spawn(function()
        while Config.AntiGrab do
            local char = getChar()
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and Config.isHeld and Config.isHeld.Value == true then
                    pcall(function() if Config.struggleRef then Config.struggleRef:FireServer(Player) end end)
                    root.Velocity = Vector3.zero
                    root.Anchored = true
                elseif root then
                    root.Anchored = false
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
end
local function DisableAntiGrab()
    Config.AntiGrab = false
    local root = getRoot(); if root then root.Anchored = false end
end

local function createTruePospart()
    local char = getChar(); if not char then return end
    if char:FindFirstChild("TruePositionPart") then return char.TruePositionPart end
    local tp = Instance.new("Part")
    tp.Name = "TruePositionPart"
    tp.Anchored = true
    tp.CanCollide = false
    tp.Transparency = 1
    tp.Size = Vector3.new(1, 1, 1)
    tp.CFrame = CFrame.new(0, -100, 0)
    tp.Parent = char
    return tp
end

local function dropFromBlobs()
    local char = getChar(); if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local plotItems = Workspace:FindFirstChild("PlotItems")
    if plotItems then
        for _, plot in pairs(plotItems:GetChildren()) do
            if plot.Name ~= "PlayersInPlots" then
                for _, itm in pairs(plot:GetChildren()) do
                    if itm.Name == "CreatureBlobman" then
                        pcall(function()
                            local script = itm:FindFirstChild("BlobmanSeatAndOwnerScript")
                            local detector = itm:FindFirstChild("RightDetector")
                            if script and detector then
                                local drop = script:FindFirstChild("CreatureDrop")
                                local weld = detector:FindFirstChild("RightWeld")
                                if drop and weld then
                                    drop:FireServer(weld, hrp)
                                    if Config.struggleRef then Config.struggleRef:FireServer(Player) end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end

local function setMassless()
    local char = getChar(); if not char then return end
    for _, prt in pairs(char:GetChildren()) do
        if prt:IsA("BasePart") and prt.Massless then
            prt.Massless = false
            dropFromBlobs()
        end
    end
end

local function moveRootAttachment()
    local char = getChar(); if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local truePart = char:FindFirstChild("TruePositionPart")
    if hrp and truePart then
        local rootAttachment = hrp:FindFirstChild("RootAttachment")
        if rootAttachment then task.wait(0.2); rootAttachment.Parent = truePart end
    end
end

local function restoreRootAttachment()
    local char = getChar(); if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local truePart = char:FindFirstChild("TruePositionPart")
    if hrp and truePart then
        local rootAttachment = truePart:FindFirstChild("RootAttachment")
        if rootAttachment then rootAttachment.Parent = hrp end
        truePart:Destroy()
    end
end

local function EnableAntiBlob()
    Config.AntiBlob = true
    task.spawn(function()
        while Config.AntiBlob do
            pcall(function()
                if getChar() then
                    createTruePospart()
                    setMassless()
                    local hrp = getRoot()
                    if hrp and hrp:FindFirstChild("RootAttachment") then
                        local truePart = getChar():FindFirstChild("TruePositionPart")
                        if truePart and not truePart:FindFirstChild("RootAttachment") then
                            moveRootAttachment()
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end
local function DisableAntiBlob()
    Config.AntiBlob = false
    restoreRootAttachment()
end

local joint_break_cache = {}
local joint_break_shield_conn = nil
local antiKickCoroutine = nil

local function EnableAntiKick()
    Config.AntiKick = true
    local safe_pos = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
    Workspace.FallenPartsDestroyHeight = 0/0
    joint_break_cache = {}
    local root_part = nil
    local function BreakJoints()
        local char = getChar(); if not char then return end
        root_part = char:WaitForChild("HumanoidRootPart")
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then
                joint_break_cache[v] = v.Part0
                v.Part0 = nil
            end
        end
        root_part.CFrame = safe_pos
        joint_break_shield_conn = RunService.RenderStepped:Connect(function()
            if root_part and root_part.Parent then
                root_part.AssemblyLinearVelocity = Vector3.zero
                root_part.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
    local function RestoreJoints()
        if joint_break_shield_conn then joint_break_shield_conn:Disconnect(); joint_break_shield_conn = nil end
        for m, p0 in pairs(joint_break_cache) do if m and m.Parent then m.Part0 = p0 end end
        joint_break_cache = {}
    end
    local function ToggleOnce()
        if not Config.AntiKick then return end
        if joint_break_shield_conn then RestoreJoints() else BreakJoints() end
    end
    ToggleOnce(); task.wait(0.12); ToggleOnce()
    antiKickCoroutine = RunService.Heartbeat:Connect(function()
        if not Config.AntiKick then return end
        local char = getChar()
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local firePart = hrp:FindFirstChild("FirePlayerPart")
                if firePart then
                    local owner = firePart:FindFirstChild("PartOwner")
                    if owner and owner.Value ~= Player.Name then
                        pcall(function()
                            if RagdollRemote then RagdollRemote:FireServer(hrp, 0) end
                            task.wait(0.1)
                            if Config.struggleRef then Config.struggleRef:FireServer(Player) end
                        end)
                    end
                end
            end
        end
    end)
    Player.CharacterAdded:Once(function()
        task.wait(0.25)
        if Config.AntiKick then ToggleOnce(); task.wait(0.12); ToggleOnce() end
    end)
end

local function DisableAntiKick()
    Config.AntiKick = false
    if joint_break_shield_conn then joint_break_shield_conn:Disconnect(); joint_break_shield_conn = nil end
    if antiKickCoroutine then antiKickCoroutine:Disconnect(); antiKickCoroutine = nil end
    for m, p0 in pairs(joint_break_cache) do if m and m.Parent then m.Part0 = p0 end end
    joint_break_cache = {}
    Workspace.FallenPartsDestroyHeight = -100
end

local function PurgeKunai()
    local inv = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
    if inv and DestroyToy then
        for _, v in pairs(inv:GetChildren()) do
            if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                pcall(function() DestroyToy:FireServer(v) end)
            end
        end
    end
end

local function EnableAntiKickKunai()
    Config.AntiKickKunai = true
    task.spawn(function()
        local sticky_evt = PlayerEvents:WaitForChild("StickyPartEvent")
        local spawn_rmt = MenuToys:WaitForChild("SpawnToyRemoteFunction")
        local can_spawn = Player:WaitForChild("CanSpawnToy")
        local function GetMyRoot()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                return Player.Character.HumanoidRootPart
            else
                local c = Player.CharacterAdded:Wait()
                return c:WaitForChild("HumanoidRootPart")
            end
        end
        local function AttachKunai(kunai)
            if not kunai or not kunai:FindFirstChild("StickyPart") then return end
            local my_root = GetMyRoot(); if not my_root then return end
            local fire_part = my_root:FindFirstChild("FirePlayerPart") or my_root:WaitForChild("FirePlayerPart", 5)
            if not fire_part then return end
            for _, obj in pairs(kunai:GetChildren()) do
                if obj:IsA("BasePart") then
                    obj.CanTouch = false
                    obj.CanCollide = false
                    obj.CanQuery = false
                    obj.AssemblyLinearVelocity = Vector3.zero
                    obj.AssemblyAngularVelocity = Vector3.zero
                end
            end
            sticky_evt:FireServer(kunai.StickyPart, fire_part, CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)))
        end
        while Config.AntiKickKunai do
            task.wait(0.05)
            if not Player.Character or not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then continue end
            local inv = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
            local kunai = inv and (inv:FindFirstChild("NinjaShuriken") or inv:FindFirstChild("AntiKick"))
            if not kunai then
                local my_root = GetMyRoot()
                if my_root and can_spawn.Value then
                    pcall(function() spawn_rmt:InvokeServer("NinjaShuriken", my_root.CFrame * CFrame.new(0, 2, 2), Vector3.zero) end)
                    task.wait(0.5)
                    inv = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
                    kunai = inv and (inv:FindFirstChild("NinjaShuriken") or inv:FindFirstChild("AntiKick"))
                end
                if not kunai then continue end
            end
            if kunai then
                kunai.Name = "AntiKick"
                AttachKunai(kunai)
            end
        end
        PurgeKunai()
    end)
end

local function DisableAntiKickKunai()
    Config.AntiKickKunai = false
    PurgeKunai()
end

local function EnableAntiLag()
    Config.AntiLag = true
    pcall(function() Player.PlayerScripts.CharacterAndBeamMove.Enabled = false end)
end
local function DisableAntiLag()
    Config.AntiLag = false
    pcall(function() Player.PlayerScripts.CharacterAndBeamMove.Enabled = true end)
end

local autoAntiLagThread = nil
local function EnableAutoAntiLag()
    Config.AutoAntiLag = true
    autoAntiLagThread = task.spawn(function()
        while Config.AutoAntiLag do
            task.wait(0.5)
            if Config.beam_count > 100 then
                pcall(function() Player.PlayerScripts.CharacterAndBeamMove.Enabled = false end)
                Config.beam_count = 0
            end
        end
    end)
end
local function DisableAutoAntiLag()
    Config.AutoAntiLag = false
    if autoAntiLagThread then task.cancel(autoAntiLagThread); autoAntiLagThread = nil end
    pcall(function() Player.PlayerScripts.CharacterAndBeamMove.Enabled = true end)
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "GrabBeam" then Config.beam_count = Config.beam_count + 1 end
end)

local antiInputLagCo = nil
local function EnableAntiInputLag()
    Config.AntiInputLag = true
    if antiInputLagCo then coroutine.close(antiInputLagCo); antiInputLagCo = nil end
    antiInputLagCo = coroutine.create(function()
        local spawn_rmt = MenuToys:FindFirstChild("SpawnToyRemoteFunction")
        if not spawn_rmt then return end
        local char = getChar() or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        while Config.AntiInputLag do
            local toysFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
            if not toysFolder then task.wait(); continue end
            local toy = toysFolder:FindFirstChild(Config.SelectedToy)
            if not toy then
                pcall(function() spawn_rmt:InvokeServer(Config.SelectedToy, hrp.CFrame * CFrame.new(0, 5, 0), Vector3.zero) end)
                local t0 = tick()
                repeat
                    RunService.Heartbeat:Wait()
                    toysFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
                    toy = toysFolder and toysFolder:FindFirstChild(Config.SelectedToy)
                until toy or tick() - t0 > 1 or not Config.AntiInputLag
                if not toy then continue end
            end
            if toy and toy.Parent then
                local holdPart = toy:FindFirstChild("HoldPart")
                if holdPart then
                    local hRemote = holdPart:FindFirstChild("HoldItemRemoteFunction")
                    local dRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
                    if hRemote and dRemote then
                        for i = 1, 80000000 do
                            if not Config.AntiInputLag then break end
                            pcall(function() hRemote:InvokeServer(toy, char) end)
                            pcall(function() dRemote:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.zero) end)
                        end
                    end
                end
            end
            task.wait()
        end
    end)
    coroutine.resume(antiInputLagCo)
end
local function DisableAntiInputLag()
    Config.AntiInputLag = false
    if antiInputLagCo then coroutine.close(antiInputLagCo); antiInputLagCo = nil end
end

local KillBypassPlatform = nil
local KillBypassSavedCamCFrame = nil
local KillBypassLoopCoroutine = nil
local KillBypassLoopInterval = 0.02

local function StartKillBypassLoop()
    while Config.KillBypass do
        local char = getChar()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera
        if root and camera then
            if not KillBypassPlatform then
                KillBypassPlatform = Instance.new("Part", Workspace)
                KillBypassPlatform.Name = "KillBypassBase"
                KillBypassPlatform.Anchored = true
                KillBypassPlatform.Size = Vector3.new(1500, 2, 1500)
                KillBypassPlatform.CFrame = CFrame.new(0, 1000000, 0)
                KillBypassPlatform.Transparency = 1
                KillBypassPlatform.CanCollide = false
                Workspace.FallenPartsDestroyHeight = -9999999
            end
            local originalPos = root.CFrame
            KillBypassSavedCamCFrame = camera.CFrame
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = KillBypassSavedCamCFrame
            root.CFrame = KillBypassPlatform.CFrame + Vector3.new(0, 5, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            task.wait(KillBypassLoopInterval)
            if not Config.KillBypass then
                char = getChar(); root = char and char:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = originalPos end
                camera.CameraType = Enum.CameraType.Custom
                break
            end
            char = getChar(); root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = originalPos
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
            camera.CameraType = Enum.CameraType.Custom
            task.wait(KillBypassLoopInterval)
        else
            task.wait(0.05)
        end
    end
    local camera = Workspace.CurrentCamera
    if camera then camera.CameraType = Enum.CameraType.Custom end
end

local function StartKillBypass()
    if Config.KillBypass then return end
    Config.KillBypass = true
    if KillBypassLoopCoroutine then coroutine.close(KillBypassLoopCoroutine); KillBypassLoopCoroutine = nil end
    OrionLib:MakeNotification({ Name = "キルバイパス", Content = "ON", Time = 2 })
    KillBypassLoopCoroutine = coroutine.create(StartKillBypassLoop)
    coroutine.resume(KillBypassLoopCoroutine)
end
local function StopKillBypass()
    if not Config.KillBypass then return end
    Config.KillBypass = false
    if KillBypassLoopCoroutine then coroutine.close(KillBypassLoopCoroutine); KillBypassLoopCoroutine = nil end
    if KillBypassPlatform then pcall(function() KillBypassPlatform:Destroy() end); KillBypassPlatform = nil end
    local camera = Workspace.CurrentCamera
    if camera then camera.CameraType = Enum.CameraType.Custom end
end

local ragdoll_blob_defense_connections = {}
local ragdoll_seat_flag = false
local function CleanRagBlobConnection(key)
    if ragdoll_blob_defense_connections[key] then
        ragdoll_blob_defense_connections[key]:Disconnect()
        ragdoll_blob_defense_connections[key] = nil
    end
end
local function SetupRagBlobCharacter(char)
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root and RagdollRemote then
        CleanRagBlobConnection("SeatWatch")
        ragdoll_blob_defense_connections["SeatWatch"] = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
            if hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name == "CreatureBlobman" then
                if not ragdoll_seat_flag then
                    ragdoll_seat_flag = true
                    local seat = hum.SeatPart
                    while not hum.Sit do task.wait() end
                    RagdollRemote:FireServer(root, 3)
                    while not (hum:FindFirstChild("Ragdolled") and hum.Ragdolled.Value) and not hum.Sit do task.wait() end
                    task.wait(0.4); hum.Sit = false
                    if seat and seat:IsA("Part") then seat:Sit(hum) end
                    task.delay(0.25, function()
                        while hum and hum.SeatPart do
                            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                                RagdollRemote:FireServer(Player.Character.HumanoidRootPart, 1)
                            end
                            task.wait(0.05)
                        end
                        ragdoll_seat_flag = false
                    end)
                end
            end
        end)
    end
end
local function EnableAntiBlobRagdoll()
    Config.AntiBlobRagdoll = true
    SetupRagBlobCharacter(getChar() or Player.CharacterAdded:Wait())
    CleanRagBlobConnection("CharWatch")
    ragdoll_blob_defense_connections["CharWatch"] = Player.CharacterAdded:Connect(function(newChar)
        task.wait(0.5); SetupRagBlobCharacter(newChar)
    end)
end
local function DisableAntiBlobRagdoll()
    Config.AntiBlobRagdoll = false
    for _, c in pairs(ragdoll_blob_defense_connections) do if c then c:Disconnect() end end
    ragdoll_blob_defense_connections = {}
end

local blob_kill_defense_thread = nil
local function EnableAntiBlobKill()
    Config.AntiBlobKill = true
    blob_kill_defense_thread = task.spawn(function()
        while Config.AntiBlobKill do
            local char = getChar()
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    hum.Sit = true
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    local cam = Workspace.CurrentCamera
                    if cam then
                        local lv = cam.CFrame.LookVector
                        root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lv.X, 0, lv.Z))
                    end
                end
            end
            task.wait()
        end
    end)
end
local function DisableAntiBlobKill()
    Config.AntiBlobKill = false
    if blob_kill_defense_thread then task.cancel(blob_kill_defense_thread); blob_kill_defense_thread = nil end
end

local function EnableAntiVoid()
    Config.AntiVoid = true
    if not Config.originalVoidHeight then
        Config.originalVoidHeight = Workspace.FallenPartsDestroyHeight
    end
    Workspace.FallenPartsDestroyHeight = -1e95
end
local function DisableAntiVoid()
    Config.AntiVoid = false
    Workspace.FallenPartsDestroyHeight = Config.originalVoidHeight or -500
end

task.spawn(function()
    local cev = ReplicatedStorage:WaitForChild("CharacterEvents", 10)
    if cev then Config.struggleRef = cev:WaitForChild("Struggle", 5) end
    Config.isHeld = Player:WaitForChild("IsHeld", 10)
end)

-- =====================================================
-- 👤2 タブ
-- =====================================================
local function GetSeatedBlobman()
    local char = Player.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local seat = humanoid.SeatPart
    if not seat or not seat:IsA("VehicleSeat") then return nil end
    local obj = seat
    while obj do
        if obj:IsA("Model") and obj.Name == "CreatureBlobman" then return obj end
        obj = obj.Parent
    end
    return nil
end

local function BlobKillSpawnBlobman()
    local seatedBlobman = GetSeatedBlobman()
    if seatedBlobman then
        BlobKillConfig.currentBlobman = seatedBlobman
        return seatedBlobman
    end
    if BlobKillConfig.currentBlobman and BlobKillConfig.currentBlobman.Parent then
        local blobmanPos = nil
        if BlobKillConfig.currentBlobman.PrimaryPart then
            blobmanPos = BlobKillConfig.currentBlobman.PrimaryPart.Position
        else
            local part = BlobKillConfig.currentBlobman:FindFirstChildWhichIsA("BasePart")
            if part then blobmanPos = part.Position end
        end
        local character = Player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local localPos = rootPart and rootPart.Position
        if blobmanPos and localPos and (blobmanPos - localPos).Magnitude < BlobKillConfig.MAX_BLOBMAN_DISTANCE then
            local seat = BlobKillConfig.currentBlobman:FindFirstChild("VehicleSeat")
            if seat then
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then seat:Sit(humanoid); task.wait(0.08) end
            end
            return BlobKillConfig.currentBlobman
        else
            pcall(function() BlobKillConfig.currentBlobman:Destroy() end)
            BlobKillConfig.currentBlobman = nil
        end
    end
    local character = Player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
    local success, err = pcall(function()
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
    end)
    if not success then warn("SpawnBlobman remote failed: " .. err); return nil end
    local toyFolderName = Player.Name .. "SpawnedInToys"
    local blobman = nil
    local startTime = tick()
    repeat
        local toyFolder = workspace:FindFirstChild(toyFolderName)
        if toyFolder then blobman = toyFolder:FindFirstChild("CreatureBlobman") end
        if blobman then break end
        task.wait()
    until tick() - startTime > 2
    if not blobman then return nil end
    BlobKillConfig.currentBlobman = blobman
    local seat = blobman:FindFirstChild("VehicleSeat")
    if seat then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then seat:Sit(humanoid) end
    end
    task.wait(0.08)
    return blobman
end

local function BlobKillKillPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    for _ = 1, BlobKillConfig.MAX_RETRIES do
        local success = pcall(function()
            humanoid.BreakJointsOnDeath = false
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
        if success and humanoid.Health <= 0 then return true end
        task.wait(BlobKillConfig.RETRY_WAIT)
    end
    return false
end

local function BlobKillGrabRelease(blobman, targetRoot)
    if not blobman or not targetRoot then return end
    pcall(function()
        local script = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script then
            script.CreatureGrab:FireServer(blobman.LeftDetector, targetRoot, blobman.LeftDetector.LeftWeld)
            script.CreatureRelease:FireServer(blobman.LeftDetector.LeftWeld)
        end
    end)
end

local function BlobKillProcessPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local blobman = BlobKillSpawnBlobman()
    if not blobman then return false end
    local localChar = Player.Character
    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
        localChar.HumanoidRootPart.CFrame = targetRoot.CFrame
        task.wait(BlobKillConfig.TP_WAIT)
    end
    BlobKillKillPlayer(targetPlayer)
    for _ = 1, 3 do
        BlobKillGrabRelease(blobman, targetRoot)
        task.wait(BlobKillConfig.GRAB_WAIT)
    end
    return true
end

local function BlobKillStartLoop()
    while BlobKillConfig.isSelectedKill do
        if BlobKillConfig.selectedPlayer then
            pcall(BlobKillProcessPlayer, BlobKillConfig.selectedPlayer)
        end
        task.wait(0.05)
    end
    BlobKillConfig.selectedKillThread = nil
end

local function ImokillGetSeatedBlobman() return GetSeatedBlobman() end

function Imokill.SpawnBlobman()
    local seatedBlobman = ImokillGetSeatedBlobman()
    if seatedBlobman then
        Imokill.currentBlobman = seatedBlobman
        return seatedBlobman
    end
    if Imokill.currentBlobman and Imokill.currentBlobman.Parent then
        local blobmanPos = nil
        if Imokill.currentBlobman.PrimaryPart then
            blobmanPos = Imokill.currentBlobman.PrimaryPart.Position
        else
            local part = Imokill.currentBlobman:FindFirstChildWhichIsA("BasePart")
            if part then blobmanPos = part.Position end
        end
        local character = Player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local localPos = rootPart and rootPart.Position
        if blobmanPos and localPos and (blobmanPos - localPos).Magnitude < Imokill.MAX_BLOBMAN_DISTANCE then
            local seat = Imokill.currentBlobman:FindFirstChild("VehicleSeat")
            if seat then
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then seat:Sit(humanoid); task.wait(0.05) end
            end
            return Imokill.currentBlobman
        else
            pcall(function() Imokill.currentBlobman:Destroy() end)
            Imokill.currentBlobman = nil
        end
    end
    local character = Player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
    pcall(function()
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
    end)
    local toyFolderName = Player.Name .. "SpawnedInToys"
    local blobman = nil
    local startTime = tick()
    repeat
        local toyFolder = Workspace:FindFirstChild(toyFolderName)
        if toyFolder then blobman = toyFolder:FindFirstChild("CreatureBlobman") end
        if blobman then break end
        task.wait()
    until tick() - startTime > 2
    if not blobman then return nil end
    Imokill.currentBlobman = blobman
    local seat = blobman:FindFirstChild("VehicleSeat")
    if seat then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then seat:Sit(humanoid) end
    end
    task.wait(0.05)
    return blobman
end

function Imokill.KillPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    for _ = 1, Imokill.MAX_RETRIES do
        local success = pcall(function()
            humanoid.BreakJointsOnDeath = false
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
        if success and humanoid.Health <= 0 then return true end
        task.wait(Imokill.RETRY_WAIT)
    end
    return false
end

function Imokill.GrabRelease(blobman, targetRoot)
    if not blobman or not targetRoot then return end
    pcall(function()
        local script = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script then
            script.CreatureGrab:FireServer(blobman.LeftDetector, targetRoot, blobman.LeftDetector.LeftWeld)
            script.CreatureRelease:FireServer(blobman.LeftDetector.LeftWeld)
        end
    end)
end

function Imokill.ProcessPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local localChar = Player.Character
    if not localChar then return false end
    local myRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local originalCFrame = myRoot.CFrame
    local originalVel = myRoot.AssemblyLinearVelocity
    local originalAngVel = myRoot.AssemblyAngularVelocity
    pcall(function()
        myRoot.CFrame = targetRoot.CFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
        RunService.Heartbeat:Wait()
        humanoid.BreakJointsOnDeath = false
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        local blobman = ImokillGetSeatedBlobman()
        if blobman then Imokill.GrabRelease(blobman, targetRoot) end
    end)
    if myRoot and myRoot.Parent then
        myRoot.CFrame = originalCFrame
        myRoot.AssemblyLinearVelocity = originalVel or Vector3.zero
        myRoot.AssemblyAngularVelocity = originalAngVel or Vector3.zero
        myRoot.Velocity = Vector3.zero
        myRoot.RotVelocity = Vector3.zero
    end
    return true
end

local function StartImokillAura()
    if Imokill.selectedKillAuraConnection then
        Imokill.selectedKillAuraConnection:Disconnect()
        Imokill.selectedKillAuraConnection = nil
    end
    if not Imokill.selectedPlayer then return end
    Imokill.selectedKillAuraConnection = RunService.Heartbeat:Connect(function()
        if not Imokill.isSelectedKill or not Imokill.selectedPlayer then return end
        local targetPlayer = Imokill.selectedPlayer
        if not targetPlayer.Parent then return end
        local localChar = Player.Character
        if not localChar then return end
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        local targetChar = targetPlayer.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        if (localRoot.Position - targetRoot.Position).Magnitude <= Imokill.SELECTED_AURA_RANGE then
            local blobman = ImokillGetSeatedBlobman()
            if not blobman then blobman = Imokill.SpawnBlobman() end
            if blobman then
                Imokill.KillPlayer(targetPlayer)
                Imokill.GrabRelease(blobman, targetRoot)
            end
        end
    end)
end

function Imokill.StartSelectedKillLoop()
    if Imokill.selectedPlayerConnection then
        Imokill.selectedPlayerConnection:Disconnect()
        Imokill.selectedPlayerConnection = nil
    end
    if not Imokill.selectedPlayer then return end
    task.spawn(function()
        while Imokill.isSelectedKill do
            if Imokill.selectedPlayer and Imokill.selectedPlayer.Parent then
                pcall(Imokill.ProcessPlayer, Imokill.selectedPlayer)
            end
            RunService.Heartbeat:Wait()
        end
    end)
    Imokill.selectedPlayerConnection = Imokill.selectedPlayer.CharacterAdded:Connect(function()
        if Imokill.isSelectedKill then
            task.spawn(function() pcall(Imokill.ProcessPlayer, Imokill.selectedPlayer) end)
        end
    end)
    StartImokillAura()
end

local function StopImokill()
    Imokill.isSelectedKill = false
    if Imokill.selectedPlayerConnection then
        Imokill.selectedPlayerConnection:Disconnect()
        Imokill.selectedPlayerConnection = nil
    end
    if Imokill.selectedKillAuraConnection then
        Imokill.selectedKillAuraConnection:Disconnect()
        Imokill.selectedKillAuraConnection = nil
    end
end

-- =====================================================
-- プレイヤー機能 (FTAP Light)
-- =====================================================
local function UpdateWalkspeed()
    if Settings.Connections.WS then Settings.Connections.WS:Disconnect() end
    if Settings.WalkspeedEnabled then
        Settings.Connections.WS = RunService.Stepped:Connect(function()
            local p = Player
            if p and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and typeof(Settings.WalkspeedValue) == "number" then
                    hrp.CFrame = hrp.CFrame + hum.MoveDirection * (16 * Settings.WalkspeedValue / 10)
                end
            end
        end)
    end
end

local function ApplyJumpPower()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.UseJumpPower == false then
        hum.JumpHeight = math.clamp(Settings.JumpPower / 10, 7.2, 50)
    else
        hum.JumpPower = Settings.JumpPower
    end
end

local function UpdateInfiniteJump()
    if Settings.Connections.JP then Settings.Connections.JP:Disconnect() end
    if Settings.InfiniteJump then
        Settings.Connections.JP = UserInputService.JumpRequest:Connect(function()
            local p = Player
            if p and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Freefall)
                    task.wait()
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    if hum.UseJumpPower == false then
                        hum.JumpHeight = math.clamp(Settings.JumpPower / 10, 7.2, 50)
                    else
                        hum.JumpPower = Settings.JumpPower
                    end
                end
            end
        end)
    end
end

Player.CharacterAdded:Connect(function(c)
    task.wait(1)
    ApplyJumpPower()
end)

local function UpdateThirdPerson()
    if Settings.Connections.TP then Settings.Connections.TP:Disconnect() end
    if Settings.ThirdPerson then
        Cam.CameraType = Enum.CameraType.Custom
        Settings.Connections.TP = RunService.RenderStepped:Connect(function()
            if not Settings.ThirdPerson then return end
            local char = Player.Character
            if not char then return end
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not head or not hum then return end
            local subjectPos = head.Position
            local camera = workspace.CurrentCamera
            local look = camera.CFrame.LookVector
            local camPos = subjectPos - look * Settings.ThirdPersonDistance
            camera.CFrame = CFrame.new(camPos, subjectPos + camera.CFrame.LookVector * 100)
            camera.Focus = CFrame.new(subjectPos)
        end)
    else
        Cam.CameraType = Enum.CameraType.Custom
    end
end

local function ApplyFOV() Cam.FieldOfView = Settings.FOV end

-- =====================================================
-- toys 機能 (フェザー)
-- =====================================================
local function findAllFeatherObjects()
    local toys = {}
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Model") and ObjectSet[item.Name] then
            table.insert(toys, item)
        end
    end
    return toys
end

local function getPrimaryPart(model)
    if model.PrimaryPart then return model.PrimaryPart end
    local potentialParts = { "Handle", "Main", "Part", "Base", "Sparkler", "Firework", "Blade", "Candle", "Keyboard", "Box", "Decoy", "Missile", "Ladder", "Blob", "Ball", "Crystal", "Island", "Ufo", "Jukebox", "Couch", "Boombox", "Snowflake", "Diamond", "Tractor" }
    for _, partName in ipairs(potentialParts) do
        local part = model:FindFirstChild(partName)
        if part and part:IsA("BasePart") then return part end
    end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

local function attachPhysics(part, pValue, dValue)
    if not part then return nil, nil end
    local existingBG = part:FindFirstChildOfClass("BodyGyro")
    local existingBP = part:FindFirstChildOfClass("BodyPosition")
    if existingBG then existingBG:Destroy() end
    if existingBP then existingBP:Destroy() end
    local BP = Instance.new("BodyPosition")
    local BG = Instance.new("BodyGyro")
    BP.P = pValue or 15000
    BP.D = dValue or 200
    BP.MaxForce = Vector3.new(1, 1, 1) * 1e10
    BP.Parent = part
    BG.P = pValue or 15000
    BG.D = dValue or 200
    BG.MaxTorque = Vector3.new(1, 1, 1) * 1e10
    BG.Parent = part
    return BG, BP
end

local function createFeatherRowPoints(count)
    local points = {}
    if count == 0 then return points end
    local halfCount = math.floor(count / 2)
    local isOdd = count % 2 == 1
    for i = 1, count do
        local x = isOdd and (i - math.ceil(count / 2)) * FeatherConfig.spacing or (i - halfCount - 0.5) * FeatherConfig.spacing
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(4, 1, 4)
        part.Parent = workspace
        points[i] = { offsetX = x, part = part, assignedToy = nil }
    end
    return points
end

local function assignFeatherToysToPoints()
    FeatherAssignedToys = {}
    local distanceGroups = {}
    for i, point in ipairs(FeatherRowPoints) do
        local absDistance = math.abs(point.offsetX)
        if not distanceGroups[absDistance] then distanceGroups[absDistance] = {} end
        table.insert(distanceGroups[absDistance], i)
    end
    local sortedDistances = {}
    for distance, _ in pairs(distanceGroups) do table.insert(sortedDistances, distance) end
    table.sort(sortedDistances)
    for rank, distance in ipairs(sortedDistances) do
        for _, pointIndex in ipairs(distanceGroups[distance]) do
            FeatherRowPoints[pointIndex].distanceRank = rank
        end
    end
    for i = 1, math.min(#FeatherToys, #FeatherRowPoints) do
        local toy = FeatherToys[i]
        if toy and toy:IsA("Model") then
            local primaryPart = getPrimaryPart(toy)
            if primaryPart then
                for _, child in ipairs(toy:GetChildren()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = false
                        child.CanTouch = false
                        child.Anchored = false
                    end
                end
                local BG, BP = attachPhysics(primaryPart)
                local toyTable = {
                    BG = BG, BP = BP, Pallet = primaryPart, Model = toy,
                    RowIndex = i,
                    offsetX = FeatherRowPoints[i].offsetX,
                    distanceRank = FeatherRowPoints[i].distanceRank
                }
                FeatherRowPoints[i].assignedToy = toyTable
                table.insert(FeatherAssignedToys, toyTable)
            end
        end
    end
    return FeatherAssignedToys
end

local function startFeatherLoop()
    if FeatherLoopConn then FeatherLoopConn:Disconnect(); FeatherLoopConn = nil end
    FeatherTime = 0
    FeatherLoopConn = RunService.RenderStepped:Connect(function(dt)
        if not FeatherConfig.Enabled or not Player.Character then return end
        local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        local torso = Player.Character:FindFirstChild("Torso") or Player.Character:FindFirstChild("UpperTorso")
        if not humanoidRootPart or not torso then return end
        FeatherTime += dt * FeatherConfig.waveSpeed
        local charCFrame = humanoidRootPart.CFrame
        local rightVector = charCFrame.RightVector
        local lookVector = charCFrame.LookVector
        local backVector = -lookVector
        local basePosition
        if FeatherConfig.followPlayer then
            basePosition = torso.Position + Vector3.new(0, FeatherConfig.heightOffset, 0) + (backVector * FeatherConfig.backwardOffset)
        else
            basePosition = Vector3.new(0, FeatherConfig.heightOffset, 0) + (backVector * FeatherConfig.backwardOffset)
        end
        for i, point in ipairs(FeatherRowPoints) do
            if point.assignedToy and point.assignedToy.BP and point.assignedToy.BG then
                local toy = point.assignedToy
                local targetPosition = basePosition + (rightVector * toy.offsetX)
                local amplitude = FeatherConfig.baseAmplitude * toy.distanceRank
                local waveMovement = math.sin(FeatherTime) * amplitude
                local finalPosition = targetPosition + Vector3.new(0, waveMovement, 0)
                if point.part then point.part.Position = finalPosition end
                toy.BP.Position = finalPosition
                local backYRotation = math.atan2(-lookVector.X, -lookVector.Z) + math.rad(FeatherConfig.rotationOffset)
                local baseCFrame = CFrame.new(finalPosition) * CFrame.Angles(0, backYRotation, 0)
                local tiltedCFrame = baseCFrame * CFrame.Angles(math.rad(-FeatherConfig.tiltAngle), 0, 0)
                toy.BG.CFrame = toy.BG.CFrame:Lerp(tiltedCFrame, 0.3)
            end
        end
    end)
end

local function stopFeatherLoop()
    if FeatherLoopConn then FeatherLoopConn:Disconnect(); FeatherLoopConn = nil end
    for _, point in ipairs(FeatherRowPoints) do
        if point.part then point.part:Destroy() end
        if point.assignedToy then
            if point.assignedToy.BG then point.assignedToy.BG:Destroy() end
            if point.assignedToy.BP then point.assignedToy.BP:Destroy() end
        end
    end
    FeatherRowPoints = {}
    FeatherAssignedToys = {}
end

local function toggleFeather(state)
    FeatherConfig.Enabled = state
    if state then
        FeatherToys = findAllFeatherObjects()
        FeatherRowPoints = createFeatherRowPoints(math.min(#FeatherToys, FeatherConfig.maxSparklers))
        FeatherAssignedToys = assignFeatherToysToPoints()
        startFeatherLoop()
        OrionLib:MakeNotification({ Name = "フェザー開始", Content = "自動検出オブジェクト数: " .. #FeatherAssignedToys, Time = 3 })
    else
        stopFeatherLoop()
        OrionLib:MakeNotification({ Name = "フェザー停止", Content = "フェザー配置を解除", Time = 2 })
    end
end

-- =====================================================
-- その他機能 (冷笑ボット + バリア破壊)
-- =====================================================
local function UniversalSend(msg)
    pcall(function()
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            tcs.TextChannels.RBXGeneral:SendAsync(msg)
        else
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end
    end)
end

local function GetRandomReply()
    return AutoReplyConfig.replyPatterns[math.random(1, #AutoReplyConfig.replyPatterns)]
end

local function GetDisplayName(textSource)
    if not textSource then return "不明" end
    local userId = textSource.UserId
    local player = game.Players:GetPlayerByUserId(userId)
    if player then return player.DisplayName end
    return textSource.Name or "不明"
end

local tcs = game:GetService("TextChatService")
if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
    tcs.MessageReceived:Connect(function(message)
        if not AutoReplyConfig.enabled then return end
        local sender = GetDisplayName(message.TextSource)
        if message.TextSource and message.TextSource.UserId == Player.UserId then return end
        UniversalSend(sender .. " " .. GetRandomReply())
    end)
else
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
        if not AutoReplyConfig.enabled then return end
        local sender = "不明"
        local player = game.Players:FindFirstChild(messageData.FromSpeaker)
        if player then sender = player.DisplayName else sender = messageData.FromSpeaker or "不明" end
        if player and player.UserId == Player.UserId then return end
        UniversalSend(sender .. " " .. GetRandomReply())
    end)
end

local function notifyBarrierSuccess()
    OrionLib:MakeNotification({ Name = "✅ Success", Content = "Barrier破壊に成功！", Time = 3 })
end

local function executeBarrierBreak()
    local playerName = Player.Name
    local plotItems = Workspace:FindFirstChild("PlotItems")
    if plotItems then
        local playersInPlots = plotItems:FindFirstChild("PlayersInPlots")
        if playersInPlots and playersInPlots:FindFirstChild(playerName) then return false end
    end
    local success, result = pcall(function()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return false end
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        local originalWalkSpeed = humanoid.WalkSpeed
        local originalPosition = Player.Character.HumanoidRootPart.CFrame
        humanoid.WalkSpeed = 0
        if not ReplicatedStorage:FindFirstChild("MenuToys") then
            humanoid.WalkSpeed = originalWalkSpeed
            return false
        end
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("InstrumentWoodwindOcarina",
            CFrame.new(184.148834, -5.54824972, 498.136749, 0.829037189, -0.214714944, 0.516328275, 0, 0.923344612, 0.383972496, -0.559193552, -0.318327487, 0.765486956),
            Vector3.new(0, 34, 0))
        wait(0.4)
        local toyFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
        if not toyFolder or not toyFolder:FindFirstChild("InstrumentWoodwindOcarina") then
            humanoid.WalkSpeed = originalWalkSpeed
            return false
        end
        local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
        if not ocarina or not ocarina:FindFirstChild("HoldPart") then
            humanoid.WalkSpeed = originalWalkSpeed
            return false
        end
        ocarina.HoldPart.HoldItemRemoteFunction:InvokeServer(ocarina, Workspace[Player.Name])
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(304.06, 25.77, 488.54)
        end
        wait(0.21)
        if toyFolder and toyFolder:FindFirstChild("InstrumentWoodwindOcarina") then
            ReplicatedStorage.MenuToys.DestroyToy:FireServer(toyFolder.InstrumentWoodwindOcarina)
        end
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = originalPosition
        end
        wait(0.7)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("Campfire",
            CFrame.new(257.638672, -5.57392979, 450.103638, -0.950906992, -0.171067372, 0.257899135, 0, 0.833338678, 0.552762806, -0.309477001, 0.525626004, -0.79242748),
            Vector3.new(0, 161.9720001220703, 0))
        wait(0.7)
        local campfirePosition = Vector3.new(257.638672, -5.57392979, 450.103638)
        local toyFolder2 = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
        if toyFolder2 and toyFolder2:FindFirstChild("Campfire") then
            local campfire = toyFolder2:FindFirstChild("Campfire")
            local primaryPart = campfire.PrimaryPart or campfire:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                local distance = (primaryPart.Position - campfirePosition).Magnitude
                if distance < 10 then
                    wait(1)
                    humanoid.WalkSpeed = originalWalkSpeed
                    notifyBarrierSuccess()
                    return true
                end
            end
        end
        humanoid.WalkSpeed = originalWalkSpeed
        return false
    end)
    if not success then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
        return false
    end
    return result
end

local function executeBarrierBreakNoTP()
    local playerName = Player.Name
    local plotItems = Workspace:FindFirstChild("PlotItems")
    if plotItems then
        local playersInPlots = plotItems:FindFirstChild("PlayersInPlots")
        if playersInPlots and playersInPlots:FindFirstChild(playerName) then return false end
    end
    local success = pcall(function()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then error("キャラクターが見つかりません") end
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then error("Humanoidが見つかりません") end
        humanoid.WalkSpeed = 0
        if not ReplicatedStorage:FindFirstChild("MenuToys") then
            humanoid.WalkSpeed = 16
            error("MenuToysが見つかりません")
        end
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("InstrumentWoodwindOcarina",
            CFrame.new(184.148834, -5.54824972, 498.136749, 0.829037189, -0.214714944, 0.516328275, 0, 0.923344612, 0.383972496, -0.559193552, -0.318327487, 0.765486956),
            Vector3.new(0, 34, 0))
        wait(0.4)
        local toyFolder = Workspace:FindFirstChild(playerName .. "SpawnedInToys")
        if not toyFolder then humanoid.WalkSpeed = 16 error("トイフォルダが見つかりません") end
        local ocarina = toyFolder:FindFirstChild("InstrumentWoodwindOcarina")
        if not ocarina then humanoid.WalkSpeed = 16 error("オカリナが見つかりません") end
        if not ocarina:FindFirstChild("HoldPart") then
            humanoid.WalkSpeed = 16
            error("HoldPartが見つかりません")
        end
        Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina.HoldPart.HoldItemRemoteFunction:InvokeServer(
            Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina,
            Workspace[playerName])
        wait(0.2)
        Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina.HoldPart.DropItemRemoteFunction:InvokeServer(
            Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina,
            CFrame.new(304.06, 25.77, 488.54),
            Vector3.new(0, 70.48600006103516, 0))
        wait(0.1)
        ReplicatedStorage.MenuToys.DestroyToy:FireServer(Workspace[playerName .. "SpawnedInToys"].InstrumentWoodwindOcarina)
        wait(1.5)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("Campfire",
            CFrame.new(257.638672, -5.57392979, 450.103638, -0.950906992, -0.171067372, 0.257899135, 0, 0.833338678, 0.552762806, -0.309477001, 0.525626004, -0.79242748),
            Vector3.new(0, 161.9720001220703, 0))
        wait(1)
        humanoid.WalkSpeed = 16
        notifyBarrierSuccess()
        return true
    end)
    if not success then
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
        return false
    end
    return true
end

-- =====================================================
-- UI: 1. プレイヤータブ
-- =====================================================
local CharTab = Window:MakeTab({ Name = "プレイヤー", Icon = "rbxassetid://4483345998", PremiumOnly = false })
CharTab:AddSection({ Name = "Movement" })
CharTab:AddToggle({ Name = "Walkspeed", Default = false, Callback = function(V) Settings.WalkspeedEnabled = V UpdateWalkspeed() end })
CharTab:AddSlider({ Name = "Speed Multiplier", Min = 1, Max = 5, Default = 1, Increment = 0.1, Callback = function(V) Settings.WalkspeedValue = V end })
CharTab:AddToggle({ Name = "Infinite Jump", Default = false, Callback = function(V) Settings.InfiniteJump = V UpdateInfiniteJump() end })
CharTab:AddSlider({ Name = "Jump Power", Min = 16, Max = 500, Default = 16, Increment = 1, Callback = function(V) Settings.JumpPower = V ApplyJumpPower() end })
CharTab:AddSection({ Name = "Camera" })
CharTab:AddToggle({ Name = "3人称視点", Default = false, Callback = function(V) Settings.ThirdPerson = V UpdateThirdPerson() end })
CharTab:AddSlider({ Name = "3人称 距離", Min = 5, Max = 40, Default = 12, Increment = 1, Callback = function(V) Settings.ThirdPersonDistance = V end })
CharTab:AddSlider({ Name = "FOV", Min = 50, Max = 120, Default = 70, Increment = 1, Callback = function(V) Settings.FOV = V ApplyFOV() end })
CharTab:AddSection({ Name = "Utility" })
CharTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        for _, c in pairs(Settings.Connections) do if c then pcall(function() c:Disconnect() end) end end
        Settings.ThirdPerson = false
        Settings.WalkspeedEnabled = false
        Settings.InfiniteJump = false
        Cam.CameraType = Enum.CameraType.Custom
        OrionLib:Destroy()
    end
})

-- =====================================================
-- UI: 2. アンチタブ
-- =====================================================
local AntiTab = Window:MakeTab({ Name = "アンチ", Icon = "rbxassetid://10734951847", PremiumOnly = false })
AntiTab:AddSection({ Name = "アンチ機能" })
AntiTab:AddToggle({ Name = "アンチグラブ", Default = false, Callback = function(v) if v then EnableAntiGrab() else DisableAntiGrab() end end })
AntiTab:AddToggle({ Name = "アンチブロブ", Default = false, Callback = function(v) if v then EnableAntiBlob() else DisableAntiBlob() end end })
AntiTab:AddToggle({ Name = "アンチキック", Default = false, Callback = function(v) if v then EnableAntiKick() else DisableAntiKick() end end })
AntiTab:AddToggle({ Name = "アンチキック手裏剣", Default = false, Callback = function(v) if v then EnableAntiKickKunai() else DisableAntiKickKunai() end end })
AntiTab:AddToggle({ Name = "アンチラグ", Default = false, Callback = function(v) if v then EnableAntiLag() else DisableAntiLag() end end })
AntiTab:AddToggle({ Name = "オートアンチラグ", Default = false, Callback = function(v) if v then EnableAutoAntiLag() else DisableAutoAntiLag() end end })
AntiTab:AddToggle({ Name = "アンチインプットラグ (poop)", Default = false, Callback = function(v) if v then EnableAntiInputLag() else DisableAntiInputLag() end end })
AntiTab:AddToggle({ Name = "キルバイパス", Default = false, Callback = function(v) if v then StartKillBypass() else StopKillBypass() end end })
AntiTab:AddToggle({ Name = "アンチブロブラグドール", Default = false, Callback = function(v) if v then EnableAntiBlobRagdoll() else DisableAntiBlobRagdoll() end end })
AntiTab:AddToggle({ Name = "アンチブロブキル", Default = false, Callback = function(v) if v then EnableAntiBlobKill() else DisableAntiBlobKill() end end })
AntiTab:AddToggle({ Name = "アンチボイド", Default = false, Callback = function(v) if v then EnableAntiVoid() else DisableAntiVoid() end end })

-- =====================================================
-- UI: 3. キックタブ
-- =====================================================
local KickTab = Window:MakeTab({ Name = "キック", Icon = "rbxassetid://4483345998", PremiumOnly = false })
KickTab:AddSection({ Name = "Player Kick" })

local KickDropdown
KickDropdown = KickTab:AddDropdown({
    Name = "キックするプレイヤーを選択",
    Default = "No Players",
    Options = GetPlayerList(),
    Callback = function(Value)
        local plr = GetPlayerFromSelection(Value)
        if plr then
            Config.SelectedPlayer = plr.Name
            Config.PlayerList = { plr.Name }
        else
            Config.SelectedPlayer = nil
            Config.PlayerList = {}
        end
    end
})

KickTab:AddButton({
    Name = "🔄 プレイヤーリスト更新",
    Callback = function()
        if KickDropdown and KickDropdown.Refresh then KickDropdown:Refresh(GetPlayerList(), true) end
    end
})

KickTab:AddSection({ Name = "キックモード" })
KickTab:AddDropdown({
    Name = "キックモードを選択",
    Default = "drift kick",
    Options = { "drift kick", "Reverse drift kick", "Loop kickv1", "Loop kickv2", "spam kick blob", "両手キック", "drift kick v2" },
    Callback = function(Value) Config.DriftMode = Value end
})

local KickToggle
KickToggle = KickTab:AddToggle({
    Name = "kick", Default = false,
    Callback = function(on)
        if on then RunSelectedKick()
        else
            Config.DriftKickT = false
            Config.SpamKickBlobActive = false
            StopDriftKickV2()
            orbitAngle = 0
        end
    end
})

KickTab:AddButton({
    Name = "⏹ 強制停止",
    Callback = function()
        Config.DriftKickT = false
        Config.SpamKickBlobActive = false
        StopDriftKickV2()
        orbitAngle = 0
        if KickToggle and KickToggle.Set then KickToggle:Set(false) end
    end
})

-- =====================================================
-- UI: 4. キルタブ
-- =====================================================
local KillTab = Window:MakeTab({ Name = "キル", Icon = "rbxassetid://4483345998", PremiumOnly = false })
KillTab:AddSection({ Name = "Blob Kill" })

local KillDropdown
KillDropdown = KillTab:AddDropdown({
    Name = "キックするプレイヤーを選択",
    Default = "No Players",
    Options = GetPlayerList(),
    Callback = function(Value)
        local plr = GetPlayerFromSelection(Value)
        if plr then
            BlobKillConfig.selectedPlayer = plr
            Imokill.selectedPlayer = plr
        else
            BlobKillConfig.selectedPlayer = nil
            Imokill.selectedPlayer = nil
        end
    end
})

KillTab:AddButton({
    Name = "🔄 プレイヤーリスト更新",
    Callback = function()
        if KillDropdown and KillDropdown.Refresh then KillDropdown:Refresh(GetPlayerList(), true) end
    end
})

KillTab:AddSection({ Name = "キルモード" })
KillTab:AddDropdown({
    Name = "キルモードを選択",
    Default = "blob kill",
    Options = { "blob kill", "blob kill v2" },
    Callback = function(Value) BlobKillConfig.selectedMode = Value end
})

local KillToggle
KillToggle = KillTab:AddToggle({
    Name = "kill", Default = false,
    Callback = function(on)
        if on then
            local target = BlobKillConfig.selectedPlayer
            if not target or not target.Parent then
                OrionLib:MakeNotification({ Name = "エラー", Content = "先にターゲットを選択してください", Time = 3 })
                KillToggle:Set(false)
                return
            end
            local mode = BlobKillConfig.selectedMode or "blob kill"
            if mode == "blob kill v2" then
                Imokill.selectedPlayer = target
                Imokill.isSelectedKill = true
                Imokill.StartSelectedKillLoop()
            else
                BlobKillConfig.selectedPlayer = target
                BlobKillConfig.isSelectedKill = true
                if BlobKillConfig.selectedKillThread then
                    BlobKillConfig.isSelectedKill = false
                    task.wait(0.1)
                    BlobKillConfig.isSelectedKill = true
                end
                BlobKillConfig.selectedKillThread = task.spawn(BlobKillStartLoop)
            end
        else
            BlobKillConfig.isSelectedKill = false
            StopImokill()
        end
    end
})

-- =====================================================
-- UI: 5. toys タブ
-- =====================================================
local ToysTab = Window:MakeTab({ Name = "toys", Icon = "rbxassetid://4483345998", PremiumOnly = false })
ToysTab:AddSection({ Name = "フェザー設定" })
ToysTab:AddLabel("対応: 板 / ガラス箱 / 花火 のみ")
ToysTab:AddToggle({ Name = "フェザー起動（背面配置）", Default = false, Callback = toggleFeather })
ToysTab:AddToggle({ Name = "プレイヤー追従", Default = FeatherConfig.followPlayer, Callback = function(v) FeatherConfig.followPlayer = v end })

ToysTab:AddSection({ Name = "配置設定" })
ToysTab:AddSlider({ Name = "最大オブジェクト数", Min = 2, Max = 100, Default = FeatherConfig.maxSparklers, Increment = 2, Callback = function(v)
    FeatherConfig.maxSparklers = v
    if FeatherConfig.Enabled then toggleFeather(false); task.wait(0.1); toggleFeather(true) end
end })
ToysTab:AddSlider({ Name = "オブジェクト間隔", Min = 0.5, Max = 20, Default = FeatherConfig.spacing, Increment = 0.5, Callback = function(v)
    FeatherConfig.spacing = v
    if FeatherConfig.Enabled then toggleFeather(false); task.wait(0.1); toggleFeather(true) end
end })
ToysTab:AddSlider({ Name = "高さオフセット", Min = -30, Max = 50, Default = FeatherConfig.heightOffset, Increment = 0.5, Callback = function(v) FeatherConfig.heightOffset = v end })
ToysTab:AddSlider({ Name = "背面オフセット", Min = -20, Max = 50, Default = FeatherConfig.backwardOffset, Increment = 0.5, Callback = function(v) FeatherConfig.backwardOffset = v end })

ToysTab:AddSection({ Name = "角度・向き設定" })
ToysTab:AddSlider({ Name = "オブジェクト傾き角度", Min = -90, Max = 90, Default = FeatherConfig.tiltAngle, Increment = 5, Callback = function(v) FeatherConfig.tiltAngle = v end })
ToysTab:AddSlider({ Name = "向き調整（左右回転）", Min = -180, Max = 180, Default = FeatherConfig.rotationOffset, Increment = 5, Callback = function(v) FeatherConfig.rotationOffset = v end })

ToysTab:AddSection({ Name = "上下動設定" })
ToysTab:AddSlider({ Name = "上下動速度", Min = 0, Max = 20, Default = FeatherConfig.waveSpeed, Increment = 0.5, Callback = function(v) FeatherConfig.waveSpeed = v end })
ToysTab:AddSlider({ Name = "基本振幅（波の大きさ）", Min = 0, Max = 20, Default = FeatherConfig.baseAmplitude, Increment = 0.5, Callback = function(v) FeatherConfig.baseAmplitude = v end })
ToysTab:AddButton({
    Name = "オブジェクト再検出（再スキャン）",
    Callback = function()
        if FeatherConfig.Enabled then toggleFeather(false); task.wait(0.3); toggleFeather(true)
        else OrionLib:MakeNotification({ Name = "再検出", Content = "フェザー起動中のみ有効です", Time = 2 }) end
    end
})

-- =====================================================
-- UI: 6. その他 タブ
-- =====================================================
local OtherTab = Window:MakeTab({ Name = "その他", Icon = "rbxassetid://4483345998", PremiumOnly = false })

OtherTab:AddSection({ Name = "冷笑ボット" })
OtherTab:AddToggle({
    Name = "冷笑ボット(ゆざまいパクった🙇‍♀️)",
    Default = false,
    Callback = function(Value) AutoReplyConfig.enabled = Value end
})

OtherTab:AddSection({ Name = "バリア破壊" })
OtherTab:AddButton({ Name = "バリア破壊", Callback = function() executeBarrierBreak() end })
OtherTab:AddButton({ Name = "no tpバリア破壊", Callback = function() executeBarrierBreakNoTP() end })

-- =====================================================
-- クリーンアップ & 自動更新
-- =====================================================
game:BindToClose(function()
    BlobKillConfig.isSelectedKill = false
    Imokill.isSelectedKill = false
    Settings.WalkspeedEnabled = false
    Settings.InfiniteJump = false
    Settings.ThirdPerson = false
    FeatherConfig.Enabled = false
    AutoReplyConfig.enabled = false
end)

task.spawn(function()
    while true do
        task.wait(5)
        if Config.SelectedPlayer then
            local found = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == Config.SelectedPlayer then found = true break end
            end
            if not found then
                Config.SelectedPlayer = nil
                Config.PlayerList = {}
            end
        end
    end
end)

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if KickDropdown and KickDropdown.Refresh then KickDropdown:Refresh(GetPlayerList(), true) end
    if KillDropdown and KillDropdown.Refresh then KillDropdown:Refresh(GetPlayerList(), true) end
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if KickDropdown and KickDropdown.Refresh then KickDropdown:Refresh(GetPlayerList(), true) end
    if KillDropdown and KillDropdown.Refresh then KillDropdown:Refresh(GetPlayerList(), true) end
end)

-- =====================================================
-- 起動
-- =====================================================
OrionLib:Init()