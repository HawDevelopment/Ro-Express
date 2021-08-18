local TestEZ = require(game:GetService("ReplicatedStorage").TestEz)

TestEZ.TestBootstrap:run({ script.Parent })

-- DEBUGGING

---[[
local express: Express = require(game:GetService("ReplicatedStorage").express)
local App = express.App

local app: App = App.new()

app:get("/Test", function(_, res)
	res:send("Hello World!")
end)

app:Listen("Debug")
wait(10)
print("From Client:")
print(express.Request.new("Debug://Test", "GET", game.Players.HawDevelopment, "Server"))
--]]
