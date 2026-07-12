-- [ GAMMA SCRIPT ] Animal Hospital Anomaly | ТОЛЬКО ПО АТРИБУТАМ

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer
player.CameraMaxZoomDistance = 99999
player.CameraMode = Enum.CameraMode.Classic

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    error("Не удалось загрузить WindUI")
end

local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local virtualInput = game:GetService("VirtualInputManager")

-- ===== ПЕРЕМЕННЫЕ =====
local noclipEnabled = false
local noclipConnection = nil
local speedEnabled = false
local speedValue = 50
local originalWalkspeed = 16
local infiniteJumpEnabled = false
local jumpConnection = nil

local thirdPersonEnabled = false
local thirdPersonDistance = 10
local thirdPersonConnection = nil

local instantPromptsEnabled = false
local instantPromptConnections = {}

local autoFarmEnabled = false
local autoFarmConnection = nil
local autoFarmDelay = 0.3

local infiniteSanityEnabled = false
local sanityCheckConnection = nil
local playerStats = player:FindFirstChild("leaderstats")

-- ===== ESP ПЕРЕМЕННЫЕ =====
local espEnabled = false
local espConnections = {}
local espHighlights = {}
local espLabels = {}
local espUpdateConnection = nil

-- ===== ОКНО С КАРТИНКОЙ =====
local Window = WindUI:CreateWindow({
    Title = "Animal Hospital Anomaly",
    Author = "Gamma",
    Folder = "Gamma_AnimalHospital",
    Icon = "cat",
    Size = UDim2.fromOffset(600, 550),
    Theme = "Dark",
    Resizable = true,
    Background = "rbxassetid://6090344677",
    BackgroundImageTransparency = 0.3
})

-- ============================================================
-- ВКЛАДКА ИГРОК
-- ============================================================
local PlayerTab = Window:Tab({
    Title = "Игрок",
    Icon = "user",
    Border = true
})

PlayerTab:Toggle({
    Title = "Noclip",
    Desc = "Проход сквозь стены",
    Flag = "NoclipFlag",
    Value = false,
    Callback = function(state)
        noclipEnabled = state
        if noclipEnabled then
            if noclipConnection then
                noclipConnection:Disconnect()
            end
            noclipConnection = runService.Stepped:Connect(function()
                character = player.Character or player.CharacterAdded:Wait()
                if not character or not character.PrimaryPart then
                    return
                end
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            character = player.Character or player.CharacterAdded:Wait()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

PlayerTab:Space()

PlayerTab:Slider({
    Flag = "SpeedFlag",
    Title = "Speed Hack",
    Desc = "Скорость передвижения",
    IsTooltip = true,
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = 50
    },
    Callback = function(value)
        speedValue = value
        if speedEnabled then
            character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speedValue
            end
        end
    end
})

PlayerTab:Space()

PlayerTab:Toggle({
    Title = "Включить Speed Hack",
    Flag = "SpeedToggleFlag",
    Value = false,
    Callback = function(state)
        speedEnabled = state
        character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if speedEnabled then
                originalWalkspeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = speedValue
            else
                humanoid.WalkSpeed = originalWalkspeed
            end
        end
    end
})

PlayerTab:Space()

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Бесконечные прыжки",
    Flag = "InfiniteJumpFlag",
    Value = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        if infiniteJumpEnabled then
            if jumpConnection then
                jumpConnection:Disconnect()
            end
            jumpConnection = userInputService.JumpRequest:Connect(function()
                if infiniteJumpEnabled then
                    character = player.Character or player.CharacterAdded:Wait()
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end
})

PlayerTab:Space()

PlayerTab:Toggle({
    Title = "Моментальные ProximityPrompts",
    Desc = "HoldDuration = 0",
    Flag = "InstantPromptsFlag",
    Value = false,
    Callback = function(state)
        instantPromptsEnabled = state
        if instantPromptsEnabled then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
            local conn = workspace.DescendantAdded:Connect(function(d)
                if instantPromptsEnabled and d:IsA("ProximityPrompt") then
                    d.HoldDuration = 0
                end
            end)
            table.insert(instantPromptConnections, conn)
        else
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 1
                end
            end
            for _, conn in ipairs(instantPromptConnections) do
                if conn then
                    conn:Disconnect()
                end
            end
            instantPromptConnections = {}
        end
    end
})

-- ============================================================
-- ВКЛАДКА SANITY
-- ============================================================
local SanityTab = Window:Tab({
    Title = "Sanity",
    Icon = "heart",
    Border = true
})

SanityTab:Toggle({
    Title = "Бесконечная Sanity",
    Desc = "Замораживает Sanity на 100",
    Flag = "InfiniteSanityFlag",
    Value = false,
    Callback = function(state)
        infiniteSanityEnabled = state
        if infiniteSanityEnabled then
            if sanityCheckConnection then
                sanityCheckConnection:Disconnect()
            end
            sanityCheckConnection = runService.Heartbeat:Connect(function()
                if infiniteSanityEnabled then
                    if playerStats then
                        local sanity = playerStats:FindFirstChild("Sanity")
                        if sanity then
                            sanity.Value = 100
                        end
                    end
                    local attributes = player:GetAttributes()
                    for key, value in pairs(attributes) do
                        if string.find(string.lower(key), "sanity") then
                            player:SetAttribute(key, 100)
                        end
                    end
                    character = player.Character or player.CharacterAdded:Wait()
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        local sanityAttr = humanoid:GetAttribute("Sanity")
                        if sanityAttr then
                            humanoid:SetAttribute("Sanity", 100)
                        end
                    end
                end
            end)
        else
            if sanityCheckConnection then
                sanityCheckConnection:Disconnect()
                sanityCheckConnection = nil
            end
        end
    end
})

-- ============================================================
-- ВКЛАДКА АВТО
-- ============================================================
local AutoTab = Window:Tab({
    Title = "Авто",
    Icon = "bot",
    Border = true
})

AutoTab:Toggle({
    Title = "Авто-фарм (только к Highlight)",
    Desc = "Телепортирует к объектам с Highlight",
    Flag = "AutoFarmFlag",
    Value = false,
    Callback = function(state)
        autoFarmEnabled = state
        if autoFarmEnabled then
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
            end
            autoFarmConnection = runService.Heartbeat:Connect(function()
                if not autoFarmEnabled then
                    return
                end
                if not character or not character.PrimaryPart then
                    return
                end
                local charPos = character.PrimaryPart.Position
                local highlightedObjects = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Highlight") and obj.Adornee then
                        local parent = obj.Adornee
                        local hasPrompt = false
                        local prompt = nil
                        for _, child in ipairs(parent:GetDescendants()) do
                            if child:IsA("ProximityPrompt") and child.Enabled then
                                hasPrompt = true
                                prompt = child
                                break
                            end
                        end
                        if hasPrompt and prompt then
                            local part = parent
                            if part:IsA("BasePart") then
                                local distance = (charPos - part.Position).Magnitude
                                table.insert(highlightedObjects, {
                                    Prompt = prompt,
                                    Part = part,
                                    Distance = distance,
                                    Highlight = obj
                                })
                            end
                        end
                    end
                end
                if #highlightedObjects > 0 then
                    table.sort(highlightedObjects, function(a, b)
                        return a.Distance < b.Distance
                    end)
                    local target = highlightedObjects[1]
                    if target.Distance > 3 then
                        character:SetPrimaryPartCFrame(
                            CFrame.new(target.Part.Position + Vector3.new(0, 2, 0))
                        )
                        task.wait(0.05)
                    end
                    virtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    virtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    target.Prompt:InputHoldBegin()
                    task.wait(0.05)
                    target.Prompt:InputHoldEnd()
                    task.wait(autoFarmDelay)
                end
            end)
        else
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
        end
    end
})

AutoTab:Space()

AutoTab:Slider({
    Flag = "AutoFarmSpeedFlag",
    Title = "Скорость авто-фарма",
    Desc = "Задержка между действиями",
    IsTooltip = true,
    Step = 0.05,
    Value = {
        Min = 0.05,
        Max = 2,
        Default = 0.3
    },
    Callback = function(value)
        autoFarmDelay = value
    end
})

AutoTab:Space()

AutoTab:Button({
    Title = "📌 Телепорт к Highlight объекту",
    Justify = "Center",
    Callback = function()
        if not character or not character.PrimaryPart then
            return
        end
        local charPos = character.PrimaryPart.Position
        local closestHighlighted = nil
        local closestDistance = math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Highlight") and obj.Adornee then
                local parent = obj.Adornee
                if parent:IsA("BasePart") then
                    local distance = (charPos - parent.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestHighlighted = parent
                    end
                end
            end
        end
        if closestHighlighted then
            character:SetPrimaryPartCFrame(
                CFrame.new(closestHighlighted.Position + Vector3.new(0, 2, 0))
            )
            WindUI:Notify({
                Title = "Авто-фарм",
                Content = "Телепорт к Highlight!",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Авто-фарм",
                Content = "Highlight не найдено!",
                Duration = 2
            })
        end
    end
})

-- ============================================================
-- ВКЛАДКА VISUALS
-- ============================================================
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
    Border = true
})

VisualsTab:Toggle({
    Title = "ESP для пациентов",
    Desc = "Игроки - белый | Норм - зелёный | Аномалия - красный",
    Flag = "EspFlag",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if espEnabled then
            EnableESP()
        else
            DisableESP()
        end
    end
})

VisualsTab:Space()

VisualsTab:Toggle({
    Title = "Третье лицо (камера)",
    Desc = "Вид от третьего лица (нажми P)",
    Flag = "ThirdPersonFlag",
    Value = false,
    Callback = function(state)
        thirdPersonEnabled = state
        if thirdPersonEnabled then
            EnableThirdPerson()
        else
            DisableThirdPerson()
        end
    end
})

VisualsTab:Space()

VisualsTab:Slider({
    Flag = "ThirdPersonDistanceFlag",
    Title = "Дистанция камеры",
    Desc = "Расстояние камеры",
    IsTooltip = true,
    Step = 1,
    Value = {
        Min = 5,
        Max = 30,
        Default = 10
    },
    Callback = function(value)
        thirdPersonDistance = value
        if thirdPersonEnabled then
            UpdateThirdPerson()
        end
    end
})

-- ============================================================
-- ВКЛАДКА НАСТРОЙКИ
-- ============================================================
local SettingsTab = Window:Tab({
    Title = "Настройки",
    Icon = "settings",
    Border = true
})

SettingsTab:Button({
    Title = "🔧 Скрипт: Animal Hospital Anomaly",
    Justify = "Center",
    Callback = function()
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "📌 Экзекьютор: Full Support",
    Justify = "Center",
    Callback = function()
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "👤 Создатель: Gamma System",
    Justify = "Center",
    Callback = function()
    end
})

SettingsTab:Space()

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("Gamma_Config")

SettingsTab:Button({
    Title = "💾 Сохранить настройки",
    Justify = "Center",
    Callback = function()
        myConfig:Save()
        WindUI:Notify({
            Title = "Gamma",
            Content = "Настройки сохранены!",
            Duration = 3
        })
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "📂 Загрузить настройки",
    Justify = "Center",
    Callback = function()
        myConfig:Load()
        WindUI:Notify({
            Title = "Gamma",
            Content = "Настройки загружены!",
            Duration = 3
        })
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "🔄 Перезагрузить скрипт",
    Justify = "Center",
    Callback = function()
        DisableESP()
        DisableThirdPerson()
        if autoFarmConnection then
            autoFarmConnection:Disconnect()
        end
        if sanityCheckConnection then
            sanityCheckConnection:Disconnect()
        end
        for _, conn in ipairs(instantPromptConnections) do
            if conn then
                conn:Disconnect()
            end
        end
        instantPromptConnections = {}
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        if jumpConnection then
            jumpConnection:Disconnect()
        end
        noclipEnabled = false
        infiniteJumpEnabled = false
        speedEnabled = false
        instantPromptsEnabled = false
        autoFarmEnabled = false
        infiniteSanityEnabled = false
        character = player.Character or player.CharacterAdded:Wait()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
        WindUI:Notify({
            Title = "Gamma",
            Content = "Перезагружено!",
            Duration = 3
        })
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "❌ Закрыть меню",
    Justify = "Center",
    Color = Color3.fromRGB(239, 79, 29),
    Callback = function()
        DisableESP()
        DisableThirdPerson()
        if autoFarmConnection then
            autoFarmConnection:Disconnect()
        end
        if sanityCheckConnection then
            sanityCheckConnection:Disconnect()
        end
        for _, conn in ipairs(instantPromptConnections) do
            if conn then
                conn:Disconnect()
            end
        end
        Window:Destroy()
    end
})

-- ============================================================
-- ФУНКЦИИ ТРЕТЬЕГО ЛИЦА
-- ============================================================
function EnableThirdPerson()
    if thirdPersonConnection then
        thirdPersonConnection:Disconnect()
    end
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = character
    thirdPersonConnection = runService.RenderStepped:Connect(function()
        if not thirdPersonEnabled then
            return
        end
        if not character or not character.PrimaryPart then
            return
        end
        local charPos = character.PrimaryPart.Position
        local mouse = player:GetMouse()
        local mousePos = mouse.Hit.Position
        local lookDir = (mousePos - charPos).Unit
        if lookDir.Magnitude < 0.1 then
            lookDir = character.PrimaryPart.CFrame.LookVector
        end
        local camPos = charPos - lookDir * thirdPersonDistance
        camPos = camPos + Vector3.new(0, 2, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {character}
        local ray = workspace:Raycast(charPos, (camPos - charPos), raycastParams)
        if ray then
            camPos = ray.Position + ray.Normal * 1
        end
        camera.CFrame = CFrame.lookAt(camPos, charPos)
    end)
end

function DisableThirdPerson()
    thirdPersonEnabled = false
    if thirdPersonConnection then
        thirdPersonConnection:Disconnect()
        thirdPersonConnection = nil
    end
    camera.CameraType = Enum.CameraType.Classic
end

function UpdateThirdPerson()
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.P then
        thirdPersonEnabled = not thirdPersonEnabled
        if thirdPersonEnabled then
            EnableThirdPerson()
            WindUI:Notify({
                Title = "Камера",
                Content = "Третье лицо ВКЛЮЧЕНО",
                Duration = 2
            })
        else
            DisableThirdPerson()
            WindUI:Notify({
                Title = "Камера",
                Content = "Третье лицо ВЫКЛЮЧЕНО",
                Duration = 2
            })
        end
    end
end)

-- ============================================================
-- ФУНКЦИИ ESP
-- ============================================================
function RemoveBuiltInHighlights(model)
    if not model then
        return
    end
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("Highlight") and child.Name ~= "GammaESP" then
            child:Destroy()
        end
        if child:IsA("BillboardGui") and child.Name == "GammaLabel" then
            child:Destroy()
        end
    end
end

function CreateLabel(model, text, color)
    if not model or not model.PrimaryPart then
        return nil
    end
    local existing = model:FindFirstChild("GammaLabel")
    if existing then
        existing:Destroy()
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GammaLabel"
    billboard.Adornee = model.PrimaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = billboard
    table.insert(espLabels, billboard)
    return billboard
end

-- ФУНКЦИЯ ОПРЕДЕЛЕНИЯ АНОМАЛИЙ (ТОЛЬКО ПО АТРИБУТАМ)
function IsAnomaly(model)
    if not model or not model.PrimaryPart then
        return false
    end
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then
        return false
    end
    
    -- Проверяем ТОЛЬКО атрибуты
    local attributes = model:GetAttributes()
    for key, value in pairs(attributes) do
        local lowerKey = string.lower(key)
        if string.find(lowerKey, "anomaly") then
            return true
        end
        if string.find(lowerKey, "skinwalker") then
            return true
        end
        if string.find(lowerKey, "evil") then
            return true
        end
        if string.find(lowerKey, "ghost") then
            return true
        end
        if string.find(lowerKey, "infected") then
            return true
        end
        if string.find(lowerKey, "cursed") then
            return true
        end
        if string.find(lowerKey, "demon") then
            return true
        end
        if string.find(lowerKey, "corrupted") then
            return true
        end
        if string.find(lowerKey, "void") then
            return true
        end
    end
    
    return false
end

function IsPlayer(model)
    if not model then
        return false
    end
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character == model then
            return true
        end
    end
    return false
end

function CreateESP(model)
    if not model or not model.PrimaryPart then
        return nil
    end
    RemoveBuiltInHighlights(model)
    local isPlayer = IsPlayer(model)
    if isPlayer then
        local highlight = Instance.new("Highlight")
        highlight.Name = "GammaESP"
        highlight.Adornee = model
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(200, 200, 200)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model
        table.insert(espHighlights, highlight)
        CreateLabel(model, "ИГРОК", Color3.fromRGB(255, 255, 255))
    else
        local isAnomaly = IsAnomaly(model)
        if isAnomaly then
            local highlight = Instance.new("Highlight")
            highlight.Name = "GammaESP"
            highlight.Adornee = model
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 200, 200)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0.2
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = model
            table.insert(espHighlights, highlight)
            CreateLabel(model, "АНОМАЛИЯ", Color3.fromRGB(255, 0, 0))
        else
            local highlight = Instance.new("Highlight")
            highlight.Name = "GammaESP"
            highlight.Adornee = model
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(200, 255, 200)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0.2
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = model
            table.insert(espHighlights, highlight)
            CreateLabel(model, "НОРМ", Color3.fromRGB(0, 255, 0))
        end
    end
    return highlight
end

function UpdateESP()
    for _, h in ipairs(espHighlights) do
        if h and h.Parent then
            h:Destroy()
        end
    end
    espHighlights = {}
    for _, l in ipairs(espLabels) do
        if l and l.Parent then
            l:Destroy()
        end
    end
    espLabels = {}
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= character then
            RemoveBuiltInHighlights(model)
            CreateESP(model)
        end
    end
end

function EnableESP()
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
    end
    UpdateESP()
    local conn = workspace.DescendantAdded:Connect(function(d)
        if espEnabled and d:IsA("Model") and d:FindFirstChild("Humanoid") and d ~= character then
            task.wait(0.2)
            if espEnabled then
                RemoveBuiltInHighlights(d)
                CreateESP(d)
            end
        end
    end)
    table.insert(espConnections, conn)
    espUpdateConnection = runService.Heartbeat:Connect(function()
        if espEnabled then
            local currentModels = {}
            for _, h in ipairs(espHighlights) do
                if h and h.Parent and h.Adornee and h.Adornee.Parent then
                    table.insert(currentModels, h.Adornee)
                    if not h.Parent or h.Parent ~= h.Adornee then
                        task.wait(0.1)
                        if espEnabled and h.Adornee and h.Adornee.Parent then
                            RemoveBuiltInHighlights(h.Adornee)
                            CreateESP(h.Adornee)
                        end
                    end
                end
            end
            for _, model in ipairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= character then
                    local has = false
                    for _, m in ipairs(currentModels) do
                        if m == model then
                            has = true
                            break
                        end
                    end
                    if not has then
                        RemoveBuiltInHighlights(model)
                        CreateESP(model)
                    end
                end
            end
        end
    end)
end

function DisableESP()
    espEnabled = false
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
        espUpdateConnection = nil
    end
    for _, conn in ipairs(espConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    espConnections = {}
    for _, h in ipairs(espHighlights) do
        if h and h.Parent then
            h:Destroy()
        end
    end
    espHighlights = {}
    for _, l in ipairs(espLabels) do
        if l and l.Parent then
            l:Destroy()
        end
    end
    espLabels = {}
end

-- ============================================================
-- ЗАГРУЗКА
-- ============================================================
task.wait(0.5)
myConfig:Load()

WindUI:Notify({
    Title = "Gamma Script",
    Content = "Animal Hospital загружен! ESP по атрибутам!",
    Duration = 4
})

print("Gamma Script запущен! 🚀")
