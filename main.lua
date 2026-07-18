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

-- ===== ПЕРЕМЕННЫЕ ДЛЯ АВТО DNA =====
local autoDNAEnabled = false
local autoDNAConnection = nil
local autoDNADelay = 0.5

-- ===== ПЕРЕМЕННЫЕ ДЛЯ МОНИТОРИНГА =====
local readyNotified = {}

-- ===== ОПРЕДЕЛЯЕМ ЭКЗЕКЬЮТОР =====
local executorName = "Unknown"
local executorStatus = "❗ НЕ ПРОВЕРЕННО"
local isSupported = false

local supportedExecutors = {
    "Solara",
    "Delta", 
    "Xeno",
    "Eclipse",
    "Madium"
}

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

for _, exec in ipairs(supportedExecutors) do
    if string.find(string.lower(executorName), string.lower(exec)) then
        isSupported = true
        executorStatus = "✅ ПОДДЕРЖИВАЕТСЯ"
        break
    end
end

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
-- ВКЛАДКА ГЛАВНАЯ
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
-- ВКЛАДКА АВТО
-- ============================================================
local AutoTab = Window:Tab({
    Title = "Авто",
    Icon = "bot",
    Border = true
})

AutoTab:Toggle({
    Title = "Авто взять DNA",
    Desc = "Телепортирует к ProximityPrompt с действием 'Take DNA Sample' и нажимает E",
    Flag = "AutoDNAFlag",
    Value = false,
    Callback = function(state)
        autoDNAEnabled = state
        if autoDNAEnabled then
            if autoDNAConnection then
                autoDNAConnection:Disconnect()
            end
            autoDNAConnection = runService.Heartbeat:Connect(function()
                if not autoDNAEnabled then
                    return
                end
                if not character or not character.PrimaryPart then
                    return
                end
                
                local charPos = character.PrimaryPart.Position
                local dnaPrompts = {}
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        local actionText = obj.ActionText or ""
                        local objectText = obj.ObjectText or ""
                        
                        local actionUpper = string.upper(actionText)
                        local objectUpper = string.upper(objectText)
                        
                        -- Проверяем наличие "DNA" в любом тексте
                        if string.find(objectUpper, "DNA") or 
                           string.find(actionUpper, "DNA") or
                           string.find(actionUpper, "TAKE DNA") then
                            
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                local distance = (charPos - parent.Position).Magnitude
                                table.insert(dnaPrompts, {
                                    Prompt = obj,
                                    Part = parent,
                                    Distance = distance
                                })
                            end
                        end
                    end
                end
                
                if #dnaPrompts > 0 then
                    table.sort(dnaPrompts, function(a, b)
                        return a.Distance < b.Distance
                    end)
                    
                    local target = dnaPrompts[1]
                    
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
                    
                    task.wait(autoDNADelay)
                end
            end)
        else
            if autoDNAConnection then
                autoDNAConnection:Disconnect()
                autoDNAConnection = nil
            end
        end
    end
})

AutoTab:Space()

AutoTab:Slider({
    Flag = "AutoDNADelayFlag",
    Title = "Задержка авто DNA",
    Desc = "Время между действиями (сек)",
    IsTooltip = true,
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 3,
        Default = 0.5
    },
    Callback = function(value)
        autoDNADelay = value
    end
})

AutoTab:Space()

AutoTab:Button({
    Title = "📌 Телепорт к DNA",
    Justify = "Center",
    Callback = function()
        if not character or not character.PrimaryPart then
            return
        end
        
        local charPos = character.PrimaryPart.Position
        local closestPrompt = nil
        local closestDistance = math.huge
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local actionText = obj.ActionText or ""
                local objectText = obj.ObjectText or ""
                
                local actionUpper = string.upper(actionText)
                local objectUpper = string.upper(objectText)
                
                if string.find(objectUpper, "DNA") or 
                   string.find(actionUpper, "DNA") or
                   string.find(actionUpper, "TAKE DNA") then
                    
                    local parent = obj.Parent
                    if parent and parent:IsA("BasePart") then
                        local distance = (charPos - parent.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPrompt = parent
                        end
                    end
                end
            end
        end
        
        if closestPrompt then
            character:SetPrimaryPartCFrame(
                CFrame.new(closestPrompt.Position + Vector3.new(0, 2, 0))
            )
            WindUI:Notify({
                Title = "Авто DNA",
                Content = "Телепорт к DNA!",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Авто DNA",
                Content = "DNA не найдено!",
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
    Desc = "Показывает имена моделей (маленький шрифт). Barney - коричневый ☕",
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
-- МОНИТОРИНГ НАДПИСИ "READY" (ВСЕГДА ВКЛЮЧЁН)
-- ============================================================
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local text = obj.Text or ""
                    local upperText = string.upper(text)
                    
                    if string.find(upperText, "READY") then
                        local objId = tostring(obj)
                        
                        if not readyNotified[objId] then
                            readyNotified[objId] = true
                            
                            WindUI:Notify({
                                Title = "☕ КОФЕ ГОТОВО!",
                                Content = "Забери кофе, пока не остыл!",
                                Duration = 5,
                                Icon = "coffee"
                            })
                            
                            print("[Mazami Hub] Кофе готов! Найдена надпись: " .. text)
                            
                            task.wait(30)
                            readyNotified[objId] = nil
                        end
                    end
                end
            end
        end)
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
    billboard.Size = UDim2.new(0, 150, 0, 30)
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
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
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

function IsBarney(model)
    if not model or not model.Name then
        return false
    end
    if string.find(string.upper(model.Name), "BARNEY") then
        return true
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
    local isBarney = IsBarney(model)
    
    local color = Color3.fromRGB(0, 255, 0)
    local labelText = model.Name or "Unknown"
    
    if isBarney then
        color = Color3.fromRGB(139, 69, 19)
        labelText = "☕ БАРНИ"  -- Убрал медведя
    elseif isPlayer then
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
