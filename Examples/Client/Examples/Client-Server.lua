--[[
    Client-Server Example
    HawDevelopment
    27/05/2021
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local express = require(ReplicatedStorage.express)

local Return = express.Request.new("MoneyTree://GetMoney", "Get").Body or 10

express.Request.new("MoneyTree://SetMoney", "Post", Return + 10)

print(express.Request.new("MoneyTree://GetMoney", "Get").Body)

return {}
