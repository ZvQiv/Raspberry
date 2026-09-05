local TOKEN_RULES = {
	{ type = "STRING", pattern = '^"([^"]*)"' },
	{ type = "WORD", pattern = '^[%w_%-]+' },
	{ type = "WHITESPACE", pattern = '^%s+' },
	{ type = "SYMBOL", pattern = '^%p' },
}

local CommandParser = {}

CommandParser.__index = CommandParser

function CommandParser.new(registry, system)
	return setmetatable({ Registry = registry, System = system }, CommandParser)
end

function CommandParser:Tokenize(input)
	local tokens = {}
	local cursor = 1

	while cursor <= #input do
		local substring = string.sub(input, cursor)
		local matched = false

		for _, rule in ipairs(TOKEN_RULES) do
			local match_start, match_end, capture = string.find(substring, rule.pattern)

			if match_start then
				if rule.type ~= "WHITESPACE" then
					table.insert(tokens, {
						type = rule.type,
						value = (rule.type == "STRING" and capture) or string.sub(substring, match_start, match_end),
					})
				end

				cursor = cursor + (match_end - match_start + 1)
				matched = true

				break
			end
		end

		if not matched then
			self.System:error(`Unexpected token at position {cursor}: '{string.sub(substring, 1, 1)}'`)
		end
	end

	return tokens
end

function CommandParser:ValidateType(value, expectedType)
	local lowerType = string.lower(expectedType)

	if lowerType == "number" then
		local num = tonumber(value)

		if not num then
			return false, `expected number, got '{value}'`
		end

		return true, num
	elseif lowerType == "boolean" or lowerType == "bool" then
		local lowerVal = string.lower(value)

		if lowerVal == "true" or lowerVal == "1" then
			return true, true
		end

		if lowerVal == "false" or lowerVal == "0" then
			return true, false
		end

		return false, `expected boolean, got '{value}'`
	elseif lowerType == "string" then
		return true, tostring(value)
	end

	return true, value
end

function CommandParser:ResolveCommand(tokens)
	local cmdToken = tokens[1]

	if not cmdToken or cmdToken.type ~= "WORD" then
		self.System:error(`Syntax Error: Expected command name, got '{cmdToken and cmdToken.value or "EOF"}'.`)
	end

	local commandObject = self.Registry:GetCommand(cmdToken.value)

	if not commandObject then
		self.System:error(`Command Error: Unknown command '{cmdToken.value}'.`)
	end

	local nextToken = tokens[2]
	local literalKey = nextToken and nextToken.type == "WORD" and string.lower(nextToken.value)
	local callbackData = literalKey and commandObject.Literals[literalKey] or commandObject.Default

	if not callbackData then
		self.System:error(`Command Error: Command '{commandObject.Name}' requires a valid subcommand.`)
	end

	return commandObject, callbackData, literalKey
end

function CommandParser:ValidateArgCount(commandName, literalKey, rawArgs, callbackData)
	local minArgs = callbackData.expectedArgs or 0
	local maxArgs = callbackData.isVararg and math.huge or minArgs

	if #rawArgs < minArgs or #rawArgs > maxArgs then
		local expected = (minArgs == maxArgs) and tostring(minArgs) or `{minArgs} to {maxArgs == math.huge and "∞" or tostring(maxArgs)}`
		local label = literalKey and `{commandName} {literalKey}` or commandName

		self.System:error(`Argument Error: '{label}' expected {expected} arguments, got {#rawArgs}.`)
	end

	return true
end

function CommandParser:ProcessArguments(rawArgs, argTypes)
	local typedArgs = {}

	for i, rawValue in ipairs(rawArgs) do
		local expectedType = argTypes[i]

		if expectedType then
			local valid, convertedValue = self:ValidateType(rawValue, expectedType)

			if not valid then
				self.System:error(`Type Error: Argument #{i} ({convertedValue}).`)
			end

			table.insert(typedArgs, convertedValue)
		else
			table.insert(typedArgs, rawValue)
		end
	end

	return typedArgs
end

function CommandParser:Parse(input)
	local tokens = self:Tokenize(input)
	if not tokens or #tokens == 0 then
		return nil
	end

	local commandObject, callbackData, literalKey = self:ResolveCommand(tokens)
	if not commandObject or not callbackData then
		return nil
	end

	local rawArgs = {}
	for i = literalKey and 3 or 2, #tokens do
		table.insert(rawArgs, tokens[i].value)
	end

	if not self:ValidateArgCount(commandObject.Name, literalKey, rawArgs, callbackData) then
		return nil
	end

	local typedArgs = self:ProcessArguments(rawArgs, callbackData.argTypes)
	if not typedArgs then
		return nil
	end

	return {
		root = commandObject.Name,
		literal = literalKey or nil,
		callbackData = callbackData,
		args = typedArgs,
	}
end
return CommandParser
