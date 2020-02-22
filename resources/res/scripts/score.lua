local S = {
	game = nil,
	scoreText = nil,
	multiplierText = nil,
	score = 0,
	multiplier = 1,
	eaten = 0,
	multiplierStep = 3,
	eatScore = 10,
	
	scaleBonus = 0,
	scaleSpeed = 1,
	scaleTimer = 0
}
------------

S.init = function(game)
	S.game = game
	
	local x = -0.7
	local y = 0.88
	
	local text = SimpleFont:create('Score')
	text:setPosition(x, y)
	BaseGame:addObject(text, 'Hud')
	
	S.scoreText = SimpleFont:create('0')
	S.scoreText:setPosition(x, y - 0.11)
	BaseGame:addObject(S.scoreText, 'Hud')
	
	S.multiplierText = SimpleFont:create('')
	S.multiplierText:setPosition(x, y - 0.56)
	BaseGame:addObject(S.multiplierText, 'Hud')
end

S.onFoodEaten = function()
	S.eaten = S.eaten + 1
	if (S.eaten >= S.multiplierStep) then
		S.eaten = 0
		S.multiplier = S.nextMultiplier()
		S.multiplierText:setText('x' .. tostring(S.multiplier))
		S.multiplierText:setVisible(true)
		S.scaleBonus = math.min(S.scaleBonus + 0.1, 0.4)
		S.scaleSpeed = math.min(S.scaleSpeed * 2, 7)
		print('multiplier now.. ', S.multiplier)
	end
	
	S.score = S.score + math.floor(S.eatScore * S.multiplier)
	S.scoreText:setText(tostring(S.score))
end

S.onBerryEaten = function()
	S.eaten = 0
	S.multiplier = 1
	S.multiplierText:setVisible(false)
	
	S.score = S.score + S.eatScore
	S.scoreText:setText(tostring(S.score))
	
	S.scaleBonus = 0
	S.scaleSpeed = 1
	S.scaleText(1)
end

S.scaleText = function(s)
	S.multiplierText:setScale(s, s)
end

S.nextMultiplier = function()
	return S.multiplier * 1.9
end

S.update = function(dt)
	S.scaleTimer = S.scaleTimer + dt
	if (S.multiplier > 1) then
		local s = 1 + S.scaleBonus * math.abs(math.sin(S.scaleTimer * S.scaleSpeed))
		S.scaleText(s)
	end
end

------------
return S