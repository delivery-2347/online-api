local Players = game:GetService("Players")
local API = "https://online-api-zzbn.onrender.com"
local KEY = "KEY-123"
local USER = tostring(Players.LocalPlayer.UserId)
task.spawn(function()
    while true do
        local success, err = pcall(function()
            game:HttpGet(API .. "/ping?key=" .. KEY .. "&user=" .. USER)
        end)
    
        if not success then
            warn("Heartbeat error:", err)
        end
    
        task.wait(5)
    end
end)
