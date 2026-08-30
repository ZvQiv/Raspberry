--// Janitor: A class for cleaning up connections and instances.
local script = [[
local connectionMannager = {}

connectionMannager.__index = connectionMannager

function connectionMannager.new()
	local _reg = setmetatable({
		connections = {},
		binds = {}
	}, connectionMannager)
	
	return _reg
end

function connectionMannager:add(t)
	assert(typeof(t) == "table", "arg must be a table of RBXScriptConnections.")

	local handles = {}

	for _, v in ipairs(t) do
		assert(typeof(v) == "RBXScriptConnection", "each entry must be a RBXScriptConnection.")
		table.insert(self.connections, v)

		table.insert(handles, {
			instance = v,
			remove = function()
				v:Disconnect()
				local idx = table.find(self.connections, v)
				if idx then
					table.remove(self.connections, idx)
				end
			end
		})
	end

	return handles
end

function connectionMannager:cleanup()
	local to_clean = { 
		self.connections, 
		self.binds
	}

	for _, t in ipairs(to_clean) do
		for key, connection in pairs(t) do
			if typeof(connection) == "RBXScriptConnection" then
				if connection.Connected then
					connection:Disconnect()
				end
			end
			
			t[key] = nil
		end
		
		table.clear(t)
	end
	
	return nil
end

function connectionMannager:bind_to(instance)
	assert(typeof(instance) == "Instance", "arg must be an instance.")

	local conn
	conn = instance.AncestryChanged:Once(function(parent)
		self:cleanup()
	end)

	table.insert(self.binds, conn)

	return nil
end

function connectionMannager:get_connections()
    return self.connections
end

function connectionMannager:get_binds()
	return self.binds
end
]]
return connectionMannager