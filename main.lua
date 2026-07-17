-- [ MAZAMI HUB ] Animal Hospital Anomaly | СИНЯЯ тема + GUI поверх всех окон

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

-- ===== РЕГИСТРИРУЕМ СИНЮЮ ТЕМУ =====
WindUI:AddTheme({ 
    Name = "Blue", 
    Accent = Color3.fromRGB(30, 144, 255),
    Dialog = Color3.fromRGB(0, 70, 180),
    Outline = Color3.fromRGB(100, 180, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(150, 200, 255),
    Background = Color3.fromRGB(10, 30, 70),
    Button = Color3.fromRGB(0, 100, 220),
    Icon = Color3.fromRGB(100, 180, 255)
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

-- ===== ОПРЕДЕЛЯЕМ ЭКЗЕКЬЮТОР =====
local executorName = "Unknown"
local executorStatus = "❗ НЕ ПРОВЕРЕННО"
local isSupported = false

-- Список поддерживаемых экзекьюторов
local supportedExecutors = {
    "Solara",
    "Delta", 
    "Xeno",
    "Eclipse",
    "Madium"
}

-- Пытаемся определить экзекьютор через стандартные функции
local function getExecutorName()
    local name = ""
    local success, result = pcall(function()
        if identifyexecutor then
            name = identifyexecutor()
        elseif getexecutorname then
            name = getexecutorname()
        elseif syn and syn.version then
            name = "Synapse X"
        elseif isfolder and isfile then
            name = "ScriptWare"
        elseif isexecutorenv and isexecutorenv() then
            name = "KRNL"
        end
        return name
    end)
    
    if success and result and result ~= "" then
        return result
    end
    return "Unknown"
end

executorName = getExecutorName()

-- Проверяем, поддерживается ли экзекьютор
for _, exec in ipairs(supportedExecutors) do
    if string.find(string.lower(executorName), string.lower(exec)) then
        isSupported = true
        executorStatus = "✅ ПОДДЕРЖИВАЕТСЯ"
        break
    end
end

-- Если не нашли в списке - помечаем как непроверенный
if not isSupported then
    executorStatus = "❗ НЕ ПРОВЕРЕННО"
end

-- ===== ОКНО С КНОПКОЙ ДЛЯ ОТКРЫТИЯ =====
local Window = WindUI:CreateWindow({
    Title = "Mazami Hub",
    Author = "ivanmartiz2013",
    Folder = "Mazami_Hub",
    Icon = "cat",
    Size = UDim2.fromOffset(600, 550),
    Resizable = true,
    Theme = "Blue",
    Transparent = true,
    AlwaysOnTop = true,
    ToggleKey = Enum.KeyCode.RightShift,
    
    OpenButton = {
        Title = "🔵 Mazami Hub",
        Icon = "cat",
        Enabled = true,
        Draggable = true,
        Scale = 0.6,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("#1E90FF"),
            Color3.fromHex("#0066CC")
        ),
        CornerRadius = UDim.new(0, 12),
        StrokeThickness = 2,
    },
    
    Background = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#0a1628"), Transparency = 0.3 },
        ["50"] = { Color = Color3.fromHex("#1a3a6b"), Transparency = 0.3 },
        ["100"] = { Color = Color3.fromHex("#1E90FF"), Transparency = 0.3 }
    }, {
        Rotation = 45
    })
})

-- ===== ТЭГ С ВЕРСИЕЙ (1.0) =====
Window:Tag({
    Title = "v1.0",
    Icon = "code",
    Color = Color3.fromHex("#1E90FF"),
    Border = true
})

-- ============================================================
-- ВКЛАДКА ГЛАВНАЯ (ОТКРЫВАЕТСЯ ПО УМОЛЧАНИЮ)
-- ============================================================
local MainTab = Window:Tab({
    Title = "Главная",
    Icon = "house",
    Border = true
})

MainTab:Button({
    Title = "📌 Экзекьютор: " .. executorName,
    Justify = "Center",
    Callback = function()
    end
})

MainTab:Space()

MainTab:Button({
    Title = executorStatus,
    Justify = "Center",
    Callback = function()
    end
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
-- ВКЛАДКА НАСТРОЙКИ (ТОЛЬКО ПРОЗРАЧНОСТЬ)
-- ============================================================
local SettingsTab = Window:Tab({
    Title = "Настройки",
    Icon = "settings",
    Border = true
})

SettingsTab:Slider({
    Flag = "TransparencyFlag",
    Title = "Прозрачность GUI",
    Desc = "Регулировка прозрачности окна",
    IsTooltip = true,
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 1,
        Default = 0
    },
    Callback = function(value)
        Window:SetBackgroundTransparency(value)
        local frame = Window.Frame
        if frame then
            frame.BackgroundTransparency = value
        end
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
    Title = "Mazami Hub",
    Content = "Animal Hospital загружен! Синяя тема 💙",
    Duration = 4
})

print("Mazami Hub запущен! Исполнитель: " .. executorName)
