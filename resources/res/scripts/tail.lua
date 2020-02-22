local T = {
	grid = nil,
	cache = nil,
}
------------

local makeSprite = function(ix, iy, w, h)
	return Sprite:fromSheet(ix * 64, iy * 64, 64, 64, Paths.RESOURCES .. 'snake.png')
end

local sprites = {
	-- Ends
	[100 + 2] =	makeSprite(0, 0), -- EndTop
	[100 + 1] =	makeSprite(1, 0), -- EndRight
	[100 - 1] =	makeSprite(2, 0), -- EndLeft
	[100 - 2] =	makeSprite(3, 0), -- EndBot
	
	-- Straight segments
	[200 + 2] =	makeSprite(4, 0), -- vertical
	[200 + 4] =	makeSprite(5, 0), -- horizontal
	
	-- Corners
	[300 + 3] =	makeSprite(0, 1), -- TopRight
	[300 - 1] =	makeSprite(1, 1), -- BotRight
	[300 - 3] =	makeSprite(2, 1), -- BotLeft
	[300 + 1] =	makeSprite(3, 1), -- TopLeft
}

sprites.selectEnd = function(dx, dy)
	return sprites[100 + dx * 1 + dy * 2]
end

sprites.selectStraight = function(dx, dy)
	return sprites[200 + math.abs(dx * 2) + math.abs(dy * 1)]
end

sprites.selectCorner = function(oldx, oldy, x, y, prevx, prevy)
	local ox = 1
	if (oldx < x or prevx < x) then
		ox = -1
	end
	
	local oy = 1
	if (oldy < y or prevy < y) then
		oy = -1
	end
	
	return sprites[300 + ox * 1 + oy * 2]
end

-- Initialize tail spawner
T.init = function(grid)
	T.grid = grid

	T.cache = dofile(Paths.SCRIPTS .. 'spriteCache.lua')
	T.cache.init(grid.spriteSX, grid.spriteSY, 'Player')
end

-- Follow given previous tail, position and setup correct sprite
T.follow = function(x, y, prev, tail)
	if (tail.grid.at(x, y) ~= nil) then
		return
	end
	
	local oldx, oldy = tail.grid.find(tail)
	tail.grid.move(x, y, tail)
	
	if (oldx ~= nil and oldy ~= nil and tail.tailNext) then
		tail.tailNext.follow(oldx, oldy, tail)
	end
	
	tail.object:setVisible(true)
	
	local prevx, prevy = tail.grid.find(prev)
	local dx = prevx - (oldx or x)
	local dy = prevy - (oldy or y)
	
	local s = nil
	if (tail.tailNext == nil) then
		-- No tail? End
		s = sprites.selectEnd(prevx - x, prevy - y)
	elseif (dx ~= dy and (dx == 0 or dy == 0)) then
		-- Either x or y zero? Straight segment
		s = sprites.selectStraight(dx, dy)
	else
		-- Else, corner
		s = sprites.selectCorner(oldx, oldy, x, y, prevx, prevy)
	end
	
	if (s ~= nil) then
		tail.object:setSprite(s:clone())
		tail.object:setScale(T.grid.spriteSX, T.grid.spriteSY)
	end
end

T.create = function()
	local tail = {
		tag = 'Tail',
		object = nil,
		tailNext = nil,
		grid = T.grid,
		follow = nil,
	}

	tail.follow = function(x, y, prev) T.follow(x, y, prev, tail) end
	
	tail.object = T.cache.create()
	tail.object:setVisible(false)
	
	return tail
end

T.destroy = function(tail)
	T.grid.removeObj(tail)
	T.cache.destroy(tail.object)
end

------------
return T