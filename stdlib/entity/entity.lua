--- Entity module
-- @module entity

require 'stdlib/core'
require 'stdlib/area/area'

Entity = {}

--- Converts an entity and its selection_box to the area around it
-- @param entity to convert to an area
-- @return area that entity selection_box is valid for
function Entity.to_selection_area(entity)
    fail_if_missing(entity, "missing entity argument")

    local pos = entity.position
    local bb = entity.prototype.selection_box
    return Area.offset(bb, pos)
end

--- Converts an entity and its selection_box to the area around it
-- @param entity to convert to an area
-- @return area that entity selection_box is valid for
function Entity.to_collision_area(entity)
    fail_if_missing(entity, "missing entity argument")

    local pos = entity.position
    local bb = entity.prototype.collision_box
    return Area.offset(bb, pos)
end

function Entity.find_all_entities(search_criteria)
    fail_if_missing(search_criteria, "missing search_criteria argument")
    if search_criteria.name == nil and search_criteria.type == nil then
        error("Missing search criteria field: name or type of entity", 2)
    end

    local surface_list = { }
    if type(search_criteria.surface) == "string" then
        surface_list = { game.surfaces[search_criteria.surface] }
    elseif search_criteria.surface then
        surface_list = { search_criteria.surface }
    else
        surface_list = game.surfaces
    end

    for _, surface in pairs(surface_list) do
        for chunk in surface.get_chunks() do
            local entities = surface.find_entities_filtered(
            {
                area = { left_top = { x = chunk.x * 32, y = chunk.y * 32 }, right_bottom = {x = (chunk.x + 1) * 32, (chunk.y + 1) * 32}},
                name = search_criteria.name,
                type = search_criteria.type,
                force = search_criteria.force
            })
            for _, entity in ipairs(entities) do
                array["x"..entity.position.x.."y"..entity.position.y] = entity
            end
        end
    end
end

    return Entity
