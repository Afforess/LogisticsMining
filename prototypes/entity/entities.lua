function assembler_charging_pipepictures()
  return
  {
     north =
     {
        filename = "__base__/graphics/entity/assembling-machine-3/pipe-north.png",
        priority = "extra-high",
        width = 40,
        height = 45,
        shift = {0.03125, 0.3125}
     },
    east =
    {
      filename = "__base__/graphics/entity/assembling-machine-2/pipe-east.png",
      priority = "extra-high",
      width = 41,
      height = 40,
      shift = {-0.71875, 0}
    },
    south =
    {
      filename = "__base__/graphics/entity/assembling-machine-2/pipe-south.png",
      priority = "extra-high",
      width = 41,
      height = 40,
      shift = {0.0625, -1}
    },
    west =
    {
      filename = "__base__/graphics/entity/assembling-machine-2/pipe-west.png",
      priority = "extra-high",
      width = 41,
      height = 40,
      shift = {0.78125, 0.03125}
    }
  }
end

data:extend({
    {
        type = "mining-drill",
        name = "robo-mining-drill",
        icon = "__LogisticsMining__/graphics/icons/robo-mining-drill.png",
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 1, result = "basic-mining-drill"},
        max_health = 100,
        resource_categories = {"basic-solid"},
        corpse = "small-remnants",
        collision_box = {{ -0.4, -0.4}, {0.4, 0.4}},
        selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
        vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        working_sound =
        {
          sound =
          {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 0.75
          },
          apparent_volume = 1.5,
        },
        animations =
        {
          north =
          {
            priority = "extra-high",
            width = 110,
            height = 114,
            line_length = 8,
            shift = {0.2 * 0.3333, -0.2 * 0.3333},
            filename = "__base__/graphics/entity/basic-mining-drill/north.png",
            frame_count = 64,
            animation_speed = 0.5,
            scale = 0.3333,
            run_mode = "forward-then-backward",
          },
          east =
          {
            priority = "extra-high",
            width = 129,
            height = 100,
            line_length = 8,
            shift = {0.45 * 0.3333, 0},
            filename = "__base__/graphics/entity/basic-mining-drill/east.png",
            frame_count = 64,
            animation_speed = 0.5,
            scale = 0.3333,
            run_mode = "forward-then-backward",
          },
          south =
          {
            priority = "extra-high",
            width = 109,
            height = 111,
            line_length = 8,
            shift = {0.15 * 0.3333, 0},
            filename = "__base__/graphics/entity/basic-mining-drill/south.png",
            frame_count = 64,
            animation_speed = 0.5,
            scale = 0.3333,
            run_mode = "forward-then-backward",
          },
          west =
          {
            priority = "extra-high",
            width = 128,
            height = 100,
            line_length = 8,
            shift = {0.25 * 0.3333, 0},
            filename = "__base__/graphics/entity/basic-mining-drill/west.png",
            frame_count = 64,
            animation_speed = 0.5,
            scale = 0.3333,
            run_mode = "forward-then-backward",
          }
        },
        mining_speed = 0.40,
        energy_source =
        {
          type = "burner",
          effectivity = 1,
          fuel_inventory_size = 1,
          emissions = 0.01
        },
        energy_usage = "200kW",
        mining_power = 3,
        resource_searching_radius = 0.99,
        vector_to_place_result = {0, 0},
        radius_visualisation_picture =
        {
          filename = "__base__/graphics/entity/basic-mining-drill/mining-drill-radius-visualization.png",
          width = 3,
          height = 3
        },
        fast_replaceable_group = "mining-drill"
    },
    {
        type = "logistic-container",
        name = "robo-miner-logistic-chest-active-provider",
        icon = "__base__/graphics/icons/logistic-chest-active-provider.png",
        flags = {"placeable-player", "player-creation"},
        minable = {hardness = 0.2, mining_time = 0.5, result = "robo-miner-logistic-chest-active-provider"},
        max_health = 150,
        selectable_in_game = false,
        corpse = "small-remnants",
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.15, -0.15}, {0.15, 0.15}},
        fast_replaceable_group = "container",
        inventory_size = 1,
        logistic_mode = "active-provider",
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        picture =
        {
          filename = "__base__/graphics/entity/logistic-chest/logistic-chest-active-provider.png",
          priority = "extra-high",
          width = 0,
          height = 0,
          shift = {0, 0}
        },
        circuit_wire_max_distance = 7.5
     },
     {
         type = "assembling-machine",
         name = "charging-assembling-machine",
         icon = "__LogisticsMining__/graphics/icons/charging-assembling-machine.png",
         flags = {"placeable-neutral", "placeable-player", "player-creation"},
         minable = {hardness = 0.2, mining_time = 0.5, result = "charging-assembling-machine"},
         max_health = 250,
         corpse = "big-remnants",
         dying_explosion = "medium-explosion",
         resistances =
         {
             {
                 type = "fire",
                 percent = 70
             }
         },
         fluid_boxes =
         {
             {
                 production_type = "input",
                 pipe_picture = assembler_charging_pipepictures(),
                 pipe_covers = pipecoverspictures(),
                 base_area = 10,
                 base_level = -1,
                 pipe_connections = {{ type="input", position = {0, -2} }}
             },
             {
                 production_type = "output",
                 pipe_picture = assembler_charging_pipepictures(),
                 pipe_covers = pipecoverspictures(),
                 base_area = 10,
                 base_level = 1,
                 pipe_connections = {{ type="output", position = {0, 2} }}
             },
             off_when_no_fluid_recipe = true
         },
         collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
         selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
         fast_replaceable_group = "assembling-machine",
         animation =
         {
             filename = "__LogisticsMining__/graphics/entity/charging-assembling-machine.png",
             priority = "high",
             width = 142,
             height = 113,
             frame_count = 32,
             line_length = 8,
             shift = {0.84, -0.09}
         },
         open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
         close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
         vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
         working_sound =
         {
             sound = {
                 {
                     filename = "__base__/sound/assembling-machine-t2-1.ogg",
                     volume = 0.8
                 },
                 {
                     filename = "__base__/sound/assembling-machine-t2-2.ogg",
                     volume = 0.8
                 },
             },
             idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
             apparent_volume = 1.5,
         },
         crafting_categories = {"battery-charging"},
         crafting_speed = 1.5,
         energy_source =
         {
             type = "electric",
             usage_priority = "secondary-input",
             emissions = 0.08 / 2
         },
         energy_usage = "10000kW",
         ingredient_count = 4,
         module_specification =
         {
             module_slots = 0
         },
         allowed_effects = {"consumption", "speed", "productivity", "pollution"}
     },
    {
        type = "roboport",
        name = "mining-logistics",
        icon = "__LogisticsMining__/graphics/icons/logistics-mining.png",
        flags = {"placeable-player", "player-creation"},
        minable = {hardness = 0.2, mining_time = 0.5, result = "mining-logistics"},
        max_health = 150,
        corpse = "small-remnants",
        collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
        selection_box = {{-1, -1}, {1, 1}},
        dying_explosion = "medium-explosion",
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          input_flow_limit = "2MW",
          buffer_capacity = "48MJ"
        },
        recharge_minimum = "20MJ",
        energy_usage = "200kW",
        -- per one charge slot
        charging_energy = "200kW",
        logistics_radius = 50,
        construction_radius = 50,
        charge_approach_distance = 5,
        robot_slots_count = 4,
        material_slots_count = 2,
        stationing_offset = {0, 0},
        charging_offsets =
        {
            {0, -1.7}, {0, 1.7}, {-1.7, 0}, {1.7, 0}
        },
        base =
        {
            filename = "__LogisticsMining__/graphics/entity/logistics-mining.png",
            width = 136,
            height = 132,
            shift = {1, -0.75}
        },
        base_animation =
        {
            filename = "__LogisticsMining__/graphics/entity/roboport-chargepad.png",
            priority = "medium",
            width = 32,
            height = 32,
            frame_count = 6,
            shift = {0, -2.28125},
            animation_speed = 0.1,
        },
        base_patch =
        {
            filename = "__LogisticsMining__/graphics/entity/blank.png",
            width = 1,
            height = 1,
            frame_count = 1,
        },
        door_animation =
        {
            filename = "__LogisticsMining__/graphics/entity/blank.png",
            width = 1,
            height = 1,
            frame_count = 1,
        },
        door_animation_up =
        {
            filename = "__LogisticsMining__/graphics/entity/blank.png",
            width = 1,
            height = 1,
            frame_count = 1,
        },
        door_animation_down =
        {
            filename = "__LogisticsMining__/graphics/entity/blank.png",
            width = 1,
            height = 1,
            frame_count = 1,
        },
        recharging_animation =
        {
          filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
          priority = "high",
          width = 37,
          height = 35,
          frame_count = 16,
          scale = 1.5,
          animation_speed = 0.5
        },
        recharging_light = {intensity = 0.4, size = 5},
        request_to_open_door_timeout = 3,
        spawn_and_station_height = 1.75,
        radius_visualisation_picture =
        {
            filename = "__base__/graphics/entity/roboport/roboport-radius-visualization.png",
            width = 12,
            height = 12,
            priority = "high"
        },
        construction_radius_visualisation_picture =
        {
            filename = "__LogisticsMining__/graphics/entity/roboport-concrete-radius-visualization.png",
            width = 12,
            height = 12,
            priority = "extra-high-no-scale"
        }
    }
})

function color_overlay(color_name, opacity)
    return {
        type = "container",
        name = "logistics_mining_" .. opacity .. "_" .. color_name .."_overlay",
        flags = {"placeable-neutral", "player-creation", "not-repairable"},
        icon = "__LogisticsMining__/graphics/overlay/" .. opacity .. "_" .. color_name .. "_overlay.png",
        max_health = 1,
        order = 'z',
        collision_mask = {"resource-layer"},
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        inventory_size = 1,
        picture =
        {
            filename = "__LogisticsMining__/graphics/overlay/" .. opacity .. "_" .. color_name .. "_overlay.png",
            priority = "extra-high",
            width = 32,
            height = 32,
            shift = {0.0, 0.0}
        }
    }
end

local overlays = {}
table.insert(overlays, color_overlay("red", 70))

data:extend(overlays)
