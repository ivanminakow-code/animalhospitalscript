-- [ MAZAMI HUB ] Animal Hospital Anomaly | BLUE THEME + GUI ON TOP OF ALL WINDOWS

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
player.CameraMaxZoomDistance = 99999
player.CameraMode = Enum.CameraMode.Classic

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    error("Failed to load WindUI")
end

-- ===== REGISTER BLUE THEME =====
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

-- ===== VARIABLES =====
local noclipEnabled = false
local noclipConnection = nil
local speedEnabled = false
local speedValue = 50
local originalWalkspeed = 16
local infiniteJumpEnabled = false
local jumpConnection = nil

local instantPromptsEnabled = false
local instantPromptConnections = {}
local instantPromptLoopConnection = nil

local espEnabled = false
local espConnections = {}
local espHighlights = {}
local espLabels = {}
local espUpdateConnection = nil

-- ===== TRACERS VARIABLES =====
local tracersEnabled = false
local tracersConnection = nil
local tracersObjects = {}

-- ===== AUTO VARIABLES =====
local autoDNAEnabled = false
local autoDNAConnection = nil
local autoDNADelay = 0.5

local autoCoffeeEnabled = false
local autoCoffeeConnection = nil
local autoCoffeeDelay = 0.5

local autoTaserEnabled = false
local autoTaserConnection = nil
local autoTaserDelay = 0.5

-- ===== MONITORING VARIABLES =====
local readyNotified = {}
local taserNotified = {}

-- ===== DETECT EXECUTOR =====
local executorName = "Unknown"
local executorStatus = "❗ NOT VERIFIED"
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
        executorStatus = "✅ SUPPORTED"
        break
    end
end

if not isSupported then
    executorStatus = "❗ NOT VERIFIED"
end

-- ===== WINDOW WITH OPEN BUTTON =====
local Window = WindUI:CreateWindow({
    Title = "Mazami Hub",
    Author = "ivanmartiz2013",
    Folder = "Mazami_Hub",
    Icon = "cat",
    Size = UDim2.fromOffset(650, 600),
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

-- ===== VERSION TAG (1.0) =====
Window:Tag({
    Title = "v1.0",
    Icon = "code",
    Color = Color3.fromHex("#1E90FF"),
    Border = true
})

-- ============================================================
-- HOME TAB
-- ============================================================
local MainTab = Window:Tab({
    Title = "Home",
    Icon = "house",
    Border = true
})

MainTab:Button({
    Title = "📌 Executor: " .. executorName,
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
-- PLAYER TAB
-- ============================================================
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user",
    Border = true
})

PlayerTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
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
    Desc = "Movement speed",
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
    Title = "Enable Speed Hack",
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
    Desc = "Unlimited jumps",
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

-- ============================================================
-- INSTANT PROXIMITYPROMPTS (UPDATE EVERY 0.5 SEC)
-- ============================================================
function SetAllPromptsInstant()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
        end
    end
end

PlayerTab:Toggle({
    Title = "Instant ProximityPrompts",
    Desc = "HoldDuration = 0 (updates every 0.5 sec)",
    Flag = "InstantPromptsFlag",
    Value = false,
    Callback = function(state)
        instantPromptsEnabled = state
        if instantPromptsEnabled then
            SetAllPromptsInstant()
            
            if instantPromptLoopConnection then
                instantPromptLoopConnection:Disconnect()
                instantPromptLoopConnection = nil
            end
            
            instantPromptLoopConnection = runService.Heartbeat:Connect(function()
                if instantPromptsEnabled then
                    SetAllPromptsInstant()
                end
            end)
            
            local conn = workspace.DescendantAdded:Connect(function(d)
                if instantPromptsEnabled and d:IsA("ProximityPrompt") then
                    d.HoldDuration = 0
                end
            end)
            table.insert(instantPromptConnections, conn)
            
        else
            if instantPromptLoopConnection then
                instantPromptLoopConnection:Disconnect()
                instantPromptLoopConnection = nil
            end
            
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
-- AUTO TAB
-- ============================================================
local AutoTab = Window:Tab({
    Title = "Auto",
    Icon = "bot",
    Border = true
})

-- ---- AUTO DNA ----
AutoTab:Toggle({
    Title = "Auto Take DNA",
    Desc = "Teleports to ProximityPrompt with 'Take DNA Sample' and presses E",
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
                        local combinedText = (actionText .. " " .. objectText):upper()
                        
                        if string.find(combinedText, "TAKE DNA SAMPLE") or 
                           string.find(combinedText, "TAKE DNA") or
                           string.find(combinedText, "DNA SAMPLE") or
                           string.find(combinedText, "DNA") then
                            
                            local parent = obj.Parent
                            local targetPart = nil
                            if parent then
                                if parent:IsA("BasePart") then
                                    targetPart = parent
                                elseif parent:IsA("Model") then
                                    if parent.PrimaryPart then
                                        targetPart = parent.PrimaryPart
                                    else
                                        for _, child in ipairs(parent:GetChildren()) do
                                            if child:IsA("BasePart") then
                                                targetPart = child
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if targetPart then
                                local distance = (charPos - targetPart.Position).Magnitude
                                table.insert(dnaPrompts, {
                                    Prompt = obj,
                                    Part = targetPart,
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
    Title = "Auto DNA Delay",
    Desc = "Time between actions (sec)",
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

-- ---- AUTO COFFEE ----
AutoTab:Toggle({
    Title = "Auto Coffee",
    Desc = "Teleports to 'Coffee: Ready' text and takes coffee",
    Flag = "AutoCoffeeFlag",
    Value = false,
    Callback = function(state)
        autoCoffeeEnabled = state
        if autoCoffeeEnabled then
            if autoCoffeeConnection then
                autoCoffeeConnection:Disconnect()
            end
            autoCoffeeConnection = runService.Heartbeat:Connect(function()
                if not autoCoffeeEnabled then
                    return
                end
                if not character or not character.PrimaryPart then
                    return
                end
                
                local charPos = character.PrimaryPart.Position
                local coffeeObjects = {}
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local text = obj.Text or ""
                        if string.find(string.upper(text), "COFFEE: READY") or 
                           (string.find(string.upper(text), "READY") and string.find(string.upper(obj.Parent and obj.Parent.Name or ""), "COFFEE")) then
                            local parent = obj.Parent
                            local targetPart = nil
                            
                            if parent then
                                if parent:IsA("BasePart") then
                                    targetPart = parent
                                elseif parent:IsA("Model") then
                                    if parent.PrimaryPart then
                                        targetPart = parent.PrimaryPart
                                    else
                                        for _, child in ipairs(parent:GetChildren()) do
                                            if child:IsA("BasePart") then
                                                targetPart = child
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if targetPart then
                                local distance = (charPos - targetPart.Position).Magnitude
                                table.insert(coffeeObjects, {
                                    Part = targetPart,
                                    Distance = distance
                                })
                            end
                        end
                    end
                end
                
                if #coffeeObjects > 0 then
                    table.sort(coffeeObjects, function(a, b)
                        return a.Distance < b.Distance
                    end)
                    
                    local target = coffeeObjects[1]
                    
                    if target.Distance > 3 then
                        character:SetPrimaryPartCFrame(
                            CFrame.new(target.Part.Position + Vector3.new(0, 2, 0))
                        )
                        task.wait(0.05)
                    end
                    
                    virtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    virtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    
                    task.wait(autoCoffeeDelay)
                end
            end)
        else
            if autoCoffeeConnection then
                autoCoffeeConnection:Disconnect()
                autoCoffeeConnection = nil
            end
        end
    end
})

AutoTab:Space()

AutoTab:Slider({
    Flag = "AutoCoffeeDelayFlag",
    Title = "Auto Coffee Delay",
    Desc = "Time between actions (sec)",
    IsTooltip = true,
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 3,
        Default = 0.5
    },
    Callback = function(value)
        autoCoffeeDelay = value
    end
})

AutoTab:Space()

-- ---- AUTO TASER ----
AutoTab:Toggle({
    Title = "Auto Taser",
    Desc = "Teleports to 'Taser: Ready' text and takes taser",
    Flag = "AutoTaserFlag",
    Value = false,
    Callback = function(state)
        autoTaserEnabled = state
        if autoTaserEnabled then
            if autoTaserConnection then
                autoTaserConnection:Disconnect()
            end
            autoTaserConnection = runService.Heartbeat:Connect(function()
                if not autoTaserEnabled then
                    return
                end
                if not character or not character.PrimaryPart then
                    return
                end
                
                local charPos = character.PrimaryPart.Position
                local taserObjects = {}
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local text = obj.Text or ""
                        if string.find(string.upper(text), "TASER: READY") or 
                           (string.find(string.upper(text), "READY") and string.find(string.upper(obj.Parent and obj.Parent.Name or ""), "TASER")) then
                            local parent = obj.Parent
                            local targetPart = nil
                            
                            if parent then
                                if parent:IsA("BasePart") then
                                    targetPart = parent
                                elseif parent:IsA("Model") then
                                    if parent.PrimaryPart then
                                        targetPart = parent.PrimaryPart
                                    else
                                        for _, child in ipairs(parent:GetChildren()) do
                                            if child:IsA("BasePart") then
                                                targetPart = child
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if targetPart then
                                local distance = (charPos - targetPart.Position).Magnitude
                                table.insert(taserObjects, {
                                    Part = targetPart,
                                    Distance = distance
                                })
                            end
                        end
                    end
                end
                
                if #taserObjects > 0 then
                    table.sort(taserObjects, function(a, b)
                        return a.Distance < b.Distance
                    end)
                    
                    local target = taserObjects[1]
                    
                    if target.Distance > 3 then
                        character:SetPrimaryPartCFrame(
                            CFrame.new(target.Part.Position + Vector3.new(0, 2, 0))
                        )
                        task.wait(0.05)
                    end
                    
                    virtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    virtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    
                    task.wait(autoTaserDelay)
                end
            end)
        else
            if autoTaserConnection then
                autoTaserConnection:Disconnect()
                autoTaserConnection = nil
            end
        end
    end
})

AutoTab:Space()

AutoTab:Slider({
    Flag = "AutoTaserDelayFlag",
    Title = "Auto Taser Delay",
    Desc = "Time between actions (sec)",
    IsTooltip = true,
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 3,
        Default = 0.5
    },
    Callback = function(value)
        autoTaserDelay = value
    end
})

-- ============================================================
-- VISUALS TAB
-- ============================================================
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
    Border = true
})

-- ---- MAIN ESP ----
VisualsTab:Toggle({
    Title = "ESP for Patients",
    Desc = "Shows model names. Barney - brown ☕",
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

-- ---- TRACERS ----
VisualsTab:Toggle({
    Title = "Tracers (lines to objects)",
    Desc = "Draws lines from screen bottom to highlighted objects",
    Flag = "TracersFlag",
    Value = false,
    Callback = function(state)
        tracersEnabled = state
        if tracersEnabled then
            if tracersConnection then
                tracersConnection:Disconnect()
            end
            tracersConnection = runService.RenderStepped:Connect(function()
                if tracersEnabled then
                    DrawTracers()
                end
            end)
        else
            if tracersConnection then
                tracersConnection:Disconnect()
                tracersConnection = nil
            end
            ClearTracers()
        end
    end
})

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
    Border = true
})

SettingsTab:Slider({
    Flag = "TransparencyFlag",
    Title = "GUI Transparency",
    Desc = "Adjust window transparency",
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
-- MONITORING "READY" TEXT (Coffee: Ready, Taser: Ready)
-- ============================================================
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local text = obj.Text or ""
                    local upperText = string.upper(text)
                    local objId = tostring(obj)
                    
                    -- Check if "READY" exists
                    if string.find(upperText, "READY") then
                        local parent = obj.Parent
                        local parentName = ""
                        if parent then
                            parentName = parent.Name or ""
                        end
                        
                        local isCoffee = string.find(string.upper(parentName), "COFFEE") or 
                                        string.find(string.upper(text), "COFFEE")
                        local isTaser = string.find(string.upper(parentName), "TASER") or 
                                       string.find(string.upper(text), "TASER")
                        
                        -- Coffee notification
                        if isCoffee then
                            if not readyNotified[objId] then
                                readyNotified[objId] = true
                                WindUI:Notify({
                                    Title = "☕ COFFEE READY!",
                                    Content = "Take the coffee before it gets cold!",
                                    Duration = 5,
                                    Icon = "coffee"
                                })
                                print("[Mazami Hub] Coffee: Ready! Found text: " .. text)
                                task.wait(30)
                                readyNotified[objId] = nil
                            end
                        end
                        
                        -- Taser notification
                        if isTaser then
                            if not taserNotified[objId] then
                                taserNotified[objId] = true
                                WindUI:Notify({
                                    Title = "⚡ TASER READY!",
                                    Content = "Taser is charged and ready to use!",
                                    Duration = 5,
                                    Icon = "bolt"
                                })
                                print("[Mazami Hub] Taser: Ready! Found text: " .. text)
                                task.wait(30)
                                taserNotified[objId] = nil
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- TRACERS FUNCTIONS
-- ============================================================
function DrawTracers()
    local viewportSize = camera.ViewportSize
    local screenBottom = Vector2.new(viewportSize.X / 2, viewportSize.Y)
    
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= character then
            local highlight = model:FindFirstChild("GammaESP")
            if highlight then
                local primaryPart = model.PrimaryPart or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                if primaryPart then
                    local pos, onScreen = camera:WorldToViewportPoint(primaryPart.Position)
                    if onScreen then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local color = highlight.FillColor
                        
                        local tracer = nil
                        for _, obj in ipairs(tracersObjects) do
                            if obj.Model == model then
                                tracer = obj
                                break
                            end
                        end
                        
                        if not tracer then
                            tracer = {
                                Model = model,
                                Line = Drawing.new("Line")
                            }
                            tracer.Line.Color = color
                            tracer.Line.Thickness = 1
                            tracer.Line.Transparency = 1
                            table.insert(tracersObjects, tracer)
                        end
                        
                        tracer.Line.From = screenBottom
                        tracer.Line.To = screenPos
                        tracer.Line.Color = color
                        tracer.Line.Visible = true
                    end
                end
            end
        end
    end
    
    for i = #tracersObjects, 1, -1 do
        local tracer = tracersObjects[i]
        if not tracer.Model or not tracer.Model:FindFirstChild("GammaESP") or not tracer.Model.Parent then
            tracer.Line.Visible = false
            table.remove(tracersObjects, i)
        end
    end
end

function ClearTracers()
    for _, tracer in ipairs(tracersObjects) do
        if tracer.Line then
            tracer.Line:Remove()
        end
    end
    tracersObjects = {}
end

-- ============================================================
-- ESP FUNCTIONS
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
        labelText = "☕ BARNEY"
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
-- LOAD
-- ============================================================
task.wait(0.5)

WindUI:Notify({
    Title = "Mazami Hub",
    Content = "Animal Hospital loaded! Blue theme 💙",
    Duration = 4
})

print("Mazami Hub started! Executor: " .. executorName)
