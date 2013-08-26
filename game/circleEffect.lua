CircleEffect = Body:new {
	alpha = 10,
	maxsize = width / 1.9,
	mode = 'line',
	__type = 'CircleEffect',
	changesimage = false,
	linewidth = 4,
	ord = 3,
	bodies = {}
}

Body.makeClass(CircleEffect)

function CircleEffect:__init()
	if self.based_on then --circle to be based on
		self.position = self.based_on.position:clone{}
		self.size = self.based_on.size
		self.variance = self.based_on.variance
		self.based_on = nil
	end
	
	self.sizeGrowth = self.sizeGrowth or math.random(120, 160)		
	self.variance = self.variance or math.random(0, 100*ColorManager.cycleTime) / 100
	if #CircleEffect.bodies > 250 then table.remove(CircleEffect.bodies, 1) end
	if self.index ~= nil then
		if self.index ~= false then
			self:start()
			CircleEffect.bodies[self.index] = self
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

function CircleEffect.init()
	CircleEffect.timer = Timer:new{
		timelimit = .2,
		running = true,
		persistent = true
	}

	function CircleEffect.timer:funcToCall() -- releases cirleEffects
		if onGame() then
			CircleEffect:new {
				based_on = psycho
			}
		end
		if state == survival then
			for i,v in pairs(Enemy.bodies) do
				if v.size >= 15 and math.random() < .5 --[[reducing chance]] then 
					CircleEffect:new{
						based_on = v
					} 
				end
			end
		end
	end
end

function CircleEffect:update(dt)
	self.size = self.size + self.sizeGrowth * dt
	if self.desiredsize then
		if self.sizeGrowth > 0 then
			if self.size > self.desiredsize then
				self.size = self.desiredsize
				self.sizeGrowth = 0
				self.desiredsize = nil
			end
		else
			if self.size < self.desiredsize then
				self.size = self.desiredsize
				self.sizeGrowth = 0
				self.desiredsize = nil
			end
		end
	end
	self.delete = self.delete or self.size < 0 or self.size > self.maxsize
end