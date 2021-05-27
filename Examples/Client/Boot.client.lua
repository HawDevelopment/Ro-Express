--[[
    Example Client
    HawDevelopment
    27/05/2021
--]]

local Examples = script.Parent:WaitForChild("Examples"):GetDescendants()

for _, module in pairs(Examples) do
	require(module)
end
