local on_built = function (data)
    local entity = data.entity --[[@as LuaEntity]]
    if entity.quality.level == 0 then return end
    local surface = entity.surface
    local info = {
        name = entity.quality.name.."-"..entity.name,
        position = entity.position,
        quality = entity.quality,
        force = entity.force,
        fast_replace = true,
        player = entity.last_user,
        temperature = entity.temperature
    }
    entity.destroy()
    surface.create_entity(info)
end

local rescan = function ()
    for _, surface in pairs(game.surfaces) do
        for _, heat_pipe in pairs(surface.find_entities_filtered{name="heat-pipe"}) do
            if heat_pipe.quality.level == 0 then goto continue end
            local info = {
                name = heat_pipe.quality.name.."-heat-pipe",
                position = heat_pipe.position,
                quality = heat_pipe.quality,
                fast_replace = true,
                force = heat_pipe.force,
                player = heat_pipe.last_user,
                temperature = heat_pipe.temperature
            }
            heat_pipe.destroy()
            surface.create_entity(info)
            ::continue::
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