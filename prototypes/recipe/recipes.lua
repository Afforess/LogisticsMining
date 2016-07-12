data:extend(
{
	{
		type = "recipe-category",
		name = "battery-charging"
	},
})

data:extend(
{
    {
        type = "recipe",
        name = "charged-battery",
        category = "crafting-with-fluid",
        energy_required = 27, -- 150KW * 27 = ~4MJ stored
        enabled = false,
        ingredients =
        {
            {"battery", 1},
            {type="fluid", name = "sulfuric-acid", amount = 0.1}
        },
        result= "charged-battery"
    },
    {
        type = "recipe",
        name = "supercharged-battery",
        category = "battery-charging",
        energy_required = 1.2,
        enabled = false,
        ingredients =
        {
            {"battery", 1},
        },
        result= "charged-battery"
    },
    {
        type = "recipe",
        name = "charging-assembling-machine",
        energy_required = 4,
        enabled = false,
        ingredients =
        {
            {"speed-module-3", 5},
            {"processing-unit", 15},
            {"assembling-machine-3", 1}
        },
        result = "charging-assembling-machine"
    },
    {
        type = "recipe",
        name = "robo-mining-drill",
        enabled = false,
        energy_required = 2,
        ingredients =
        {
            {"electric-mining-drill", 1},
            {"charged-battery", 10}
        },
        result = "robo-mining-drill"
    },
    {
        type = "recipe",
        name = "mining-logistics",
        enabled = false,
        ingredients =
        {
            {"steel-plate", 15},
            {"roboport", 1},
            {"advanced-circuit", 15}
        },
        result = "mining-logistics",
        energy_required = 15
    },
}
)
