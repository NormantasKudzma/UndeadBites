local R = {
	spots = nil,
	width = 0,
	height = 0,
	sizeX = 0,
	sizeY = 0,
}
------------

R.create = function(w, h)
	print('Grid: create with size', w, h)

	R.spots = {}
	R.width = w
	R.height = h
	R.sizeX = 0.1 -- / aspect
	R.sizeY = 0.1
end

R.at = function(x, y)
	if (x < 0 or x >= R.width) then
		return false
	end
	
	if (y < 0 or y >= R.height) then
		return false
	end
	
	return R.spots[R.index(x, y)]
end

R.index = function(x, y)
	return y * R.width + x
end

R.put = function(x, y, thing)
	if (x < 0 or x >= R.width) then
		return false
	end
	
	if (y < 0 or y >= R.height) then
		return false
	end
	
	local oldThing = R.at(x, y)
	R.spots[R.index(x, y)] = thing
	
	local wx, wy = R.positionOf(x, y)
	thing.object:setPosition(wx, wy)
	return oldThing
end

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

R.removeObj = function(thing)
	local x, y = R.find(thing)
	if (x == nil or y == nil) then
		return false
	end
	
	return R.remove(x, y)
end

R.positionOf = function(x, y)
	return (x - math.floor(R.width / 2)) * R.sizeX,
		   (y - math.floor(R.height / 2)) * R.sizeY
end

------------
return R