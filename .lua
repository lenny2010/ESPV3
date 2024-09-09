-- // Skeleton ESP Script for Roblox (Lua)
-- // Roblox Local Script (Run in a LocalScript context)
-- // Box ESP with Health Bar for Players

-- Function to create a new ESP box for a player
local function createESPBox(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    -- Create the BillboardGui for the ESP box
    local espBox = Instance.new("BillboardGui")
    espBox.Name = "ESPBox"
    espBox.AlwaysOnTop = true
    espBox.Size = UDim2.new(4, 0, 5, 0)  -- Size of the ESP box
    espBox.Adornee = character:FindFirstChild("HumanoidRootPart")  -- Attach to player's character

    -- Create a frame for the box visualization
    local frame = Instance.new("Frame", espBox)
    frame.Size = UDim2.new(1, 0, 1, 0)  -- Full size of the BillboardGui
    frame.BackgroundTransparency = 0.5  -- Semi-transparent
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red color for the ESP box

    -- Create health bar inside the ESP box
    local healthBar = Instance.new("Frame", espBox)
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(0.2, 0, 1, 0)  -- Thin vertical bar
    healthBar.Position = UDim2.new(-0.3, 0, 0, 0)  -- Position to the left of the ESP box
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- Green color for health
    healthBar.BorderSizePixel = 0

    -- Update health bar size and color based on health
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            healthBar.Size = UDim2.new(0.2, 0, healthPercent, 0)
            healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)  -- Color change from green to red based on health
        end)
    end

    -- Attach the ESP box to the player's character
    espBox.Parent = character:WaitForChild("HumanoidRootPart")
end

-- Function to remove ESP box from a player
local function removeESPBox(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local espBox = player.Character:FindFirstChild("ESPBox")
        if espBox then
            espBox:Destroy()
        end
    end
end

-- Function to check if the player is on the same team as the local player
local function isEnemy(player)
    local localPlayer = game:GetService("Players").LocalPlayer

    -- Check if both players are in teams and compare their teams
    if localPlayer.Team and player.Team then
        return localPlayer.Team ~= player.Team  -- Return true if the player is not on the same team
    else
        return true  -- If there are no teams, consider everyone as enemies
    end
end

-- Function to update ESP for all players
local function updateESP()
    local players = game:GetService("Players")
    
    -- Loop through all players
    for _, player in pairs(players:GetPlayers()) do
        if player ~= players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if isEnemy(player) then  -- Only create ESP for enemies
                if not player.Character:FindFirstChild("ESPBox") then
                    createESPBox(player)  -- Create ESP if not already present
                end
            else
                removeESPBox(player)  -- Remove ESP if they are no longer an enemy
            end
        end
    end
end

-- Main ESP loop that constantly updates ESP every 0.1 seconds
local function enableESP()
    local players = game:GetService("Players")

    -- Listen for new players joining the game
    players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            wait(1)  -- Wait for the character to fully load
            updateESP()  -- Update ESP once the character is loaded
        end)
    end)

    -- Listen for players leaving and clean up their ESP boxes
    players.PlayerRemoving:Connect(function(player)
        removeESPBox(player)
    end)

    -- Continuous loop to constantly update ESP
    while true do
        updateESP()
        wait(0.1)  -- Adjust the delay to balance performance and responsiveness
    end
end

-- Start ESP
enableESP()
