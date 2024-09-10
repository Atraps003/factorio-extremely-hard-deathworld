local handler = require("event_handler")
handler.add_lib(require("freeplay"))
handler.add_lib(require("silo-script"))

commands.add_command("reset", "Resets map with random seed. Accepts valid seed as parameter.", function(command)
	local player = game.get_player(command.player_index)
	if player.admin == true then
		if command.parameter ~= nil then
			if tonumber(command.parameter, 10) ~= nil then
				local reset_seed = tonumber(command.parameter)
				if reset_seed > 0 and reset_seed < 4294967296 then
					global.reset_seed = reset_seed
				end
			end
		else
			global.reset_seed = math.random(1111, 4294967295)
		end
		reset(string.format("%s has manually forced a reset.", player.name))
	end
end)
