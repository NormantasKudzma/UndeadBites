local S = {
	game = nil,
	scoreText = nil,
	multiplierText = nil,
	score = 0,
	multiplier = 1,
	eaten = 0,
	multiplierStep = 3,
	eatScore = 10,
}
------------

S.init = function(game)
	S.game = game
	
	local x = -0.8
	local y = 0.88
	
	local text = SimpleFont:create('Score')
	text:setPosition(x, y)
	BaseGame:addObject(text)
	
	S.scoreText = SimpleFont:create('0')
	S.scoreText:setPosition(x, y - 0.11)
	BaseGame:addObject(S.scoreText)
	
	S.multiplierText = SimpleFont:create('')
	S.multiplierText:setPosition(x, y - 0.26)
	BaseGame:addObject(S.multiplierText)
end

S.onFoodEaten = function()
	S.eaten = S.eaten + 1
	if (S.eaten >= S.multiplierStep) then
		S.multiplier = S.multiplier + 2
		S.eaten = 0
		S.multiplierText:setText('x' .. tostring(S.multiplier))
	end
	
	S.score = S.score + S.eatScore * S.multiplier
	S.scoreText:setText(tostring(S.score))
end

S.onBerryEaten = function()
	S.eaten = 0
	S.multiplier = 0
	S.multiplierText:setVisible(false)
	
	S.score = S.score + S.eatScore
	S.scoreText:setText(tostring(S.score))
end

------------
return S