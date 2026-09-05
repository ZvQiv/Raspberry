
local class = {}

class.__index = class 

function class.new()
    local self = setmetatable({}, class)

    return self
end

function class:method_b()
    print('method b')
end

return class
