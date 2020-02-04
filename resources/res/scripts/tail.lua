local T = {}
------------

T.follow = function(x, y, tail)
	if (tail.grid.at(x, y) ~= nil) then
		return
	end
	
	local oldx, oldy = tail.grid.find(tail)
	tail.grid.move(x, y, tail)
	tail.object:setVisible(true)
	
	if (oldx ~= nil and oldy ~= nil and tail.tailNext) then
		tail.tailNext.follow(oldx, oldy)
	end
end

T.create = function(grid)
	local tail = {
		tag = 'Tail',
		object = nil,
		tailNext = nil,
		grid = grid,
		follow = nil,
	}

	tail.follow = function(x, y) T.follow(x, y, tail) end
	
	tail.object = GameObject.new()
	tail.object:setVisible(false)
	tail.object:setSprite(Sprite:fromSheet(0, 64, 64, 64, Paths.RESOURCES .. 'objs.png'))
	BaseGame:addObject(tail.object)
	
	return tail
end

------------
return T