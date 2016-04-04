data:extend(
{
    {
        type = "item",
        name = "charged-battery",
        icon = "__LogisticsMining__/graphics/icons/charged-battery.png",
        flags = {"goes-to-main-inventory"},
        subgroup = "intermediate-product",
        order = "i[battery]",
        stack_size = 200
    },
    {
        type = "item",
        name = "charging-assembling-machine",
        icon = "__LogisticsMining__/graphics/icons/charging-assembling-machine.png",
        flags = {"goes-to-quickbar"},
        subgroup = "production-machine",
        order = "c[charging-assembling-machine]",
        place_result = "charging-assembling-machine",
        stack_size = 50
    },
    {
        type = "item",
        name = "robo-mining-drill",
        icon = "__LogisticsMining__/graphics/icons/robo-mining-drill.png",
        flags = {"goes-to-quickbar"},
        subgroup = "extraction-machine",
        order = "a[items]-b[robo-mining-drill]",
        place_result = "robo-mining-drill",
        stack_size = 100
    },
    -- dummy item, not visible
    {
        type = "item",
        name = "robo-miner-logistic-chest-active-provider",
        icon = "__base__/graphics/icons/logistic-chest-active-provider.png",
        flags = {"goes-to-quickbar"},
        subgroup = "logistic-network",
        order = "b[storage]-c[logistic-chest-active-provider]",
        place_result = "robo-miner-logistic-chest-active-provider",
        stack_size = 50
    },
    {
        type = "item",
        name = "mining-logistics",
        icon = "__LogisticsMining__/graphics/icons/logistics-mining.png",
        flags = {"goes-to-quickbar"},
        subgroup = "logistic-network",
        order = "c[signal]-a[roboport]",
        place_result = "mining-logistics",
        stack_size = 5
    },
}
)
