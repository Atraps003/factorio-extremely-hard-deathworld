local handler = require("event_handler")
handler.add_lib(require("freeplay"))
handler.add_lib(require("silo-script"))

commands.add_command("reset", "Reset map", function(command)
	local player = game.get_player(command.player_index)
	if player.admin == true then
	reset(string.format("%s has manually forced a reset.", player.name))
	end
end)
