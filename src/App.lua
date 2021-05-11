--[[
    App Class
    HawDevelopment
    5/11/2021
--]]

local function Extend(tab1,tab2)
    for i,v in pairs(tab2) do
        tab1[i] = v
    end
    return tab1
end

local Signal = require(script.Parent.Signal)
local Methods = require(script.Parent.Methods)

local App = {}

function App.new()
    
    local self = setmetatable({},{__index = Extend(App, Methods)})
    
    self._methods = {}
    self._name = {}
    self._newitem = Signal.new()
    
    self._newitem:Connect(function()
        if self._root then
            self:Listen(self._name)
        end
        
    end)
    
    return self
end

function App:Listen(name: string | number)
    
    self._name = assert(name, "Expected a name!")
    if self._root or self._build then
        return
    end
    
    local Root = Instance.new("Folder")
    Root.Name = name
    
    if #self._methods > 0 then
        
        for _, method in pairs(self._methods) do
            
            if not method._build then
                method:Build(Root)
            end
            
        end
    end
    
    Root.Parent = game:GetService("ReplicatedStorage")
    self._root = Root
    
    return Root
end

return App