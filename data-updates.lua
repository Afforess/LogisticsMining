function technology_has_recipe(tech_name, recipe_name)
	for _, effect in pairs(data.raw.technology[tech_name].effects) do
	    if effect.recipe and effect.recipe == recipe_name then
	        return true
	    end
	end
	return false
end

if not technology_has_recipe("automation-4", "charging-assembling-machine") then
	table.insert(data.raw.technology["automation-4"].effects, {
		type = "unlock-recipe",
		recipe = "charging-assembling-machine"
	})
end

if not technology_has_recipe("automation-4", "supercharged-battery") then
	table.insert(data.raw.technology["automation-4"].effects, {
		type = "unlock-recipe",
		recipe = "supercharged-battery"
	})
end

if not technology_has_recipe("logistic-system-2", "mining-logistics") then
	table.insert(data.raw.technology["logistic-system-2"].effects, {
		type = "unlock-recipe",
		recipe = "mining-logistics"
	})
end

if not technology_has_recipe("logistic-system-2", "robo-mining-drill") then
	table.insert(data.raw.technology["logistic-system-2"].effects, {
		type = "unlock-recipe",
		recipe = "robo-mining-drill"
	})
end

if not technology_has_recipe("battery-2", "charged-battery") then
	table.insert(data.raw.technology["battery-2"].effects, {
		type = "unlock-recipe",
		recipe = "charged-battery"
	})
end
