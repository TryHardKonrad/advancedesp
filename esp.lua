local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local boxes = {}
local healthbars = {}
local healthbarBorders = {}
local names = {}
local distances = {}
local tracers = {}
local skeletons = {}
local maxDistance = 2500
local updateInterval = 0.1

-- Stałe kolory
local BOX_COLOR = Color3.fromRGB(0, 255, 0)
local LOCAL_BOX_COLOR = Color3.fromRGB(0, 0, 255)
local TRACER_COLOR = Color3.fromRGB(255, 255, 255)
local HEALTHBAR_COLOR = Color3.fromRGB(255, 0, 0)
local SKELETON_COLOR = Color3.fromRGB(255, 255, 255)
local LOCAL_SKELETON_COLOR = Color3.fromRGB(0, 0, 255)

-- Tekst liczby widocznych graczy
local visiblePlayersText = Drawing.new("Text")
visiblePlayersText.Visible = true
visiblePlayersText.Color = Color3.fromRGB(255, 255, 255)
visiblePlayersText.Size = 16
visiblePlayersText.Position = Vector2.new(10, 10)
visiblePlayersText.Center = false
visiblePlayersText.Outline = true
visiblePlayersText.OutlineColor = Color3.fromRGB(0, 0, 0)
visiblePlayersText.Font = 1
visiblePlayersText.Text = "Visible Players: 0"

-- Ustawienia GUI
local guiEnabled = true
local guiElements = {}
local toggles = {
    boxes = true,
    healthbars = true,
    names = true,
    distances = true,
    tracers = true,
    skeletons = true
}

-- Funkcja tworzenia GUI
local function createGUI()
    local background = Drawing.new("Square")
    background.Visible = guiEnabled
    background.Filled = true
    background.Color = Color3.fromRGB(20, 20, 20)
    background.Transparency = 0.3
    background.Position = Vector2.new(10, 50)
    background.Size = Vector2.new(200, 180)
    guiElements.background = background

    local title = Drawing.new("Text")
    title.Visible = guiEnabled
    title.Color = Color3.fromRGB(255, 255, 255)
    title.Size = 18
    title.Position = Vector2.new(20, 60)
    title.Text = "ESP Settings"
    title.Outline = true
    guiElements.title = title

    local options = {"Boxes", "Healthbars", "Names", "Distances", "Tracers", "Skeletons"}
    for i, option in ipairs(options) do
        local text = Drawing.new("Text")
        text.Visible = guiEnabled
        text.Color = Color3.fromRGB(255, 255, 255)
        text.Size = 16
        text.Position = Vector2.new(20, 80 + (i-1) * 20)
        text.Text = option .. ": ON"
        text.Outline = true
        guiElements[option:lower()] = text
    end
end

-- Informacja o uruchomieniu
print("Skrypt ESP został uruchomiony! Naciśnij 'P' aby wyłączyć ESP, 'G' aby przełączyć GUI.")
print("Wersja 1.0.9")

-- Funkcja określająca typ modelu (R6 lub R15)
local function getSkeletonParts(model)
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then return nil end

    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        return {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"UpperTorso", "RightUpperArm"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LowerTorso", "RightUpperLeg"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"RightUpperLeg", "RightLowerLeg"}
        }
    else -- R6
        return {
            {"Head", "Torso"},
            {"Torso", "Left Arm"},
            {"Torso", "Right Arm"},
            {"Torso", "Left Leg"},
            {"Torso", "Right Leg"}
        }
    end
end

-- Inicjalizacja ESP
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Humanoid") then
        local model = obj.Parent
        local player = Players:GetPlayerFromCharacter(model)
        local nickname = player and player.Name or "NPC"
        local isLocalPlayer = (model == LocalPlayer.Character)

        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = isLocalPlayer and LOCAL_BOX_COLOR or BOX_COLOR
        boxes[model] = box

        local healthbar = Drawing.new("Square")
        healthbar.Visible = false
        healthbar.Thickness = 1
        healthbar.Filled = true
        healthbar.Transparency = 0.7
        healthbar.Color = HEALTHBAR_COLOR
        healthbars[model] = healthbar

        local healthbarBorder = Drawing.new("Square")
        healthbarBorder.Visible = false
        healthbarBorder.Thickness = 1
        healthbarBorder.Filled = false
        healthbarBorder.Transparency = 1
        healthbarBorder.Color = Color3.fromRGB(255, 255, 255)
        healthbarBorders[model] = healthbarBorder

        local name = Drawing.new("Text")
        name.Visible = false
        name.Color = Color3.fromRGB(255, 255, 255)
        name.Size = 14
        name.Center = true
        name.Outline = true
        name.OutlineColor = Color3.fromRGB(0, 0, 0)
        name.Font = 1
        name.Text = nickname
        names[model] = name

        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Color = Color3.fromRGB(255, 255, 255)
        distance.Size = 12
        distance.Center = true
        distance.Outline = true
        distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        distance.Font = 1
        distances[model] = distance

        if not isLocalPlayer then
            local tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Thickness = 1
            tracer.Transparency = 0.5
            tracer.Color = TRACER_COLOR
            tracers[model] = tracer
        end

        local skeletonLines = {}
        local skeletonParts = getSkeletonParts(model)
        if skeletonParts then
            for _, pair in ipairs(skeletonParts) do
                local line = Drawing.new("Line")
                line.Visible = false
                line.Thickness = 1
                line.Transparency = 0.8
                line.Color = isLocalPlayer and LOCAL_SKELETON_COLOR or SKELETON_COLOR
                skeletonLines[pair[1] .. "-" .. pair[2]] = line
            end
            skeletons[model] = skeletonLines
        end
    end
end

-- Główna pętla aktualizacji
local espConnection
espConnection = RunService.RenderStepped:Connect(function()
    task.wait(updateInterval)
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local localPos = localRoot and localRoot.Position
    local localScreenPos = localPos and Workspace.CurrentCamera:WorldToViewportPoint(localPos)
    local camera = Workspace.CurrentCamera
    local visibleCount = 0

    for model, box in pairs(boxes) do
        if model and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Humanoid") and localPos and localScreenPos then
            local hrp = model.HumanoidRootPart
            local humanoid = model.Humanoid
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            local studDistance = math.floor((localPos - hrp.Position).Magnitude)
            local isLocalPlayer = (model == LocalPlayer.Character)

            local cameraCFrame = camera.CFrame
            local vectorToPlayer = (hrp.Position - cameraCFrame.Position).Unit
            local cameraLookVector = cameraCFrame.LookVector
            local dotProduct = vectorToPlayer:Dot(cameraLookVector)
            local isInFront = dotProduct > 0

            local player = Players:GetPlayerFromCharacter(model)
            local nickname = player and player.Name or "NPC"
            names[model].Text = nickname

            if studDistance <= maxDistance and onScreen and isInFront then
                visibleCount = visibleCount + 1
                
                if toggles.boxes then
                    box.Position = Vector2.new(pos.X - 20, pos.Y - 40)
                    box.Size = Vector2.new(40, 80)
                    box.Visible = true
                else
                    box.Visible = false
                end

                if toggles.healthbars then
                    local healthbar = healthbars[model]
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthHeight = 80 * healthPercent
                    healthbar.Size = Vector2.new(5, healthHeight)
                    healthbar.Position = Vector2.new(pos.X - 35, pos.Y - 40 + (80 - healthHeight))
                    healthbar.Visible = true
                    healthbar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)

                    local healthbarBorder = healthbarBorders[model]
                    healthbarBorder.Size = Vector2.new(7, 82)
                    healthbarBorder.Position = Vector2.new(pos.X - 36, pos.Y - 41)
                    healthbarBorder.Visible = true
                else
                    healthbars[model].Visible = false
                    healthbarBorders[model].Visible = false
                end

                if toggles.names then
                    local name = names[model]
                    name.Position = Vector2.new(pos.X, pos.Y - 45)
                    name.Visible = true
                else
                    names[model].Visible = false
                end

                if toggles.distances and not isLocalPlayer then
                    local distance = distances[model]
                    distance.Text = studDistance .. " studs"
                    distance.Position = Vector2.new(pos.X, pos.Y + 45)
                    distance.Visible = true
                else
                    distances[model].Visible = false
                end

                if toggles.tracers and tracers[model] then
                    local tracer = tracers[model]
                    tracer.From = Vector2.new(localScreenPos.X, localScreenPos.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Visible = true
                elseif tracers[model] then
                    tracers[model].Visible = false
                end

                if toggles.skeletons and skeletons[model] then
                    local skeletonLines = skeletons[model]
                    for name, line in pairs(skeletonLines) do
                        local part1Name, part2Name = name:match("(.+)-(.+)")
                        local part1 = model:FindFirstChild(part1Name)
                        local part2 = model:FindFirstChild(part2Name)
                        if part1 and part2 then
                            local pos1 = camera:WorldToViewportPoint(part1.Position)
                            local pos2 = camera:WorldToViewportPoint(part2.Position)
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    end
                elseif skeletons[model] then
                    for _, line in pairs(skeletons[model]) do
                        line.Visible = false
                    end
                end
            else
                box.Visible = false
                healthbars[model].Visible = false
                healthbarBorders[model].Visible = false
                names[model].Visible = false
                distances[model].Visible = false
                if tracers[model] then tracers[model].Visible = false end
                if skeletons[model] then
                    for _, line in pairs(skeletons[model]) do
                        line.Visible = false
                    end
                end
            end
        else
            box.Visible = false
            healthbars[model].Visible = false
            healthbarBorders[model].Visible = false
            names[model].Visible = false
            distances[model].Visible = false
            if tracers[model] then tracers[model].Visible = false end
            if skeletons[model] then
                for _, line in pairs(skeletons[model]) do
                    line.Visible = false
                end
            end
        end
    end
    
    visiblePlayersText.Text = "Visible Players: " .. visibleCount
end)

-- Obsługa nowych humanoidów
local descendantAddedConnection
descendantAddedConnection = Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Humanoid") then
        local model = obj.Parent
        local player = Players:GetPlayerFromCharacter(model)
        local nickname = player and player.Name or "NPC"
        local isLocalPlayer = (model == LocalPlayer.Character)

        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = isLocalPlayer and LOCAL_BOX_COLOR or BOX_COLOR
        boxes[model] = box

        local healthbar = Drawing.new("Square")
        healthbar.Visible = false
        healthbar.Thickness = 1
        healthbar.Filled = true
        healthbar.Transparency = 0.7
        healthbar.Color = HEALTHBAR_COLOR
        healthbars[model] = healthbar

        local healthbarBorder = Drawing.new("Square")
        healthbarBorder.Visible = false
        healthbarBorder.Thickness = 1
        healthbarBorder.Filled = false
        healthbarBorder.Transparency = 1
        healthbarBorder.Color = Color3.fromRGB(255, 255, 255)
        healthbarBorders[model] = healthbarBorder

        local name = Drawing.new("Text")
        name.Visible = false
        name.Color = Color3.fromRGB(255, 255, 255)
        name.Size = 14
        name.Center = true
        name.Outline = true
        name.OutlineColor = Color3.fromRGB(0, 0, 0)
        name.Font = 1
        name.Text = nickname
        names[model] = name

        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Color = Color3.fromRGB(255, 255, 255)
        distance.Size = 12
        distance.Center = true
        distance.Outline = true
        distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        distance.Font = 1
        distances[model] = distance

        if not isLocalPlayer then
            local tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Thickness = 1
            tracer.Transparency = 0.5
            tracer.Color = TRACER_COLOR
            tracers[model] = tracer
        end

        local skeletonLines = {}
        local skeletonParts = getSkeletonParts(model)
        if skeletonParts then
            for _, pair in ipairs(skeletonParts) do
                local line = Drawing.new("Line")
                line.Visible = false
                line.Thickness = 1
                line.Transparency = 0.8
                line.Color = isLocalPlayer and LOCAL_SKELETON_COLOR or SKELETON_COLOR
                skeletonLines[pair[1] .. "-" .. pair[2]] = line
            end
            skeletons[model] = skeletonLines
        end
    end
end)

-- Czyszczenie po zniszczeniu modelu
local descendantRemovingConnection
descendantRemovingConnection = Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Humanoid") and boxes[obj.Parent] then
        boxes[obj.Parent]:Remove()
        healthbars[obj.Parent]:Remove()
        healthbarBorders[obj.Parent]:Remove()
        names[obj.Parent]:Remove()
        distances[obj.Parent]:Remove()
        if tracers[obj.Parent] then tracers[obj.Parent]:Remove() end
        if skeletons[obj.Parent] then
            for _, line in pairs(skeletons[obj.Parent]) do
                line:Remove()
            end
            skeletons[obj.Parent] = nil
        end

        boxes[obj.Parent] = nil
        healthbars[obj.Parent] = nil
        healthbarBorders[obj.Parent] = nil
        names[obj.Parent] = nil
        distances[obj.Parent] = nil
        tracers[obj.Parent] = nil
    end
end)

-- Funkcja niszcząca ESP
local function destroyESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    if descendantAddedConnection then
        descendantAddedConnection:Disconnect()
        descendantAddedConnection = nil
    end
    if descendantRemovingConnection then
        descendantRemovingConnection:Disconnect()
        descendantRemovingConnection = nil
    end

    for model, box in pairs(boxes) do
        box:Remove()
        healthbars[model]:Remove()
        healthbarBorders[model]:Remove()
        names[model]:Remove()
        distances[model]:Remove()
        if tracers[model] then tracers[model]:Remove() end
        if skeletons[model] then
            for _, line in pairs(skeletons[model]) do
                line:Remove()
            end
        end
    end

    visiblePlayersText:Remove()
    for _, element in pairs(guiElements) do
        element:Remove()
    end

    boxes = {}
    healthbars = {}
    healthbarBorders = {}
    names = {}
    distances = {}
    tracers = {}
    skeletons = {}
    guiElements = {}

    print("ESP zostało zniszczone!")
end

-- Inicjalizacja GUI
createGUI()

-- Obsługa wejścia
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        destroyESP()
    elseif input.KeyCode == Enum.KeyCode.G then
        guiEnabled = not guiEnabled
        for _, element in pairs(guiElements) do
            element.Visible = guiEnabled
        end
    elseif input.KeyCode == Enum.KeyCode.F1 then
        toggles.boxes = not toggles.boxes
        guiElements.boxes.Text = "Boxes: " .. (toggles.boxes and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggles.healthbars = not toggles.healthbars
        guiElements.healthbars.Text = "Healthbars: " .. (toggles.healthbars and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F3 then
        toggles.names = not toggles.names
        guiElements.names.Text = "Names: " .. (toggles.names and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggles.distances = not toggles.distances
        guiElements.distances.Text = "Distances: " .. (toggles.distances and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F5 then
        toggles.tracers = not toggles.tracers
        guiElements.tracers.Text = "Tracers: " .. (toggles.tracers and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F6 then
        toggles.skeletons = not toggles.skeletons
        guiElements.skeletons.Text = "Skeletons: " .. (toggles.skeletons and "ON" or "OFF")
    end
end)
