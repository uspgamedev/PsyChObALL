circleEffect = body:new {
	alpha = 10,
	maxsize = width / 1.9,
	mode = 'line',
	__type = 'circleEffect',
	changesimage = false,
	bodies = {}
}

function circleEffect:__init()
	if self.based_on then --circle to be based on
		self.position = self.based_on.position:clone{}
		self.size = self.based_on.size
		self.variance = self.based_on.variance
		self.based_on = nil
	end
	
	self.sizeGrowth = self.sizeGrowth or math.random(120, 160)		
	self.variance = self.variance or math.random(0, 100*colorcycle) / 100
	if #circleEffect.bodies > 250 then table.remove(circleEffect.bodies, 1) end
	if self.index ~= nil then
		if self.index ~= false then
			self:start()
			circleEffect.bodies[self.index] = self
		end
	else
		self:register()
	end
	--[[self.stencil = graphics.newStencil( function() 
		local n = (self.linewidth or 4) + 4
		graphics.setLine(n)
		graphics.circle(self.mode, self.x, self.y, self.size - n/2) 
		end)]]
end

function circleEffect.init()
	circleEffect.timer = timer:new{
		timelimit = .2,
		running = true,
		persistent = true
	}

	function circleEffect.timer:funcToCall() -- releases cirleEffects
		if onGame() then
			circleEffect:new {
				based_on = psycho
			}
		end
		for i,v in pairs(enemy.bodies) do
			if v.size >= 15 and math.random() < .5 --[[reducing chance]] then 
				circleEffect:new{
					based_on = v
				} 
			end
		end
	end
end

function circleEffect:draw()
	if self.linewidth then graphics.setLine(self.linewidth) end
	body.draw(self)
	if self.linewidth then graphics.setLine(4) end
end

function circleEffect:update(dt)
	self.size = self.size + self.sizeGrowth * dt
	self.delete = self.size < 0 or self.size > self.maxsize
end