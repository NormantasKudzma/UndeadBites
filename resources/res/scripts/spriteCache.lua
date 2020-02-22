local C = {
	unused = {},
	
	scaleX = 1,
	scaleY = 1,
	layer = nil,
}
------------

-- Initializes cache for given layer and sprite scale
C.init = function(scaleX, scaleY, layer)
	C.scaleX = scaleX
	C.scaleY = scaleY
	C.layer = layer
	print('Sprite cache: created with scale ' .. C.scaleX .. ' ' .. C.scaleY .. ' for layer ' .. C.layer)
end

-- Get a new object or from cache if possible
C.create = function(sprite)
	local object = nil
	if (#C.unused <= 0) then
		object = GameObject.new()
		BaseGame:addObject(object, C.layer)
	else
		object = table.remove(C.unused)
	end
	
	if (sprite ~= nil) then
		object:setSprite(sprite:clone())
	end
	object:setScale(C.scaleX, C.scaleY)
	object:setVisible(true)
	return object
end

-- Return object for later reuse
C.destroy = function(obj)
	obj:setVisible(false)
	table.insert(C.unused, obj)
end

------------
return C