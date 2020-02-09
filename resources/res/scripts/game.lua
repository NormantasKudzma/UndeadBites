local G = {
	player = nil,
	grid = nil,
	foodSpawner = nil,
	score = nil,
	
	steps = 0,
	stepListeners = {},
	
	foodInitial = 4,
	foodMax = 3,
	foodEveryN = 10,
	
	berriesCounter = 0,
	berriesEveryN = 20,
	berriesMax = 1,
}
------------

local Button = {
	UP = 150,
	DOWN = 152,
	LEFT = 149,
	RIGHT = 151,
}

-- Process things when player does a step
G.nextStep = function()
	G.steps = G.steps + 1
	print('Game: steps', G.steps)

	for i=#G.stepListeners, 1, -1 do
		G.stepListeners[i].step()
	end
	
	-- No food on screen, spawn another
	if (G.foodSpawner.activeFood == 0) then
		G.foodSpawner.spawnFood()
	-- Enough steps passed and no more than max food on screen
	elseif (G.foodSpawner.activeFood < G.foodMax and G.steps % G.foodEveryN == 0) then
		G.foodSpawner.spawnFood()
	end
	
	G.berriesCounter = G.berriesCounter + 1
	if (G.foodSpawner.activeBerries < G.berriesMax and G.berriesCounter >= G.berriesEveryN) then
		G.berriesCounter = 0
		G.berriesEveryN = G.berriesEveryN * 1.16
		G.foodSpawner.spawnBerry()
	end
	
	if (not G.player.hasMoves()) then
		print('Game: player is stuck. Game over')
		BaseGame:restart()
	end
end

G.addStepListener = function(obj)
	table.insert(G.stepListeners, obj)
end

G.removeStepListener = function(obj)
	for i=1, #G.stepListeners do
		if (G.stepListeners[i] == obj) then
			table.remove(G.stepListeners, i)
			return
		end
	end
end

-- Try to move the player and advance the step counter
G.move = function (dx, dy)
	if (G.player.move(dx, dy)) then
		G.nextStep()
	end
end

G.init = function()
	BaseGame:addLayer('Player', 1000)

	G.score = dofile(Paths.SCRIPTS .. 'score.lua')
	G.score.init(G)
	
	G.grid = dofile(Paths.SCRIPTS .. 'grid.lua')
	G.grid.create(9, 9)

	G.player = dofile(Paths.SCRIPTS .. 'player.lua')
	G.player.create(5, 5, G.grid)
	
	G.foodSpawner = dofile(Paths.SCRIPTS .. 'food.lua')
	G.foodSpawner.init(G)
	for i = 1, G.foodInitial do
		G.foodSpawner.spawnFood()
	end
end

G.onButton = function(btn)
	if (btn == Button.UP) then
		G.move(0, 1)
	elseif (btn == Button.DOWN) then
		G.move(0, -1)
	elseif (btn == Button.LEFT) then
		G.move(-1, 0)
	elseif (btn == Button.RIGHT) then
		G.move(1, 0)
	end
end

G.onClick = function(pos)
	--stub
end

G.tableShuffle = function(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

------------
return G