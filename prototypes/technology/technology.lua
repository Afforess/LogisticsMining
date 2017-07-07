data:extend(
{
    {
        type = "technology",
        name = "battery-2",
        icon = "__base__/graphics/technology/battery.png",
        prerequisites = {"battery", "automation-3"},
        unit =
        {
            count = 100,
            ingredients =
            {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
            },
            time = 30
        },
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "charged-battery"
            }
        },
        order = "b-c"
    },
    {
        type = "technology",
        name = "logistic-system-2",
        icon = "__base__/graphics/technology/logistic-system.png",
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "robo-mining-drill"
            },
            {
                type = "unlock-recipe",
                recipe = "mining-logistics"
            }
        },
        prerequisites = { "logistic-system", "battery-2"},
        unit = {
            count = 250,
            ingredients = {
                {"science-pack-1", 1},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
                {"production-science-pack", 1},
            },
            time = 45
        },
        order = "c-k-d",
    },
    {
        type = "technology",
        name = "automation-4",
        icon = "__base__/graphics/technology/automation.png",
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "charging-assembling-machine"
            },
            {
                type = "unlock-recipe",
                recipe = "supercharged-battery"
            }
        },
        prerequisites = { "automation-3", "battery-2", "speed-module-3"},
        unit = {
            count = 250,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 2},
                {"science-pack-3", 2},
                {"production-science-pack", 1},
                {"high-tech-science-pack", 1}
            },
            time = 60
        },
        order = "a-b-c",
    }
}
)
