local F = {
	game = nil,
	grid = nil,
	unused = {},
	active = 0,
	spriteFood = nil,
	spriteBones = nil,
	spriteZombie = nil,
}
------------

F.init = function(game)
	F.game = game
	F.grid = game.grid
	F.spriteFood = Sprite:fromSheet(64, 0, 64, 64, Paths.RESOURCES .. 'objs.png')
	F.spriteBones = Sprite:fromSheet(64, 64, 64, 64, Paths.RESOURCES .. 'objs.png')
	F.spriteZombie = Sprite:fromSheet(128, 0, 64, 64, Paths.RESOURCES .. 'objs.png')
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

-- Returns a game object for food; reuses old objects
F.makeObject = function(sprite)
	if (#F.unused <= 0) then
		local object = GameObject.new()
		object:setSprite(sprite:clone())
		BaseGame:addObject(object)
		print('create new obj..')
		return object
	else
		local object = table.remove(F.unused)
		object:setSprite(sprite:clone())
		object:setVisible(true)
		print('-- obj, now ', #F.unused)
		return object
	end
end

F.releaseObject = function(obj)
	obj:setVisible(false)
	table.insert(F.unused, obj)
	print('++ obj, now ', #F.unused)
end

F.makeZombie = function(x, y)
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
	}
	
	bones.step = function()
		if (F.grid.at(fx, fy) == nil) then
			bones.stepsRemain = bones.stepsRemain - 1
			if (bones.stepsRemain <= 0) then
				F.releaseObject(bones.object)
				F.game.removeStepListener(bones)
				bones.moveOffGrid()
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
	
	bones.object = F.makeObject(F.spriteBones)
	bones.object:setPosition(F.grid.positionOf(fx, fy))
	F.game.addStepListener(bones)
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
		F.releaseObject(food.object)
		F.active = math.max(0, F.active - 1)
		print('Food: eaten, remaining ', F.active)
	end
	food.object = F.makeObject(F.spriteFood)
	
	F.grid.move(x, y, food)
	
	F.active = F.active + 1
	print('Food: spawned, now ', F.active)
end

------------
return F