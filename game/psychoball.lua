psychoball = body:new {
	size	 = 23,
	mode	 = 'fill',
	variance = 0
}

function psychoball:update(dt)
	if gamelost then return true end
	self.position:add(self.speed * dt)

	self.position:set(
		math.max(self.size, math.min(width - self.size, self.position[1])),
		math.max(self.size, math.min(height - self.size, self.position[2]))
	)

	for i,v in pairs(enemy.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			lostgame()
			self.diereason = "shot"
		end
	end
end

function psychoball:draw()
	if gamelost then return end
	graphics.setColor(color(colortimer.time + self.variance))
	graphics.circle(self.mode, self.x, self.y, self.size)
end