local util = require("util")
local crash_site = require("crash-site")

----We disable victory conditions of silo script because it doesn't work with soft reset
global.no_victory = true
----

global.extremely_hard_victory = false

global.restart = "false"

global.latch = 0
global.u = {
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0},
{0,0,0}
}
global.biter_hp = 1
global.kills_min = 250
global.kills_max = 300

global.player_state = {}
global.first_respawn = true

local default_player_state = function ()
	return {
		has_received_starting_items = false
	}
end

local created_items = function()
	return
	{
		["iron-plate"] = 8,
		["wood"] = 1,
		["pistol"] = 1,
		["firearm-magazine"] = 10,
		["burner-mining-drill"] = 1,
		["stone-furnace"] = 1
	}
end

local respawn_items = function()
	return
	{
		["pistol"] = 1,
		["firearm-magazine"] = 5
	}
end

local ship_items = function()
	return
	{
		["firearm-magazine"] = 180,
		["gun-turret"] = 9
	}
end

local debris_items = function()
	return
	{
		["iron-plate"] = 8,
		["burner-mining-drill"] = 30,
		["stone-furnace"] = 20
	}
end

local ship_parts = function()
	return crash_site.default_ship_parts()
end
-----------------------------------------------------------------------------------------------------------------
local change_seed = function()
	local surface = game.surfaces[1]
	local mgs = surface.map_gen_settings
	mgs.seed = math.random(1111,999999999)
	surface.map_gen_settings = mgs
end
-------------------------------------------------------------------------------------------------------------------------------

-- Some values need to be reset pre-surface clear, and some need to be set
-- post-surface clear.
--
-- For the most part, settings should be set post-clear, but a few select
-- variables that control how the game behaves during resets, might need special
-- care on when it is called.
local reset_global_setings__pre_surface_clear = function ()
	-- Altering tiles during a surface clear causes desyncs, this is a known factorio bug.
	-- See https://forums.factorio.com/viewtopic.php?f=230&t=113601

	-- [on_chunk_generated] checks [converted_shallow_water] to determine if to
	-- convert water tiles immediately. We need to disable this flag before
	-- reset, so that reset chunks are not touch until the surface clear is
	-- fully complete.
	-- global.converted_shallow_water = false
	
	-- We reset time played before clearing the surface. That way,
	-- the periodic check that converts all water tiles does not fire until
	-- after the surface map-generation is fully complete.
	game.reset_time_played()
end

local reset_global_settings__post_surface_clear = function()
	-- clear game statistics
	game.reset_game_state()
	game.forces["enemy"].reset()
	game.forces["enemy"].reset_evolution()
	game.pollution_statistics.clear()

	-- clear globals
	global.extremely_hard_victory = false
	global.latch = 0
	global.u = {
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0}
	}
	global.player_state = {}
	global.first_respawn = true
	global.biter_hp = 1
	global.kills_min = 250
	global.kills_max = 300

	-- default starting map settings
	game.map_settings.enemy_evolution.destroy_factor = 0
	game.map_settings.enemy_evolution.pollution_factor = 0
	game.map_settings.enemy_evolution.time_factor = 0.00007
	game.map_settings.enemy_expansion.enabled = true
	game.map_settings.enemy_expansion.max_expansion_cooldown  = 4000
	game.map_settings.enemy_expansion.min_expansion_cooldown  = 3000
	game.map_settings.enemy_expansion.settler_group_max_size  = 11
	game.map_settings.enemy_expansion.settler_group_min_size = 10
	game.map_settings.path_finder.general_entity_collision_penalty = 1
	game.map_settings.path_finder.general_entity_subsequent_collision_penalty = 1
	game.map_settings.path_finder.ignore_moving_enemy_collision_distance = 0
	game.map_settings.max_failed_behavior_count = 1
	game.map_settings.pollution.ageing = 0.5
	game.map_settings.pollution.enabled = true
	game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.5
	game.map_settings.unit_group.max_gathering_unit_groups = 30
	game.map_settings.unit_group.max_unit_group_size = 150

	local surface = game.surfaces[1]
	if math.random(1,2) == 2 then
		--pitch black nights
		surface.brightness_visual_weights = { 1, 1, 1 }
		surface.min_brightness = 0
		surface.dawn = 0.80
		surface.dusk = 0.20
		surface.evening = 0.40
		surface.morning = 0.60
		surface.daytime = 0.61
		surface.freeze_daytime = false
	else
		--default nights
		surface.brightness_visual_weights = { 0, 0, 0 }
		surface.min_brightness = 0.15
		surface.dawn = 0.80
		surface.dusk = 0.20
		surface.evening = 0.40
		surface.morning = 0.60
		surface.daytime = 0.75
		surface.freeze_daytime = false
	end
	
	game.forces["enemy"].friendly_fire = false
	game.forces["player"].research_queue_enabled = true
	game.forces["player"].max_failed_attempts_per_tick_per_construction_queue = 2
	game.forces["player"].max_successful_attempts_per_tick_per_construction_queue = 6
	game.difficulty_settings.technology_price_multiplier = 1
	game.difficulty_settings.recipe_difficulty = 0
	surface.solar_power_multiplier = 1
	game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -0.8)
	game.forces["player"].set_turret_attack_modifier("laser-turret", 1.35)
	game.forces["player"].set_gun_speed_modifier("laser", 4)
end

local reset_global_settings = function ()
	reset_global_setings__pre_surface_clear()
	reset_global_settings__post_surface_clear()
end

local handle_player_created_or_respawned = function(player_index)
	local player = game.get_player(player_index)

	if global.player_state[player_index] == nil then
		global.player_state[player_index] = default_player_state()
	end
	local player_state = global.player_state[player_index]

	if player_state.has_received_starting_items == false then
		player_state.has_received_starting_items = true
		util.insert_safe(player, global.created_items)
	else
		util.insert_safe(player, global.respawn_items)
	end
end

local on_player_created = function(event)
	local player = game.get_player(event.player_index)
	local name = player.name
	local x = {ID = (event.player_index - 1), Name = name}
	print(serpent.line(x))

	handle_player_created_or_respawned(event.player_index)
	
	if not global.init_ran then
	-- This is so that other mods and scripts have a chance to do remote calls before we do things like charting the starting area, creating the crash site, etc.
		global.init_ran = true
		
		reset_global_settings()
		game.forces.player.chart(game.surfaces[1], {{x = -200, y = -200}, {x = 200, y = 200}})

		if not global.disable_crashsite then
			local surface = player.surface
			crash_site.create_crash_site(surface, {-5,-6}, util.copy(global.crashed_ship_items), util.copy(global.crashed_debris_items), util.copy(global.crashed_ship_parts))
		end
		
	end
	
	if not global.skip_intro then
		player.print(global.custom_intro_message or {"msg-intro"})
	end
	
end

local on_player_respawned = function(event)
	handle_player_created_or_respawned(event.player_index)
	if global.first_respawn == true then
		global.first_respawn = false
		game.forces.player.chart(game.surfaces[1], {{x = -200, y = -200}, {x = 200, y = 200}})
	end
end
------------------------------------------------------------------------------------------------
function reset(reason)
	local reset_type = nil
	local red = game.forces["player"].item_production_statistics.get_output_count "automation-science-pack"
	if (global.restart == "true") then
		reset_type = "[color=red][font=default-large-bold]Hard reset[/font][/color]"
		game.write_file("reset/reset.log", "restart", false, 0)
	else
		if (red > 0) then
			local victory = global.extremely_hard_victory
			local deaths = game.forces["player"].kill_count_statistics.get_output_count "character"
			local minutes = math.floor((game.ticks_played / 3600) * 10) / 10
			game.write_file("reset/reset.log", {"",victory,"_",red,"_",deaths,"_",minutes}, false, 0)
		end
		reset_type = "[color=green][font=default-large-bold]Soft reset[/font][/color]"
		change_seed()
		game.surfaces[1].clear(true)
		game.forces["player"].reset()
	end
	if reason ~= nil then
		game.print(string.format("%s [color=yellow]%s[/color]", reset_type, reason))
	end
end
-----------------------------------------------------------------------------------------------
local on_pre_surface_cleared = function(event) 
	reset_global_setings__pre_surface_clear()

	-- We need to kill all players _before_ the surface is cleared, so that
	-- their inventory, and crafting queue, end up on the old surface
	for _, pl in pairs(game.players) do
		if pl.connected and pl.character ~= nil then
			-- We call die() here because otherwise we will spawn a duplicate
			-- character, who will carry over into the new surface
			pl.character.die()
		end
		-- Setting [ticks_to_respawn] to 1 seems to consistantly kill offline
		-- players. Calling this for online players will cause them instead be
		-- respawned the next tick, skipping the 10 respawn second timer.
		pl.ticks_to_respawn = 1
	end
end
-----------------------------------------------------------------------------------------------
local on_surface_cleared = function(event)
	reset_global_settings__post_surface_clear()

	local surface = game.surfaces[1]
	surface.request_to_generate_chunks({0, 0}, 6)
	surface.force_generate_chunk_requests()
	crash_site.create_crash_site(surface, {-5,-6}, util.copy(global.crashed_ship_items), util.copy(global.crashed_debris_items), util.copy(global.crashed_ship_parts))
end
------------------------------------------------------------------------------------------
local on_player_toggled_map_editor = function(event)
	global.restart = "true"

	local player = game.get_player(event.player_index)
	reset(string.format("%s has toggled the map editor.", player.name))
end
------------------------------------------------------------------------------------------
local on_console_command = function(event)
	local command = event.command
	local parameters = event.parameters
	print(command)
	print(parameters)

	if (game.console_command_used and global.restart ~= "true") then
		global.restart = "true"
		local name = nil
		if event.player_index ~= nil then
			name = game.get_player(event.player_index).name
		end
		reset(string.format("%s has used a console command.", name or "SERVER"))
	end
end
--------------------------------------------------------------------------------------------
local on_unit_group_finished_gathering = function(event)
	if event.group.command.ignore_planner == false then
		if global.latch == 0 then
			global.latch = 1
		else
			global.latch = 0
			local command = {
			type = defines.command.compound,structure_type = defines.compound_command.return_last,commands =
			{
			{type = defines.command.go_to_location,destination = {0, 0}},
			{type = defines.command.attack_area,destination = {0, 0},radius = 16,distraction = defines.distraction.by_anything},
			{type = defines.command.build_base,destination = {0, 0},distraction = defines.distraction.none,ignore_planner = true}
			}
			}
			event.group.set_command(command)
		end
	else
		if math.random(1,3) ~= 2 then
			local command = {
			type = defines.command.compound,structure_type = defines.compound_command.return_last,commands =
			{
			{type = defines.command.go_to_location,destination = {0, 0}},
			{type = defines.command.attack_area,destination = {0, 0},radius = 16,distraction = defines.distraction.by_anything},
			{type = defines.command.build_base,destination = {0, 0},distraction = defines.distraction.none,ignore_planner = true}
			}
			}
			event.group.set_command(command)
		else
			local x = event.group.position.x
			local y = event.group.position.y
			local dx1 = x - global.u[1][1]
			local dy1 = y - global.u[1][2]
			local dx2 = x - global.u[2][1]
			local dy2 = y - global.u[2][2]
			local dx3 = x - global.u[3][1]
			local dy3 = y - global.u[3][2]
			local dx4 = x - global.u[4][1]
			local dy4 = y - global.u[4][2]
			local dx5 = x - global.u[5][1]
			local dy5 = y - global.u[5][2]
			local dx6 = x - global.u[6][1]
			local dy6 = y - global.u[6][2]
			local dx7 = x - global.u[7][1]
			local dy7 = y - global.u[7][2]
			local dx8 = x - global.u[8][1]
			local dy8 = y - global.u[8][2]
			local dx9 = x - global.u[9][1]
			local dy9 = y - global.u[9][2]
			local dx10 = x - global.u[10][1]
			local dy10 = y - global.u[10][2]
			local dx11 = x - global.u[11][1]
			local dy11 = y - global.u[11][2]
			local dx12 = x - global.u[12][1]
			local dy12 = y - global.u[12][2]
			local dx13 = x - global.u[13][1]
			local dy13 = y - global.u[13][2]
			local dx14 = x - global.u[14][1]
			local dy14 = y - global.u[14][2]
			local dx15 = x - global.u[15][1]
			local dy15 = y - global.u[15][2]
			local dx16 = x - global.u[16][1]
			local dy16 = y - global.u[16][2]
			local dx17 = x - global.u[17][1]
			local dy17 = y - global.u[17][2]
			local dx18 = x - global.u[18][1]
			local dy18 = y - global.u[18][2]
			local dx19 = x - global.u[19][1]
			local dy19 = y - global.u[19][2]
			local dx20 = x - global.u[20][1]
			local dy20 = y - global.u[20][2]
			global.u[1][3] = (math.sqrt(dx1 * dx1 + dy1 * dy1))
			global.u[2][3] = (math.sqrt(dx2 * dx2 + dy2 * dy2))
			global.u[3][3] = (math.sqrt(dx3 * dx3 + dy3 * dy3))
			global.u[4][3] = (math.sqrt(dx4 * dx4 + dy4 * dy4))
			global.u[5][3] = (math.sqrt(dx5 * dx5 + dy5 * dy5))
			global.u[6][3] = (math.sqrt(dx6 * dx6 + dy6 * dy6))
			global.u[7][3] = (math.sqrt(dx7 * dx7 + dy7 * dy7))
			global.u[8][3] = (math.sqrt(dx8 * dx8 + dy8 * dy8))
			global.u[9][3] = (math.sqrt(dx9 * dx9 + dy9 * dy9))
			global.u[10][3] = (math.sqrt(dx10 * dx10 + dy10 * dy10))
			global.u[11][3] = (math.sqrt(dx11 * dx11 + dy11 * dy11))
			global.u[12][3] = (math.sqrt(dx12 * dx12 + dy12 * dy12))
			global.u[13][3] = (math.sqrt(dx13 * dx13 + dy13 * dy13))
			global.u[14][3] = (math.sqrt(dx14 * dx14 + dy14 * dy14))
			global.u[15][3] = (math.sqrt(dx15 * dx15 + dy15 * dy15))
			global.u[16][3] = (math.sqrt(dx16 * dx16 + dy16 * dy16))
			global.u[17][3] = (math.sqrt(dx17 * dx17 + dy17 * dy17))
			global.u[18][3] = (math.sqrt(dx18 * dx18 + dy18 * dy18))
			global.u[19][3] = (math.sqrt(dx19 * dx19 + dy19 * dy19))
			global.u[20][3] = (math.sqrt(dx20 * dx20 + dy20 * dy20))
			table.sort(global.u, function(a,b) local aNum = a[3] local bNum = b[3] return aNum < bNum end)
			local command = {
			type = defines.command.compound,structure_type = defines.compound_command.return_last,commands =
			{
			{type = defines.command.go_to_location,destination = {global.u[1][1], global.u[1][2]}},
			{type = defines.command.build_base,destination = {global.u[1][1], global.u[1][2]},distraction = defines.distraction.none,ignore_planner = true}
			}
			}
			event.group.set_command(command)
		end
	end
end
-------------------------------------------------------------------------------------------------------
script.on_nth_tick(18000, function()
	local evo = game.forces["enemy"].evolution_factor
	local kills = game.forces["player"].kill_count_statistics.get_flow_count{name="medium-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} + game.forces["player"].kill_count_statistics.get_flow_count{name="big-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} + game.forces["player"].kill_count_statistics.get_flow_count{name="behemoth-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} + (game.forces["player"].kill_count_statistics.get_flow_count{name="small-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} * 0.5)
	local pollution = game.pollution_statistics.get_flow_count{name="biter-spawner",output=true,precision_index=defines.flow_precision_index.ten_minutes}
	local tpd = ((evo + 1) * 25000)
	game.surfaces[1].ticks_per_day = tpd
	---------------------------------------------------------------------------------------------------------------------------------
	--  local hours = math.floor((game.ticks_played / 216000) * 100) / 100
	--  local rounded_evo = math.floor(evo * 100) / 100
	--  game.write_file("evo", {"",rounded_evo," evo in ",hours," hours\n"}, true, 1)
	---------------------------------------------------------------------------------------------------------------------------------
	if (evo > 0.3 and evo < 0.5) then
		game.map_settings.enemy_evolution.time_factor = 0.00056
	end
	if (evo > 0.5 and evo < 0.7) then
		game.map_settings.enemy_evolution.time_factor = 0.0008
	end
	if (evo > 0.7 and evo < 0.9) then
		game.map_settings.enemy_evolution.time_factor = 0.004
	end
	if (evo > 0.95) then
		global.biter_hp = global.biter_hp + 1
	end
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if (kills < global.kills_min and pollution > 1) then
		game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = (math.max((game.map_settings.pollution.enemy_attack_pollution_consumption_modifier * 0.7), 0.01))
	end
	if (kills > global.kills_max and pollution > 1) then
		game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = (math.min((game.map_settings.pollution.enemy_attack_pollution_consumption_modifier * 1.3), 1.5))
	end
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 if (game.ticks_played > 35000) then
	 	game.map_settings.enemy_expansion.settler_group_min_size = 90
	 	game.map_settings.enemy_expansion.settler_group_max_size  = 100
	 end
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if game.ticks_played > 36288000 then
		reset("Game has reached its maximum playtime of 7 days.")
	end
end)
----------------------------------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_entity_died,
function(event)
	if math.random(1,5) == 2 then
		local create_entity = game.surfaces[1].create_entity
		local entity_position = event.entity.position
		local rand = math.random(1, 20)
		create_entity{name = "grenade", target = entity_position, speed = 1, position = entity_position, force = "enemy"}
		global.u[rand][1] = entity_position.x
		global.u[rand][2] = entity_position.y
	end
end
)
script.set_event_filter(defines.events.on_entity_died, {{filter = "name", name = "behemoth-spitter"}, {filter = "name", name = "big-spitter"}, {filter = "name", name = "medium-spitter"}, {filter = "name", name = "small-spitter"}})
----------------------------------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_entity_damaged,
function(event)
	if math.random(1, global.biter_hp) ~= global.biter_hp then
		event.entity.health = 3000
	end
end
)
script.set_event_filter(defines.events.on_entity_damaged, {{filter = "name", name = "behemoth-biter"}, {filter = "final-health", comparison = "=", value = 0, mode = "and"}})
----------------------------------------------------------------------------------------------------------
local on_biter_base_built = function(event)
	local oxpos = event.entity.position.x
	local oypos = event.entity.position.y
	if (oxpos > -32 and oxpos < 32 and oypos > -32 and oypos < 32) then
		reset("Uh oh... The biters have overtaken your spawn!")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
local on_rocket_launched = function(event)
	if global.extremely_hard_victory == false then
		game.forces["enemy"].kill_all_units()
		game.surfaces[1].clear_pollution()
		game.map_settings.pollution.enabled = false
		global.extremely_hard_victory = true
		game.set_game_state{game_finished = true, player_won = true, can_continue = true, victorious_force = player}
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------
local on_research_finished = function(event)
	game.difficulty_settings.technology_price_multiplier = 1
	game.surfaces[1].solar_power_multiplier = ((game.forces["player"].mining_drill_productivity_bonus * 10) + 1)
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	if (event.research.name == "laser-shooting-speed-1") then
		game.forces["player"].set_gun_speed_modifier("laser", 5)
	end
	if (event.research.name == "laser-shooting-speed-2") then
		game.forces["player"].set_gun_speed_modifier("laser", 5.1)
	end
	if (event.research.name == "laser-shooting-speed-3") then
		game.forces["player"].set_gun_speed_modifier("laser", 5.2)
	end
	if (event.research.name == "laser-shooting-speed-4") then
		game.forces["player"].set_gun_speed_modifier("laser", 5.3)
	end
	if (event.research.name == "laser-shooting-speed-5") then
		game.forces["player"].set_gun_speed_modifier("laser", 5.4)
	end
	if (event.research.name == "laser-shooting-speed-6") then
		game.forces["player"].set_gun_speed_modifier("laser", 5.5)
	end
	if (event.research.name == "laser-shooting-speed-7") then
		game.forces["player"].set_gun_speed_modifier("laser", 5.6)
	end
	------------------------------------------------------------------------------------
	if (event.research.name == "physical-projectile-damage-1") then
	game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	end
	if (event.research.name == "physical-projectile-damage-2") then
	game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	end
	if (event.research.name == "physical-projectile-damage-3") then
	game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	end
	if (event.research.name == "physical-projectile-damage-4") then
	game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	end
	if (event.research.name == "physical-projectile-damage-5") then
	game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	end
	if (event.research.name == "physical-projectile-damage-6") then
	game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	end
	---------------------------------------------------------------------------------------------------------
	if (event.research.name == "refined-flammables-1") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -0.79)
	end
	if (event.research.name == "refined-flammables-2") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -0.78)
	end
	if (event.research.name == "refined-flammables-3") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -0.76)
	end
	if (event.research.name == "refined-flammables-4") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -0.73)
	end
	if (event.research.name == "refined-flammables-5") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -0.7)
	end
	if (event.research.name == "refined-flammables-6") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -0.65)
	end
	--------------------------------------------------------------------------------------------
	if (event.research.name == "worker-robots-speed-1") then
		game.forces["player"].worker_robots_speed_modifier = 1
		game.forces["player"].worker_robots_battery_modifier = 0.5
	end
	if (event.research.name == "worker-robots-speed-2") then
		game.forces["player"].worker_robots_speed_modifier = 2
		game.forces["player"].worker_robots_battery_modifier = 1
	end
	if (event.research.name == "worker-robots-speed-3") then
		game.forces["player"].worker_robots_speed_modifier = 4
		game.forces["player"].worker_robots_battery_modifier = 2
	end
	if (event.research.name == "worker-robots-speed-4") then
		game.forces["player"].worker_robots_speed_modifier = 7
		game.forces["player"].worker_robots_battery_modifier = 3.5
	end
	if (event.research.name == "worker-robots-speed-5") then
		game.forces["player"].worker_robots_speed_modifier = 12
		game.forces["player"].worker_robots_battery_modifier = 6
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local on_research_cancelled = function(event)
	game.difficulty_settings.technology_price_multiplier = 1
end
-------------------------------------------------------------------------------------------
local on_research_started = function(event)
	if (event.research.name == "nuclear-power") then
		game.difficulty_settings.technology_price_multiplier = 0.5
	end
	if (event.research.name == "spidertron") then
		game.difficulty_settings.technology_price_multiplier = 0.16
	end
	if (event.research.name == "atomic-bomb") then
		game.difficulty_settings.technology_price_multiplier = 0.08
	end
	if (event.research.name == "artillery") then
		game.difficulty_settings.technology_price_multiplier = 0.2
	end
	if (event.research.name == "uranium-ammo") then
		game.difficulty_settings.technology_price_multiplier = 0.4
	end
	if (event.research.name == "kovarex-enrichment-process") then
		game.difficulty_settings.technology_price_multiplier = 0.25
	end
	if (event.research.name == "rocket-silo") then
		game.difficulty_settings.technology_price_multiplier = 10
	end
end
-------------------------------------------------------------------------------------------
local on_cutscene_waypoint_reached = function(event)
	if not global.crash_site_cutscene_active then return end
	if not crash_site.is_crash_site_cutscene(event) then return end
	
	local player = game.get_player(event.player_index)
	
	player.exit_cutscene()
	
	if not global.skip_intro then
		if game.is_multiplayer() then
			player.print(global.custom_intro_message or {"msg-intro"})
		else
			game.show_message_dialog{text = global.custom_intro_message or {"msg-intro"}}
		end
	end
end

local skip_crash_site_cutscene = function(event)
	if not global.crash_site_cutscene_active then return end
	if event.player_index ~= 1 then return end
	local player = game.get_player(event.player_index)
	if player.controller_type == defines.controllers.cutscene then
		player.exit_cutscene()
	end
end

local on_cutscene_cancelled = function(event)
	if not global.crash_site_cutscene_active then return end
	if event.player_index ~= 1 then return end
	global.crash_site_cutscene_active = nil
	local player = game.get_player(event.player_index)
	if player.gui.screen.skip_cutscene_label then
		player.gui.screen.skip_cutscene_label.destroy()
	end
	if player.character then
		player.character.destructible = true
	end
	player.zoom = 1.5
end

local on_player_display_refresh = function(event)
	crash_site.on_player_display_refresh(event)
end

local freeplay_interface =
{
	get_created_items = function()
		return global.created_items
	end,
	set_created_items = function(map)
		global.created_items = map or error("Remote call parameter to freeplay set created items can't be nil.")
	end,
	get_respawn_items = function()
		return global.respawn_items
	end,
	set_respawn_items = function(map)
		global.respawn_items = map or error("Remote call parameter to freeplay set respawn items can't be nil.")
	end,
	set_skip_intro = function(bool)
		global.skip_intro = bool
	end,
	get_skip_intro = function()
		return global.skip_intro
	end,
	set_custom_intro_message = function(message)
		global.custom_intro_message = message
	end,
	get_custom_intro_message = function()
		return global.custom_intro_message
	end,
	set_chart_distance = function(value)
		global.chart_distance = tonumber(value) or error("Remote call parameter to freeplay set chart distance must be a number")
	end,
	get_disable_crashsite = function()
		return global.disable_crashsite
	end,
	set_disable_crashsite = function(bool)
		global.disable_crashsite = bool
	end,
	get_init_ran = function()
		return global.init_ran
	end,
	get_ship_items = function()
		return global.crashed_ship_items
	end,
	set_ship_items = function(map)
		global.crashed_ship_items = map or error("Remote call parameter to freeplay set created items can't be nil.")
	end,
	get_debris_items = function()
		return global.crashed_debris_items
	end,
	set_debris_items = function(map)
		global.crashed_debris_items = map or error("Remote call parameter to freeplay set respawn items can't be nil.")
	end,
	get_ship_parts = function()
		return global.crashed_ship_parts
	end,
	set_ship_parts = function(parts)
		global.crashed_ship_parts = parts or error("Remote call parameter to freeplay set ship parts can't be nil.")
	end
}

if not remote.interfaces["freeplay"] then
	remote.add_interface("freeplay", freeplay_interface)
end

local is_debug = function()
	local surface = game.surfaces.nauvis
	local map_gen_settings = surface.map_gen_settings
	return map_gen_settings.width == 50 and map_gen_settings.height == 50
end

local freeplay = {}

freeplay.events =
{
	[defines.events.on_player_created] = on_player_created,
	[defines.events.on_player_respawned] = on_player_respawned,
	[defines.events.on_cutscene_waypoint_reached] = on_cutscene_waypoint_reached,
	["crash-site-skip-cutscene"] = skip_crash_site_cutscene,
	[defines.events.on_player_display_resolution_changed] = on_player_display_refresh,
	[defines.events.on_player_display_scale_changed] = on_player_display_refresh,
	[defines.events.on_cutscene_cancelled] = on_cutscene_cancelled,
	[defines.events.on_research_finished] = on_research_finished,
	[defines.events.on_unit_group_finished_gathering] = on_unit_group_finished_gathering,
	[defines.events.on_biter_base_built] = on_biter_base_built,
	[defines.events.on_rocket_launched] = on_rocket_launched,
	[defines.events.on_pre_surface_cleared] = on_pre_surface_cleared,
	[defines.events.on_surface_cleared] = on_surface_cleared,
	[defines.events.on_console_command] = on_console_command,
	[defines.events.on_player_toggled_map_editor] = on_player_toggled_map_editor,
	[defines.events.on_research_cancelled] = on_research_cancelled,
	[defines.events.on_research_started] = on_research_started
	
}


freeplay.on_configuration_changed = function()
	global.created_items = global.created_items or created_items()
	global.respawn_items = global.respawn_items or respawn_items()
	global.crashed_ship_items = global.crashed_ship_items or ship_items()
	global.crashed_debris_items = global.crashed_debris_items or debris_items()
	global.crashed_ship_parts = global.crashed_ship_parts or ship_parts()
	
	if not global.init_ran then
		-- migrating old saves.
		global.init_ran = #game.players > 0
	end
end


freeplay.on_init = function()
	global.created_items = created_items()
	global.respawn_items = respawn_items()
	global.crashed_ship_items = ship_items()
	global.crashed_debris_items = debris_items()
	global.crashed_ship_parts = ship_parts()
	
	if is_debug() then
		global.skip_intro = true
		global.disable_crashsite = true
	end
	
end

return freeplay
