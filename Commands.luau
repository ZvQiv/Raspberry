local script = [[
return function(registry, buffer, renderer, filter, output, system, con)
	registry:Register({'console', 'con'})
		-- console clear | con c
		:cmd({'clear', 'c'}, function()
			buffer:reset()
			renderer:clearPool()
			renderer:setDirty()
		end)
		-- console pause | con p
		:cmd({'pause', 'p'}, function()
			output:pause()
			system:out("Output logging paused.")
		end)
		
		-- console query <string> | con q <string>
		:cmd({'query', 'q'}, {"string"}, function(q)
			filter:set(q)
			renderer:clearPool()
			renderer:setDirty()
		end)
		
		-- console resume | con r
		:cmd({'resume', 'r'}, function()
			output:resume()
			system:out("Output logging resumed.")
		end)
		
		-- console resume | con r
		:cmd({'toggle_stamps', 'ts'}, function()
			output:toggleTimestamps()

			system:out("Time stamps only change for new logs, clear the console to see full changes.")
		end)

		-- console resume | con r
		:cmd({'restart', 'rs'}, function()
			con:restart(game.Players.LocalPlayer.PlayerGui)
		end)

	registry:Register({'buffer', 'b'})
		-- buffer max_size | b -ms
		:cmd({'max_size', '-ms'}, function()
			system:out(`[max size]: {buffer:getMaxSize()}`)
		end)
		-- buffer size | b -s
		:cmd({'size', '-s'}, function()
			system:out(`[current size]: {buffer:getSize()}`)
		end)
		-- buffer data | b -d
		:cmd({'data', '-d'}, function()
			system:out(`[data]: {buffer:getData()}`)
		end)
		
		-- buffer set <number> | b set <number>
		:cmd({'set'}, {"number"}, function(n)
			buffer:setSize(n)
			system:out(`[max size set]: {n}`)
		end)
	
	registry:Register({'echo', 'e'})
		:cmd(nil, {"string"}, function(arg)
			if arg ~= nil or arg == "" then
				output:out(arg)
			end
		end)

end
]]
