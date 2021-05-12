--local TestEZ = require(game:GetService("ReplicatedStorage").TestEz)

--TestEZ.TestBootstrap:run({ script.Parent })

-- DEBUGGING

local express = require(game:GetService("ReplicatedStorage").express)
local App = express.App

local app = App.new()

app:get("/Test", function()
	print("Hello World!")
end)

app:get("/Test2", function()
	print("Foo Bar Bazz")
end)

app:Listen("Debug")
