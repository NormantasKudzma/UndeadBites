local P = {
	grid = nil,
	object = nil,
	x = 0,
	y = 0,
	tag = 'Head',
}
------------

P.create = function(grid)
	P.object = GameObject.new()
	P.object:setSprite(Sprite:fromSheet(0, 0, 64, 64, Paths.RESOURCES .. 'objs.png'))
	
	BaseGame:addObject(P.object)
	
	P.grid = grid
end

P.move = function(dx, dy)
	local thingAt = P.grid.at(P.x + dx, P.y + dy)
	if (thingAt == false) then
		return false
	end
	
	if (thingAt ~= nil) then
		print('Player: stepped on', thingAt.tag)
		if (thingAt.tag == 'Food') then
			thingAt.eat()
			--add tail
		end
	end

	P.grid.remove(P.x, P.y)
	P.x = P.x + dx
	P.y = P.y + dy
	P.grid.put(P.x, P.y, P)
	return true
end

------------
return P