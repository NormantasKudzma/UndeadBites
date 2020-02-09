local Main = {}

--
Main.init = function()
	print('Main script: init')
	
	Main.game = dofile(Paths.SCRIPTS .. 'game.lua')
	Main.game.init()
end

-- On keyboard button press; see link below for values
-- https://jogamp.org/deployment/v2.0.2/javadoc/jogl/javadoc/constant-values.html
Main.onButton = function(btn)
	Main.game.onButton(btn)
end

-- On mouse click; pos.x, pos.y
Main.onClick = function(pos)
	Main.game.onClick(pos)
end

--
Main.update = function(dt)
	Main.game.update(dt)
end

return Main