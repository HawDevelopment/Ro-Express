--local TestEZ = require(game:GetService("ReplicatedStorage").TestEz)

--TestEZ.TestBootstrap:run({ script.Parent })

-- DEBUGGING

---[[
local express = require(game:GetService("ReplicatedStorage").express)
local App = express.App

local app = App.new()

app:get("/Test", function(_, res)
	res:send("Hello From The Client")
end)

app:Listen("Debug")
--]]
