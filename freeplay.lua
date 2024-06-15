local util = require("util")
local crash_site = require("crash-site")

global.restart = "false"
global.tick_to_start_charting_spawn = nil

global.latch = 0
global.w = "small-worm-turret"
global.e = "grenade"
global.n = 6
global.f = {}
global.t = {}
global.pu = {}
global.r = {}
global.s = {}

--[[
	key: player_idnex
	value: 
	{ has_received_starting_items: bool
	}
--]]
global.player_state = {}

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
		["firearm-magazine"] = 8
	}
end

local debris_items = function()
	return
	{
		["iron-plate"] = 8
	}
end

local ship_parts = function()
	return crash_site.default_ship_parts()
end

local chart_starting_area = function()
	local r = global.chart_distance or 200
	local force = game.forces.player
	local surface = game.surfaces[1]
	local origin = force.get_spawn_position(surface)
	force.chart(surface, {{origin.x - r, origin.y - r}, {origin.x + r, origin.y + r}})
end

-----------------------------------------------------------------------------------------------------------------
local map_gen_1 = function()
	local surface = game.surfaces[1]
	local iron = "iron-ore"
	local copper = "copper-ore"
	local coal = "coal"
	local stone = "stone"
	local oil = "crude-oil"
	local uranium = "uranium-ore"
	local enemy = "enemy-base"
	local mgs = surface.map_gen_settings
	mgs.water = "1"
	mgs.terrain_segmentation = "1"
	mgs.autoplace_controls[iron].size = "10"
	mgs.autoplace_controls[iron].frequency = "1"
	mgs.autoplace_controls[iron].richness = "1"
	mgs.autoplace_controls[copper].size = "10"
	mgs.autoplace_controls[copper].frequency = "1"
	mgs.autoplace_controls[copper].richness = "1"
	mgs.autoplace_controls[coal].size = "10"
	mgs.autoplace_controls[coal].frequency = "1"
	mgs.autoplace_controls[coal].richness = "1"
	mgs.autoplace_controls[stone].size = "10"
	mgs.autoplace_controls[stone].frequency = "1"
	mgs.autoplace_controls[stone].richness = "1"
	mgs.autoplace_controls[oil].size = "10"
	mgs.autoplace_controls[oil].frequency = "10"
	mgs.autoplace_controls[oil].richness = "0.05"
	mgs.autoplace_controls[uranium].size = "4"
	mgs.autoplace_controls[uranium].frequency = "0.1"
	mgs.autoplace_controls[uranium].richness = "1"
	mgs.autoplace_controls[enemy].size = "6"
	mgs.autoplace_controls[enemy].frequency = "1"
	surface.map_gen_settings = mgs
end

local change_seed = function()
	local surface = game.surfaces[1]
	local mgs = surface.map_gen_settings
	mgs.seed = math.random(1111,999999999)
	surface.map_gen_settings = mgs
end
-------------------------------------------------------------------------------------------------------------------------------

local reset_global_settings = function()
	-- clear game statistics
	game.reset_game_state()
	game.reset_time_played()
	game.forces["enemy"].reset()
	game.forces["enemy"].reset_evolution()
	game.pollution_statistics.clear()

	-- clear globals
	global.latch = 0
	global.w = "small-worm-turret"
	global.e = "grenade"
	global.n = 6
	global.f = {}
	global.t = {}
	global.pu = {}
	global.r = {}
	global.s = {}
	global.player_state = {}

	-- default starting map settings
	game.map_settings.enemy_evolution.destroy_factor = 0
	game.map_settings.enemy_evolution.pollution_factor = 0.0000009
	game.map_settings.enemy_evolution.time_factor = 0.00002
	game.map_settings.enemy_expansion.enabled = true
	game.map_settings.enemy_expansion.max_expansion_cooldown  = 4000
	game.map_settings.enemy_expansion.min_expansion_cooldown  = 3000
	game.map_settings.enemy_expansion.settler_group_max_size  = 7
	game.map_settings.enemy_expansion.settler_group_min_size = 5
	game.map_settings.path_finder.general_entity_collision_penalty = 1
	game.map_settings.path_finder.general_entity_subsequent_collision_penalty = 1
	game.map_settings.pollution.ageing = 0.5
	game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.5
	game.map_settings.unit_group.max_gathering_unit_groups = 30
	game.map_settings.unit_group.max_unit_group_size = 300

	local surface = game.surfaces[1]
	surface.brightness_visual_weights = { 1, 1, 1 }
	surface.min_brightness = 0
	surface.dawn = 0.80
	surface.dusk = 0.20
	surface.evening = 0.40
	surface.morning = 0.60
	surface.daytime = 0.70
	surface.freeze_daytime = false

	game.forces["enemy"].friendly_fire = false
	game.forces["player"].research_queue_enabled = true

--  game.map_settings.enemy_expansion.max_expansion_distance = 1
--  game.map_settings.enemy_expansion.friendly_base_influence_radius = 0
--	game.map_settings.enemy_expansion.enemy_building_influence_radius  = 0
--  game.map_settings.enemy_expansion.other_base_coefficient = 0
--	game.map_settings.enemy_expansion.building_coefficient = 0
--  game.map_settings.enemy_expansion.max_colliding_tiles_coefficient = 0

--	game.forces["player"].max_successful_attempts_per_tick_per_construction_queue = 10
--	game.forces["player"].max_failed_attempts_per_tick_per_construction_queue = 10
--	game.permissions.get_group('Default').set_allows_action(defines.input_action.add_permission_group, false)
--	game.permissions.get_group('Default').set_allows_action(defines.input_action.delete_permission_group, false)
--	game.permissions.get_group('Default').set_allows_action(defines.input_action.edit_permission_group, false)
--	game.permissions.get_group('Default').set_allows_action(defines.input_action.import_permissions_string, false)
--	game.permissions.get_group('Default').set_allows_action(defines.input_action.map_editor_action, false)
--	game.permissions.get_group('Default').set_allows_action(defines.input_action.toggle_map_editor, false)
--	game.permissions.create_group('Owner')
--	game.permissions.get_group('Owner').add_player("Atraps003")

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

		chart_starting_area()
		--	map_gen_1()

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

	-- CR-someday: Ideally, we should not be using the [on_player_respawned] event to chart the starting area.
	-- Probobly should implement a delayed execution processor to handle things like this a bit cleaner.
	if global.tick_to_start_charting_spawn ~= nil and game.tick >= global.tick_to_start_charting_spawn then
		chart_starting_area()
		global.tick_to_start_charting_spawn = nil
	end
end
-----------------------------------------ID 1--------------------------------------------------------
function f_location()
	local next = next
	local fpos = {}
	local rf = {}
	for id, f in pairs(global.f) do
		if f.valid then
			if f.kills > 200 then
				table.insert(fpos, {f.position.x, f.position.y, 1, f.direction})
			end
		else
			global.f[id] = nil
		end
	end
	if next(fpos) ~= nil then
		table.insert(rf, (fpos[math.random(#fpos)]))
		if rf[1][4] == 0 then
			rf[1][2] = rf[1][2] - 40
			rf[1][4] = nil
			if math.random(1,2) == 2
				rf[1][1] = rf[1][1] - 40
			else
				rf[1][1] = rf[1][1] + 40
			end
		end
		if rf[1][4] == 2 then
			rf[1][1] = rf[1][1] + 40
			rf[1][4] = nil
			if math.random(1,2) == 2
				rf[1][2] = rf[1][2] - 40
			else
				rf[1][2] = rf[1][2] + 40
			end
		end
		if rf[1][4] == 4 then
			rf[1][2] = rf[1][2] + 40
			rf[1][4] = nil
			if math.random(1,2) == 2
				rf[1][1] = rf[1][1] - 40
			else
				rf[1][1] = rf[1][1] + 40
			end
		end
		if rf[1][4] == 6 then
			rf[1][1] = rf[1][1] - 40
			rf[1][4] = nil
			if math.random(1,2) == 2
				rf[1][2] = rf[1][2] - 40
			else
				rf[1][2] = rf[1][2] + 40
			end
		end
		local mud = game.surfaces[1].find_tiles_filtered{name = {"water-mud"}, position = {rf[1][1], rf[1][2]}, radius = 16}
		local shallow = game.surfaces[1].find_tiles_filtered{name = {"water-shallow"}, position = {rf[1][1], rf[1][2]}, radius = 16}
		if next(mud) ~= nil or next(shallow) ~= nil then
			rf = nil
		end
		return rf
	end
end
-------------------------------------------------ID 2--------------------------------------------------------
function t_location()
	local next = next
	local rt = {}
	if next(global.t) ~= nil then
		table.insert(rt, (global.t[math.random(#global.t)]))
		return rt
	end
end
--------------------------------------------------------ID 3-------------------------------------------------------------------------------------
function pu_location()
	local next = next
	local pupos = {}
	local rpu = {}
	for id, pu in pairs(global.pu) do
		if pu.valid then
			table.insert(pupos, {pu.position.x, pu.position.y, 3})
		else
			global.pu[id] = nil
		end
	end
	if next(pupos) ~= nil then
		table.insert(rpu, (pupos[math.random(#pupos)]))
		return rpu
	end
end
---------------------------------------------------------------------ID 4------------------------------------------------------------------------
function r_location()
	local next = next
	local rpos = {}
	local rr = {}
	for id, r in pairs(global.r) do
		if r.valid then
			table.insert(rpos, {r.position.x, r.position.y, 4})
		else
			global.r[id] = nil
		end
	end
	if next(rpos) ~= nil then
		table.insert(rr, (rpos[math.random(#rpos)]))
		return rr
	end
end
--------------------------------------------------------------------ID 5------------------------------------------------------------------------
function pl_location()
	local next = next
	local plpos = {}
	local rpl = {}
	for _, pl in pairs(game.connected_players) do
		table.insert(plpos, {pl.position.x, pl.position.y, 5})
	end
	if next(plpos) ~= nil then
		table.insert(rpl, (plpos[math.random(#plpos)]))
	end
	return rpl
end
-------------------------------------------------ID 6--------------------------------------------------------
function s_location()
	local next = next
	local rs = {}
	if next(global.s) ~= nil then
		table.insert(rs, (global.s[math.random(#global.s)]))
		return rs
	end
end
------------------------------------------------------------------------------------------------
function reset(reason)
	local reset_type = nil
	if (global.restart == "true") then
		reset_type = "[color=red][font=default-large-bold]Hard reset[/font][/color]"
		game.write_file("reset/reset.log", "restart", false, 0)
	else
		reset_type = "[color=green][font=default-large-bold]Soft reset[/font][/color]"
		local victory = game.finished_but_continuing
		local red = game.forces["player"].item_production_statistics.get_output_count "automation-science-pack"
		local deaths = game.forces["player"].kill_count_statistics.get_output_count "character"
		game.write_file("reset/reset.log", {"",victory,"_",red,"_",deaths}, false, 0)
		change_seed()
		game.surfaces[1].clear(true)
		game.forces["player"].reset()
		global.tick_to_start_charting_spawn = game.tick + 1
	end

	if reason ~= nil then
		game.print(string.format("%s [color=yellow]%s[/color]", reset_type, reason))
	end
end
-----------------------------------------------------------------------------------------------
local on_pre_surface_cleared = function(event) 
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
	local surface = game.surfaces[1]
	--	game.forces["enemy"].kill_all_units()
	--	surface.request_to_generate_chunks({0, 0}, 6)
	--	surface.force_generate_chunk_requests()
	--	crash_site.create_crash_site(surface, {-5,-6}, util.copy(global.crashed_ship_items), util.copy(global.crashed_debris_items), util.copy(global.crashed_ship_parts))

	-- Spawning an explosive cannon shell used to be called to kill players at
	-- (0,0). This is no longer needed due to players being killed during
	-- [on_pre_surface_cleared], but hey, it still looks cool :)
	surface.create_entity{name = "explosive-cannon-projectile", target = {0,0}, speed=1, position = {0,0}, force = "enemy"}

	reset_global_settings()
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
			local next = next
			local selection = {}
			local selected = {}
			local f_location = f_location()
			local t_location = t_location()
			local pu_location = pu_location()
			local r_location = r_location()
			local s_location = s_location()
			local pl_location = pl_location()
			table.insert(selection, f_location)
			table.insert(selection, t_location)
			table.insert(selection, pu_location)
			table.insert(selection, r_location)
			table.insert(selection, s_location)
			if next(selection) ~= nil then
				table.insert(selected, (selection[math.random(#selection)]))
				if selected[1][1][3] == 1 then
					--					game.print("EX F [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.none,ignore_planner = true}
					event.group.set_command(command)
				end
				if selected[1][1][3] == 2 then
					--					game.print("EX T [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
					event.group.set_command(command)
					if math.random(1,3) == 2 then
						global.t = {}
					end
				end
				if selected[1][1][3] == 3 then
					--					game.print("EX PU [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
					event.group.set_command(command)
				end
				if selected[1][1][3] == 4 then
					--					game.print("EX R [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
					event.group.set_command(command)
				end
				if selected[1][1][3] == 6 then
					--					game.print("EX S [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.none,ignore_planner = true}}}
					event.group.set_command(command)
					if math.random(1,5) == 2 then
						global.s = {}
					end
				end
			end
			if next(selected) == nil and next(pl_location) ~= nil then
				table.insert(selected, pl_location)
				--				game.print("EX PL [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
				local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
				event.group.set_command(command)
			end
			if next(selected) == nil then
				table.insert(selected, {{0, 0}})
				--				game.print("EX SPAWN [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
				local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
				event.group.set_command(command)
			end
		end
	else
		if math.random(1,2) == 2 then
			local next = next
			local selection = {}
			local selected = {}
			local f_location = f_location()
			local t_location = t_location()
			local pu_location = pu_location()
			local r_location = r_location()
			local s_location = s_location()
			local pl_location = pl_location()
			table.insert(selection, f_location)
			table.insert(selection, t_location)
			table.insert(selection, pu_location)
			table.insert(selection, r_location)
			table.insert(selection, s_location)
			if next(selection) ~= nil then
				table.insert(selected, (selection[math.random(#selection)]))
				if selected[1][1][3] == 1 then
					--					game.print("PO F [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.none,ignore_planner = true}
					event.group.set_command(command)
				end
				if selected[1][1][3] == 2 then
					--					game.print("PO T [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
					event.group.set_command(command)
					if math.random(1,3) == 2 then
						global.t = {}
					end
				end
				if selected[1][1][3] == 3 then
					--					game.print("PO PU [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
					event.group.set_command(command)
				end
				if selected[1][1][3] == 4 then
					--					game.print("PO R [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
					event.group.set_command(command)
				end
				if selected[1][1][3] == 6 then
					--					game.print("PO S [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
					local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.none,ignore_planner = true}}}
					event.group.set_command(command)
					if math.random(1,5) == 2 then
						global.s = {}
					end
				end
			end
			if next(selected) == nil and next(pl_location) ~= nil then
				table.insert(selected, pl_location)
				--				game.print("PO PL [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
				local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
				event.group.set_command(command)
			end
			if next(selected) == nil then
				table.insert(selected, {{0, 0}})
				--				game.print("PO SPAWN [gps=" .. selected[1][1][1] .. "," .. selected[1][1][2] .. "]")
				local command = {type = defines.command.compound,structure_type = defines.compound_command.return_last,commands ={{type = defines.command.go_to_location,destination = {selected[1][1][1], selected[1][1][2]}},{type = defines.command.attack_area,destination = {selected[1][1][1], selected[1][1][2]},radius = 16,distraction = defines.distraction.by_anything},{type = defines.command.build_base,destination = {selected[1][1][1], selected[1][1][2]},distraction = defines.distraction.by_anything,ignore_planner = true}}}
				event.group.set_command(command)
			end
		end
	end
end
-------------------------------------------------------------------------------------------
script.on_nth_tick(36000, function()
	local evo = game.forces["enemy"].evolution_factor
	local kills = game.forces["player"].kill_count_statistics.get_flow_count{name="medium-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} + game.forces["player"].kill_count_statistics.get_flow_count{name="big-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} + game.forces["player"].kill_count_statistics.get_flow_count{name="behemoth-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} + (game.forces["player"].kill_count_statistics.get_flow_count{name="small-biter",input=true,precision_index=defines.flow_precision_index.ten_minutes} * 0.5)
	local pollution = game.pollution_statistics.get_flow_count{name="biter-spawner",output=true,precision_index=defines.flow_precision_index.ten_minutes}
	local iron = game.forces["player"].item_production_statistics.get_flow_count{name="iron-ore",input=true,precision_index=defines.flow_precision_index.one_hour}
	local tpd = ((evo + 1) * 25000)
	game.surfaces[1].ticks_per_day = tpd
	---------------------------------------------------------------------------------------------------------------------------------
	if (evo > 0.2 and evo < 0.5) then
		game.map_settings.enemy_evolution.time_factor = 0.00005
		global.w = "medium-worm-turret"
	end
	if (evo > 0.5 and evo < 0.7) then
		game.map_settings.enemy_evolution.time_factor = 0.0002
		global.w = "big-worm-turret"
	end
	if (evo > 0.7 and evo < 0.9) then
		game.map_settings.enemy_evolution.time_factor = 0.002
	end
	if (evo > 0.9) then
		global.w = "behemoth-worm-turret"
	end
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if (evo > 0.2 and kills < 250 and pollution > 1) then
		game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = (math.max((game.map_settings.pollution.enemy_attack_pollution_consumption_modifier * 0.5), 0.01))
	end
	if (evo > 0.2 and kills > 290 and pollution > 1) then
		game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = (math.min((game.map_settings.pollution.enemy_attack_pollution_consumption_modifier * 1.2), 0.5))
	end
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if (evo > 0.2 and iron > 60 and pollution < 5) then
		game.map_settings.pollution.ageing = (game.map_settings.pollution.ageing * 0.8)
	end
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if (evo > 0.034) then
		game.map_settings.enemy_expansion.settler_group_min_size = 90
		game.map_settings.enemy_expansion.settler_group_max_size  = 100
		end
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		if game.ticks_played > 36288000 then
			reset("Game has reached its maximum playtime of 7 days.")
		end
	end)

-------------------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_post_entity_died,
function(event)
	if (event.prototype.type == "unit-spawner") then
		table.insert(global.s, {event.position.x, event.position.y, 6})
	else
		table.insert(global.t, {event.position.x, event.position.y, 2})
	end
end
)
script.set_event_filter(defines.events.on_post_entity_died, {{filter = "type", type = "fluid-turret"}, {filter = "type", type = "ammo-turret"}, {filter = "type", type = "unit-spawner"}})
----------------------------------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_entity_died,
function(event)
	game.surfaces[1].create_entity{name = global.e, target = event.entity.position, speed=1, position = event.entity.position, force = "enemy"}
end
)
script.set_event_filter(defines.events.on_entity_died, {{filter = "name", name = "behemoth-spitter"}, {filter = "name", name = "big-spitter"}, {filter = "name", name = "medium-spitter"}, {filter = "name", name = "small-spitter"}})
----------------------------------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_built_entity,
function(event)
	if (event.created_entity.name == "pumpjack") then
		global.pu[event.created_entity.unit_number] = event.created_entity
	end
	if (event.created_entity.name == "nuclear-reactor") then
		global.r[event.created_entity.unit_number] = event.created_entity
	end
	if (event.created_entity.name == "flamethrower-turret") then
		global.f[event.created_entity.unit_number] = event.created_entity
	end
end
)
script.set_event_filter( defines.events.on_built_entity, {{filter = "name", name = "pumpjack"}, {filter = "name", name = "nuclear-reactor"}, {filter = "name", name = "flamethrower-turret"}})
------------------------------------------------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_robot_built_entity,
function(event)
	if (event.created_entity.name == "pumpjack") then
		global.pu[event.created_entity.unit_number] = event.created_entity
	end
	if (event.created_entity.name == "nuclear-reactor") then
		global.r[event.created_entity.unit_number] = event.created_entity
	end
	if (event.created_entity.name == "flamethrower-turret") then
		global.f[event.created_entity.unit_number] = event.created_entity
	end
end
)
script.set_event_filter( defines.events.on_robot_built_entity, {{filter = "name", name = "pumpjack"}, {filter = "name", name = "nuclear-reactor"}, {filter = "name", name = "flamethrower-turret"}})
-------------------------------------------------------------------------------------------------------------------------
local on_chunk_generated = function(event)
	local chunk_area = event.area
	local set_water_shallow = {}
	local set_water_mud = {}
	local water_count = 0
	local deepwater_count = 0
	for k, tile in pairs (game.surfaces[1].find_tiles_filtered{name = "water", area = chunk_area}) do
		water_count = water_count + 1
		set_water_shallow[water_count] = {name = "water-shallow", position = tile.position}
	end
	for k, tile in pairs (game.surfaces[1].find_tiles_filtered{name = "deepwater", area = chunk_area}) do
		deepwater_count = deepwater_count + 1
		set_water_mud[deepwater_count] = {name = "water-mud", position = tile.position}
	end
	game.surfaces[1].set_tiles(set_water_shallow)
	game.surfaces[1].set_tiles(set_water_mud)
end
----------------------------------------------------------------------------------------------------------
local on_biter_base_built = function(event)
	--	if (event.entity.type == "turret") then
	local oxpos = event.entity.position.x
	local oypos = event.entity.position.y
	local n = global.n
	local w = global.w
	local function find_location()
		local pos = game.surfaces[1].find_non_colliding_position("biter-spawner", {x = oxpos, y = oypos}, n, 2, true)
		return pos
	end
	local function create_worm()
		local loc = find_location()
		if loc ~= nil then
			game.surfaces[1].create_entity{name = w, position = loc, spawn_decorations = true}
			create_worm()
		end
	end
	create_worm()
	if (oxpos > -32 and oxpos < 32 and oypos > -32 and oypos < 32) then
		reset("Biters have nested at spawn!")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
local on_rocket_launched = function(event)
	global.e = "explosive-rocket"
	global.n = 10
end
------------------------------------------------------------------------------------------------------------------------------------------------
--local on_player_died = function(event)
--	local cause = event.cause.type
--	local player = game.get_player(event.player_index)
--	local x = player.position.x
--	local y = player.position.y
--	if (x == 0 and y == 0 and cause == "turret") then
--	game.print("RESET")
--	end
--end
-------------------------------------------------------------------------------------------------------------------------------------------
local on_research_finished = function(event)
	
	-----------------------------------------------------------------------------------------------------------
	-- local tpd = (((game.forces["player"].mining_drill_productivity_bonus * 10) + 1) * 25000)
	-- game.surfaces[1].ticks_per_day = tpd
	
	-----------------------------------------------------------------------------------------------------------
	--  if (game.forces["enemy"].evolution_factor > 0.07 and game.forces["enemy"].evolution_factor <= 0.19) then
	--  game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.5
	--  end
	--  if (game.forces["enemy"].evolution_factor > 0.200 and game.forces["enemy"].evolution_factor <= 0.550) then
	--  game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.5
	--  end
	--  if (game.forces["enemy"].evolution_factor > 0.550 and game.forces["enemy"].evolution_factor <= 0.800) then
	--  game.map_settings.pollution.ageing = 0.7
	--  game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.12
	--  game.forces["enemy"].set_ammo_damage_modifier("biological", 1)
	--  end
	--  if (game.forces["enemy"].evolution_factor > 0.800 and game.forces["enemy"].evolution_factor <= 0.950) then
	--  game.map_settings.pollution.ageing = 0.5
	--  game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.08
	--  game.forces["enemy"].set_ammo_damage_modifier("biological", 2)
	--  end
	--  if (game.forces["enemy"].evolution_factor > 0.950) then
	--  game.map_settings.pollution.ageing = 0.3
	--  game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.06
	--  game.forces["enemy"].set_ammo_damage_modifier("biological", 3)
	--  end
	------------------------------------------------------------------------------------------------------------------------------------------------------
	--  if (event.research.name == "chemical-science-pack") then
	--  game.map_settings.enemy_evolution.time_factor = 0.00003
	--  game.map_settings.enemy_evolution.pollution_factor = 0.0000012
	--  end
	--  if (event.research.name == "utility-science-pack") then
	--  game.map_settings.enemy_evolution.time_factor = 0.00006
	--  game.map_settings.enemy_evolution.pollution_factor = 0.0000013
	--  end
	--  if (event.research.name == "rocket-control-unit" or event.research.name == "military-4") then
	--  game.map_settings.enemy_evolution.time_factor = 0.00018
	--  game.map_settings.enemy_evolution.pollution_factor = 0.0000016
	--  end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	if (event.research.name == "laser-shooting-speed-1") then
		game.forces["player"].set_gun_speed_modifier("laser", 1)
	end
	if (event.research.name == "laser-shooting-speed-2") then
		game.forces["player"].set_gun_speed_modifier("laser", 2)
	end
	if (event.research.name == "laser-shooting-speed-3") then
		game.forces["player"].set_gun_speed_modifier("laser", 3)
	end
	if (event.research.name == "laser-shooting-speed-4") then
		game.forces["player"].set_gun_speed_modifier("laser", 4)
	end
	if (event.research.name == "laser-shooting-speed-5") then
		game.forces["player"].set_gun_speed_modifier("laser", 5)
	end
	if (event.research.name == "laser-shooting-speed-6") then
		game.forces["player"].set_gun_speed_modifier("laser", 6)
	end
	if (event.research.name == "laser-shooting-speed-7") then
		game.forces["player"].set_gun_speed_modifier("laser", 7)
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	--  if (event.research.name == "physical-projectile-damage-1") then
	--  game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	--  end
	--  if (event.research.name == "physical-projectile-damage-2") then
	--  game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	--  end
	--  if (event.research.name == "physical-projectile-damage-3") then
	--  game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	--  end
	--  if (event.research.name == "physical-projectile-damage-4") then
	--  game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	--  end
	--  if (event.research.name == "physical-projectile-damage-5") then
	--  game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	--  end
	--  if (event.research.name == "physical-projectile-damage-6") then
	--  game.forces["player"].set_turret_attack_modifier("gun-turret", 0)
	--  end
	---------------------------------------------------------------------------------------------------------
	--  if (event.research.name == "stronger-explosives-2") then
	--  game.forces["player"].set_ammo_damage_modifier("landmine", 0)
	--  end
	--  if (event.research.name == "stronger-explosives-3") then
	--  game.forces["player"].set_ammo_damage_modifier("landmine", 0)
	--  end
	--  if (event.research.name == "stronger-explosives-4") then
	--  game.forces["player"].set_ammo_damage_modifier("landmine", 0)
	--  end
	--  if (event.research.name == "stronger-explosives-5") then
	--  game.forces["player"].set_ammo_damage_modifier("landmine", 0)
	--  end
	--  if (event.research.name == "stronger-explosives-6") then
	--  game.forces["player"].set_ammo_damage_modifier("landmine", 0)
	--  end
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
	if (event.research.name == "refined-flammables-1") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", 0)
	end
	if (event.research.name == "refined-flammables-2") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", 0)
	end
	if (event.research.name == "refined-flammables-3") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", 0)
	end
	if (event.research.name == "refined-flammables-4") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", 0)
	end
	if (event.research.name == "refined-flammables-5") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", 0)
	end
	if (event.research.name == "refined-flammables-6") then
		game.forces["player"].set_turret_attack_modifier("flamethrower-turret", 0)
	end
	if (event.research.name == "rocket-silo") then
		game.difficulty_settings.recipe_difficulty = 1
	end
end
--  if (game.forces["player"].technologies["flamethrower"].researched == true) then
--  local evo_flame = (math.ceil(game.forces["enemy"].evolution_factor * 0.90 * 100)) / 100
--  game.forces["player"].set_turret_attack_modifier("flamethrower-turret", -evo_flame)
--  end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

-----------------------------------------------Examples--------------------------------------------------------------------

--  if (event.research.name == "rocket-silo") then
--  game.forces["enemy"].set_gun_speed_modifier("melee", 1)
--  end
--  game.forces["enemy"].evolution_factor = 1
--  game.forces["enemy"].set_ammo_damage_modifier("melee", 1)
--  game.map_settings.pollution.ageing = 0.3
--  if (event.research.name == "automation-2") then
--  game.map_settings.pollution.ageing = 0.5
--  game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.8
--  end
--  if (event.research.name == "oil-processing") then
--  game.map_settings.pollution.ageing = 0.4
--  game.map_settings.pollution.enemy_attack_pollution_consumption_modifier = 0.5
--  game.forces["enemy"].set_gun_speed_modifier("melee", 1)
--	game.forces["player"].set_turret_attack_modifier("gun-turret", -0.5)
--	game.forces["enemy"].set_ammo_damage_modifier("melee", 1)
--	game.map_settings.enemy_expansion.neighbouring_base_chunk_coefficient = 300
--	game.map_settings.enemy_expansion.neighbouring_chunk_coefficient = -3000
--  /c game.player.disable_flashlight()
--  game.difficulty_settings.technology_difficulty = 1
--  game.difficulty_settings.technology_price_multiplier = 0.001
--  Deathworld evo settings
--  game.map_settings.enemy_evolution.time_factor = 0.00002
--  game.map_settings.enemy_evolution.destroy_factor = 0.002
--  game.map_settings.enemy_evolution.pollution_factor = 0.0000012
--  game.print(serpent.line({"EVO", game.forces["enemy"].evolution_factor}))
--  game.print(serpent.line({"Attack_Cost", game.map_settings.pollution.enemy_attack_pollution_consumption_modifier}))
--  game.print(serpent.line({"Ageing", game.map_settings.pollution.ageing}))
--  game.print(serpent.line({'EVO_time', game.map_settings.enemy_evolution.time_factor}))
--  game.print(serpent.line({"EVO_pollution", game.map_settings.enemy_evolution.pollution_factor}))
--  game.print(serpent.line({"Brightness", game.surfaces[1].brightness_visual_weights}))
--  game.print(serpent.line({"Day_ticks", game.surfaces[1].ticks_per_day}))

----------------
--- How to print settings in game for debugging
---- /c game.player.print(game.player.surface.ticks_per_day)
---- /c game.player.print(serpent.block(game.player.surface.map_gen_settings))
---- game.print({global.chunk_count})
---- local printer = event.position
---- game.print(serpent.line({printer}))
--  end

------

--local on_entity_died = function(event)
--	if (event.force.name == "enemy" and event.entity.name == "gun-turret") then
--	game.print("DIED")
--	end
--end
--	game.surfaces[1].create_entity{name='atomic-rocket', target={x, y}, speed=1, position = {x, y}, force = "enemy"}
--	game.surfaces[1].set_multi_command{command = {type=defines.command.build_base, destination=event.created_entity.position, distraction=defines.distraction.by_enemy, ignore_planner=true}, unit_count = 100, unit_search_distance = 3000}
--	game.surfaces[1].build_enemy_base(event.created_entity.position, 20)

------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------OLD---------------------------------------------------------------

--local on_sector_scanned = function(event)
--	local x = event.chunk_position.x
--	local y = event.chunk_position.y
--	if (x == 12 and y == 12 or x == -12 and y == -12 or x == 12 and y == -12 or x == -12 and y == 12) then
--	map_gen_2()
--	end
--	if (game.surfaces[1].daytime > 0.8) then
--	local evo = game.forces["enemy"].evolution_factor
--	local tpd = math.ceil(((game.forces["enemy"].evolution_factor * 2) + 1) * 25000)
--	game.surfaces[1].brightness_visual_weights = { evo, evo, evo }
--	game.surfaces[1].ticks_per_day = tpd
--	end
--end

--	local poi_table = {}
--	local next = next
--	local pumpjack = game.surfaces[1].find_entities_filtered{name = "pumpjack", limit = 5}
--		for _, entity in pairs(pumpjack) do
--		table.insert(poi_table, entity.position)
--		end
--		if next(poi_table) == nil then
--		local character = game.surfaces[1].find_entities_filtered{name = "character", limit = 5}
--			for _,entity in pairs(character) do
--			table.insert(poi_table, entity.position)
--			end
--		end
--		if next(poi_table) == nil then
--		table.insert(poi_table, {x = 0, y = 0})
--		end
--	global.destination = (poi_table[math.random(#poi_table)])
--	game.print(global.destination)

--local on_robot_built_tile = function(event)
--	if (event.tile.name == "landfill") then
--	local x = event.tiles[1].position.x
--	local y = event.tiles[1].position.y
--	local radius = math.random(57, 80)
--	local destination_area = {{x - radius, y - radius}, {x + radius, y + radius}}
--	local set_water = {}
--	local water_count = 0
--	for k, tile in pairs (game.surfaces[1].find_tiles_filtered{name = { "water", "deepwater" }, area = destination_area}) do
--    water_count = water_count + 1
--    set_water[water_count] = {name = "water-shallow", position = {x = tile.position.x, y = tile.position.y}}
--	end
--	game.surfaces[1].set_tiles(set_water)
--	end
--end

--local on_player_built_tile = function(event)
--	if (event.tile.name == "landfill") then
--	local x = event.tiles[1].position.x
--	local y = event.tiles[1].position.y
--	local radius = math.random(20, 70)
--	local destination_area = {{x - radius, y - radius}, {x + radius, y + radius}}
--	local set_water = {}
--	local water_count = 0
--	for k, tile in pairs (game.surfaces[1].find_tiles_filtered{name = { "water", "deepwater" }, area = destination_area}) do
--   water_count = water_count + 1
--    set_water[water_count] = {name = "water-shallow", position = {x = tile.position.x, y = tile.position.y}}
--	end
--	game.surfaces[1].set_tiles(set_water)
--	end
--end

--  local command =
--  {
--    type = defines.command.compound,
--    structure_type = defines.compound_command.return_last,
--    commands =
--    {
--	  {
--        type = defines.command.go_to_location,
--        destination = global.destination
--      },
--      {
--        type = defines.command.attack_area,
--        destination = global.destination,
--		radius = 16,
--        distraction = defines.distraction.by_anything
--      },
--      {
--        type = defines.command.build_base,
--		destination = global.destination,
--		distraction = defines.distraction.by_anything,
--		ignore_planner = true
--      }
--    }
--  }

--	local command =
--		{
--		type = defines.command.build_base,
--		destination = global.destination,
--		ignore_planner = true
--		}

--script.on_event(defines.events.on_entity_died,
--	function(event)
--		if (event.entity.name == "small-spitter" and math.random(1, 100) <= global.worms) then
--		game.surfaces[1].create_entity{name = "small-worm-turret", position = event.entity.position}
--		end
--		if (event.entity.name == "medium-spitter" and math.random(1, 100) <= global.worms) then
--		game.surfaces[1].create_entity{name = "medium-worm-turret", position = event.entity.position}
--		end
--		if (event.entity.name == "big-spitter" and math.random(1, 100) <= global.worms) then
--		game.surfaces[1].create_entity{name = "big-worm-turret", position = event.entity.position}
--		end
--		if (event.entity.name == "behemoth-spitter" and math.random(1, 100) <= global.worms) then
--		game.surfaces[1].create_entity{name = "behemoth-worm-turret", position = event.entity.position}
--		end
--		if (event.entity.name == "big-biter" and math.random(1, 100) <= global.big_biter_hp) then
--		game.surfaces[1].create_entity{name = "big-biter", position = event.entity.position}
--		end
--		if (event.entity.name == "behemoth-biter" and math.random(1, 100) <= global.behemoth_biter_hp) then
--		game.surfaces[1].create_entity{name = "behemoth-biter", position = event.entity.position}
--		end
--	end
--)
--script.set_event_filter(defines.events.on_entity_died, {{filter = "name", name = "small-spitter"}, {filter = "name", name = "medium-spitter"}, {filter = "name", name = "big-spitter"}, {filter = "name", name = "behemoth-spitter"}, {filter = "name", name = "big-biter"}, {filter = "name", name = "behemoth-biter"}})


--		if (evo > 0.55 and evo < 0.95 and losses < 8) then
--		global.big_biter_hp = (math.min((global.big_biter_hp + 1), 95))
--		end
--		if (evo > 0.55 and evo < 0.95 and losses > 15) then
--		global.big_biter_hp = (math.max((global.big_biter_hp - 2), 80))
--		end
--		if (evo >= 0.95) then
--		global.big_biter_hp = 0
--		end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--		if (evo >= 0.91 and losses < 20) then
--		global.behemoth_biter_hp = (math.min((global.behemoth_biter_hp + 1), 96))
--		end
--		if (evo >= 0.91 and losses > 25) then
--		global.behemoth_biter_hp = (math.max((global.behemoth_biter_hp - 2), 80))
--		end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--		if (evo > 0.25 and losses < 8) then
--		global.worms = (math.min((global.worms + 5), 95))
--		end
--		if (evo > 0.25 and losses > 15) then
--		global.worms = (math.max((global.worms - 10), 1))
--		end

--local on_chunk_generated = function(event)
--	local chunk_area = {event.area.left_top, event.area.right_bottom}
--	local set_water = {}
--	local water_count = 0
--		for k, tile in pairs (game.surfaces[1].find_tiles_filtered{name = { "water", "deepwater" }, area = chunk_area}) do
--		water_count = water_count + 1
--		set_water[water_count] = {name = "water-shallow", position = tile.position}
--		end
--	game.surfaces[1].set_tiles(set_water)
--end

--script.on_event(defines.events.on_entity_damaged,
--	function(event)
--		local damage = event.final_damage_amount
--		if event.damage_type.name ~= "fire" then
--		damage = damage / 5
--		else
--		damage = damage / 10
--		end
--	end
--)
--script.set_event_filter(defines.events.on_entity_damaged, {{filter = "name", name = "small-spitter"}, {filter = "name", name = "medium-spitter"}, {filter = "name", name = "big-spitter"}, {filter = "name", name = "behemoth-spitter"}, {filter = "name", name = "big-biter"}, {filter = "name", name = "behemoth-biter"}})
--local on_tick = function(event)
--	if event.tick % 36000 == 1 then
--	end
--end







---------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

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
	[defines.events.on_chunk_generated] = on_chunk_generated,
	[defines.events.on_biter_base_built] = on_biter_base_built,
	[defines.events.on_rocket_launched] = on_rocket_launched,
	[defines.events.on_pre_surface_cleared] = on_pre_surface_cleared,
	[defines.events.on_surface_cleared] = on_surface_cleared,
	[defines.events.on_console_command] = on_console_command,
	[defines.events.on_player_toggled_map_editor] = on_player_toggled_map_editor
	
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
