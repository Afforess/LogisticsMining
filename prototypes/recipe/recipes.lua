data:extend(
{
    {
        type = "recipe",
        name = "charged-battery",
        category = "crafting-with-fluid",
        energy_required = 33, -- 150KW * 33 = ~5MJ stored
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
        name = "robo-mining-drill",
        energy_required = 4,
        ingredients =
        {
            {"basic-mining-drill", 1},
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
