--- Updates an invidiual heat pipe to be a quality heat pipe.
--- @param pipe LuaEntity
--- @param surface LuaSurface
--- @param quality LuaQualityPrototype
local function pipe_swap(pipe, surface, quality)
    if (pipe.valid == false) or (surface.valid == false) or (quality.valid == false) then return end
    if quality.level == 0 then return end
    if string.find(pipe.name, "QHP-") then log("Double QHP detected. Report to mod author with information to replicate if possible.") return end
    local info = {
        name = "QHP-"..quality.name.."-"..pipe.name,
        position = pipe.position,
        quality = pipe.quality,
        force = pipe.force,
        fast_replace = true,
        player = pipe.last_user,
    }

    local temp = pipe.temperature
    local new_pipe = surface.create_entity(info)
    new_pipe.temperature = temp
    pipe.destroy()
end


local function rescan()
    for _, surface in pairs(game.surfaces) do
        for _, heat_pipe in pairs(surface.find_entities_filtered{name="heat-pipe"}) do
            if heat_pipe.quality.level == 0 then goto continue end
            pipe_swap(heat_pipe, surface, heat_pipe.quality)
            ::continue::
        end
    end
end


local function on_built(event)
    local entity = event.entity         --[[@as LuaEntity]]
    local surface = entity.surface      --[[@as LuaSurface]]
    local quality = entity.quality      --[[@as LuaQualityPrototype]]
    pipe_swap(entity, surface, quality)
end



local function pipette_mimic(event)
	if not event.selected_prototype then return end
	if not (event.selected_prototype.derived_type == "heat-pipe") then return end

	local selected_pipe = prototypes.entity[event.selected_prototype.name]
	local normal_pipe = prototypes.entity[selected_pipe.fast_replaceable_group]
	local quality = event.selected_prototype.quality
    if quality == "normal" then return end
	
	local player = game.players[event.player_index]
	if player.cursor_stack == nil then return end
	local pipe = normal_pipe.items_to_place_this[1]
	local pick_sound = "item-pick/"..pipe.name
	
	-- gotta find if player has the correct pipe in the inventory and then grab the index
	local cursor = player.cursor_stack
    if player.get_main_inventory() == nil then -- in map view
        player.cursor_ghost= {name = pipe.name, quality = quality}
        player.play_sound({path = "utility/smart_pipette"})
    else
        local item_stack, index = player.get_main_inventory().find_item_stack({name = pipe.name, quality = quality, count = pipe.count})
        if cursor and (cursor.valid_for_read == true) then return end
        if item_stack then
            player.cursor_stack.swap_stack(item_stack)
            player.play_sound({path = pick_sound})
        else
            player.cursor_ghost= {name = pipe.name, quality = quality}
            player.play_sound({path = "utility/smart_pipette"})
        end
    end
end



local heat_pipe_filter = {
    filter = "type",
    type = "heat-pipe"
}

script.on_init(rescan)

script.on_event(defines.events.on_built_entity,                 on_built, {heat_pipe_filter})
script.on_event(defines.events.on_space_platform_built_entity,  on_built, {heat_pipe_filter})
script.on_event(defines.events.script_raised_built,             on_built, {heat_pipe_filter})
script.on_event(defines.events.script_raised_revive,            on_built, {heat_pipe_filter})
script.on_event(defines.events.on_robot_built_entity,           on_built, {heat_pipe_filter})
script.on_event(defines.events.on_entity_cloned,                on_built, {heat_pipe_filter})

script.on_event("pipes-pipette-used",							pipette_mimic)