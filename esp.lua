local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local boxes = {} -- Ramki
local healthbars = {} -- Paski zdrowia
local healthbarBorders = {} -- Ramki dla pasków zdrowia
local names = {}
local distances = {}
local tracers = {} -- Linie śledzące
local skeletons = {} -- Linie szkieletu
local maxDistance = 2500
local updateInterval = 0.1

-- Stałe kolory
local BOX_COLOR = Color3.fromRGB(0, 255, 0) -- Zielony dla ramki
local LOCAL_BOX_COLOR = Color3.fromRGB(0, 0, 255) -- Niebieski dla lokalnego gracza
local TRACER_COLOR = Color3.fromRGB(255, 255, 255) -- Biały dla linii śledzących
local HEALTHBAR_COLOR = Color3.fromRGB(255, 0, 0) -- Czerwony dla paska zdrowia
local SKELETON_COLOR = Color3.fromRGB(255, 255, 255) -- Biały dla szkieletu
local LOCAL_SKELETON_COLOR = Color3.fromRGB(0, 0, 255) -- Niebieski dla szkieletu lokalnego gracza

-- Informacja o uruchomieniu
print("Skrypt ESP został uruchomiony! Naciśnij 'P', aby wyłączyć ESP.")
print("Wersja 1.0.8")

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

        -- Ramka
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = isLocalPlayer and LOCAL_BOX_COLOR or BOX_COLOR
        boxes[model] = box

        -- Pasek zdrowia
        local healthbar = Drawing.new("Square")
        healthbar.Visible = false
        healthbar.Thickness = 1
        healthbar.Filled = true
        healthbar.Transparency = 0.7
        healthbar.Color = HEALTHBAR_COLOR
        healthbars[model] = healthbar

        -- Ramka paska zdrowia
        local healthbarBorder = Drawing.new("Square")
        healthbarBorder.Visible = false
        healthbarBorder.Thickness = 1
        healthbarBorder.Filled = false
        healthbarBorder.Transparency = 1
        healthbarBorder.Color = Color3.fromRGB(255, 255, 255)
        healthbarBorders[model] = healthbarBorder

        -- Nazwa
        local name = Drawing.new("Text")
        name.Visible = false
        name.Color = Color3.fromRGB(255, 255, 255)
        name.Size = 14
        name.Center = true
        name.Outline = true
        name.OutlineColor = Color3.fromRGB(0, 0, 0)
        name.Font = 1 -- SourceSans
        name.Text = nickname
        names[model] = name

        -- Odległość
        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Color = Color3.fromRGB(255, 255, 255)
        distance.Size = 12
        distance.Center = true
        distance.Outline = true
        distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        distance.Font = 1 -- SourceSans
        distances[model] = distance

        -- Linia śledząca (tylko dla innych graczy)
        if not isLocalPlayer then
            local tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Thickness = 1
            tracer.Transparency = 0.5
            tracer.Color = TRACER_COLOR
            tracers[model] = tracer
        end

        -- Szkielet
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

    for model, box in pairs(boxes) do
        if model and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Humanoid") and localPos and localScreenPos then
            local hrp = model.HumanoidRootPart
            local humanoid = model.Humanoid
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            local studDistance = math.floor((localPos - hrp.Position).Magnitude)
            local isLocalPlayer = (model == LocalPlayer.Character)

            -- Sprawdzenie, czy gracz jest w polu widzenia kamery
            local cameraCFrame = camera.CFrame
            local vectorToPlayer = (hrp.Position - cameraCFrame.Position).Unit
            local cameraLookVector = cameraCFrame.LookVector
            local dotProduct = vectorToPlayer:Dot(cameraLookVector)
            local isInFront = dotProduct > 0 -- Gracz jest przed kamerą, jeśli iloczyn skalarny > 0

            -- Aktualizacja nazwy dynamicznie
            local player = Players:GetPlayerFromCharacter(model)
            local nickname = player and player.Name or "NPC"
            names[model].Text = nickname -- Odświeżanie nazwy w każdej klatce

            -- ESP i snaplines widoczne tylko gdy gracz jest w polu widzenia i na ekranie
            if studDistance <= maxDistance and onScreen and isInFront then
                -- Ramka
                box.Position = Vector2.new(pos.X - 20, pos.Y - 40)
                box.Size = Vector2.new(40, 80)
                box.Visible = true

                -- Pasek zdrowia
                local healthbar = healthbars[model]
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthHeight = 80 * healthPercent
                healthbar.Size = Vector2.new(5, healthHeight)
                healthbar.Position = Vector2.new(pos.X - 35, pos.Y - 40 + (80 - healthHeight))
                healthbar.Visible = true
                healthbar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)

                -- Ramka paska zdrowia
                local healthbarBorder = healthbarBorders[model]
                healthbarBorder.Size = Vector2.new(7, 82)
                healthbarBorder.Position = Vector2.new(pos.X - 36, pos.Y - 41)
                healthbarBorder.Visible = true

                -- Nazwa
                local name = names[model]
                name.Position = Vector2.new(pos.X, pos.Y - 45)
                name.Visible = true

                -- Odległość (pomijamy dla lokalnego gracza)
                local distance = distances[model]
                distance.Text = studDistance .. " studs"
                distance.Position = Vector2.new(pos.X, pos.Y + 45)
                distance.Visible = not isLocalPlayer

                -- Snapline (tylko gdy gracz jest w polu widzenia)
                if tracers[model] then
                    local tracer = tracers[model]
                    tracer.From = Vector2.new(localScreenPos.X, localScreenPos.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Visible = true
                end

                -- Aktualizacja szkieletu
                local skeletonLines = skeletons[model]
                if skeletonLines then
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
                end
            else
                -- Wyłącz wszystko, gdy gracz nie jest w polu widzenia
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
end)

-- Obsługa nowych humanoidów
local descendantAddedConnection
descendantAddedConnection = Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Humanoid") then
        local model = obj.Parent
        local player = Players:GetPlayerFromCharacter(model)
        local nickname = player and player.Name or "NPC"
        local isLocalPlayer = (model == LocalPlayer.Character)

        -- Ramka
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = isLocalPlayer and LOCAL_BOX_COLOR or BOX_COLOR
        boxes[model] = box

        -- Pasek zdrowia
        local healthbar = Drawing.new("Square")
        healthbar.Visible = false
        healthbar.Thickness = 1
        healthbar.Filled = true
        healthbar.Transparency = 0.7
        healthbar.Color = HEALTHBAR_COLOR
        healthbars[model] = healthbar

        -- Ramka paska zdrowia
        local healthbarBorder = Drawing.new("Square")
        healthbarBorder.Visible = false
        healthbarBorder.Thickness = 1
        healthbarBorder.Filled = false
        healthbarBorder.Transparency = 1
        healthbarBorder.Color = Color3.fromRGB(255, 255, 255)
        healthbarBorders[model] = healthbarBorder

        -- Nazwa
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

        -- Odległość
        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Color = Color3.fromRGB(255, 255, 255)
        distance.Size = 12
        distance.Center = true
        distance.Outline = true
        distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        distance.Font = 1
        distances[model] = distance

        -- Linia śledząca (tylko dla innych)
        if not isLocalPlayer then
            local tracer = Drawing.new("Line")
            tracer.Visible = false
            tracer.Thickness = 1
            tracer.Transparency = 0.5
            tracer.Color = TRACER_COLOR
            tracers[model] = tracer
        end

        -- Szkielet
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

    boxes = {}
    healthbars = {}
    healthbarBorders = {}
    names = {}
    distances = {}
    tracers = {}
    skeletons = {}

    print("ESP zostało zniszczone!")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        destroyESP()
    end
end)
