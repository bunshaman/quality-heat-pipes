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