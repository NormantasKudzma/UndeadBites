local Main = {}

--
Main.init = function()
	print('Main script: init')
	Main.game = dofile(Paths.SCRIPTS .. 'game.lua')
	Main.game.init()
end

-- On keyboard button press; check lwjgl docs for masks
Main.onButton = function(btn)
	Main.game.onButton(btn)
end

-- On mouse click; pos.x, pos.y
Main.onClick = function(pos)
	Main.game.onClick(pos)
end

--
Main.update = function(dt)

end

return Main