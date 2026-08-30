local script = [[
local Commands = {}

Commands.__index = Commands

function Commands.new()
	return setmetatable({ MasterTable = {} }, Commands)
end

local function addSubcommand(self, literals, types, callback)
	if type(literals) == "function" then
		callback, types, literals = literals, nil, nil
	elseif type(types) == "function" then
		callback, types = types, nil
	end

	local argCount, isVararg = debug.info(callback, "a")
	
	local cmdData = {
		func = callback,
		expectedArgs = argCount,
		isVararg = isVararg,
		argTypes = types or {},
	}

	if not literals then
		self.Default = cmdData
	else
		local subNames = type(literals) == "table" and literals or { literals }
		
		for _, name in ipairs(subNames) do
			self.Literals[string.lower(`{name}`)] = cmdData
		end
	end

	return self
end

function Commands:Register(names)
	local rootList = type(names) == "table" and names or { names }

	local commandData = {
		Name = rootList[1],
		Literals = {},
		Default = nil,
		cmd = addSubcommand,
	}

	for _, name in ipairs(rootList) do
		self.MasterTable[string.lower(name)] = commandData
	end

	return commandData
end

function Commands:GetCommand(name)
	return self.MasterTable[string.lower(name)]
end
]]

return script
