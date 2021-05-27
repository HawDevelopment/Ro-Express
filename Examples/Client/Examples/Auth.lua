--[[
    Auth Example
    HawDevelopment
    27/05/2021
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local express = require(ReplicatedStorage.express)

local Return = express.Request.new("AuthTree://GetHugs", "Get")

if Return.Status == 401 or not Return.Succes then
	print("You are not Authorized!")
else
	print("Get some hugs: " .. Return.Body)
end

return {}
