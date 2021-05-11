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

function Methods.setBuild(inst: Instance, type: string): Instance
    inst:SetAttribute("TYPE",type)
end

function Methods.newInstance(parent: Instance, name: string, type: string): Folder
    local inst = Instance.new(type)
    inst.Name = name
    inst.Parent = parent
    return inst
end

function Methods:Build(parent: Folder)
    
    local path = string.gsub(self._path, "^/", "")
    local split = path:split("/")
    
    if #split < 1 then
        Methods.setBuild(parent,self._type)
    else
        local curr: Instance = parent
        for i = 1, #split, 1 do
            
            local temp = curr:FindFirstChild(split[i])
            if temp then
                curr = temp
            else
                temp = Methods.newInstance(curr, split[i], "RemoteEvent")
                Methods.setBuild(temp,self._type)
            end
        end
    end
    
    return parent
end

function Methods.get(_, path, callback)
    path = assert(path, "Need a valid path")
    callback = assert(callback, "Need a valid callback")
    
    return Methods._new("GET", path, callback)
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