--// ReplicatedStorage.Raspberry.Utils.CommandHandler
local script = [[
local CommandHandler = {}

CommandHandler.__index = CommandHandler

function CommandHandler.new(ui, parser, janitor, onErrorCallback)
	local self = setmetatable({}, CommandHandler)
	self.ui = ui
	self.parser = parser
	self.janitor = janitor
	self.onError = onErrorCallback

	self:init()
	
	return self
end

function CommandHandler:init()
	local input = self.ui.CMD
	
	self.janitor:add{
		input.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local success, parseResult = pcall(function()
					return self.parser:Parse(input.Text)
				end)

				if success and parseResult then
					parseResult.callbackData.func(unpack(parseResult.args))
				elseif not success and self.onError then
					self.onError(parseResult)
				end

				input.Text = ""
			end
		end)
	}
end
]]
return script
