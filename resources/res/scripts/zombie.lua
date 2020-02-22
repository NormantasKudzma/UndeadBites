local Z = {
	game = nil,
	grid = nil,

	cache = nil,
	
	activeZombies = {},
	spriteZombie = nil,
}
------------

Z.init = function(game)
	Z.game = game
	Z.grid = game.grid

	Z.cache = dofile(Paths.SCRIPTS .. 'objectCache.lua')
	Z.cache.init(Z.grid.spriteSX, Z.grid.spriteSY, 'Zombie')
	
	Z.spriteZombie = Sprite:fromSheet(128, 0, 64, 64, Paths.RESOURCES .. 'objs.png')
end

-- Spawn zombie at a given position
Z.makeZombie = function(x, y)
	local zombie = {
		tag = 'Zombie',
		object = nil,
		moveSteps = 5,
		stepsRemain = 5,
		step = nil,
		die = nil,
	}
	
	zombie.step = function()
		zombie.stepsRemain = zombie.stepsRemain - 1
		if (zombie.stepsRemain <= 0) then
			zombie.stepsRemain = zombie.moveSteps
			
			local canMove = function(thingAt)
				if (thingAt == false) then
					return false
				end
				
				return thingAt == nil or thingAt.tag == 'Player' or thingAt.tag == 'Tail'
			end
			
			local movex = Z.game.tableShuffle({ -1, 0, 1 })
			local movey = Z.game.tableShuffle({ -1, 0, 1 })
			for i=1, 3 do
				local dx = movex[i]
				local dy = movey[i]
				
				local thingAt = Z.grid.at(x + dx, y + dy)
				if (math.abs(dx) ~= math.abs(dy) and canMove(thingAt)) then
					x = x + dx
					y = y + dy
					if (thingAt ~= nil and (thingAt.tag == 'Player' or thingAt.tag == 'Tail')) then
						Z.game.restart()
						zombie.object:setPosition(Z.grid.positionOf(x, y))
					else
						Z.grid.move(x, y, zombie)
					end
					print('Zombie: move by ', dx, dy)
					return
				end
			end
		end
	end
	
	zombie.die = function()
		Z.grid.remove(x, y)
		Z.cache.destroy(zombie.object)
		Z.game.removeStepListener(zombie)
	end
	
	zombie.object = Z.cache.create(Z.spriteZombie)
	Z.grid.move(x, y, zombie)
	Z.game.addStepListener(zombie)
	table.insert(Z.activeZombies, zombie)

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