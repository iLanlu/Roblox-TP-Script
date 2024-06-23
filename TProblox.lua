-- Script para teletransportarse constantemente delante de un jugador objetivo en Strongest Battlegrounds con botón de encendido/apagado y cambio de objetivo

local player = game.Players.LocalPlayer
local targetUsername = "" -- Nombre de usuario inicial del jugador objetivo (inicialmente vacío)
local teleportActive = false -- Estado del teletransporte
local targetPlayer -- Variable para almacenar el jugador objetivo

-- Crear la GUI
local function createGui()
    local screenGui = Instance.new("ScreenGui", player.PlayerGui)
    screenGui.Name = "TeleportGui"
    local mainFrame = Instance.new("Frame", screenGui)
    local toggleButton = Instance.new("TextButton", mainFrame)
    local nameBox = Instance.new("TextBox", mainFrame)

    -- Configurar el marco principal de la GUI
    mainFrame.Size = UDim2.new(0, 300, 0, 100)
    mainFrame.Position = UDim2.new(0.5, -150, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainFrame.Active = true
    mainFrame.Draggable = true

    -- Configurar el botón de encendido/apagado
    toggleButton.Size = UDim2.new(0, 100, 0, 50)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.Text = "Encender"
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    -- Configurar la caja de entrada de texto
    nameBox.Size = UDim2.new(0, 180, 0, 50)
    nameBox.Position = UDim2.new(0, 120, 0, 10)
    nameBox.Text = targetUsername
    nameBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    nameBox.PlaceholderText = "Ingresa nombre del objetivo"

    -- Función para moverse a la posición delante del objetivo
    local function teleportToTarget()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Teletransportarse delante del objetivo
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
            local newPosition = CFrame.new(targetPosition + Vector3.new(0, 3, -3)) -- Ajusta la distancia delante y arriba del objetivo
            player.Character.HumanoidRootPart.CFrame = newPosition
        end
    end

    -- Función para manejar el respawn del personaje
    local function onCharacterAdded(char)
        char:WaitForChild("HumanoidRootPart")
        if teleportActive then
            teleportToTarget()
        end
    end

    -- Función para alternar el estado del teletransporte
    local function toggleTeleport()
        teleportActive = not teleportActive
        toggleButton.Text = teleportActive and "Apagar" or "Encender"
        toggleButton.BackgroundColor3 = teleportActive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        if teleportActive then
            teleportToTarget()
        end
    end

    -- Conexión a eventos para teletransporte continuo
    local function setupTeleport()
        player.CharacterAdded:Connect(onCharacterAdded)
        while true do
            if teleportActive and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                teleportToTarget()
            end
            wait(0.5) -- Teletransportarse cada 0.5 segundos
        end
    end

    -- Configurar el botón de encendido/apagado
    toggleButton.MouseButton1Click:Connect(toggleTeleport)

    -- Cambiar el nombre del objetivo cuando se deja de enfocar la caja de entrada de texto
    nameBox.FocusLost:Connect(function()
        local newTargetUsername = nameBox.Text
        local newTargetPlayer = game.Players:FindFirstChild(newTargetUsername)
        if newTargetPlayer then
            targetUsername = newTargetUsername
            targetPlayer = newTargetPlayer
            print("Nuevo objetivo: " .. targetUsername)
            if teleportActive then
                teleportToTarget()
            end
        else
            print("Jugador no encontrado: " .. newTargetUsername)
        end
    end)

    -- Buscar y seleccionar automáticamente el primer jugador en el juego
    local function findFirstPlayer()
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= player then
                targetPlayer = p
                targetUsername = p.Name
                nameBox.Text = targetUsername
                print("Jugador objetivo inicial: " .. targetUsername)
                break
            end
        end
    end

    game.Players.PlayerAdded:Connect(function(newPlayer)
        if not targetPlayer then
            targetPlayer = newPlayer
            targetUsername = newPlayer.Name
            nameBox.Text = targetUsername
            print("Jugador objetivo inicial: " .. targetUsername)
        end
    end)

    findFirstPlayer()
    setupTeleport()
end

-- Crear la GUI inicial
createGui()

-- Asegurarse de que la GUI se vuelva a crear cuando el personaje reaparece
player.CharacterAdded:Connect(function()
    wait(1) -- Esperar un segundo para asegurarse de que el personaje haya reaparecido completamente
    createGui()
end)
