for _, force in pairs(game.forces) do 
    if force.technologies["battery-2"].researched then
        force.recipes['charging-assembling-machine'].enabled = true
        force.recipes['supercharged-battery'].enabled = true
    end
end
