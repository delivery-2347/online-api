-- Останавливаем предыдущую версию
if getgenv().OnlineStop then
    pcall(getgenv().OnlineStop)
end

local running = true

getgenv().OnlineStop = function()
    running = false
end

local onlain = "wait"

local function obnova()
    local ok, result = pcall(function()
        return game:HttpGet("https://online-api-zzbn.onrender.com/online")
    end)

    if ok then
        onlain = result
    end
end

obnova()

local OnlineWatermark = loadstring(game:HttpGet("https://raw.githubusercontent.com/delivery-2347/online-api/refs/heads/main/vm.Lua"))()

local wm = OnlineWatermark.new()
wm:Show()
wm:SetOnline(onlain)

task.spawn(function()
    while running do
        task.wait(5)

        if not running then
            break
        end

        obnova()
        wm:SetOnline(onlain)
    end
end)
