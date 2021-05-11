--[[
    App Class
    HawDevelopment
    5/11/2021
--]]


local Signal = require(script.Parent.Signal)
local Methods = require(script.Parent.Methods)

local App = {}
App.__index = App

function App.new()
    
    local self = setmetatable({},App)
    
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

function App:_registerMethod(method)
    
    self._methods[method._path] = method
    self._newitem:Fire()
end

function App:get(...)
    App:_registerMethod(Methods.get(self,...))
end


return App