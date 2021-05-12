--local TestEZ = require(game:GetService("ReplicatedStorage").TestEz)

--TestEZ.TestBootstrap:run({ script.Parent })

-- DEBUGGING

local express = require(game:GetService("ReplicatedStorage").express)
local App = express.App

local app = App.new()

app:get("/Test", function(arg)
	print(arg)
end)

app:post("/Test2", function()
	print("Foo Bar Bazz")
end)

app:delete("/Test/Test3", function()
	print("Hello World!")
end)

app:use("/Test", function()
	print("Middleware!")
end)

app:use("/Test/Test3", function(arg)
	print(arg)
end)

app:Listen("Debug")
