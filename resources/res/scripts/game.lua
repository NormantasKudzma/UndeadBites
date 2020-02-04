local G = {
	player = nil,
	grid = nil,
	foodSpawner = nil,
	
	steps = 0,
	
	foodInitial = 2,
	foodMax = 3,
	foodEveryN = 10,
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

	-- No food on screen, spawn another
	if (G.foodSpawner.active == 0) then
		G.foodSpawner.spawn(G.grid)
	-- Enough steps passed and no more than max food on screen
	elseif (G.foodSpawner.active < G.foodMax and G.steps % G.foodEveryN == 0) then
		G.foodSpawner.spawn(G.grid)
	end
end

-- Try to move the player and advance the step counter
G.move = function (dx, dy)
	if (G.player.move(dx, dy)) then
		G.nextStep()
	end
end

G.init = function()
	G.grid = dofile(Paths.SCRIPTS .. 'grid.lua')
	G.grid.create(9, 9)

	G.player = dofile(Paths.SCRIPTS .. 'player.lua')
	G.player.create(G.grid)
	G.player.move(5, 5)
	
	G.foodSpawner = dofile(Paths.SCRIPTS .. 'food.lua')
	for i = 1, G.foodInitial do
		G.foodSpawner.spawn(G.grid)
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

------------
return G