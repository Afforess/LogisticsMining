require 'defines'
require 'config'
require 'libs/logger'
require 'libs/array_pair'
require 'libs/scan_area'

script.on_event(defines.events.on_built_entity, function(event)
    if event.created_entity.name == "robo-mining-drill" then
        place_robo_mining_drill(event.created_entity)
    end
    if event.created_entity.name == "mining-logistics" then
        event.created_entity.backer_name = ""
        place_mining_logistics(event.created_entity)
    end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.created_entity.name == "robo-mining-drill" then
        place_robo_mining_drill(event.created_entity)
    end
    if event.created_entity.name == "mining-logistics" then
        event.created_entity.backer_name = ""
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
        elseif tuple.scanned ~= true then
            if game.tick % 2 == 0 then
                while true do
                    if scan_mining_area(tuple) > 0 or tuple.scanned then
                        break
                    end
                end
            end
        elseif tuple.tick == (game.tick % LOGISTICS_HUB_TICK_FREQUENCY) then
            update_mining_logistics(tuple)
            update_scan_overlay(tuple)
        end
    end
end

function update_scan_overlay(tuple)
    if tuple.scan_countdown then
        tuple.scan_countdown = tuple.scan_countdown - 1
        if tuple.scan_countdown <= 0 then
            for _, entity in pairs(tuple.scan_entities) do
                if entity.valid then
                    entity.destroy()
                end
            end
            tuple.scan_entities = nil
            tuple.scan_countdown = nil
        end
    end
end

function scan_mining_area(tuple)
    local valid_ores = tuple.ores
    if valid_ores == nil then
        valid_ores = array_pair.new()
        tuple.ores = valid_ores
    end
    if tuple.scan_progress == nil then
        tuple.scan_progress = 1
        tuple.scan_entities = {}
        tuple.scan_countdown = 6
    end
    
    local delta_pos = get_position_for_index(tuple.scan_progress)
    if delta_pos == nil then
        tuple.scan_progress = nil
        tuple.scanned = true
        array_pair.reverse(tuple.ores)
    else
        tuple.scan_progress = tuple.scan_progress + 1
        
        local surface = tuple.entity.surface
        local ore_type = tuple.ore_type
        local position = tuple.entity.position

        local mining_position = {x = math.floor(position.x + delta_pos.x) + 0.5, y = math.floor(position.y + delta_pos.y) + 0.5}
        if has_ore_type(surface, mining_position, ore_type) then
            array_pair.insert(valid_ores, mining_position)
            
            local overlay_entity = surface.create_entity({name = "logistics_mining_70_red_overlay", force = game.forces.neutral, position = mining_position })
            overlay_entity.minable = false
            overlay_entity.destructible = false
            overlay_entity.operable = false
            table.insert(tuple.scan_entities, overlay_entity)
            return 1
        end
    end
    return 0
end

function update_mining_logistics(tuple)
    local force = tuple.entity.force
    local surface = tuple.entity.surface
    local position = tuple.entity.position
    local ore_type = tuple.ore_type
    local entities_created = 0
    local ghost_entities = tuple.ghost_entities
    if ghost_entities == nil then
        ghost_entities = {}
        tuple.ghost_entities = ghost_entities
    end
    local num_ghosts = 0
    for i = #tuple.ghost_entities, 1, -1 do
        local ghost_entity = tuple.ghost_entities[i]
        if ghost_entity.valid then
            num_ghosts = num_ghosts + 1
            ghost_entity.time_to_live = ghost_entity.force.ghost_time_to_live
        else
            table.remove(tuple.ghost_entities, i)
        end
    end
    if num_ghosts >= 25 then
        return
    end
    
    local iter = array_pair.iterator(tuple.ores)
    while(iter.has_next()) do
        local pos = iter.next()
        entities_created = entities_created + update_mining_logistics_position(force, surface, pos, ore_type, ghost_entities)
        if entities_created >= 3 then
            return
        end
    end
end

function update_mining_logistics_position(force, surface, position, ore_type, ghost_entities)
    if surface.find_entity("entity-ghost", position) == nil then
        if surface.can_place_entity({name = "robo-mining-drill", position = position, force = force}) then
            if has_ore_type(surface, position, ore_type) then
                local ghost = surface.create_entity({name = "entity-ghost", inner_name = "robo-mining-drill", position = position, force = force})
                table.insert(ghost_entities, ghost)
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
    global.mining_logistics[entity_key(entity)] = {entity = entity, ore_type = ore_type, tick = game.tick % LOGISTICS_HUB_TICK_FREQUENCY}
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
