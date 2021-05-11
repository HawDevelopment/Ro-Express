--[[
    Methods Class
    HawDevelopment
    5/11/2021
--]]

local Methods = {}
Methods.__index = Methods

function Methods._new(type: string, path: string, callback: (any) -> any)
    
    local self = setmetatable({},Methods)
    
    self._type = type
    self._path = path
    self._callback = callback
    
    return self
end

function Methods:Build(parent)
    
    
end

function Methods.get()
    
end

function Methods.get()
    
end

function Methods.get()
    
end

function Methods.get()
    
end

function Methods.get()
    
end

return Methods