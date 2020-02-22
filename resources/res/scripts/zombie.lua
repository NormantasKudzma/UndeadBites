local Z = {
	game = nil,
	grid = nil,

	cache = nil,
	cacheArrow = nil,
	
	activeZombies = {},
	
	spriteZombie = nil,
	spriteArrow = nil,
}
------------

local makeSprite = function(ix, iy, w, h)
	return Sprite:fromSheet(ix * 64, iy * 64, 64, 64, Paths.RESOURCES .. 'objs.png')
end

Z.init = function(game)
	Z.game = game
	Z.grid = game.grid

	Z.cache = dofile(Paths.SCRIPTS .. 'objectCache.lua')
	Z.cache.init(Z.grid.spriteSX, Z.grid.spriteSY, 'Zombie')
	
	Z.cacheArrow = dofile(Paths.SCRIPTS .. 'objectCache.lua')
	Z.cacheArrow.init(Z.grid.spriteSX, Z.grid.spriteSY, 'ZombieArrow')
	
	Z.spriteZombie = makeSprite(2, 0)
	Z.spriteArrow = {
		[100 + 2] = makeSprite(2, 1), -- Top
		[100 + 1] = makeSprite(3, 1), -- Right
		[100 - 2] = makeSprite(2, 2), -- Bot
		[100 - 1] = makeSprite(3, 2), -- Left
	}
end

-- Spawn zombie at a given position
Z.makeZombie = function(x, y)
	local zombie = {
		tag = 'Zombie',
		object = nil,
		arrow = nil,
		moveSteps = 5,
		stepsRemain = 5,
		step = nil,
		die = nil,
		selectDirection = nil,
	}
	
	local canMove = function(thingAt)
		if (thingAt == false) then
			return false
		end
		
		return thingAt == nil or thingAt.tag == 'Player' or thingAt.tag == 'Tail'
	end
		
	zombie.selectDirection = function()
		zombie.nextDx = nil
		zombie.nextDy = nil
		
		local movex = Z.game.tableShuffle({ -1, 0, 1 })
		local movey = Z.game.tableShuffle({ -1, 0, 1 })
		for i=1, 3 do
			local dx = movex[i]
			local dy = movey[i]
			
			local thingAt = Z.grid.at(x + dx, y + dy)
			if (math.abs(dx) ~= math.abs(dy) and canMove(thingAt)) then
				zombie.nextDx = dx
				zombie.nextDy = dy
				break
			end
		end
	
		print('Zombie ' .. tostring(zombie) .. ' destroy arrow ' .. tostring(zombie.arrow))
		Z.cacheArrow.destroy(zombie.arrow)
		zombie.arrow = nil
		
		if (zombie.nextDx ~= nil and zombie.nextDy ~= nil) then
			local sprite = Z.spriteArrow[100 + zombie.nextDx * 1 + zombie.nextDy * 2]
			zombie.arrow = Z.cacheArrow.create(sprite)
			zombie.arrow:setPosition(zombie.object:getPosition())
		end
	end
	
	zombie.step = function()
		zombie.stepsRemain = zombie.stepsRemain - 1
		if (zombie.stepsRemain <= 0) then
			zombie.stepsRemain = zombie.moveSteps
			
			if (zombie.nextDx ~= nil and zombie.nextDy ~= nil) then
				local thingAt = Z.grid.at(x + zombie.nextDx, y + zombie.nextDy)
				if (canMove(thingAt)) then
					x = x + zombie.nextDx
					y = y + zombie.nextDy
					if (thingAt ~= nil and (thingAt.tag == 'Player' or thingAt.tag == 'Tail')) then
						Z.game.restart()
						zombie.object:setPosition(Z.grid.positionOf(x, y))
					else
						Z.grid.move(x, y, zombie)
					end
					print('Zombie: move by ', zombie.nextDx, zombie.nextDy)
				end
			end
			
			zombie.selectDirection()
		end
	end
	
	zombie.die = function()
		Z.grid.remove(x, y)
		Z.cache.destroy(zombie.object)
		Z.game.removeStepListener(zombie)
		Z.cacheArrow.destroy(zombie.arrow)
	end
	
	zombie.object = Z.cache.create(Z.spriteZombie)
	Z.grid.move(x, y, zombie)
	Z.game.addStepListener(zombie)
	table.insert(Z.activeZombies, zombie)
	
	zombie.selectDirection()

	print('Zombie: spawn at', x, y)
end

Z.killAll = function()
	for i=1, #Z.activeZombies do
		Z.activeZombies[i].die()
	end
	Z.activeZombies = {}
end

------------
return Z