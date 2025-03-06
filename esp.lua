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
local maxDistance = 999
local updateInterval = 0.1

-- Stałe kolory
local BOX_COLOR = Color3.fromRGB(0, 255, 0) -- Zielony dla ramki
local TRACER_COLOR = Color3.fromRGB(255, 255, 255) -- Biały dla linii śledzących
local HEALTHBAR_COLOR = Color3.fromRGB(255, 0, 0) -- Czerwony dla paska zdrowia

-- Informacja o uruchomieniu
print("Skrypt ESP został uruchomiony! Naciśnij 'P', aby wyłączyć ESP.")

-- Inicjalizacja ESP
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Humanoid") and obj.Parent ~= LocalPlayer.Character then
        local model = obj.Parent
        local player = Players:GetPlayerFromCharacter(model)
        local nickname = player and player.Name or "NPC"

        -- Ramka
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = BOX_COLOR
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
        healthbarBorder.Color = Color3.fromRGB(255, 255, 255) -- Biały kolor obramowania
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

        -- Linia śledząca
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1
        tracer.Transparency = 0.5 -- Przezroczystość 0.5
        tracer.Color = TRACER_COLOR
        tracers[model] = tracer
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

    for model, box in pairs(boxes) do
        if model and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Humanoid") and localPos and localScreenPos then
            local hrp = model.HumanoidRootPart
            local humanoid = model.Humanoid
            local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            local studDistance = math.floor((localPos - hrp.Position).Magnitude)

            if studDistance <= maxDistance then
                -- Ramka
                box.Position = Vector2.new(pos.X - 20, pos.Y - 40)
                box.Size = Vector2.new(40, 80)
                box.Visible = true

                -- Pasek zdrowia
                local healthbar = healthbars[model]
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthHeight = 80 * healthPercent
                healthbar.Size = Vector2.new(5, healthHeight)
                healthbar.Position = Vector2.new(pos.X - 35, pos.Y - 40 + (80 - healthHeight)) -- Oddalony
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

                -- Odległość
                local distance = distances[model]
                distance.Text = studDistance .. " studs"
                distance.Position = Vector2.new(pos.X, pos.Y + 45)
                distance.Visible = true

                -- Linia śledząca
                local tracer = tracers[model]
                tracer.From = Vector2.new(localScreenPos.X, localScreenPos.Y)
                tracer.To = Vector2.new(pos.X, pos.Y)
                tracer.Visible = true
            else
                box.Visible = false
                healthbars[model].Visible = false
                healthbarBorders[model].Visible = false
                names[model].Visible = false
                distances[model].Visible = false
                tracers[model].Visible = false
            end
        else
            box.Visible = false
            healthbars[model].Visible = false
            healthbarBorders[model].Visible = false
            names[model].Visible = false
            distances[model].Visible = false
            tracers[model].Visible = false
        end
    end
end)

-- Obsługa nowych humanoidów
local descendantAddedConnection
descendantAddedConnection = Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Humanoid") and obj.Parent ~= LocalPlayer.Character then
        local model = obj.Parent
        local player = Players:GetPlayerFromCharacter(model)
        local nickname = player and player.Name or "NPC"

        -- Ramka
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Color = BOX_COLOR
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

        -- Linia śledząca
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1
        tracer.Transparency = 0.5
        tracer.Color = TRACER_COLOR
        tracers[model] = tracer
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
        tracers[obj.Parent]:Remove()

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
    -- Rozłączanie połączeń
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

    -- Usuwanie wszystkich elementów rysowania
    for model, box in pairs(boxes) do
        box:Remove()
        healthbars[model]:Remove()
        healthbarBorders[model]:Remove()
        names[model]:Remove()
        distances[model]:Remove()
        tracers[model]:Remove()
    end

    -- Czyszczenie tabel
    boxes = {}
    healthbars = {}
    healthbarBorders = {}
    names = {}
    distances = {}
    tracers = {}

    print("ESP zostało zniszczone!")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignoruj, jeśli gracz używa klawisza w UI (np. w czacie)
    if input.KeyCode == Enum.KeyCode.P then
        destroyESP()
    end
end)
