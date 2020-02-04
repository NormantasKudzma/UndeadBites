local P = {
	grid = nil,
	object = nil,
	x = 0,
	y = 0,
	tag = 'Head',
	tailSpawner = nil,
	tail = nil,
}
------------

P.makeTail = function()
	local last = P.tail
	while (last.tailNext ~= nil) do
		last = last.tailNext
	end
	
	last.tailNext = P.tailSpawner.create(P.grid)
end

-- Create and spawn player on given grid
P.create = function(x, y, grid)
	P.tailSpawner = dofile(Paths.SCRIPTS .. 'tail.lua')
	
	P.object = GameObject.new()
	P.object:setSprite(Sprite:fromSheet(0, 0, 64, 64, Paths.RESOURCES .. 'objs.png'))
	
	BaseGame:addObject(P.object)
	
	P.grid = grid
	P.grid.move(x, y, P)
	
	P.tail = P.tailSpawner.create(grid)
end

-- Attempt to move player to this direction
P.move = function(dx, dy)
	local thingAt = P.grid.at(P.x + dx, P.y + dy)
	if (thingAt == false) then
		return false
	end
	
	if (thingAt ~= nil) then
		print('Player: stepped on', thingAt.tag)
		if (thingAt.tag == 'Food') then
			thingAt.eat()
			P.makeTail()
		elseif (thingAt.tag == 'Tail') then
			return false
		end
	end

	local oldx = P.x
	local oldy = P.y
	
	P.x = P.x + dx
	P.y = P.y + dy
	P.grid.move(P.x, P.y, P)
	
	P.tail.follow(oldx, oldy)
	
	return true
end

------------
return P