local F = {
	unused = {},
	active = 0,
}
------------

-- Find a suitable free space on the grid
F.findSpot = function(grid)
	for i = 1, 10 do
		local x = math.random(0, grid.width - 1)
		local y = math.random(0, grid.height - 1)
		if (grid.at(x, y) == nil) then
			return x, y
		end
	end
	return nil
end

-- Returns a game object for food; reuses old objects
F.makeObject = function()
	if (#F.unused <= 0) then
		local object = GameObject.new()
		object:setSprite(Sprite:fromSheet(64, 0, 64, 64, Paths.RESOURCES .. 'objs.png'))
		BaseGame:addObject(object)
		return object
	else
		local object = table.remove(F.unused)
		object:setVisible(true)
		return object
	end
end

-- Remove food object from game
F.eat = function(food)
	food.grid.removeObj(food)
	food.object:setVisible(false)
	table.insert(F.unused, food.object)
	F.active = math.max(0, F.active - 1)
	print('Food: eaten, remaining ', F.active)
end

-- Randomly spawn food on the grid in a free space
F.spawn = function(grid)
	local x, y = F.findSpot(grid)
	if (x == nil or y == nil) then
		print('Food: could not find a suitable place to spawn..')
		return
	end
	
	local food = {
		tag = 'Food',
		object = nil,
		grid = grid,
		eat = nil,
	}
	
	food.eat = function() F.eat(food) end
	food.object = F.makeObject()
	
	grid.put(x, y, food)
	
	F.active = F.active + 1
	print('Food: spawned, now ', F.active)
end

------------
return F