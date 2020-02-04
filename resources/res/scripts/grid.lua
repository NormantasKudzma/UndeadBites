local R = {
	spots = nil,
	width = 0,
	height = 0,
	sizeX = 0,
	sizeY = 0,
}
------------

-- Initialize grid with given size
R.create = function(w, h)
	print('Grid: create with size', w, h)

	R.spots = {}
	R.width = w
	R.height = h
	R.sizeY = (2.0 - 0.1) / R.height
	R.sizeX = R.sizeY -- / aspect
end

-- Returns object at grid position or false if out of bounds
R.at = function(x, y)
	if (x < 0 or x >= R.width) then
		return false
	end
	
	if (y < 0 or y >= R.height) then
		return false
	end
	
	return R.spots[R.index(x, y)]
end

-- Returns index into grid array from coordinates
R.index = function(x, y)
	return y * R.width + x
end

-- Puts and positions given thing at coordinates, returns old object at that position or false if failed
R.move = function(x, y, thing)
	if (x < 0 or x >= R.width) then
		return false
	end
	
	if (y < 0 or y >= R.height) then
		return false
	end
	
	R.removeObj(thing)
	
	local oldThing = R.at(x, y)
	R.spots[R.index(x, y)] = thing
	
	local wx, wy = R.positionOf(x, y)
	thing.object:setPosition(wx, wy)
	return oldThing
end

-- Removes object from grid coordinates, returns removed object or false if failed
R.remove = function(x, y)
	if (x < 0 or x >= R.width) then
		return false
	end
	
	if (y < 0 or y >= R.height) then
		return false
	end
	
	local oldThing = R.spots[R.index(x, y)]
	R.spots[R.index(x, y)] = nil
	return oldThing
end

-- Finds given object on grid, returns coordinates or nil if not found
R.find = function(thing)
	if (thing == nil) then
		return nil
	end
	
	for k, v in pairs(R.spots) do
		if (v == thing) then
			local y = math.floor(k / R.height)
			local x = k - y * R.height
			return x, y
		end
	end
	return nil
end

-- Removes given object from grid, returns removed object or false if not found
R.removeObj = function(thing)
	local x, y = R.find(thing)
	if (x == nil or y == nil) then
		return false
	end
	
	return R.remove(x, y)
end

-- Returns position on screen for given coordinates
R.positionOf = function(x, y)
	return (x - math.floor(R.width / 2)) * R.sizeX,
		   (y - math.floor(R.height / 2)) * R.sizeY
end

------------
return R