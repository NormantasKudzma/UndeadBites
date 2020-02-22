local F = {
	game = nil,
	grid = nil,
	
	miscCache = nil,
	zombieCache = nil,
	
	activeFood = 0,
	activeBerries = 0,
	activeZombies = {},
	activeBones = {},
	
	spriteFood = nil,
	spriteBones = nil,
	spriteZombie = nil,
	spriteBerry = nil,
}
------------

F.init = function(game)
	F.game = game
	F.grid = game.grid
	
	F.miscCache = dofile(Paths.SCRIPTS .. 'spriteCache.lua')
	F.miscCache.init(F.grid.spriteSX, F.grid.spriteSY, 'Food')
	F.zombieCache = dofile(Paths.SCRIPTS .. 'spriteCache.lua')
	F.zombieCache.init(F.grid.spriteSX, F.grid.spriteSY, 'Zombie')
	
	F.spriteFood = Sprite:fromSheet(64, 0, 64, 64, Paths.RESOURCES .. 'objs.png')
	F.spriteBones = Sprite:fromSheet(64, 64, 64, 64, Paths.RESOURCES .. 'objs.png')
	F.spriteZombie = Sprite:fromSheet(128, 0, 64, 64, Paths.RESOURCES .. 'objs.png')
	F.spriteBerry = Sprite:fromSheet(0, 0, 64, 64, Paths.RESOURCES .. 'objs.png')
end

-- Find a suitable free space on the grid
F.findSpot = function()
	for i = 1, 10 do
		local x = math.random(0, F.grid.width - 1)
		local y = math.random(0, F.grid.height - 1)
		if (F.grid.at(x, y) == nil) then
			return x, y
		end
	end
	return nil
end

-- Spawn zombie at a given position
F.makeZombie = function(x, y)
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
			
			local movex = F.game.tableShuffle({ -1, 0, 1 })
			local movey = F.game.tableShuffle({ -1, 0, 1 })
			for i=1, 3 do
				local dx = movex[i]
				local dy = movey[i]
				
				local thingAt = F.grid.at(x + dx, y + dy)
				if (math.abs(dx) ~= math.abs(dy) and canMove(thingAt)) then
					x = x + dx
					y = y + dy
					if (thingAt ~= nil and (thingAt.tag == 'Player' or thingAt.tag == 'Tail')) then
						F.game.restart()
						zombie.object:setPosition(F.grid.positionOf(x, y))
					else
						F.grid.move(x, y, zombie)
					end
					print('Zombie: move by ', dx, dy)
					return
				end
			end
		end
	end
	
	zombie.die = function()
		F.grid.remove(x, y)
		F.zombieCache.destroy(zombie.object)
		F.game.removeStepListener(zombie)
	end
	
	zombie.object = F.zombieCache.create(F.spriteZombie)
	F.grid.move(x, y, zombie)
	F.game.addStepListener(zombie)
	table.insert(F.activeZombies, zombie)

	print('Zombie: spawn at', x, y)
end

F.makeBones = function(food)
	local fx, fy = F.grid.find(food)
	if (fx == nil or fy == nil) then
		return
	end
	
	local bones = {
		tag = 'Bones',
		object = nil,
		stepsRemain = 5,
		onGrid = false,
		moveToGrid = nil,
		moveOffGrid = nil,
		die = nil,
	}
	
	bones.die = function()
		F.miscCache.destroy(bones.object)
		F.game.removeStepListener(bones)
		bones.moveOffGrid()
	end
	
	bones.step = function()
		if (F.grid.at(fx, fy) == nil) then
			bones.stepsRemain = bones.stepsRemain - 1
			if (bones.stepsRemain <= 0) then
				bones.die()
				table.remove(F.activeBones, F.game.tableIndexOf(F.activeBones, bones))
				F.makeZombie(fx, fy)
			end
		end
	end
	
	bones.moveToGrid = function()
		if (bones.onGrid) then
			return
		end
		bones.onGrid = true
		F.grid.move(x, y, bones)
	end
	
	bones.moveOffGrid = function()
		if (not bones.onGrid) then
			return
		end
		bones.onGrid = false
		F.grid.remove(fx, fy)
	end
	
	bones.object = F.miscCache.create(F.spriteBones)
	bones.object:setPosition(F.grid.positionOf(fx, fy))
	F.game.addStepListener(bones)
	table.insert(F.activeBones, bones)
	print('Bones: spawned at ', fx, fy)
end

-- Randomly spawn food on the grid in a free space
F.spawnFood = function()
	local x, y = F.findSpot()
	if (x == nil or y == nil) then
		print('Food: could not find a suitable place to spawn..')
		return
	end
	
	local food = {
		tag = 'Food',
		object = nil,
		eat = nil,
	}
	
	food.eat = function()
		F.makeBones(food)
		F.grid.removeObj(food)
		F.miscCache.destroy(food.object)
		F.activeFood = math.max(0, F.activeFood - 1)
		F.game.score.onFoodEaten()
		print('Food: eaten, remaining ', F.activeFood)
	end
	food.object = F.miscCache.create(F.spriteFood)
	
	F.grid.move(x, y, food)
	
	F.activeFood = F.activeFood + 1
	print('Food: spawned, now ', F.activeFood)
end

F.spawnBerry = function()
	local x, y = F.findSpot()
	if (x == nil or y == nil) then
		print('Berry: could not find a suitable place to spawn..')
		return
	end
	
	local food = {
		tag = 'Berry',
		object = nil,
		eat = nil,
	}
	
	food.eat = function()
		for i=1, #F.activeZombies do
			F.activeZombies[i].die()
		end
		F.activeZombies = {}
		
		for i=1, #F.activeBones do
			F.activeBones[i].die()
		end
		F.activeBones = {}
		
		F.grid.removeObj(food)
		F.miscCache.destroy(food.object)
		F.activeBerries = math.max(0, F.activeBerries - 1)
		F.game.score.onBerryEaten()
		print('Berry: eaten, remaining ', F.activeBerries)
	end
	food.object = F.miscCache.create(F.spriteBerry)
	
	F.grid.move(x, y, food)
	
	F.activeBerries = F.activeBerries + 1
	print('Berry: spawned at ', x, y)
end

------------
return F