-- [ GAMMA SCRIPT ] Animal Hospital Anomaly | GUI поверх всех окон + OpenButton

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

-- ===== РЕГИСТРИРУЕМ РОЗОВУЮ ТЕМУ =====
WindUI:AddTheme({ 
    Name = "Pink", 
    Accent = Color3.fromRGB(255, 80, 200),
    Dialog = Color3.fromRGB(200, 40, 150),
    Outline = Color3.fromRGB(255, 180, 230),
    Text = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(255, 160, 220),
    Background = Color3.fromRGB(60, 10, 50),
    Button = Color3.fromRGB(230, 60, 180),
    Icon = Color3.fromRGB(255, 180, 230)
})

local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local virtualInput = game:GetService("VirtualInputManager")

-- ===== ПЕРЕМЕННЫЕ =====
local noclipEnabled = false
local noclipConnection = nil
local speedEnabled = false
local speedValue = 50
local originalWalkspeed = 16
local infiniteJumpEnabled = false
local jumpConnection = nil

local instantPromptsEnabled = false
local instantPromptConnections = {}

local espEnabled = false
local espConnections = {}
local espHighlights = {}
local espLabels = {}
local espUpdateConnection = nil

-- ===== ОКНО С КНОПКОЙ ДЛЯ ОТКРЫТИЯ =====
local Window = WindUI:CreateWindow({
    Title = "Animal Hospital Anomaly",
    Author = "Gamma System",
    Folder = "Gamma_AnimalHospital",
    Icon = "cat",
    Size = UDim2.fromOffset(600, 550),
    Resizable = true,
    Theme = "Pink",
    Transparent = true,
    AlwaysOnTop = true,  -- GUI поверх всех окон
    ToggleKey = Enum.KeyCode.RightShift,  -- можно открывать/закрывать через RightShift
    
    -- ===== КНОПКА ДЛЯ ОТКРЫТИЯ GUI =====
    OpenButton = {
        Title = "🐾 Gamma Script",  -- название на кнопке
        Icon = "cat",  -- иконка
        Enabled = true,  -- включена
        Draggable = true,  -- можно перетаскивать
        Scale = 0.6,  -- размер кнопки
        OnlyMobile = false,  -- работает и на ПК
        Color = ColorSequence.new(  -- градиент
            Color3.fromHex("#FF1493"),  -- ярко-розовый
            Color3.fromHex("#8A2BE2")   -- фиолетовый
        ),
        CornerRadius = UDim.new(0, 12),  -- скруглённые углы
        StrokeThickness = 2,  -- обводка
    },
    
    Background = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#1a0a2e"), Transparency = 0.3 },
        ["50"] = { Color = Color3.fromHex("#4a1a6b"), Transparency = 0.3 },
        ["100"] = { Color = Color3.fromHex("#ff1493"), Transparency = 0.3 }
    }, {
        Rotation = 45
    })
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
    Flag = "SpeedValueFlag",
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
-- ВКЛАДКА VISUALS
-- ============================================================
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
    Border = true
})

VisualsTab:Toggle({
    Title = "ESP для пациентов",
    Desc = "Показывает имена моделей (маленький шрифт)",
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

SettingsTab:Button({
    Title = "🔄 Перезагрузить скрипт",
    Justify = "Center",
    Callback = function()
        DisableESP()
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
        for _, conn in ipairs(instantPromptConnections) do
            if conn then
                conn:Disconnect()
            end
        end
        Window:Destroy()
    end
})

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
    billboard.Size = UDim2.new(0, 100, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 0.4
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = billboard
    
    table.insert(espLabels, billboard)
    return billboard
end

function IsAnomaly(model)
    if not model or not model.PrimaryPart then
        return false
    end
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then
        return false
    end
    
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
    local isAnomaly = IsAnomaly(model)
    
    local color = Color3.fromRGB(0, 255, 0)
    local labelText = model.Name or "Unknown"
    
    if isPlayer then
        color = Color3.fromRGB(255, 255, 255)
        labelText = model.Name or "Player"
    elseif isAnomaly then
        color = Color3.fromRGB(255, 0, 0)
        labelText = model.Name or "Anomaly"
    else
        color = Color3.fromRGB(0, 255, 0)
        labelText = model.Name or "Normal"
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GammaESP"
    highlight.Adornee = model
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    table.insert(espHighlights, highlight)
    
    CreateLabel(model, labelText, color)
    
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

WindUI:Notify({
    Title = "Gamma Script",
    Content = "Animal Hospital загружен! 💗",
    Duration = 4
})

print("Gamma Script запущен!")
