local quality_blacklist = {["quality-unknown"] = true}


local quality_names = {}
for quality_name, quality_prototype in pairs(data.raw["quality"]) do
	if not quality_blacklist[quality_name] then
		quality_names[quality_name] = quality_prototype
	end
end


local heat_pipes = {}
for _, quality_prototype in pairs(quality_names) do
	for heat_pipe_name, _ in pairs(data.raw["heat-pipe"]) do
		local k = quality_prototype.name
		local v = 1 + 0.3 * quality_prototype.level
		local heat_pipe = table.deepcopy(data.raw["heat-pipe"][heat_pipe_name])
		local heating_radius = heat_pipe.heating_radius or 1
		if quality_prototype.name == "normal" then
		else
			heat_pipe.localised_name = {"entity-name."..heat_pipe.name}
			heat_pipe.name = "QHP-"..k.."-"..heat_pipe.name

			-- hacky code to prevent spam of heat pipes in upgrade planners because different collision_boxes will not show up as proper upgrades for the source in placeable_by
			if heat_pipe.collision_box ~= nil then
				if quality_prototype.level % 4 == 0 then	
					heat_pipe.collision_box[1][1] = heat_pipe.collision_box[1][1] - quality_prototype.level/1000
				elseif quality_prototype.level % 4 == 1 then
					heat_pipe.collision_box[1][2] = heat_pipe.collision_box[1][2] - quality_prototype.level/1000
				elseif quality_prototype.level % 4 == 2 then
					heat_pipe.collision_box[2][1] = heat_pipe.collision_box[2][1] + quality_prototype.level/1000
				elseif quality_prototype.level % 4 == 3 then
					heat_pipe.collision_box[2][2] = heat_pipe.collision_box[2][2] + quality_prototype.level/1000
				end
			end
			heat_pipe.heating_radius = heating_radius * (1 + quality_prototype.level)
			if data.raw.item[heat_pipe_name] then
				heat_pipe.placeable_by = { item = heat_pipe_name, count = 1, quality = k }
			else
				--log("No item found for heat pipe: " .. heat_pipe_name..". Proceeding without the placeable_by tag.")
			end

			heat_pipe.hidden = true
			heat_pipe.hidden_in_factoriopedia = true

			if heat_pipe.max_health then heat_pipe.max_health = heat_pipe.max_health * v end
			if heat_pipe.next_upgrade then heat_pipe.next_upgrade = "QHP-"..k.."-"..heat_pipe.next_upgrade end
			table.insert(heat_pipes, heat_pipe)
		end
	end
end

data:extend(heat_pipes)

data:extend({
    {
        type = "custom-input",
        name = "pipes-pipette-used",
        key_sequence = "",
        linked_game_control = "pipette",
        include_selected_prototype = true
    }
})
