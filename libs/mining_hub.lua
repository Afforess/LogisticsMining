
 mining_hub = {}

 function mining_hub.create(entity, ore_type)
     local hub = {entity = entity, ore_type = ore_type, tick = game.tick % LOGISTICS_HUB_TICK_FREQUENCY}
     return hub
 end

 function mining_hub.tick(hub_key, hub)
     if not mining_hub.is_valid(hub) then
         mining_hub.delete(hub_key, hub)
         return
     end
     mining_hub.migrate_scan_progress(hub)

     if hub.scanned ~= true and game.tick % 2 == 0 then
         while true do
             if mining_hub.scan_mining_area(hub) > 0 or hub.scanned then
                 break
             end
         end
     elseif hub.tick == (game.tick % LOGISTICS_HUB_TICK_FREQUENCY) then
         mining_hub.request_miners(hub)
         mining_hub.update_scan_overlay(hub)
     end
 end

 function mining_hub.migrate_scan_progress(hub)
     if hub.scan_progress then
         hub.scan = { progress = hub.scan_progress, entities = hub.scan_entities, countdown = hub.scan_countdown }
         hub.scan_progress = nil
         hub.scan_entities = nil
         hub.scan_countdown = nil
     end
 end

 function mining_hub.update_ghost_entities(hub)
     local num_ghosts = 0
     local ghost_entities = get_value_or_default(hub, 'ghost_entities', {})
     for i = #ghost_entities, 1, -1 do
         local ghost_entity = ghost_entities[i]
         if ghost_entity.valid then
             num_ghosts = num_ghosts + 1
             ghost_entity.time_to_live = ghost_entity.force.ghost_time_to_live
         else
             table.remove(ghost_entities, i)
         end
     end
     return num_ghosts
 end

 function mining_hub.request_miners(hub)
     local num_ghosts = mining_hub.update_ghost_entities(hub)
     if num_ghosts >= MAX_CONSTRUCTION_REQUESTS then
         return
     end
     local logistics_network = hub.entity.logistic_network
     if not logistics_network then
         return
     end
     if num_ghosts >= logistics_network.get_item_count("robo-mining-drill") then
         return
     end

     local iter = array_pair.iterator(hub.ores)
     while(iter.has_next()) do
         local pos = iter.next()
         if mining_hub.request_logistics_miner(hub, pos) > 0 then
             break
         end
     end
 end

 function mining_hub.request_logistics_miner(hub, position)
     local force = hub.entity.force
     local surface = hub.entity.surface
     local ore_type = hub.ore_type
     local ghost_entities = hub.ghost_entities

     if surface.find_entity("entity-ghost", position) == nil then
         if surface.can_place_entity({name = "robo-mining-drill", position = position, force = force}) then
             if not ore_type then LOGGER.log("update_mining_logistics_position ore_type was nil!") end
             if has_ore_type(surface, position, ore_type) then
                 local ghost = surface.create_entity({name = "entity-ghost", inner_name = "robo-mining-drill", position = position, force = force})
                 table.insert(ghost_entities, ghost)
                 return 1
             end
         end
     end
     return 0
 end

 function mining_hub.scan_mining_area(hub)
     local valid_ores = get_value_or_default(hub, 'ores', array_pair.new())
     local scan = get_value_or_default(hub, 'scan', { progress = 1, entities = {}, countdown = {} })

     local delta_pos = get_position_for_index(scan.progress)
     if delta_pos == nil then
         hub.scan = nil
         hub.scanned = true
         array_pair.reverse(valid_ores)
     else
         scan.progress = scan.progress + 1

         local surface = hub.entity.surface
         local position = hub.entity.position
         local ore_type = hub.ore_type
         local mining_position = {x = math.floor(position.x + delta_pos.x) + 0.5, y = math.floor(position.y + delta_pos.y) + 0.5}

         if not ore_type then LOGGER.log("scan_mining_area ore_type was nil!") end
         if has_ore_type(surface, mining_position, ore_type) then
             array_pair.insert(valid_ores, mining_position)

             local overlay_entity = surface.create_entity({name = "logistics_mining_70_red_overlay", force = game.forces.neutral, position = mining_position })
             overlay_entity.minable = false
             overlay_entity.destructible = false
             overlay_entity.operable = false
             table.insert(scan.entities, overlay_entity)
             return 1
         end
     end
     return 0
 end

 function mining_hub.update_scan_overlay(hub)
     if hub.scan and hub.scan.countdown then
         hub.scan.countdown = hub.scan.countdown - 1
         if hub.scan.countdown <= 0 then
             mining_hub.delete_scan_overlay(hub)
         end
     end
 end

 function mining_hub.delete_scan_overlay(hub)
     if hub.scan and hub.scan.entities then
         for _, entity in pairs(hub.scan.entities) do
             if entity.valid then
                 entity.destroy()
             end
         end
     end
     hub.scan = nil
 end

 function mining_hub.delete(hub_key, hub)
     mining_hub.delete_scan_overlay(hub)
     global.mining_logistics[hub_key] = nil
 end

 function mining_hub.is_valid(hub)
     if hub == nil then
         return false
     end
     return hub.entity ~= nil and hub.entity.valid
 end
