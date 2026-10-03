-- ============================================================
-- 起動時チャット送信
-- ============================================================
local p = game.Players.LocalPlayer

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

UniversalSend("かつらはぶきどうします")

-- ============================================================
-- Rayfield 本体読み込み
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "かつらはぶ 🤪",
   Icon = 7743871002,
   LoadingTitle = "読み込み中... 🤪",
   LoadingSubtitle = "作: かつら 🤪",
   ShowText = "かつらはぶ 🤪",
   Theme = {
      TextColor = Color3.fromRGB(255, 240, 250),
      Background = Color3.fromRGB(30, 10, 25),
      Topbar = Color3.fromRGB(45, 15, 35),
      Shadow = Color3.fromRGB(255, 105, 180),
      NotificationBackground = Color3.fromRGB(35, 10, 28),
      NotificationActionsBackground = Color3.fromRGB(255, 182, 213),
      TabBackground = Color3.fromRGB(60, 20, 45),
      TabStroke = Color3.fromRGB(255, 105, 180),
      TabBackgroundSelected = Color3.fromRGB(255, 105, 180),
      TabTextColor = Color3.fromRGB(255, 182, 213),
      SelectedTabTextColor = Color3.fromRGB(40, 5, 25),
      ElementBackground = Color3.fromRGB(40, 12, 30),
      ElementBackgroundHover = Color3.fromRGB(60, 18, 45),
      SecondaryElementBackground = Color3.fromRGB(30, 8, 22),
      ElementStroke = Color3.fromRGB(255, 105, 180),
      SecondaryElementStroke = Color3.fromRGB(255, 182, 213),
      SliderBackground = Color3.fromRGB(60, 20, 45),
      SliderProgress = Color3.fromRGB(255, 105, 180),
      SliderStroke = Color3.fromRGB(255, 192, 203),
      ToggleBackground = Color3.fromRGB(50, 15, 38),
      ToggleEnabled = Color3.fromRGB(255, 105, 180),
      ToggleDisabled = Color3.fromRGB(120, 70, 100),
      ToggleEnabledStroke = Color3.fromRGB(255, 192, 203),
      ToggleDisabledStroke = Color3.fromRGB(140, 90, 115),
      ToggleEnabledOuterStroke = Color3.fromRGB(255, 182, 213),
      ToggleDisabledOuterStroke = Color3.fromRGB(90, 50, 75),
      DropdownSelected = Color3.fromRGB(255, 105, 180),
      DropdownUnselected = Color3.fromRGB(45, 15, 35),
      InputBackground = Color3.fromRGB(45, 12, 32),
      InputStroke = Color3.fromRGB(255, 105, 180),
      PlaceholderColor = Color3.fromRGB(255, 182, 213)
   },
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   FreeMouse = true,
   ConfigurationSaving = { Enabled = false, FolderName = nil, FileName = "katsura_hub" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   KeySystem = false,
   KeySettings = {
      Title = "", Subtitle = "", Note = "",
      FileName = "Key", SaveKey = false, GrabKeyFromSite = false, Key = {}
   }
})

-- ============================================================
-- サービス
-- ============================================================
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
SoundService = game:GetService("SoundService")
Debris = game:GetService("Debris")
LocalPlayer = Players.LocalPlayer
Mouse = LocalPlayer:GetMouse()
me = LocalPlayer

-- ============================================================
-- 死亡時サウンド
-- ============================================================
function playSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://"
    sound.Volume = 0.5
    sound.PlayOnRemove = true
    sound.Parent = SoundService
    sound:Destroy()
end

if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function() task.delay(3, playSound) end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum.Died:Connect(function() task.delay(3, playSound) end)
    end
end)

function playTpSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://77457926931973"
    sound.Volume = 0.2
    sound.PlayOnRemove = true
    sound.Parent = SoundService
    sound:Destroy()
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- ============================================================
-- プレイヤータブ 🤪
-- ============================================================
PlayerTab = Window:CreateTab("プレイヤー 🤪", 7743871002)

PlayerTab:CreateButton({
	Name = "UIを削除する 🗑️",
	Callback = function() Rayfield:Destroy() end,
})

PlayerTab:CreateParagraph({
	Title = "現在のプレイヤー 👤",
	Content = LocalPlayer.Name .. " (@" .. LocalPlayer.DisplayName .. ")"
})

PlayerTab:CreateSection("スピード 🏃")

speedEnabled, speedConnection = false, nil
customSpeedValue = 1

PlayerTab:CreateToggle({
    Name = 'カスタムスピードを有効化 🏃',
    CurrentValue = false,
    Flag = "Player_CustomSpeed",
    Callback = function(v)
        speedEnabled = v
        if speedConnection then speedConnection:Disconnect() speedConnection = nil end
        if v then
            speedConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection.Unit * customSpeedValue)
                end
            end)
        end
    end
})

PlayerTab:CreateInput({
    Name = "カスタムスピード値 ⚡",
    CurrentValue = tostring(customSpeedValue),
    PlaceholderText = "速度を入力",
    RemoveTextAfterFocusLost = false,
    Flag = "Player_SpeedInput",
    Callback = function(Text)
        local n = tonumber(Text)
        if n and n > 0 then customSpeedValue = n end
    end
})

local jumpEnabled = false
local customJumpPower = 30
local jumpConnection = nil

PlayerTab:CreateSection("ジャンプ 🦘")

PlayerTab:CreateToggle({
	Name = "ジャンプパワー 🦘",
	CurrentValue = false,
	Callback = function(state)
		jumpEnabled = state
		if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
		if state then
			jumpConnection = RunService.Heartbeat:Connect(function()
				if humanoid then
					humanoid.UseJumpPower = true
					humanoid.JumpPower = customJumpPower
				end
			end)
		else
			if humanoid then
				humanoid.UseJumpPower = false
				humanoid.JumpPower = 50
			end
		end
	end
})

PlayerTab:CreateInput({
	Name = "ジャンプパワー値を変更 🦘",
	CurrentValue = tostring(customJumpPower),
	PlaceholderText = "ジャンプパワーを入力",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local num = tonumber(text)
		if num and num > 0 then customJumpPower = num end
	end
})

local infJump = false
local infJumpConnection = nil

PlayerTab:CreateToggle({
	Name = "無限ジャンプ ♾️",
	CurrentValue = false,
	Callback = function(state)
		infJump = state
		if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
		if state then
			infJumpConnection = UserInputService.JumpRequest:Connect(function()
				if infJump and humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end
	end
})

PlayerTab:CreateDivider()

PlayerTab:CreateKeybind({
	Name = "クリックテレポート 📍",
	CurrentKeybind = "Z",
	HoldToInteract = false,
	Flag = "ClickTP",
	Callback = function(Keybind)
		if Mouse.Target then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
				for _,v in pairs(char:GetChildren()) do
					if v:IsA("BasePart") then v.Velocity = Vector3.new() end
				end
				playTpSound()
			end
		end
	end,
})

PlayerTab:CreateDivider()

function stopVelocityF()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
end

PlayerTab:CreateKeybind({
   Name = "速度を停止する 🛑",
   CurrentKeybind = "G",
   HoldToInteract = false,
   Flag = "StopVelocity",
   Callback = function(Keybind) stopVelocityF() end
})

PlayerTab:CreateSection("カメラ 📷")

PlayerTab:CreateSlider({
   Name = "視野角 (FOV) 🔭",
   Range = {0, 120}, Increment = 0.1, Suffix = "%",
   CurrentValue = 70, Flag = "FOVSlider",
   Callback = function(Value) workspace.CurrentCamera.FieldOfView = Value end,
})

local originalMaxZoom, originalMinZoom, originalCameraMode

PlayerTab:CreateToggle({
    Name = "三人称視点 👀",
    Default = false,
    Callback = function(Value)
        if Value then
            originalMaxZoom = LocalPlayer.CameraMaxZoomDistance
            originalMinZoom = LocalPlayer.CameraMinZoomDistance
            originalCameraMode = LocalPlayer.CameraMode
            LocalPlayer.CameraMaxZoomDistance = math.huge
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        else
            LocalPlayer.CameraMaxZoomDistance = originalMaxZoom or 128
            LocalPlayer.CameraMinZoomDistance = originalMinZoom or 0.5
            LocalPlayer.CameraMode = originalCameraMode or Enum.CameraMode.Classic
        end
    end
})

-- ============================================================
-- マップ破壊タブ 💥
-- ============================================================
BreakerTab = Window:CreateTab("マップ破壊 💥", 4483362458)

BreakerTab:CreateSection("マップを破壊する 💣")

w = game:GetService("Workspace")
BackPack = w[LocalPlayer.Name .. 'SpawnedInToys']
setowner = ReplicatedStorage.GrabEvents.SetNetworkOwner
StickyPartEvent = ReplicatedStorage.PlayerEvents.StickyPartEvent

BreakerTab:CreateButton({
    Name = "大きな瓦礫 1 🪨",
    Callback = function()
        local debris = w.Map.AlwaysHereTweenedObjects.LrgDebris.Object.ObjectModel.Rock
        for i = 1,10 do
            local shur = BackPack.NinjaShuriken
            shur.Name = i
            StickyPartEvent:FireServer(shur.StickyPart, debris, CFrame.Angles(0,0,0))
        end
        for i = 1,100 do
            me.Character.HumanoidRootPart.CFrame = debris.CFrame
            setowner:FireServer(debris, debris.CFrame)
            task.wait()
        end
        local obj = w.Map.AlwaysHereTweenedObjects.LrgDebris.Object
        local body = obj.ObjectModel.Rock
        local attach = body:FindFirstChild("ObjectModelAttachment")
        if attach then attach:Destroy() end
        obj.FollowThisPart.AlignPosition.Attachment0 = nil
        obj.FollowThisPart.AlignOrientation.Attachment0 = nil
    end
})

BreakerTab:CreateButton({
    Name = "大きな瓦礫 2 🪨",
    Callback = function()
        local debris = w.Map.AlwaysHereTweenedObjects.LrgDebris2.Object.ObjectModel.Rock
        for i = 1,10 do
            local shur = BackPack.NinjaShuriken
            shur.Name = i
            StickyPartEvent:FireServer(shur.StickyPart, debris, CFrame.Angles(0,0,0))
        end
        for i = 1,100 do
            me.Character.HumanoidRootPart.CFrame = debris.CFrame
            setowner:FireServer(debris, debris.CFrame)
            task.wait()
        end
        local obj = w.Map.AlwaysHereTweenedObjects.LrgDebris2.Object
        local body = obj.ObjectModel.Rock
        local attach = body:FindFirstChild("ObjectModelAttachment")
        if attach then attach:Destroy() end
        obj.FollowThisPart.AlignPosition.Attachment0 = nil
        obj.FollowThisPart.AlignOrientation.Attachment0 = nil
    end
})

BreakerTab:CreateButton({
    Name = "電車 🚂",
    Callback = function()
        local train = w.Map.AlwaysHereTweenedObjects.Train.Object.ObjectModel.BallOctagon
        for i = 1,10 do
            local shur = BackPack.NinjaShuriken
            shur.Name = i
            StickyPartEvent:FireServer(shur.StickyPart, train, CFrame.Angles(0,0,0))
        end
        for i = 1,100 do
            me.Character.HumanoidRootPart.CFrame = train.CFrame
            setowner:FireServer(train, train.CFrame)
            task.wait()
        end
        local obj = w.Map.AlwaysHereTweenedObjects.Train.Object
        local body = obj.ObjectModel.BallOctagon
        local attach = body:FindFirstChild("ObjectModelAttachment")
        if attach then attach:Destroy() end
        obj.FollowThisPart.AlignPosition.Attachment0 = nil
        obj.FollowThisPart.AlignOrientation.Attachment0 = nil
    end
})

BreakerTab:CreateButton({
   Name = "UFO 1 (外側) 🛸",
   Callback = function()
      local UFO = w.Map.AlwaysHereTweenedObjects.OuterUFO.Object.ObjectModel.Body
      for i = 1,10 do
          local shur = BackPack.NinjaShuriken
          shur.Name = i
          StickyPartEvent:FireServer(shur.StickyPart,UFO,CFrame.Angles(0,0,0))
      end
      for i = 1,100 do
          me.Character.HumanoidRootPart.CFrame = UFO.CFrame
          setowner:FireServer(UFO,UFO.CFrame)
          task.wait()
      end
      local obj = w.Map.AlwaysHereTweenedObjects.OuterUFO.Object
      local body = obj.ObjectModel.Body
      local attach = body:FindFirstChild("ObjectModelAttachment")
      if attach then attach:Destroy() end
      obj.FollowThisPart.AlignPosition.Attachment0 = nil
      obj.FollowThisPart.AlignOrientation.Attachment0 = nil
   end
})

BreakerTab:CreateButton({
   Name = "UFO 2 (内側) 🛸",
   Callback = function()
      local UFO = w.Map.AlwaysHereTweenedObjects.InnerUFO.Object.ObjectModel.Body
      for i = 1,10 do
          local shur = BackPack.NinjaShuriken
          shur.Name = i
          StickyPartEvent:FireServer(shur.StickyPart,UFO,CFrame.Angles(0,0,0))
      end
      for i = 1,100 do
          me.Character.HumanoidRootPart.CFrame = UFO.CFrame
          setowner:FireServer(UFO,UFO.CFrame)
          task.wait()
      end
      local obj = w.Map.AlwaysHereTweenedObjects.InnerUFO.Object
      local body = obj.ObjectModel.Body
      local attach = body:FindFirstChild("ObjectModelAttachment")
      if attach then attach:Destroy() end
      obj.FollowThisPart.AlignPosition.Attachment0 = nil
      obj.FollowThisPart.AlignOrientation.Attachment0 = nil
   end
})

BreakerTab:CreateButton({
   Name = "洞窟のトロッコ 🛒",
   Callback = function()
      local obj = w.Map.AlwaysHereTweenedObjects.CaveCart.Object
      local model = obj.ObjectModel
      local target = model:GetChildren()[13]
      for i = 1,10 do
          local shur = BackPack.NinjaShuriken
          shur.Name = i
          StickyPartEvent:FireServer(shur.StickyPart,target,CFrame.Angles(0,0,0))
      end
      for i = 1,100 do
          me.Character.HumanoidRootPart.CFrame = target.CFrame
          setowner:FireServer(target,target.CFrame)
          task.wait()
      end
      local attach = target:FindFirstChild("ObjectModelAttachment")
      if attach then attach:Destroy() end
      obj.FollowThisPart.AlignPosition.Attachment0 = nil
      obj.FollowThisPart.AlignOrientation.Attachment0 = nil
   end
})

BreakerTab:CreateDivider()

local Sense, Massless = 30, nil

BreakerTab:CreateToggle({
    Name = '無質量グラブ 🪶',
    CurrentValue = false,
    Flag = "MasslessToggle",
    Callback = function(v)
        if v then
            Massless = workspace.ChildAdded:Connect(function(r)
                if r.Name == "GrabParts" then
                    while workspace:FindFirstChild("GrabParts") do
                        task.wait()
                        local dp = r:FindFirstChild("DragPart")
                        if dp and dp:FindFirstChild("AlignPosition") and dp:FindFirstChild("AlignOrientation") then
                            dp.AlignPosition.Responsiveness = Sense
                            dp.AlignPosition.MaxForce = math.huge
                            dp.AlignPosition.MaxVelocity = math.huge
                            dp.AlignOrientation.Responsiveness = Sense
                            dp.AlignOrientation.MaxTorque = math.huge
                        end
                    end
                end
            end)
        else
            if Massless then Massless:Disconnect() Massless = nil end
        end
    end
})

BreakerTab:CreateInput({
    Name = "無質量の感度 🎚️",
    CurrentValue = tostring(Sense),
    PlaceholderText = "感度値を入力",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local v = tonumber(Text)
        if v and v > 0 then Sense = v end
    end
})

-- ============================================================
-- アンチタブ 🛡️
-- ============================================================
AntisTab = Window:CreateTab("アンチ 🛡️", 7734056608)

GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
DestroyGrabLine = GrabEvents:FindFirstChild("DestroyGrabLine")
CreateGrabEvent = GrabEvents:FindFirstChild("CreateGrabLine")

local defenseEnabled = false
local defenseConnection = nil
local defenseMode = "アンチ投げ飛ばし"

local function getAttacker()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    local owner = char.Head:FindFirstChild("PartOwner")
    if not owner or not owner:IsA("StringValue") then return end
    return Players:FindFirstChild(owner.Value)
end

local function performFling(attacker)
    if not attacker or not attacker.Character then return end
    local root = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(root) end
        local away = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
        away = Vector3.new(away.X, 0, away.Z) * 10000
        local bv = Instance.new("BodyVelocity")
        bv.Name = "RinneganFling"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = away
        bv.P = 12500
        bv.Parent = root
        Debris:AddItem(bv, 0.1)
    end)
end

local function performKill(attacker)
    if not attacker or not attacker.Character then return end
    local root = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(root) end
        local away = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
        away = Vector3.new(away.X, 0, away.Z) * 99999999999999
        local bv = Instance.new("BodyVelocity")
        bv.Name = "RinneganFling"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = away
        bv.P = 12500
        bv.Parent = root
        Debris:AddItem(bv, 0.1)
    end)
end

local function performHeaven(attacker)
    if not attacker or not attacker.Character then return end
    local root = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(root) end
        root.CFrame = CFrame.new(0, 100, 0)
        local bv = Instance.new("BodyVelocity")
        bv.Name = "RinneganHeaven"
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Velocity = Vector3.new(0, 100, 0)
        bv.P = 12500
        bv.Parent = root
        Debris:AddItem(bv, 5)
    end)
end

local function performKick(attacker)
    if not attacker or not attacker.Character then return end
    local root = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(root) end
        root.CFrame = CFrame.new(0, 999999999999, 0)
        local bv = Instance.new("BodyVelocity")
        bv.Name = "RinneganHeaven"
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Velocity = Vector3.new(0, 99999999999999, 0)
        bv.P = 12500
        bv.Parent = root
        Debris:AddItem(bv, 5)
    end)
end

local function performRagdoll(attacker)
    if not attacker or not attacker.Character then return end
    local root = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(root) end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "RinneganSpy"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, -90, 0)
        bv.P = 12500
        bv.Parent = root
        Debris:AddItem(bv, 0.1)
    end)
end

local function performHell(attacker)
    if not attacker or not attacker.Character then return end
    local root = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(root) end
        for _, part in ipairs(attacker.Character:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                part.CanCollide = false
            end
        end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "RinneganSpy"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, -10000000, 0)
        bv.P = 12500
        bv.Parent = root
        local noclipConnection
        noclipConnection = RunService.Heartbeat:Connect(function()
            if not attacker.Character or not attacker.Character.Parent then
                noclipConnection:Disconnect()
                return
            end
            for _, part in ipairs(attacker.Character:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored then
                    part.CanCollide = false
                end
            end
        end)
        task.delay(1.5, function()
            if noclipConnection then noclipConnection:Disconnect() end
        end)
        Debris:AddItem(bv, 0.1)
    end)
end

local function performChina(attacker)
    if not attacker or not attacker.Character then return end
    local root = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        SetNetworkOwner:FireServer(root, root.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(root) end
        root.CFrame = CFrame.new(591, 153, -101)
    end)
end

local function performSpamGrabLines(attacker)
    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local owner = head:FindFirstChild("PartOwner")
            if owner and owner:IsA("StringValue") then
                local attacker2 = Players:FindFirstChild(owner.Value)
                if attacker2 and attacker2.Character then
                    local attackerHead = attacker2.Character:FindFirstChild("Head")
                    local attackerHRP = attacker2.Character:FindFirstChild("HumanoidRootPart")
                    if attackerHead and attackerHRP then
                        for i = 1, 3 do
                            pcall(function() CreateGrabEvent:FireServer(attackerHead, attackerHead.CFrame) end)
                        end
                        for i = 1, 3 do
                            pcall(function() CreateGrabEvent:FireServer(attackerHRP, attackerHRP.CFrame) end)
                        end
                    end
                end
            end
        end
    end
end

local function startDefense()
    if defenseConnection then return end
    defenseConnection = RunService.Heartbeat:Connect(function()
        if not defenseEnabled then return end
        local attacker = getAttacker()
        if not attacker then return end
        if defenseMode == "アンチ投げ飛ばし" then performFling(attacker)
        elseif defenseMode == "アンチキル" then performKill(attacker)
        elseif defenseMode == "アンチ天国送り" then performHeaven(attacker)
        elseif defenseMode == "アンチキック" then performKick(attacker)
        elseif defenseMode == "アンチラグドール" then performRagdoll(attacker)
        elseif defenseMode == "アンチ地獄送り" then performHell(attacker)
        elseif defenseMode == "アンチ中国送り" then performChina(attacker)
        elseif defenseMode == "アンチグラブライン" then performSpamGrabLines(attacker)
        end
    end)
end

local function stopDefense()
    if defenseConnection then
        defenseConnection:Disconnect()
        defenseConnection = nil
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BodyVelocity") and (obj.Name == "RinneganFling" or obj.Name == "RinneganHeaven") then
                    obj:Destroy()
                end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if defenseEnabled then
        task.wait(1)
        startDefense()
    end
end)

AntisTab:CreateSection("自動攻撃 ⚔️")

AntisTab:CreateToggle({
    Name = 'アンチ自動反撃 🤖',
    CurrentValue = false,
    Flag = "RinneganDefenseToggle",
    Callback = function(enabled)
        defenseEnabled = enabled
        if enabled then startDefense() else stopDefense() end
    end
})

AntisTab:CreateDropdown({
    Name = "アンチモード 🎯",
    Options = {"アンチ投げ飛ばし", "アンチキル", "アンチ天国送り", "アンチキック", "アンチラグドール", "アンチ地獄送り", "アンチ中国送り", "アンチグラブライン"},
    CurrentOption = "アンチ投げ飛ばし",
    Flag = "RinneganMode",
    Callback = function(mode)
        if typeof(mode) == "table" then mode = mode[1] end
        defenseMode = mode
    end
})

AntisTab:CreateDivider()

-- Tractor Gucci
local gucciEnabled = false
local gucciConnection = nil
local tractor = nil
local vehicleSeat = nil
local safePosition = nil
local restoreFrames = 0
local humanoidA, rootPart, seat = nil
local playerName = LocalPlayer.Name

local function spawnTractor()
    local args = {"TractorGreen", CFrame.new(0, 5000000, 0), Vector3.new(0, 60, 0)}
    ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(unpack(args))
    local folder = Workspace:WaitForChild(playerName.."SpawnedInToys", 5)
    if folder and folder:FindFirstChild("TractorGreen") then
        tractor = folder.TractorGreen
        vehicleSeat = tractor:FindFirstChild("VehicleSeat")
        if tractor:FindFirstChild("Main") then
            tractor.Main.CFrame = CFrame.new(0, 50000, 0)
            tractor.Main.Anchored = true
        end
    end
end

local function startGucci()
    local charA = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoidA = charA:WaitForChild("Humanoid")
    rootPart = charA:WaitForChild("HumanoidRootPart")
    safePosition = rootPart.Position

    if vehicleSeat and vehicleSeat:IsA("VehicleSeat") then
        rootPart.CFrame = vehicleSeat.CFrame + Vector3.new(0, 2, 0)
        vehicleSeat:Sit(humanoidA)
    end

    humanoidA:GetPropertyChangedSignal("Jump"):Connect(function()
        if humanoidA.Jump and humanoidA.Sit then
            restoreFrames = 15
            safePosition = rootPart.Position
        end
    end)

    if gucciConnection then gucciConnection:Disconnect() end
    gucciConnection = RunService.Heartbeat:Connect(function()
        if not rootPart or not humanoidA then return end
        ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(rootPart, 0)
        if restoreFrames > 0 then
            rootPart.CFrame = CFrame.new(safePosition)
            restoreFrames = 1
        end
    end)

    task.spawn(function()
        while humanoidA.Sit do task.wait(1) end
        task.wait(0.5)
        rootPart.CFrame = CFrame.new(safePosition)
    end)
end

local function stopGucci()
    if gucciConnection then gucciConnection:Disconnect() gucciConnection = nil end
    if tractor then
        ReplicatedStorage.MenuToys.DestroyToy:FireServer(tractor)
        tractor:Destroy()
        tractor = nil
        vehicleSeat = nil
    end
end

AntisTab:CreateToggle({
    Name = "アンチトラクターグッチ 🚜",
    CurrentValue = false,
    Callback = function(enabled)
        gucciEnabled = enabled
        if enabled then
            spawnTractor()
            task.wait(0.5)
            if tractor then startGucci() end
        else
            stopGucci()
        end
    end
})

AntisTab:CreateToggle({
    Name = "アンチグッチトレイン 🚂",
    Callback = function(enabled)
        local train = workspace.Map.AlwaysHereTweenedObjects.Train.Object.ObjectModel
        local Seat = train.Seat
        local hrpP = LocalPlayer.Character.HumanoidRootPart
        local ragdollingevent = ReplicatedStorage.CharacterEvents.RagdollRemote
        local conn
        conn = RunService.Heartbeat:Connect(function()
            task.wait(0.09)
            Seat:Sit(LocalPlayer.Character.Humanoid)
            ragdollingevent:FireServer(hrpP, 0)
            conn:Disconnect()
            Seat:Sit(LocalPlayer.Character.Humanoid)
        end)
    end
})

-- Anti Grab
local antiGrabConn = nil
AntisTab:CreateToggle({
    Name = "アンチグラブ 🚫",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(enabled)
        if antiGrabConn then antiGrabConn:Disconnect() antiGrabConn = nil end
        if not enabled then return end
        antiGrabConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local head = char:FindFirstChild("Head")
            local hrpA = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not head or not hrpA or not hum then return end
            local grabbedTag = head:FindFirstChild("PartOwner")
            if not grabbedTag then return end
            local oldCF = hrpA.CFrame
            for _=1,3 do
                pcall(function() ReplicatedStorage.CharacterEvents.Struggle:FireServer() end)
                pcall(function() ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrpA, 0) end)
                pcall(function() if DestroyGrabLine then DestroyGrabLine:FireServer() end end)
                hum.Sit = false
                hum.PlatformStand = false
                local rag = hum:FindFirstChild("Ragdolled")
                if rag and rag:IsA("BoolValue") then rag.Value = false end
                hrpA.AssemblyLinearVelocity = Vector3.zero
                hrpA.AssemblyAngularVelocity = Vector3.zero
                hrpA.CFrame = oldCF
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                task.wait()
            end
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end)
    end
})

-- Anti Kick
AntisTab:CreateToggle({
    Name = "アンチキック 🛡️",
    CurrentValue = false,
    Flag = "AntiKickToggle",
    Callback = function(Value)
        getgenv().AntiKickEnabled = Value
        if Value then
            task.spawn(function()
                local plr = game.Players.LocalPlayer
                local inv = workspace[plr.Name.."SpawnedInToys"]
                local setOwner = game.ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
                local stickyEvent = game.ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
                local destroyrem = game.ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
                local canSpawn = plr:WaitForChild("CanSpawnToy")

                local function getHRP()
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        return plr.Character.HumanoidRootPart
                    else
                        local character2 = plr.CharacterAdded:Wait()
                        return character2:WaitForChild("HumanoidRootPart")
                    end
                end

                local function CheckForHome()
                    local ToyFolder
                    if not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then return false end
                    for _, v in pairs(workspace.Plots:GetChildren()) do
                        for _, b in pairs(v.PlotSign.ThisPlotsOwners:GetChildren()) do
                            if b.Value == plr.Name then
                                ToyFolder = workspace.PlotItems[v.Name]
                            end
                        end
                    end
                    if ToyFolder then return true, ToyFolder else return false end
                end

                local function StickKunai(kunai)
                    if not kunai or not kunai:FindFirstChild("StickyPart") then return end
                    local currentHRP = getHRP()
                    if kunai:FindFirstChild("SoundPart") then
                        if not kunai["SoundPart"]:FindFirstChild("PartOwner") or kunai["SoundPart"].PartOwner.Value ~= plr.Name then 
                            setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame)
                        end
                    end
                    stickyEvent:FireServer(
                        kunai.StickyPart,
                        currentHRP:FindFirstChild("FirePlayerPart") or currentHRP:WaitForChild("FirePlayerPart"),
                        CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(90),math.rad(90))
                    )
                    for _, obj in pairs(kunai:GetChildren()) do
                        if obj.Name == "Pyramid" then
                            obj.CanTouch = false
                            obj.CanCollide = false
                            obj.CanQuery = false
                            obj.Transparency = 0
                        elseif obj.Name == "Main" then
                            obj.CanTouch = false
                            obj.CanCollide = false
                            obj.CanQuery = false
                            obj.Transparency = 0
                        elseif obj:IsA("BasePart") then
                            obj.CanTouch = false
                            obj.CanCollide = false
                            obj.CanQuery = false
                            obj.Transparency = 1
                        end
                    end
                end

                local function ClearKunai()
                    for _,v in pairs(inv:GetChildren()) do
                        if v.Name == "AntiKick" then
                            destroyrem:FireServer(v)
                        end
                    end
                end

                local function SpawnToy(name)
                    while not canSpawn.Value do canSpawn.Changed:Wait() end
                    local currentHRP = getHRP()
                    task.spawn(function()
                        game.ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
                            name, currentHRP.CFrame * CFrame.new(0, 12, 20), Vector3.new(0,0,0)
                        )
                    end)
                    local boolik, house = CheckForHome()
                    if boolik then 
                        return house:WaitForChild(name, 2)
                    elseif not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then 
                        return inv:WaitForChild(name, 2)
                    elseif workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) and not boolik then 
                        return nil
                    end
                end

                while getgenv().AntiKickEnabled do 
                    task.wait(0.005)
                    if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then continue end
                    local kunai = inv:FindFirstChild("NinjaShuriken")
                    if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then 
                        local boolik, house = CheckForHome()
                        if boolik and house and workspace.Plots:FindFirstChild(house.Name) and workspace.Plots:FindFirstChild(house.Name)["PlotSign"]["ThisPlotsOwners"]:FindFirstChild("Value") and workspace.Plots:FindFirstChild(house.Name)["PlotSign"]["ThisPlotsOwners"]["Value"]["TimeRemainingNum"].Value > 89 then 
                            kunai = SpawnToy("NinjaShuriken")
                            if kunai == nil then continue end
                            kunai.Name = "AntiKick" 
                            StickKunai(kunai)
                        end
                    end
                    if not kunai then
                        if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then continue end 
                        kunai = SpawnToy("NinjaShuriken")
                        if kunai == nil then continue end 
                        kunai.Name = "AntiKick"
                    end
                    repeat
                        if kunai and kunai:FindFirstChild("StickyPart") and kunai.StickyPart.CanTouch == true then
                            StickKunai(kunai)
                            kunai.Name = "AntiKick"
                        end
                        wait(0.3)
                    until not kunai or not getgenv().AntiKickEnabled or not kunai:FindFirstChild("StickyPart")
                    if not kunai or not kunai:FindFirstChild("StickyPart") then ClearKunai() end 
                end
            end)
        end
    end,
})

-- Antiblob
antiblob = false
antiblobConnection = nil
truePosPart = nil

function createTruePospart()
    charB = LocalPlayer.Character
    if not charB then return end
    if charB:FindFirstChild("TruePositionPart") then return charB.TruePositionPart end
    tp = Instance.new("Part")
    tp.Name = "TruePositionPart"
    tp.Anchored = true
    tp.CanCollide = false
    tp.Transparency = 1
    tp.Size = Vector3.new(1, 1, 1)
    tp.CFrame = CFrame.new(0, -100, 0)
    tp.Parent = charB
    return tp
end

function dropFromBlobs()
    charB = LocalPlayer.Character
    if not charB then return end
    hrpB = charB:FindFirstChild("HumanoidRootPart")
    if not hrpB then return end
    for _, plot in pairs(Workspace.PlotItems:GetChildren()) do
        if plot.Name ~= "PlayersInPlots" then
            for _, itm in pairs(plot:GetChildren()) do
                if itm.Name == "CreatureBlobman" then
                    pcall(function()
                        scriptB = itm:FindFirstChild("BlobmanSeatAndOwnerScript")
                        detector = itm:FindFirstChild("RightDetector")
                        if scriptB and detector then
                            drop = scriptB:FindFirstChild("CreatureDrop")
                            weld = detector:FindFirstChild("RightWeld")
                            if drop and weld then
                                drop:FireServer(weld, hrpB)
                                ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
                            end
                        end
                    end)
                end
            end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        toysFolder = Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
        if toysFolder then
            for _, itm in pairs(toysFolder:GetChildren()) do
                if itm.Name == "CreatureBlobman" then
                    pcall(function()
                        scriptB = itm:FindFirstChild("BlobmanSeatAndOwnerScript")
                        detector = itm:FindFirstChild("RightDetector")
                        if scriptB and detector then
                            drop = scriptB:FindFirstChild("CreatureDrop")
                            weld = detector:FindFirstChild("RightWeld")
                            if drop and weld then
                                drop:FireServer(weld, hrpB)
                                ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
                            end
                        end
                    end)
                end
            end
        end
    end
end

function setMassless()
    charB = LocalPlayer.Character
    if not charB then return end
    for _, prt in pairs(charB:GetChildren()) do
        if prt:IsA("BasePart") and prt.Massless then
            prt.Massless = false
            dropFromBlobs()
        end
    end
end

function moveRootAttachment()
    charB = LocalPlayer.Character
    if not charB then return end
    hrpB = charB:FindFirstChild("HumanoidRootPart")
    truePart = charB:FindFirstChild("TruePositionPart")
    if hrpB and truePart then
        rootAttachment = hrpB:FindFirstChild("RootAttachment")
        if rootAttachment then
            task.wait(0.2)
            rootAttachment.Parent = truePart
            Rayfield:Notify({
                Title = "アンチブロブ 🦠",
                Content = "アンチブロブが有効になりました 🤪",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end
end

function restoreRootAttachment()
    charB = LocalPlayer.Character
    if not charB then return end
    hrpB = charB:FindFirstChild("HumanoidRootPart")
    truePart = charB:FindFirstChild("TruePositionPart")
    if hrpB and truePart then
        rootAttachment = truePart:FindFirstChild("RootAttachment")
        if rootAttachment then
            rootAttachment.Parent = hrpB
            Rayfield:Notify({
                Title = "アンチブロブ 🦠",
                Content = "アンチブロブが無効になりました",
                Duration = 3,
                Image = 4483362458,
            })
        end
        truePart:Destroy()
    end
end

function antiblobLoop()
    while antiblob do
        pcall(function()
            if LocalPlayer.Character then
                createTruePospart()
                setMassless()
                hrpB = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrpB and hrpB:FindFirstChild("RootAttachment") then
                    truePart = LocalPlayer.Character:FindFirstChild("TruePositionPart")
                    if truePart and not truePart:FindFirstChild("RootAttachment") then
                        moveRootAttachment()
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end

AntisTab:CreateToggle({
    Name = 'アンチブロブ 🦠',
    CurrentValue = false,
    Flag = "AntiblobToggle",
    Callback = function(Value)
        antiblob = Value
        if Value then
            if antiblobConnection then antiblobConnection:Disconnect() end
            task.spawn(antiblobLoop)
            antiblobConnection = LocalPlayer.CharacterAdded:Connect(function(charC)
                if antiblob then
                    task.wait(1)
                    createTruePospart()
                    task.wait(0.5)
                    moveRootAttachment()
                end
            end)
        else
            if antiblobConnection then
                antiblobConnection:Disconnect()
                antiblobConnection = nil
            end
            restoreRootAttachment()
        end
    end,
})

-- Anti Lag
AntisTab:CreateToggle({
    Name = "アンチラグ 📉",
    Default = false,
    Callback = function(Value)
        local characterScript = LocalPlayer.PlayerScripts:FindFirstChild("CharacterAndBeamMove")
        if characterScript then
            characterScript.Disabled = Value
        end
    end
})

-- Anti Burn
antiBurnEnabled = false
AntisTab:CreateToggle({
    Name = "アンチ燃焼 🔥",
    CurrentValue = false,
    Flag = "antiburn_toggle",
    Callback = function(Value)
        antiBurnEnabled = Value
        task.spawn(function()
            while antiBurnEnabled do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local hrpD = char:FindFirstChild("HumanoidRootPart")
                        local myToys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                        if hrpD and myToys and hrpD:FindFirstChild("FireParticleEmitter") then
                            local fireExtinguisher = myToys:FindFirstChild("FireExtinguisher")
                            if not fireExtinguisher then
                                ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("FireExtinguisher", hrpD.CFrame * CFrame.new(0, 100, 0), Vector3.new(0,0,0))
                                task.wait(0.5)
                                fireExtinguisher = myToys:FindFirstChild("FireExtinguisher")
                            end
                            if fireExtinguisher then
                                local extinguishPart = fireExtinguisher.ExtinguishPart
                                while hrpD:FindFirstChild("FireParticleEmitter") do
                                    extinguishPart.Position = hrpD.Position
                                    extinguishPart.Size = Vector3.new(100, 100, 100)
                                    RunService.Heartbeat:Wait()
                                    extinguishPart.Position = Vector3.new(-1000, 0, 0)
                                    RunService.Heartbeat:Wait()
                                end
                                ReplicatedStorage.MenuToys.DestroyToy:FireServer(fireExtinguisher)
                            end
                        end
                    end
                end)
                task.wait(0.01)
            end
        end)
    end,
})

-- Anti Void
antiVoidEnabled = false
AntisTab:CreateToggle({
    Name = "アンチ奈落 🕳️",
    CurrentValue = false,
    Flag = "AntiVoid",
    Callback = function(v)
        antiVoidEnabled = v
        if v then
            workspace.FallenPartsDestroyHeight = -100000
            task.spawn(function()
                while antiVoidEnabled do
                    local char = LocalPlayer.Character
                    local hrpE = char and char:FindFirstChild("HumanoidRootPart")
                    if hrpE and hrpE.Position.Y < -500 then
                        hrpE.CFrame = CFrame.new(2, -7, -4)
                    end
                    task.wait(0.2)
                end
            end)
        else
            workspace.FallenPartsDestroyHeight = -100
        end
    end,
})

-- Anti Ownership Kick
antiok = true
AntisTab:CreateToggle({
    Name = "アンチ所有権キック 👑",
    Default = true,
    Callback = function(Value)
        antiok = Value
        task.spawn(function()
            while antiok do
                if game.Players.LocalPlayer.Character then
                    if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.Position.Magnitude > 10000000 then
                            game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(0,-10,0)
                            game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyLinearVelocity = Vector3.new(0,0,0)
                        end
                    end
                end
                task.wait()
            end
        end)
    end    
})

-- Burger Loop
folder = workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys")
currentFood = nil
lastSpawn = 0
spawnCooldown = 0.5
Root = nil
FoodToggle = false
HeartbeatConnection = nil

function gethrp()
    if LocalPlayer.Character then
        hrpF = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrpF then Root = hrpF end
    end
    return Root
end

function spawnfood()
    if tick() - lastSpawn < spawnCooldown then return end
    lastSpawn = tick()
    if not Root then return end
    args = {
        "FoodHamburger",
        Root.CFrame * CFrame.new(5, 0, 5),
        Vector3.new(0, 33.0880012512207, 0)
    }
    ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(unpack(args))
end

function hold(food)
    if not food or not food.Parent then return end
    holdPart = food:FindFirstChild("HoldPart")
    if not holdPart then return end
    holdArgs = { food, LocalPlayer.Character }
    dropArgs = {
        food,
        CFrame.new(-128.37586975097656, -10.35040283203125, 72.18002319335938),
        Vector3.new(0, 154.77699279785156, 0)
    }
    holdPart.HoldItemRemoteFunction:InvokeServer(unpack(holdArgs))
    holdPart.DropItemRemoteFunction:InvokeServer(unpack(dropArgs))
end

folder.ChildAdded:Connect(function(child)
    if child.Name == "FoodHamburger" then
        currentFood = child
    end
end)

AntisTab:CreateToggle({
    Name = "アンチバーガーループ 🍔",
    Default = false,
    Callback = function(v)
        FoodToggle = v
        if v then
            HeartbeatConnection = RunService.Heartbeat:Connect(function()
                gethrp()
                if not currentFood or not currentFood.Parent then
                    currentFood = nil
                    spawnfood()
                else
                    hold(currentFood)
                end
            end)
        else
            if HeartbeatConnection then
                HeartbeatConnection:Disconnect()
                HeartbeatConnection = nil
            end
        end
    end
})

-- ============================================================
-- ループタブ 🔁
-- ============================================================
LoopTab = Window:CreateTab("ループ 🔁", 7734058599)

RemoteSetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
RemoteDestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine")
SpawnToyRF = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
DestroyToyEvent = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("DestroyToy")

SelectedPlayer = nil
KillHB, KickHB = nil, nil
LoopKickOn, LoopKillOn, LoopBlobKickOn, LoopBlobKillOn = false, false, false, false
spamActive = false

HEIGHT_LIMIT = 100000
TELEPORT_OFFSET = Vector3.new(6, -18.5, 0)

function sno(part)
    if not part or not part.Parent then return end
    pcall(function() RemoteSetNetworkOwner:FireServer(part, part.CFrame) end)
end

function DisableCollisions(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then d.CanCollide = false end
    end
end

function setNoCollideChar(charD)
    for _, v in ipairs(charD:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end

function isTooHigh(plr)
    local c = plr.Character
    local hrpG = c and c:FindFirstChild("HumanoidRootPart")
    return not hrpG or hrpG.Position.Y > HEIGHT_LIMIT
end

function findBlobman()
    local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    return toys and toys:FindFirstChild("CreatureBlobman") or nil
end

function spawnBlobman()
    local charE = LocalPlayer.Character
    if not charE or not charE:FindFirstChild("HumanoidRootPart") then return end
    SpawnToyRF:InvokeServer("CreatureBlobman", charE.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5), Vector3.new(0, -15, 0))
end

function ensureBlobman()
    local b = findBlobman()
    if b then return b end
    spawnBlobman()
    for _ = 1, 11 do
        task.wait(1)
        b = findBlobman()
        if b then return b end
    end
    return nil
end

CameraAnchor = {}
CameraAnchor.__index = CameraAnchor
function CameraAnchor.new() return setmetatable({}, CameraAnchor) end
function CameraAnchor:attach(cf)
    self:detach()
    local p = Instance.new("Part")
    p.Name, p.Size, p.Transparency, p.Anchored, p.CanCollide, p.CFrame, p.Parent =
        "CameraAnchor", Vector3.new(0.2, 0.2, 0.2), 1, true, false, cf, Workspace
    self.part = p
    local cam = Workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = p
end
function CameraAnchor:detach()
    if self.part then self.part:Destroy() self.part = nil end
    local cam = Workspace.CurrentCamera
    local charF = LocalPlayer.Character
    if charF and charF:FindFirstChild("Humanoid") then
        cam.CameraSubject = charF.Humanoid
    else
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = cam
    end
end
local cameraAnchor = CameraAnchor.new()

function saveOriginalPosAttr()
    local charG = LocalPlayer.Character
    local hrpH = charG and charG:FindFirstChild("HumanoidRootPart")
    if hrpH then
        charG:SetAttribute("OriginalPosition", hrpH:GetPivot())
    end
end

function getOriginalPosAttr()
    local charH = LocalPlayer.Character
    return charH and charH:GetAttribute("OriginalPosition") or nil
end

function initCharAttrs()
    local charI = LocalPlayer.Character
    if charI and charI:FindFirstChild("HumanoidRootPart") then
        charI:SetAttribute("OriginalPosition", charI.HumanoidRootPart:GetPivot())
        charI:SetAttribute("SavingOriginalPos", false)
    end
end

function scheduleReturnHome()
    local originalPos = getOriginalPosAttr()
    if not originalPos then return end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local charJ = LocalPlayer.Character
        local hrpI = charJ and charJ:FindFirstChild("HumanoidRootPart")
        if hrpI then
            hrpI:PivotTo(originalPos)
            if getgenv().originalFallenHeight then
                Workspace.FallenPartsDestroyHeight = getgenv().originalFallenHeight
            end
            charJ:SetAttribute("SavingOriginalPos", false)
        end
        cameraAnchor:detach()
        conn:Disconnect()
    end)
end

function modifyTarget(root, hum)
    if not (root and hum) or hum.Health <= 0 then return end
    local blob = ensureBlobman()
    if blob and blob:FindFirstChild("BlobmanSeatAndOwnerScript") then
        local drop = blob.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureDrop")
        if drop then
            for _, part in ipairs(hum.Parent:GetDescendants()) do
                if part:IsA("Weld") or part:IsA("BallSocketConstraint") then
                    drop:FireServer(part, part)
                end
            end
        end
    end
    hum.Sit = false
    hum:ChangeState(Enum.HumanoidStateType.Running)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    local plr = Players:GetPlayerFromCharacter(hum.Parent)
    if plr and plr:FindFirstChild("IsHeld") then plr.IsHeld.Value = false end
    local rag = hum:FindFirstChild("Ragdolled")
    if rag then rag.Value = false end
    local bv, bav = Instance.new("BodyVelocity"), Instance.new("BodyAngularVelocity")
    bv.MaxForce = Vector3.new(1e7, -1e7, 1e7)
    bv.P = 100
    bv.Velocity = Vector3.new(math.random(-500, 50), -50, math.random(-50, 50))
    bav.MaxTorque = Vector3.new(-1e7, -1e7, -1e7)
    bav.P = 1e6
    bav.AngularVelocity = Vector3.new(math.random(-500, 300), math.random(-300, 300), math.random(-500, 500))
    bv.Parent, bav.Parent = root, root
    hum.BreakJointsOnDeath = false
    hum:ChangeState(Enum.HumanoidStateType.Dead)
    hum.RigType = Enum.HumanoidRigType.R15
    task.delay(0.08, function()
        if bv.Parent then bv:Destroy() end
        if bav.Parent then bav:Destroy() end
    end)
end

function performKill()
    if not SelectedPlayer then return end
    local target = Players:FindFirstChild(SelectedPlayer)
    local tChar = target and target.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChild("Humanoid")
    local tHead = tChar and tChar:FindFirstChild("Head")
    if not (target and tRoot and tHum and tHead) then return end
    if isTooHigh(target) then return end
    if target:FindFirstChild("InPlot") and target.InPlot.Value then return end
    if tHum:GetState() == Enum.HumanoidStateType.Dead then return end
    local charK = LocalPlayer.Character
    local hrpJ = charK and charK:FindFirstChild("HumanoidRootPart")
    if not (charK and hrpJ) then return end
    if not charK:GetAttribute("SavingOriginalPos") then saveOriginalPosAttr() end
    charK:SetAttribute("SavingOriginalPos", true)
    getgenv().originalFallenHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = 0/0
    local originalPos = getOriginalPosAttr()
    if originalPos then cameraAnchor:attach(originalPos) end
    local desiredCFrame = CFrame.new(tRoot.Position + TELEPORT_OFFSET)
    hrpJ:PivotTo(desiredCFrame)
    setNoCollideChar(tChar)
    RemoteSetNetworkOwner:FireServer(tRoot, tRoot.CFrame)
    task.wait()
    RemoteDestroyGrabLine:FireServer(tRoot)
    task.wait()
    if tHead:FindFirstChild("PartOwner") and tHead.PartOwner.Value == LocalPlayer.Name then
        task.wait()
        modifyTarget(tRoot, tHum)
    end
    scheduleReturnHome()
end

function StartLoopKill()
    if KillHB then KillHB:Disconnect() end
    KillHB = RunService.Heartbeat:Connect(performKill)
end

function StopLoopKill()
    if KillHB then KillHB:Disconnect() KillHB = nil end
    cameraAnchor:detach()
end

function sendToSky(root, hum)
    DisableCollisions(hum.Parent)
    local BV = Instance.new("BodyVelocity")
    BV.Velocity = Vector3.new(0, 9000000, 0)
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BV.P = 100
    BV.Parent = root
    hum.Sit = false
    hum.Jump = true
    task.delay(0, function() if BV.Parent then BV:Destroy() end end)
end

function executeKick()
    if not SelectedPlayer then return end
    local p = Players:FindFirstChild(SelectedPlayer)
    local c = p and p.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local head = c and c:FindFirstChild("Head")
    local hum = c and c:FindFirstChild("Humanoid")
    if not (root and head and hum) or hum.Health <= 0 then return end
    if isTooHigh(p) then return end
    if p:FindFirstChild("InPlot") and p.InPlot.Value then return end
    local selfChar = LocalPlayer.Character
    local selfRoot = selfChar and selfChar:FindFirstChild("HumanoidRootPart")
    if not selfRoot then return end
    local saved = selfChar:GetPivot()
    selfChar:PivotTo(CFrame.new(root.Position + Vector3.new(0, 0, -3)))
    DisableCollisions(c)
    RemoteSetNetworkOwner:FireServer(root, root.CFrame)
    task.wait()
    selfChar:PivotTo(saved)
    task.wait(0.005)
    RemoteDestroyGrabLine:FireServer(root)
    task.wait(0.005)
    local po = head:FindFirstChild("PartOwner")
    if po and po.Value == LocalPlayer.Name then
        sendToSky(root, hum)
    end
end

function StartLoopKick()
    if KickHB then KickHB:Disconnect() end
    LoopKickOn = true
    KickHB = RunService.Heartbeat:Connect(function()
        if LoopKickOn then executeKick() end
    end)
end

function StopLoopKick()
    LoopKickOn = false
    if KickHB then KickHB:Disconnect() KickHB = nil end
end

function getPlayerList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local displayName = plr.DisplayName or plr.Name
            local entry = string.format("%s (@%s)", displayName, plr.Name)
            table.insert(list, entry)
        end
    end
    return list
end

function extractUsername(entry)
    local username = entry:match("@([%w_]+)")
    return username
end

LoopTab:CreateButton({
    Name = "ブロブマンをスポーン 👾",
    Callback = function() spawnBlobman() end
})

LoopTab:CreateButton({
    Name = "ブロブマンに座る 🪑",
    Callback = function()
        local blob = findBlobman()
        if blob then
            local seatB = blob:FindFirstChild("VehicleSeat")
            local charL = LocalPlayer.Character
            local humanoidB = charL and charL:FindFirstChild("Humanoid")
            if seatB and humanoidB then seatB:Sit(humanoidB) end
        end
    end
})

PlayerDropdown = LoopTab:CreateDropdown({
    Name = "プレイヤーを選択 🎯",
    Options = getPlayerList(),
    CurrentOption = {},
    Flag = "PlayerDropdown",
    Callback = function(option)
        local selected = type(option) == "table" and option[1] or option
        SelectedPlayer = extractUsername(selected)
    end
})

LoopTab:CreateButton({
    Name = "プレイヤーリストを更新 🔄",
    Callback = function() PlayerDropdown:Refresh(getPlayerList(), true) end
})

LoopTab:CreateButton({
    Name = '引っ張るグラブ 🤏',
    Callback = function()
        if not SelectedPlayer then return end
        local characterM = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = characterM:WaitForChild("HumanoidRootPart")
        local oldCFrame = root.CFrame
        local targetPlayer = Players:FindFirstChild(SelectedPlayer)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local targetHead = targetPlayer.Character.Head
            for i = 1, 2 do
                if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then break end
                root.CFrame = targetHead.CFrame * CFrame.new(2, 0, 0)
                local args = { [1] = targetHead, [2] = root.CFrame }
                RemoteSetNetworkOwner:FireServer(unpack(args))
                task.wait(0.3)
            end
            task.wait(0.3)
            root.CFrame = oldCFrame
            local front = oldCFrame.LookVector * 5
            targetHead.CFrame = CFrame.new(oldCFrame.Position + front)
            local destroyArgs = { [1] = targetHead }
            RemoteDestroyGrabLine:FireServer(unpack(destroyArgs))
        end
    end
})

LoopTab:CreateToggle({
    Name = 'アンチループキックグラブ 🔁👢',
    CurrentValue = false,
    Flag = "LoopKickToggle",
    Callback = function(v)
        if v then StartLoopKick() else StopLoopKick() end
    end
})

LoopTab:CreateToggle({
    Name = "アンチループキル 🔁💀",
    CurrentValue = false,
    Flag = "LoopKillToggle",
    Callback = function(v) 
        if v then StartLoopKill() else StopLoopKill() end 
    end
})

LoopTab:CreateToggle({
    Name = "アンチブロブマンキック 👾👢",
    CurrentValue = false,
    Flag = "BlobKickToggle",
    Callback = function(enabled)
        LoopBlobKickOn = enabled
        local function findMountedBlob()
            local charN = Players.LocalPlayer.Character
            local hum = charN and charN:FindFirstChild("Humanoid")
            return (hum and hum.SeatPart and hum.SeatPart.Parent.Name == "CreatureBlobman") and hum.SeatPart.Parent or nil
        end
        local function bringRightArm(targetName, blob)
            local tp = Players:FindFirstChild(targetName)
            local hrpK = tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart")
            if hrpK then
                blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(Players.LocalPlayer, hrpK, blob.RightDetector.RightWeld)
            end
        end
        local function execBlobKick(targetName)
            local charO = Players.LocalPlayer.Character
            local hum = charO and charO:FindFirstChild("Humanoid")
            local hrpL = charO and charO:FindFirstChild("HumanoidRootPart")
            if not (hum and hrpL) then return end
            local blob = findMountedBlob() or ensureBlobman()
            task.wait(0.12)
            local seatC = blob and blob:FindFirstChild("VehicleSeat")
            if seatC then seatC:Sit(hum) task.wait(0.12) end
            local tp = Players:FindFirstChild(targetName)
            local tHRP = tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart")
            if not tHRP then return end
            local startSelf, startBlob = hrpL.CFrame, blob.PrimaryPart and blob.PrimaryPart.CFrame
            local oldCF = tHRP.CFrame
            hrpL.CFrame = oldCF
            task.wait(0.12)
            for _ = 1, 15 do
                task.wait()
                RemoteSetNetworkOwner:FireServer(tHRP, tHRP.CFrame)
                tHRP.CFrame = oldCF * CFrame.new(0, 40, 0)
            end
            task.wait(0.13)
            RemoteDestroyGrabLine:FireServer(tHRP)
            task.wait(0.13)
            bringRightArm(targetName, blob)
            bringRightArm(targetName, blob)
            bringRightArm(targetName, blob)
            task.delay(0.55, function()
                if hrpL then hrpL.CFrame = startSelf end
                if blob and blob.PrimaryPart and startBlob then
                    blob:SetPrimaryPartCFrame(startBlob)
                end
            end)
        end
        local function monitorRespawnBlobKick(targetName)
            local tp = Players:FindFirstChild(targetName)
            if not tp then return end
            tp.CharacterAdded:Connect(function()
                if LoopBlobKickOn then
                    task.wait(0.75)
                    execBlobKick(targetName)
                end
            end)
        end
        if enabled then
            if SelectedPlayer and SelectedPlayer ~= "" then
                execBlobKick(SelectedPlayer)
                monitorRespawnBlobKick(SelectedPlayer)
            end
        else
            LoopBlobKickOn = false
        end
    end
})

LoopTab:CreateToggle({
    Name = "アンチブロブキル 👾💀",
    CurrentValue = false,
    Flag = "BlobKillToggle",
    Callback = function(enabled)
        LoopBlobKillOn = enabled
        local function execBlobKill(targetName)
            if not targetName or targetName == "" then return end
            local plr = Players:FindFirstChild(targetName)
            if not plr or not plr.Character then return end
            local localChar = LocalPlayer.Character
            if not localChar then return end
            local hum = localChar:FindFirstChild("Humanoid")
            local hrpM = localChar:FindFirstChild("HumanoidRootPart")
            if not (hum and hrpM) then return end
            local blob = (hum.SeatPart and hum.SeatPart.Parent.Name == "CreatureBlobman" and hum.SeatPart.Parent) or ensureBlobman()
            if not blob or not blob.PrimaryPart then return end
            local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if not targetHRP then return end
            if targetHRP.Position.Y > HEIGHT_LIMIT then return end
            local startLocalCFrame = hrpM.CFrame
            local startBlobCFrame = blob.PrimaryPart.CFrame
            blob:SetPrimaryPartCFrame(targetHRP.CFrame)
            if blob:FindFirstChild("VehicleSeat") then
                blob.VehicleSeat:Sit(hum)
                task.wait(0.05)
            end
            local detector = blob:FindFirstChild("LeftDetector")
            local weld = detector and detector:FindFirstChild("LeftWeld")
            if detector and weld then
                blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(detector, targetHRP, weld)
            end
            task.wait(0.05)
            local targetHum = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetHum then targetHum.RigType = Enum.HumanoidRigType.R15 end
            task.wait(0.05)
            if weld then
                blob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(weld, targetHRP)
            end
            task.delay(0.05, function()
                hrpM.CFrame = startLocalCFrame
                if blob and blob.PrimaryPart then
                    blob:SetPrimaryPartCFrame(startBlobCFrame)
                end
            end)
        end
        if enabled then
            task.spawn(function()
                while LoopBlobKillOn do
                    if SelectedPlayer and Players:FindFirstChild(SelectedPlayer) then
                        local plr = Players[SelectedPlayer]
                        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            execBlobKill(SelectedPlayer)
                        end
                    end
                    task.wait(0.06)
                end
            end)
        else
            LoopBlobKillOn = false
        end
    end
})

LoopTab:CreateToggle({
    Name = 'アンチスパムキックブロブ + グラブ 💥',
    CurrentValue = false,
    Flag = "SpamKickToggle",
    Callback = function(Value)
        spamActive = Value 
        if Value then
            if not SelectedPlayer then spamActive = false return end
            local blob = findBlobman()
            if not blob then spamActive = false return end
            local charP = LocalPlayer.Character
            if not charP or not charP:FindFirstChild("HumanoidRootPart") then spamActive = false return end
            local RightDetector = blob:FindFirstChild("RightDetector")
            if not RightDetector then spamActive = false return end
            local RightWeld = RightDetector:FindFirstChild("RightWeld")
            local BlobmanScript = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            if not (RightWeld and BlobmanScript) then spamActive = false return end
            local CreatureGrab = BlobmanScript:FindFirstChild("CreatureGrab")
            local CreatureRelease = BlobmanScript:FindFirstChild("CreatureRelease")
            if not (CreatureGrab and CreatureRelease) then spamActive = false return end
            task.spawn(function()
                local oldCF = charP:GetPivot()
                local targetPlayer = Players:FindFirstChild(SelectedPlayer)
                local targetChar = targetPlayer and targetPlayer.Character
                if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
                    spamActive = false
                    return
                end
                local targetRoot = targetChar.HumanoidRootPart
                pcall(function()
                    charP:PivotTo(targetRoot.CFrame)
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
                pcall(function() charP:PivotTo(oldCF) end)
                task.wait(0.18)
                while spamActive do
                    targetPlayer = Players:FindFirstChild(SelectedPlayer)
                    if not targetPlayer then spamActive = false break end
                    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        task.wait(0.18)
                        continue
                    end
                    targetRoot = targetPlayer.Character.HumanoidRootPart
                    local targetHead = targetPlayer.Character:FindFirstChild("Head")
                    pcall(function()
                        sno(targetRoot)
                        if targetHead then sno(targetHead) end
                        RemoteDestroyGrabLine:FireServer(targetRoot)
                        CreatureGrab:FireServer(RightDetector, targetRoot, RightWeld)
                        if targetHead then
                            GrabEvents.CreateGrabLine:FireServer(targetHead, targetHead.CFrame)
                        end
                        GrabEvents.CreateGrabLine:FireServer(targetRoot, targetRoot.CFrame)
                        CreatureRelease:FireServer(RightWeld, targetRoot)
                    end)
                    task.wait()
                end
            end)
        end
    end
})

-- Auto Blobman Delete
autoBlobmanEnabled = false
targetCFrame = CFrame.new(466.741, 28, -745.949, 0.906275, -0.000000, -0.422688, 0.000000, 1.000000, -0.000000, 0.422688, 0.000000, 0.906275)
originalPosition = nil
processingBlobmans = {}

function saveCurrentPosition()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
        return true
    end
    return false
end

function teleportToPosition(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        LocalPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    return false
end

function sitOnBlobman(blobman)
    local seatD = blobman:FindFirstChild("VehicleSeat")
    local humanoidD = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if seatD and humanoidD and not seatD.Occupant then
        seatD:Sit(humanoidD)
        task.wait(0.08)
        return seatD.Occupant == humanoidD
    end
    return false
end

function getOffBlobman()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoidE = LocalPlayer.Character.Humanoid
        if humanoidE.SeatPart then
            humanoidE.Sit = false
            humanoidE.Jump = true
            return true
        end
    end
    return false
end

function executeBlobmanSequence(blobman)
    if processingBlobmans[blobman] then return end
    if not SelectedPlayer then return end
    processingBlobmans[blobman] = true
    task.spawn(function()
        if not saveCurrentPosition() then
            processingBlobmans[blobman] = nil
            return
        end
        local blobmanPosition = nil
        if blobman:FindFirstChild("VehicleSeat") then
            blobmanPosition = blobman.VehicleSeat.CFrame
        elseif blobman:FindFirstChild("HumanoidRootPart") then
            blobmanPosition = blobman.HumanoidRootPart.CFrame
        elseif blobman.PrimaryPart then
            blobmanPosition = blobman:GetPrimaryPartCFrame()
        end
        if blobmanPosition then
            teleportToPosition(blobmanPosition + Vector3.new(0, 2, 0))
            task.wait(0.12)
        end
        if sitOnBlobman(blobman) then task.wait(0.12) end
        teleportToPosition(targetCFrame)
        task.wait(0.14)
        getOffBlobman()
        task.wait(0.14)
        if originalPosition then teleportToPosition(originalPosition) end
        processingBlobmans[blobman] = nil
    end)
end

workspace.DescendantAdded:Connect(function(descendant)
    if not autoBlobmanEnabled or not SelectedPlayer then return end
    if descendant.Name == "CreatureBlobman" and descendant:IsA("Model") then
        local parent = descendant.Parent
        while parent do
            if parent.Name == SelectedPlayer .. "SpawnedInToys" and parent:IsA("Folder") then
                task.wait(0.14)
                executeBlobmanSequence(descendant)
                break
            end
            parent = parent.Parent
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not autoBlobmanEnabled or not SelectedPlayer then return end
    local toysFolder = workspace:FindFirstChild(SelectedPlayer .. "SpawnedInToys")
    if not toysFolder then return end
    for _, toy in ipairs(toysFolder:GetDescendants()) do
        if toy.Name == "CreatureBlobman" and toy:IsA("Model") then
            if not processingBlobmans[toy] then
                executeBlobmanSequence(toy)
            end
        end
    end
end)

LoopTab:CreateToggle({
    Name = "アンチブロブ削除 (自動座り & 削除) 🗑️",
    CurrentValue = false,
    Flag = "AutoBlobman",
    Callback = function(Value)
        autoBlobmanEnabled = Value
        if Value then
            if SelectedPlayer then
                Rayfield:Notify({
                    Title = "アンチ自動ブロブ 🤖",
                    Content = "有効化 - ターゲット: " .. SelectedPlayer,
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "アンチ自動ブロブ 🤖",
                    Content = "先にプレイヤーを選択してください",
                    Duration = 3
                })
                autoBlobmanEnabled = false
                return
            end
        else
            Rayfield:Notify({
                Title = "アンチ自動ブロブ 🤖",
                Content = "無効化",
                Duration = 2
            })
            processingBlobmans = {}
        end
    end
})

Players.PlayerRemoving:Connect(function()
    task.wait(0)
    PlayerDropdown:Refresh(getPlayerList(), true)
end)

LocalPlayer.CharacterAdded:Connect(function(charQ)
    initCharAttrs()
    local hum = charQ:WaitForChild("Humanoid", 5)
    if hum then
        hum.Died:Connect(function() cameraAnchor:detach() end)
    end
end)

-- ============================================================
-- 全部タブ 🌟
-- ============================================================
TestTab = Window:CreateTab("全部 🌟", 7734058599)

camBlocker = Instance.new("Part", Workspace)
camBlocker.Anchored = true
camBlocker.CanCollide = false
camBlocker.Transparency = 1
camBlocker.CanQuery = false
camBlocker.Size = Vector3.new(10,10,10)

BringState = {
    Active = false,
    Queue = {},
    SavedPos = nil,
    SavedCamCFrame = nil,
    Radius = 100,
    Connection = nil
}

whitelistFriends = true

function disableCollisions(characterR)
    for _, part in pairs(characterR:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

function inPlot(player)
    local plots = Workspace:FindFirstChild("PlotItems")
    local playersInPlots = plots and plots:FindFirstChild("PlayersInPlots")
    return playersInPlots and playersInPlots:FindFirstChild(player.Name)
end

function inRadius(part)
    return (part.Position - BringState.SavedPos).Magnitude <= BringState.Radius
end

function shouldIgnore(player)
    if player == LocalPlayer then return true end
    if whitelistFriends and LocalPlayer:IsFriendsWith(player.UserId) then return true end
    return false
end

function refreshQueue()
    BringState.Queue = {}
    for _, player in pairs(Players:GetPlayers()) do
        if not shouldIgnore(player) and player.Character and not inPlot(player) then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and not inRadius(root) then
                table.insert(BringState.Queue, player)
            end
        end
    end
end

function freezeCamera()
    local cam = Workspace.CurrentCamera
    camBlocker.CFrame = BringState.SavedCamCFrame
    camBlocker.Parent = Workspace
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = BringState.SavedCamCFrame
end

function unfreezeCamera()
    camBlocker.Parent = nil
    local cam = Workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Custom
    if BringState.SavedCamCFrame then
        cam.CFrame = BringState.SavedCamCFrame
    end
    BringState.SavedCamCFrame = nil
end

function processNext()
    if #BringState.Queue == 0 then
        refreshQueue()
        if #BringState.Queue == 0 then return end
    end
    local target = BringState.Queue[1]
    table.remove(BringState.Queue, 1)
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    local head = target.Character:FindFirstChild("Head")
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and head and localRoot then
        LocalPlayer.Character:PivotTo(root.CFrame * CFrame.new(0, -6, 0))
        disableCollisions(LocalPlayer.Character)
        local tries = 0
        repeat
            RemoteSetNetworkOwner:FireServer(root, localRoot.CFrame)
            task.wait(0)
            tries = tries + 2
            if tries > 40 then break end
        until (head:FindFirstChild("PartOwner") and head.PartOwner.Value == LocalPlayer.Name) or not BringState.Active
        if BringState.Active and head:FindFirstChild("PartOwner") and head.PartOwner.Value == LocalPlayer.Name then
            root.CFrame = CFrame.new(BringState.SavedPos)
            root.Position = BringState.SavedPos
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(0)
        end
    end
end

function startBringAll()
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    BringState.SavedPos = localRoot.Position
    BringState.SavedCamCFrame = Workspace.CurrentCamera.CFrame
    refreshQueue()
    freezeCamera()
    BringState.Connection = RunService.Heartbeat:Connect(function()
        if BringState.Active then
            processNext()
            if BringState.SavedCamCFrame then
                local cam = Workspace.CurrentCamera
                cam.CameraType = Enum.CameraType.Scriptable
                cam.CFrame = BringState.SavedCamCFrame
                camBlocker.CFrame = BringState.SavedCamCFrame
                camBlocker.Parent = Workspace
            end
        end
    end)
end

function stopBringAll()
    if BringState.Connection then
        BringState.Connection:Disconnect()
        BringState.Connection = nil
    end
    unfreezeCamera()
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRoot and BringState.SavedPos then
        localRoot.AssemblyLinearVelocity = Vector3.zero
        localRoot.CFrame = CFrame.new(BringState.SavedPos)
    end
end

TestTab:CreateToggle({
    Name = "アンチフレンドホワイトリスト (ブリング & キック) 👥",
    CurrentValue = false,
    Flag = "WhitelistFriends",
    Callback = function(value)
        whitelistFriends = value
    end
})

TestTab:CreateToggle({
    Name = "アンチ全員引き寄せ 🌐",
    CurrentValue = false,
    Flag = "BringAllToggle",
    Callback = function(value)
        BringState.Active = value
        if value then
            startBringAll()
            Rayfield:Notify({
                Title = "アンチ全員引き寄せ 🌐",
                Content = "有効化！🤪",
                Duration = 3,
                Image = 4483345998
            })
        else
            stopBringAll()
            Rayfield:Notify({
                Title = "アンチ全員引き寄せ 🌐",
                Content = "無効化",
                Duration = 2,
                Image = 4483345998
            })
        end
    end
})

function onCharacterAdded(characterS)
    local humanoidF = characterS:WaitForChild("Humanoid")
    humanoidF.Died:Connect(function()
        if BringState.Connection then
            BringState.Connection:Disconnect()
            BringState.Connection = nil
        end
        unfreezeCamera()
    end)
    if BringState.Active then
        local localRoot = characterS:WaitForChild("HumanoidRootPart")
        BringState.SavedPos = BringState.SavedPos or localRoot.Position
        BringState.SavedCamCFrame = BringState.SavedCamCFrame or Workspace.CurrentCamera.CFrame
        freezeCamera()
        BringState.Connection = RunService.Heartbeat:Connect(function()
            if BringState.Active then
                processNext()
                if BringState.SavedCamCFrame then
                    local cam = Workspace.CurrentCamera
                    cam.CameraType = Enum.CameraType.Scriptable
                    cam.CFrame = BringState.SavedCamCFrame
                    camBlocker.CFrame = BringState.SavedCamCFrame
                    camBlocker.Parent = Workspace
                end
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

Players.PlayerAdded:Connect(function()
    if BringState.Active then refreshQueue() end
end)

Players.PlayerRemoving:Connect(function(p)
    for i = #BringState.Queue, 1, -1 do
        if BringState.Queue[i] == p then
            table.remove(BringState.Queue, i)
        end
    end
end)

function findMountedBlobman()
    local charT = LocalPlayer.Character
    if not charT then return nil end
    local hum = charT:FindFirstChild("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    local parent = hum.SeatPart.Parent
    if parent and parent.Name == "CreatureBlobman" then return parent end
    return nil
end

local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if whitelistFriends and LocalPlayer:IsFriendsWith(player.UserId) then return false end
    local inPlotVal = player:FindFirstChild("InPlot")
    if inPlotVal and inPlotVal.Value == true then return false end
    local charU = player.Character
    if not charU then return false end
    local hum = charU:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local hrpN = charU:FindFirstChild("HumanoidRootPart")
    if not hrpN then return false end
    return true
end

function kickPlayer(target, blobman, detector, weld, creatureGrab, creatureDrop)
    local targetChar = target.Character
    if not targetChar then return false end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return false end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end
    local blobHum = blobman:FindFirstChild("Humanoid")
    if blobHum then blobHum.AutoRotate = false end
    local behindPos = targetHRP.CFrame * CFrame.new(0, 1, 5)
    myChar:PivotTo(CFrame.lookAt(behindPos.Position, targetHRP.Position))
    if not targetHRP.Parent then return false end
    for i = 1, 30 do
        pcall(function()
            RemoteSetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
            targetHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 20, 0)
            RemoteDestroyGrabLine:FireServer(targetHRP)
            creatureGrab:FireServer(detector, myHRP, weld)
            task.wait(0)
            creatureGrab:FireServer(detector, targetHRP, weld)
            creatureDrop:FireServer(weld)
        end)
        task.wait(0)
    end
    return true
end

TestTab:CreateButton({
    Name = "アンチ全員キック 👢",
    Callback = function()
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local blobman = findMountedBlobman()
        if not blobman then return end
        local detector = blobman:FindFirstChild("LeftDetector")
        local weld = detector and detector:FindFirstChild("LeftWeld")
        local scriptD = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        local creatureGrab = scriptD and scriptD:FindFirstChild("CreatureGrab")
        local creatureDrop = scriptD and scriptD:FindFirstChild("CreatureDrop")
        if not (detector and weld and creatureGrab and creatureDrop) then return end
        local oldCF = myChar:GetPivot()
        local count = 0
        for _, target in ipairs(Players:GetPlayers()) do
            if not findMountedBlobman() then break end
            if isValidTarget(target) then
                local success = kickPlayer(target, blobman, detector, weld, creatureGrab, creatureDrop)
                if success then count = count + 5 end
                task.wait(0)
            end
        end
        pcall(function() myChar:PivotTo(oldCF) end)
    end    
})

TestTab:CreateToggle({
    Name = "アンチフレンドホワイトリスト 👥",
    Default = true,
    Callback = function(Value) whitelistFriends = Value end    
})

Players.PlayerRemoving:Connect(function(player)
    Rayfield:Notify({
        Title = "誰か退出しました 🚪",
        Content = (player and player.Name or "不明") .. " が退出しました",
        Duration = 5,
        Image = 4483362458
    })
end)

Players.PlayerAdded:Connect(function(plr)
    if plr:IsFriendsWith(LocalPlayer.UserId) then
        Rayfield:Notify({
            Title = "フレンドが参加 👋",
            Content = plr.Name .. " が参加しました",
            Duration = 5,
            Image = 4483362458
        })
    end
end)

-- PCLD View
espEnabled = false
local espBoxes = {}
local targetNames = {"partesp", "playercharacterlocationdetector"}

local function IsTarget(obj)
    if not obj:IsA("BasePart") then return false end
    for _, name in ipairs(targetNames) do 
        if string.lower(obj.Name) == string.lower(name) then return true end 
    end
    return false
end

local function AddBoxESP(obj)
    if espBoxes[obj] then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = obj
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.fromRGB(255, 105, 180)
    box.Transparency = 0.5
    box.Size = obj.Size
    box.Parent = game.CoreGui
    espBoxes[obj] = box
    obj.AncestryChanged:Connect(function(_, parent)
        if not parent and espBoxes[obj] then espBoxes[obj]:Destroy() espBoxes[obj] = nil end
    end)
end

function RemoveAllBoxes()
    for obj, box in pairs(espBoxes) do if box then box:Destroy() end end
    espBoxes = {}
end

function Scan()
    for _, obj in ipairs(workspace:GetDescendants()) do 
        if espEnabled and IsTarget(obj) then AddBoxESP(obj) end 
    end
end

workspace.DescendantAdded:Connect(function(obj) 
    if espEnabled and IsTarget(obj) then AddBoxESP(obj) end 
end)

TestTab:CreateToggle({
    Name = "アンチPCLD表示 👁️",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then Scan() else RemoveAllBoxes() end
    end
})

-- Spin Character
SpinEnabled = false
SpinSpeed = 5
SpinConnection = nil

TestTab:CreateToggle({
    Name = "アンチキャラクター回転 🌀",
    CurrentValue = false,
    Flag = "SpinCharacter",
    Callback = function(Value)
        SpinEnabled = Value
        if Value then
            if SpinConnection then SpinConnection:Disconnect() end
            SpinConnection = RunService.Heartbeat:Connect(function()
                local charV = LocalPlayer.Character
                local root = charV and charV:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                end
            end)
        else
            if SpinConnection then
                SpinConnection:Disconnect()
                SpinConnection = nil
            end
        end
    end,
})

TestTab:CreateSlider({
    Name = "アンチ回転速度 🌀",
    Range = {1, 10000},
    Increment = 1,
    Suffix = "度",
    CurrentValue = 5,
    Flag = "SpinSpeed",
    Callback = function(Value) SpinSpeed = Value end,
})

-- BlackHole Viewer
dick2 = Instance.new("Folder")
dick2.Parent = workspace
dick2.Name = "BinisHoles"

gettingkicked = {}
VOBBC = false

workspace.ChildAdded:Connect(function(model)
    if model.Name == "BlackHoleKick" then
        local hole = model:WaitForChild("Hole", 5)
        if not hole then return end
        local diddler
        local victimPlayer = nil
        task.spawn(function()
            task.wait(0.1)
            diddler = model:Clone()
            diddler.Parent = dick2
            diddler.Name = "Unknown's BlackHole"
            if not VOBBC then
                if diddler:FindFirstChild("Hole") then
                    diddler.Hole.Transparency = 1
                    if diddler.Hole:FindFirstChild("BillboardGui") then
                        diddler.Hole.BillboardGui.Enabled = false
                    end
                end
            end
            local starttime = tick()
            while diddler and diddler.Parent do
                if diddler:FindFirstChild("Hole") and diddler.Hole:FindFirstChild("BillboardGui") then
                    local billboardGui = diddler.Hole.BillboardGui
                    if billboardGui:FindFirstChild("Large") then
                        billboardGui.Large.Rotation = (tick() - starttime) * 150
                    end
                    if billboardGui:FindFirstChild("Small") then
                        billboardGui.Small.Rotation = (tick() - starttime) * 150
                    end
                end
                task.wait()
            end
        end)
        local solved = false
        while not solved and model and model.Parent do
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrpO = plr.Character.HumanoidRootPart
                    if hrpO.Anchored == true then
                        solved = true
                        local alreadyFlagged = false
                        for _, id in pairs(gettingkicked) do
                            if id == plr.UserId then
                                alreadyFlagged = true
                                break
                            end
                        end
                        if not alreadyFlagged then
                            victimPlayer = plr
                            table.insert(gettingkicked, plr.UserId)
                            if diddler then
                                diddler.Name = plr.Name .. "'s BlackHole"
                            end
                            local hpp = hrpO.CFrame.Position
                            local bhk = hole.CFrame.Position
                            local distance = (hpp - bhk).Magnitude
                            local byPlayer = distance > 2
                            local notifContent = string.format(
                                "%s (@%s) がキックされました%s 位置 (%d, %d, %d)",
                                plr.DisplayName, plr.Name,
                                byPlayer and " (プレイヤーによる)" or "",
                                math.floor(hole.CFrame.Position.X),
                                math.floor(hole.CFrame.Position.Y),
                                math.floor(hole.CFrame.Position.Z)
                            )
                            Rayfield:Notify({
                                Title = "アンチブラックホールキック 🕳️",
                                Content = notifContent,
                                Duration = 6.5,
                                Image = 4483362458
                            })
                            task.spawn(function()
                                task.wait(5)
                                for i, id in pairs(gettingkicked) do
                                    if id == plr.UserId then
                                        table.remove(gettingkicked, i)
                                        break
                                    end
                                end
                            end)
                        end
                        break
                    end
                end
            end
            task.wait()
        end
    end
end)

TestTab:CreateToggle({
    Name = "アンチオフライン黒穴表示 🕳️",
    CurrentValue = false,
    Flag = "ViewBlackHoles",
    Callback = function(Value)
        VOBBC = Value
        if VOBBC then
            for _, diddler in pairs(dick2:GetChildren()) do
                if diddler:FindFirstChild("Hole") then
                    if diddler.Hole:FindFirstChild("BillboardGui") then
                        diddler.Hole.BillboardGui.Enabled = true
                    end
                    for _, prt in pairs(diddler:GetDescendants()) do
                        if prt:IsA("BasePart") then
                            prt.Transparency = 0
                            if prt.Name == "HumanoidRootPart" then
                                prt.Transparency = 1
                            elseif prt.Name == "Hole" then
                                prt.Transparency = 0.25
                            end
                        end
                    end
                end
            end
            Rayfield:Notify({
                Title = "アンチブラックホールビューア 🕳️",
                Content = "オフライン黒穴を表示中 🤪",
                Duration = 3,
                Image = 4483362458
            })
        else
            for _, diddler in pairs(dick2:GetChildren()) do
                if diddler:FindFirstChild("Hole") then
                    if diddler.Hole:FindFirstChild("BillboardGui") then
                        diddler.Hole.BillboardGui.Enabled = false
                    end
                    for _, prt in pairs(diddler:GetDescendants()) do
                        if prt:IsA("BasePart") then prt.Transparency = 1 end
                    end
                end
            end
            Rayfield:Notify({
                Title = "アンチブラックホールビューア 🕳️",
                Content = "オフライン黒穴を非表示",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

TestTab:CreateButton({
    Name = "アンチ全ブラックホール削除 🗑️",
    Callback = function()
        local count = #dick2:GetChildren()
        dick2:ClearAllChildren()
        Rayfield:Notify({
            Title = "アンチブラックホールビューア 🕳️",
            Content = string.format("%d 個の黒穴を削除しました", count),
            Duration = 3,
            Image = 4483362458
        })
    end,
})

Rayfield:LoadConfiguration()