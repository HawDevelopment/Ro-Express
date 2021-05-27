--local TestEZ = require(game:GetService("ReplicatedStorage").TestEz)

--TestEZ.TestBootstrap:run({ script.Parent })

-- DEBUGGING

--[[
local express = require(game:GetService("ReplicatedStorage").express)
local App = express.App

local app = App.new()

app:get("/Test", function()
end)

app:post("/Test2", function()
	print("Foo Bar Bazz")
end)

app:delete("/Test/Test3", function()
	print("Hello World!")
end)

app:get("/Test4", function()
	print("Callback")
end)

app:all("/Test4", function()
	print("All")
end)

app:use("/Test", function(req, res)
	print(req.Body)
	res:status(200):send("Hello", "World", "!")
end)

app:use("/Test/Test3", function(_, res)
	print(res)
end)

app:Listen("Client")
--]]
