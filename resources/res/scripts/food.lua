local F = {
	game = nil,
	grid = nil,
	
	cache = nil,
	zombies = nil,
	
	activeFood = 0,
	activeBerries = 0,
	activeBones = {},
	
	spriteFood = nil,
	spriteBones = nil,
	spriteBerry = nil,
}
------------

F.init = function(game)
	F.game = game
	F.grid = game.grid
	
	F.zombies = dofile(Paths.SCRIPTS .. 'zombie.lua')
	F.zombies.init(game)
	
	F.cache = dofile(Paths.SCRIPTS .. 'objectCache.lua')
	F.cache.init(F.grid.spriteSX, F.grid.spriteSY, 'Food')
	
	F.spriteFood = Sprite:fromSheet(64, 0, 64, 64, Paths.RESOURCES .. 'objs.png')
	F.spriteBones = Sprite:fromSheet(64, 64, 64, 64, Paths.RESOURCES .. 'objs.png')
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
		F.cache.destroy(bones.object)
		F.game.removeStepListener(bones)
		bones.moveOffGrid()
	end
	
	bones.step = function()
		if (F.grid.at(fx, fy) == nil) then
			bones.stepsRemain = bones.stepsRemain - 1
			if (bones.stepsRemain <= 0) then
				bones.die()
				table.remove(F.activeBones, F.game.tableIndexOf(F.activeBones, bones))
				F.zombies.makeZombie(fx, fy)
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
	
	bones.object = F.cache.create(F.spriteBones)
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
		F.cache.destroy(food.object)
		F.activeFood = math.max(0, F.activeFood - 1)
		F.game.score.onFoodEaten()
		print('Food: eaten, remaining ', F.activeFood)
	end
	food.object = F.cache.create(F.spriteFood)
	
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
		F.zombies.killAll()
		
		for i=1, #F.activeBones do
			F.activeBones[i].die()
		end
		F.activeBones = {}
		
		F.grid.removeObj(food)
		F.cache.destroy(food.object)
		F.activeBerries = math.max(0, F.activeBerries - 1)
		F.game.score.onBerryEaten()
		print('Berry: eaten, remaining ', F.activeBerries)
	end
	food.object = F.cache.create(F.spriteBerry)
	
	F.grid.move(x, y, food)
	
	F.activeBerries = F.activeBerries + 1
	print('Berry: spawned at ', x, y)
end

------------
return F