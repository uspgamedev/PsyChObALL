timer = lux.object.new {
	time			 = 0,
	onceonly		 = false,
	pausable		 = true, -- If pause
	running		 = false,
	timeaffected = true,
	persistent	 = false, -- continues on death
	delete		 = false,
	works_on_gamelost = true,
	timers = {}
}

function timer:__init()
	table.insert(timer.timers, self)
end

function timer:update(dt, timefactor, paused, gamelost)
	if not self.running or (paused and self.pausable) or (gamelost and not self.works_on_gamelost) then return end
	if self.timeaffected then dt = dt * timefactor end
	self.time = self.time + dt
	if not self.timelimit and self.funcToCall then 
		if self.extraelements then self:funcToCall(dt, unpack(self.extraelements))
		else self:funcToCall(dt) end
		return
	end 
	if self.time >= self.timelimit then
		self.time = self.time - self.timelimit
		if self.funcToCall then
			if self.extraelements then self:funcToCall(unpack(self.extraelements))
			else self:funcToCall() end
		end
		if self.onceonly then self:stop() end
	end
end

function timer:start(delay)
	self.time = delay or 0
	self.running = true
end

function timer:stop()
	self.running = false
end


function timer.updatetimers(dt, timefactor, paused, gamelost)
	local todelete
	for i,v in pairs(timer.timers) do
		if v.delete then
			if not todelete then todelete = {i}
			else table.insert(todelete,i) end
		else
			v:update(dt, timefactor, paused, gamelost)
		end
	end
	if todelete then
		for i,v in ipairs(todelete) do
			table.remove(todelete, v)
		end
	end
end

function timer.closenonessential()
	local todelete = {}
	for i,v in pairs(timer.timers) do
		if not v.persistent then table.insert(todelete, i)
		else 
			if v.handlereset then v:handlereset() end 
		end
	end
	local a = 0
	for j,k in pairs(todelete) do
		table.remove(timer.timers, k - a)
		a = a + 1
	end
end