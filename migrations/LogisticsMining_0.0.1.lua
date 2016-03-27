for i, force in pairs(game.forces) do 
    print("Test")
    if force.technologies["battery-2"].researched then
        force.recipes['charging-assembling-machine'].enabled = true
        force.recipes['supercharged-battery'].enabled = true
    end
end
