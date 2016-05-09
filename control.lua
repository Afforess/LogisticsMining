require 'defines'
require 'config'
require 'stdlib/log/logger'
require 'stdlib/area/position'
require 'stdlib/entity/entity'
require 'stdlib/game'
require 'libs/array_pair'
require 'libs/scan_area'
require 'libs/mining_hub'

LOGGER = Logger.new('LogisticsMining', 'main', true)

script.on_event(defines.events.on_built_entity, function(event)
    if event.created_entity.name == "robo-mining-drill" then
        place_robo_mining_drill(event.created_entity)
    elseif event.created_entity.name == "mining-logistics" then
        event.created_entity.backer_name = ""
        place_mining_logistics(event.created_entity)
    end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.created_entity.name == "robo-mining-drill" then
        place_robo_mining_drill(event.created_entity)
    elseif event.created_entity.name == "mining-logistics" then
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

script.on_event(defines.events.on_tick, function()
    tick_miners()
    tick_mining_logistics()
end)

function tick_mining_logistics()
    if global.mining_logistics then
        for key, tuple in pairs(global.mining_logistics) do
            mining_hub.tick(key, tuple)
        end
    end
end

function get_value_or_default(tbl, field, default_value)
    if tbl[field] then
        return tbl[field]
    end
    tbl[field] = default_value
    return default_value
end

function tick_miners()
    local tick_updates = get_value_or_default(global, 'tick_updates', {})
    local update_list = get_value_or_default(tick_updates, game.tick % LOGISTICS_DRILL_TICK_FREQUENCY, {})

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

function update_miner(tuple)
    local miner = tuple.miner
    local container = tuple.container
    -- attempt to deconstruct
    if not tuple.ore_type then LOGGER.log("update_miner ore_type was nil!") end
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
        local inventory = get_robo_mining_container_inventory(entity)
        if inventory and not inventory.is_empty() then
            local items = inventory[1]
            -- give items to player if possible
            if player.character then
                LOGGER.log("Attempting to insert " .. serpent.line(items) .. " into player character")
                local inserted = player.character.insert(items)
                if inserted ~= items.count then
                    items.count = items.count - inserted
                else
                    inventory.clear()
                end
            end
            -- spill anything left on the surface
            if not inventory.is_empty() then
                LOGGER.log("Spilling itemstack: " .. serpent.line(items))
                entity.surface.spill_item_stack(entity.position, items)
            end
            inventory.clear()
        end
        destroy_robo_mining_drill(entity)
    end
end)

function destroy_robo_mining_drill(entity)
    local container_removed = false
    if global.miners then
        local key = entity_key(entity)
        local tuple = global.miners[key]
        if tuple and tuple.container and tuple.container.valid then
            tuple.container.destroy()
            container_removed = true
        end
        global.miners[key] = nil
    end

    -- try and find the container and remove it
    if not container_removed then
        LOGGER.log("Failed to remove container, attempting to find container and destroy it")
        local area = Entity.to_selection_area(entity)
        local entities = entity.surface.find_entities_filtered({area = area, name = 'robo-miner-logistic-chest-active-provider'})
        for _, entity in pairs(entities) do
            entity.destroy()
        end
    end

    entity.get_inventory(defines.inventory.fuel).clear()
end

function place_mining_logistics(entity)
    local mining_logistics = get_value_or_default(global, 'mining_logistics', {})

    local ore_type = find_nearest_ore_type(entity.surface, entity.position, 8)
    if ore_type == nil then
        Game.print_force(entity.force, "No ores nearby mining logistics!")
    else
        mining_logistics[entity_key(entity)] = mining_hub.create(entity, ore_type)
    end
end

function place_robo_mining_drill(entity)
    container = entity.surface.create_entity({name = "robo-miner-logistic-chest-active-provider", position = entity.position, force = entity.force})
    container.destructible = false
    container.operable = false
    container.minable = false

    local coal = math.ceil(calculate_coal_amount(LOGISTICS_DRILL_BATTERY_CHARGED))
    entity.get_inventory(defines.inventory.fuel).insert({name = "coal", count =  coal})
    entity.operable = false

    local ore_type = find_ore_type(entity.surface, entity.position)
    local key = entity_key(entity)
    local miners = get_value_or_default(global, 'miners', {})
    miners[key] = { miner = entity, container = container, ore_type = ore_type }

    -- keep a list of which miners to update each tick
    local tick_updates = get_value_or_default(global, 'tick_updates', {})
    local update_list = get_value_or_default(tick_updates, game.tick % LOGISTICS_DRILL_TICK_FREQUENCY, {})
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
    local area = Position.expand_to_area(position, radius)
    local closest_prototype = nil
    local closest_distance = nil
    for _, prototype in pairs(game.entity_prototypes) do
        if prototype.type == "resource" and prototype.resource_category == "basic-solid" then
            local entities = surface.find_entities_filtered({area = area, name = prototype.name})
            for _, entity in pairs(entities) do
                local dist_squared = Position.distance_squared(entity.position, position)
                if closest_distance == nil or dist_squared < closest_distance then
                    closest_prototype = prototype.name
                    closest_distance = dist_squared
                end
            end
        end
    end
    return closest_prototype
end

function has_ore_type(surface, position, ore_type)
    if not ore_type then
        return false
    end
    return surface.find_entity(ore_type, position) ~= nil
end

function pos_key(surface, position)
    return string.format("%s@{%d,%d}", surface.name, position.x, position.y)
end

function entity_key(entity)
    return pos_key(entity.surface, entity.position)
end

function get_robo_mining_container_inventory(entity)
    if global.miners ~= nil then
        local tuple = global.miners[entity_key(entity)]
        if tuple and tuple.container and tuple.container.valid then
            return tuple.container.get_inventory(defines.inventory.chest)
        end
    end
    return nil
end
