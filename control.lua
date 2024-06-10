local handler = require("event_handler")
handler.add_lib(require("freeplay"))
handler.add_lib(require("silo-script"))

commands.add_command("reset", "Reset map", function(command)
	if game.get_player(command.player_index).admin == true then
	reset()
	end
end)
