--[[
    Client-Server Example
    HawDevelopment
    27/05/2021
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local express = require(ReplicatedStorage.express)

local app: App = express.App.new()

local Money = {}

app:get("/GetMoney", function(req: Request, res: Response)
	-- Response Status will defualt to 200, so we dont have to call it.
	res:send(Money[req.Player] or 0)
end)

app:post("/SetMoney", function(req: Request, res: Response)
	assert(req.Body, "Need a valid amount of Money to set!")
	Money[req.Player] = req.Body

	res:send("We set the Money!")
end)

app:Listen("MoneyTree")

return {}
