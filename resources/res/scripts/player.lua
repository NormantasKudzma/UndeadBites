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

local makeSprite = function(ix, iy, w, h)
	return Sprite:fromSheet(ix * 64, iy * 64, 64, 64, Paths.RESOURCES .. 'snake.png')
end

local sprites = {
	[100 + 2] =	makeSprite(4, 1), -- Top
	[100 + 1] =	makeSprite(5, 1), -- Right
	[100 - 2] =	makeSprite(0, 2), -- Bot
	[100 - 1] =	makeSprite(1, 2), -- Left
}

local selectSprite = function(dx, dy)
	P.object:setSprite(sprites[100 + dx * 1 + dy * 2])
	P.object:setScale(P.grid.spriteSX, P.grid.spriteSY)
end

-- Adds new tail segment
P.makeTail = function()
	local last = P.tail
	while (last.tailNext ~= nil) do
		last = last.tailNext
	end
	
	last.tailNext = P.tailSpawner.create(P.grid)
end

-- Create and spawn player on given grid
P.create = function(x, y, grid)
	P.grid = grid
	P.x = x
	P.y = y
	
	P.tailSpawner = dofile(Paths.SCRIPTS .. 'tail.lua')
	
	P.object = GameObject.new()
	selectSprite(0, 1)
	
	BaseGame:addObject(P.object, 'Player')
	
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
		elseif (thingAt.tag == 'Bones') then
			thingAt.moveOffGrid()
		elseif (thingAt.tag == 'Zombie') then
			BaseGame:restart()
			return false
		elseif (thingAt.tag == 'Tail') then
			return false
		end
	end

	local oldx = P.x
	local oldy = P.y
	
	P.x = P.x + dx
	P.y = P.y + dy
	P.grid.move(P.x, P.y, P)
	
	P.tail.follow(oldx, oldy, P)
	selectSprite(P.x - oldx, P.y - oldy)
	
	return true
end

-- Returns true if player can move in any direction
P.hasMoves = function()
	local coords = {
		{ 0, 1 },
		{ 0, -1 },
		{ 1, 0 },
		{ -1, 0 },
	}
	
	local canMoveOn = function(thing)
		if (thing == false) then
			return false
		end
		
		if (thing == nil) then
			return true
		end
		
		return thing.tag == 'Food' or thing.tag == 'Bones'
	end
	
	for k, v in pairs(coords) do
		local thingAt = P.grid.at(P.x + v[1], P.y + v[2])
		if (canMoveOn(thingAt)) then
			return true
		end
	end
	
	return false
end

------------
return P