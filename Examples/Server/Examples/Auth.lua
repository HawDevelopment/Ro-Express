--[[
    Auth Example
    HawDevelopment
    27/05/2021
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local express = require(ReplicatedStorage.express)

local app: App = express.App.new()

local VerifiedUsers = {
	"HawDevelopment_",
	"Elttob",
	"ScriptOn",
	"Sleitnick",
}

app:use("/", function(req, res)
	local isVerified = false

	for _, name in pairs(VerifiedUsers) do
		if req.Player.Name == name then
			isVerified = true
			break
		end
	end

	if not isVerified then
		res:status(401):send("Your not Authorized to do that!")
	end
end)

app:get("/GetHugs", function(_: Request, res: Response)
	res:send("Hugs 🤗")
end)

print(app)

app:Listen("AuthTree")

return {}
