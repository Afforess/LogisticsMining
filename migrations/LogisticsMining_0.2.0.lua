for _, force in pairs(game.forces) do 
    force.reset_recipes()

    force.recipes['charging-assembling-machine'].enabled = force.technologies["automation-4"].researched
    force.recipes['supercharged-battery'].enabled = force.technologies["automation-4"].researched
    force.recipes['mining-logistics'].enabled = force.technologies["logistic-system-2"].researched
    force.recipes['robo-mining-drill'].enabled = force.technologies["logistic-system-2"].researched
    force.recipes['charged-battery'].enabled = force.technologies["battery-2"].researched
end
