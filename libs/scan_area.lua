_RADIUS = 50
_scan_area = {}
_scanned_area = {}
_index = 0

-- this insanity creates a lookup table of the next position to scan for ores, based on an origin of 0,0
-- the positions spiral outward from the origin, so it looks pretty to players
-- e.g   1,  0
--      -1,  0
--       0,  1
--       0, -1
--       2,  0
--       2,  1
--       2, -1
-- etc. Useful because then I don't have to recursively generate it, just find the next sequence by the next index
function _populate_scan_area()
    local to_scan = {{x = 0, y = 0}}
    while #to_scan > 0 do
        local pos = table.remove(to_scan, 1)
        local key = string.format("%d,%d", pos.x, pos.y)
        if not _scanned_area[key] and (math.abs(pos.x) < _RADIUS and math.abs(pos.y) < _RADIUS) then

            table.insert(_scan_area, pos)
            _index = _index + 1
            _scanned_area[key] = _index
            table.insert(to_scan, {x = pos.x + 1, y = pos.y})
            table.insert(to_scan, {x = pos.x - 1, y = pos.y})
            table.insert(to_scan, {x = pos.x, y = pos.y + 1})
            table.insert(to_scan, {x = pos.x, y = pos.y - 1})
        end
    end
end

_populate_scan_area()

function get_position_for_index(index)
    return _scan_area[index]
end
