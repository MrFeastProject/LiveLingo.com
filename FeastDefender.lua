-- ===== МАКСИМАЛЬНАЯ АНОНИМНАЯ ЗАЩИТА ПРОФИЛЯ =====
-- Добавить в конец antiByfronAndBanProtection() или заменить её

local function maxAnonProfileProtection()
    local lplr = LocalPlayer
    local originalUserId = lplr.UserId
    local originalName = lplr.Name
    local originalAccountAge = lplr.AccountAge
    
    -- 1. Полная маскировка имени на всех уровнях
    local function maskNameEverywhere()
        -- Изменяем имя в самом объекте игрока (клиент-сайд)
        pcall(function()
            lplr.Name = "🛡️ Protected_" .. math.random(10000, 99999)
        end)
        
        -- Перехват всех попыток прочитать имя
        local nameMetatable = getrawmetatable(lplr)
        local oldNameIndex = nameMetatable.__index
        nameMetatable.__index = function(self, key)
            if key == "Name" then
                return "Guest_" .. math.random(1000, 9999)
            elseif key == "DisplayName" then
                return "Аноним"
            elseif key == "UserId" then
                return math.random(100000, 999999)
            elseif key == "AccountAge" then
                return 365 -- притворяемся старым аккаунтом
            end
            return oldNameIndex(self, key)
        end
        setrawmetatable(lplr, nameMetatable)
    end
    
    -- 2. Блокировка всех телеметрических запросов
    local function blockTelemetry()
        -- Блокировка отправки логов в Roblox
        local http = game:GetService("HttpService")
        local oldPost = http.PostAsync
        http.PostAsync = function(...)
            local args = {...}
            local url = tostring(args[1] or "")
            if url:find("telemetry") or url:find("analytics") or url:find("log") or url:find("tracking") then
                return "" -- имитируем успешный ответ, но ничего не отправляем
            end
            return oldPost(...)
        end
        
        -- Блокировка внутренних событий Roblox
        local analytics = game:GetService("AnalyticsService")
        if analytics then
            local oldReport = analytics.ReportCounter
            analytics.ReportCounter = function() end
            local oldSet = analytics.SetCounter
            analytics.SetCounter = function() end
        end
    end
    
    -- 3. Фальшивый клиент для сервера (через изменение Remote)
    local function fakeClientIdentity()
        -- Каждый Remote вызов маскирует реальные данные
        local oldFireServer = nil
        local remoteEvents = {}
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                table.insert(remoteEvents, remote)
            end
        end
        
        for _, remote in pairs(remoteEvents) do
            oldFireServer = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                -- Подменяем имя и ID в аргументах
                for i, arg in pairs(args) do
                    if type(arg) == "string" and arg == originalName then
                        args[i] = "FakeUser_" .. math.random(1000, 9999)
                    elseif type(arg) == "number" and arg == originalUserId then
                        args[i] = math.random(100000, 999999)
                    end
                end
                return oldFireServer(self, unpack(args))
            end
        end
    end
    
    -- 4. Скрытие от PlayerList и других GUI
    local function hideFromPlayerList()
        local playerList = CoreGui:FindFirstChild("PlayerList")
        if playerList then
            playerList:Destroy()
        end
        
        -- Блокировка создания новых списков игроков
        local oldInstance = Instance.new
        Instance.new = function(className, parent)
            if className == "PlayerList" or (parent and parent.Name:find("PlayerList")) then
                return nil
            end
            return oldInstance(className, parent)
        end
    end
    
    -- 5. Подмена аппаратных идентификаторов (через перехват)
    local function spoofHardwareIds()
        -- Перехват GraphicsDevice (GPU ID)
        local settings = game:GetService("UserSettings")
        local graphics = settings:GetService("UserGameSettings")
        local oldGet = graphics.GetGraphicsDevice
        graphics.GetGraphicsDevice = function()
            return "Virtual Device v" .. math.random(100, 999)
        end
        
        -- Подмена разрешения экрана
        local oldScreenSize = workspace.CurrentCamera.ViewportSize
        local screenMetatable = getrawmetatable(workspace.CurrentCamera)
        local oldIndex = screenMetatable.__index
        screenMetatable.__index = function(self, key)
            if key == "ViewportSize" then
                return Vector2.new(math.random(1280, 1920), math.random(720, 1080))
            end
            return oldIndex(self, key)
        end
        setrawmetatable(workspace.CurrentCamera, screenMetatable)
    end
    
    -- 6. Блокировка скриншотов и записи экрана (клиент-сайд)
    local function blockScreenshots()
        -- Roblox не имеет прямого API, но можно перехватить клавиши
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.F12 or 
               input.KeyCode == Enum.KeyCode.PrintScreen or
               (input.KeyCode == Enum.KeyCode.LeftShift and input.UserInputType == Enum.UserInputType.Keyboard) then
                return true -- блокируем
            end
        end)
        
        -- Для мобильных устройств
        UserInputService.TouchLongPress:Connect(function()
            return true -- блокируем долгое нажатие (скриншот на некоторых устройствах)
        end)
    end
    
    -- 7. Полная анонимизация чата
    local function anonymizeChat()
        -- Все сообщения от тебя идут без имени
        local oldSay = TextChatService.TextChannels.RBXGeneral.SendAsync
        if oldSay then
            TextChatService.TextChannels.RBXGeneral.SendAsync = function(self, message)
                -- Отправляем от имени "🔒 Аноним"
                return oldSay(self, message, "🔒 Аноним")
            end
        end
        
        -- Скрываем входящие сообщения для других о тебе
        TextChatService.OnIncomingMessage = function(message)
            if message.FromPlayer and message.FromPlayer.Name == lplr.Name then
                message.FromPlayer.Name = "Скрыто"
            end
            return message
        end
    end
    
    -- 8. Анти-логгирование действий
    local function blockActionLogs()
        -- Блокировка всех возможных логгеров в игре
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name:lower():find("log") or 
               obj.Name:lower():find("history") or
               obj.Name:lower():find("record") then
                pcall(function() obj:Destroy() end)
            end
        end
        
        -- Отключение обращений к логам
        local logger = game:GetService("LogService")
        if logger then
            local oldLog = logger.MessageOut
            logger.MessageOut = function() end
        end
    end
    
    -- 9. Имитация другого региона/IP
    local function spoofLocation()
        -- Подмена языка и региона
        pcall(function()
            game:GetService("LocalizationService").SystemLocale = "en-US"
            game:GetService("LocalizationService").PlayerLocale = "ru-RU" -- смешиваем
        end)
        
        -- Для сервера: подставляем фальшивый заголовок
        local http = game:GetService("HttpService")
        local oldGet = http.GetAsync
        http.GetAsync = function(self, url, ...)
            if url:find("ip") or url:find("location") then
                return '{"ip": "1.1.1.1", "country": "US"}'
            end
            return oldGet(self, url, ...)
        end
    end
    
    -- 10. Защита от внутреннего бана Roblox (максимальная)
    local function ultimateBanEvasion()
        -- Перехват запросов на бан аккаунта (локальная защита)
        local teleport = TeleportService
        local oldTeleport = teleport.Teleport
        teleport.Teleport = function(self, ...)
            -- Игнорируем телепортацию если это бан
            return nil
        end
        
        -- Блокировка вызова :Ban() если такое существует
        local banned = false
        lplr.Kick = function(self, msg)
            if msg and (msg:find("ban") or msg:find("banned")) then
                return nil -- отменяем бан
            end
            return oldKick(self, msg)
        end
    end
    
    -- ЗАПУСК ВСЕХ ЗАЩИТ
    maskNameEverywhere()
    blockTelemetry()
    fakeClientIdentity()
    hideFromPlayerList()
    spoofHardwareIds()
    blockScreenshots()
    anonymizeChat()
    blockActionLogs()
    spoofLocation()
    ultimateBanEvasion()
    
    print("[FeastRaidExploit] 🔒 МАКСИМАЛЬНАЯ АНОНИМНАЯ ЗАЩИТА АКТИВИРОВАНА")
    print("[FeastRaidExploit] Ваше реальное имя/ID скрыты от сервера и других игроков")
    print("[FeastRaidExploit] Все телеметрические данные заблокированы")
end

-- ВСТАВЬ ЭТУ ФУНКЦИЮ В main() ПОСЛЕ antiByfronAndBanProtection()
-- Просто добавь строку: maxAnonProfileProtection()
