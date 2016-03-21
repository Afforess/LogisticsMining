require 'defines'
require 'config'
require 'libs/logger'

script.on_event(defines.events.on_built_entity, function(event)
    if event.created_entity.name == "robo-mining-drill" then
        place_robo_mining_drill(event.created_entity)
    end
    if event.created_entity.name == "mining-logistics" then
        place_mining_logistics(event.created_entity)
    end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.created_entity.name == "robo-mining-drill" then
        place_robo_mining_drill(event.created_entity)
    end
    if event.created_entity.name == "mining-logistics" then
        place_mining_logistics(event.created_entity)
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if entity.name == "robo-mining-drill" then
        destroy_robo_mining_drill(entity)
    end
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
    local entity = event.entity
    if entity.name == "robo-mining-drill" then
        destroy_robo_mining_drill(entity)
    end
end)

script.on_event(defines.events.on_tick, function(event)
    tick_miners()
    tick_mining_logistics()
end)

function tick_mining_logistics()
    if global.mining_logistics == nil then
        return 
    end
    for key, tuple in pairs(global.mining_logistics) do
        if tuple.entity == nil or not tuple.entity.valid then
            global.mining_logistics[key] = nil
        elseif tuple.tick == (game.tick % LOGISTICS_HUB_TICK_FREQUENCY) then
            update_mining_logistics(tuple)
        end
    end
end

function update_mining_logistics(tuple)
    local force = tuple.entity.force
    local surface = tuple.entity.surface
    local position = tuple.entity.position
    local ore_type = tuple.ore_type
    local start_y = -(tuple.radius) + tuple.sweep
    local entities_created = 0
    for dx = -(tuple.radius), tuple.radius, 1 do
        for dy = start_y, math.min(tuple.radius, start_y + 1), 1 do
            if math.abs(dx) == tuple.radius or math.abs(dy) == tuple.radius then
                local pos = {x = math.floor(position.x + dx) + 0.5, y = math.floor(position.y + dy) + 0.5}
                entities_created = entities_created + update_mining_logistics_position(force, surface, pos, ore_type)
                if entities_created > 4 then
                    -- abort and continue this sweep next update
                    return
                end
            end
        end
    end
    tuple.sweep = tuple.sweep + 1
    if start_y >= tuple.radius then
        tuple.radius = (tuple.radius + 1) % 25
        tuple.sweep = 0
    end
end

function update_mining_logistics_position(force, surface, position, ore_type)
    if surface.find_entity("entity-ghost", position) == nil then
        if surface.can_place_entity({name = "robo-mining-drill", position = position, force = force}) then
            if has_ore_type(surface, position, ore_type) then
                surface.create_entity({name = "entity-ghost", inner_name = "robo-mining-drill", position = position, force = force})
                return 1
            end
        end
    end
    return 0
end

function tick_miners()
    if global.tick_updates == nil then
        return 
    end
    local update_list = global.tick_updates[game.tick % LOGISTICS_DRILL_TICK_FREQUENCY]
    if update_list ~= nil then
        for i = #update_list, 1, -1 do
            local key = update_list[i]
            local tuple = global.miners[key]
            if tuple == nil or not tuple.miner.valid or not tuple.container.valid then
                table.remove(update_list, i)
            else
                update_miner(tuple)
            end
        end
    end
end

function update_miner(tuple)
    local miner = tuple.miner
    local container = tuple.container
    -- attempt to deconstruct
    if miner.get_inventory(defines.inventory.fuel).is_empty() or not has_ore_type(miner.surface, miner.position, tuple.ore_type) then
        if container.get_inventory(defines.inventory.chest).is_empty() then
            -- load the container with 10 discharged (regular) batteries
            if tuple.deconstruction_started == nil then
                tuple.deconstruction_started = true
                container.insert({name = "battery", count = 10})
            else
                destroy_robo_mining_drill(miner)
                miner.order_deconstruction(miner.force)
            end
        end
    end
end

script.on_event(defines.events.on_preplayer_mined_item, function(event)
    local entity = event.entity
    if entity.name == "robo-mining-drill" then
        local player = game.players[event.player_index]
        local container = get_robo_mining_container(entity)
        -- empty container
        if container ~= nil then
            local container_inventory = container.get_inventory(defines.inventory.chest)
            if not container_inventory.is_empty() then 
                -- give items to player if possible
                if player.character ~= nil then
                    local items = container_inventory[1]
                    Logger.log("Attempting to insert " .. serpent.line(items) .. " into player character")
                    local inserted = player.character.insert(items)
                    if inserted ~= items.count then
                        items.count = items.count - inserted
                    else
                        container_inventory.clear()
                    end
                end
                -- spill anything left on the surface
                if not container_inventory.is_empty() then 
                    Logger.log("Spilling itemstack: " .. serpent.line(items))
                    entity.surface.spill_item_stack(entity.position, items)
                end
                container_inventory.clear()
            end
        end
        destroy_robo_mining_drill(entity)
    end
end)

function destroy_robo_mining_drill(entity)
    if global.miners ~= nil then
        local key = entity_key(entity)
        local tuple = global.miners[key]
        if tuple ~= nil and tuple.container ~= nil and tuple.container.valid then
            tuple.container.destroy()
        end
        global.miners[key] = nil
    end

    entity.get_inventory(defines.inventory.fuel).clear()
end

function place_mining_logistics(entity)
    if global.mining_logistics == nil then global.mining_logistics = {} end
    
    local ore_type = find_nearest_ore_type(entity.surface, entity.position, 8)
    global.mining_logistics[entity_key(entity)] = {entity = entity, radius = 1, sweep = 0, ore_type = ore_type, tick = game.tick % LOGISTICS_HUB_TICK_FREQUENCY}
end

function place_robo_mining_drill(entity)
    container = entity.surface.create_entity({name = "robo-miner-logistic-chest-active-provider", position = entity.position, force = entity.force})
    container.destructible = false
    container.operable = false
    container.minable = false
    
    local coal = math.ceil(calculate_coal_amount(LOGISTICS_DRILL_BATTERY_CHARGED))
    entity.get_inventory(defines.inventory.fuel).insert({name = "coal", count =  coal})
    entity.operable = false
    
    if global.miners == nil then global.miners = {} end
    if global.tick_updates == nil then global.tick_updates = {} end
    
    local ore_type = find_ore_type(entity.surface, entity.position)
    local key = entity_key(entity)
    global.miners[key] = {miner = entity, container = container, ore_type = ore_type}
    
    -- keep a list of which miners to update each tick
    local update_list = global.tick_updates[game.tick % LOGISTICS_DRILL_TICK_FREQUENCY]
    if update_list == nil then
        update_list = {}
        global.tick_updates[game.tick % LOGISTICS_DRILL_TICK_FREQUENCY] = update_list
    end
    table.insert(update_list, key)
end

function calculate_coal_amount(megajoules)
    local joules = megajoules * 1000 * 1000
    return joules / game.item_prototypes["coal"].fuel_value
end

function find_ore_type(surface, position)
    for _, prototype in pairs(game.entity_prototypes) do
        if prototype.type == "resource" and prototype.resource_category == "basic-solid" then
            if has_ore_type(surface, position, prototype.name) then
                return prototype.name
            end
        end
    end
    return nil
end

function find_nearest_ore_type(surface, position, radius)
    local area = {left_top = {x = position.x - radius, y = position.y - radius}, right_bottom = {x = position.x + radius, y = position.y + radius}}
    local closest_prototype = nil
    local closest_distance = nil
    for _, prototype in pairs(game.entity_prototypes) do
        if prototype.type == "resource" and prototype.resource_category == "basic-solid" then
            local entities = surface.find_entities_filtered({area = area, name = prototype.name})
            for _, entity in pairs(entities) do
                local dist_squared = dist_squared(entity.position, position)
                if closest_distance == nil or dist_squared < closest_distance then
                    closest_prototype = prototype.name
                    closest_distance = dist_squared
                end
            end
        end
    end
    return closest_prototype
end

function dist_squared(pos_a, pos_b)
    local axbx = pos_a.x - pos_b.x
    local ayby = pos_a.y - pos_b.y
    return axbx * axbx + ayby * ayby
end

function has_ore_type(surface, position, ore_type)
    return surface.find_entity(ore_type, position) ~= nil
end

function pos_key(surface, position)
    return string.format("%s@{%d,%d}", surface.name, position.x, position.y)
end

function entity_key(entity)
    return pos_key(entity.surface, entity.position)
end

function get_robo_mining_container(entity)
    if global.miners ~= nil then
        local tuple = global.miners[entity_key(entity)]
        if tuple ~= nil and tuple.container ~= nil and tuple.container.valid then
            return tuple.container
        end
    end
    return nil
end
