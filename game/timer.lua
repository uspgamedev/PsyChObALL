timer = lux.object.new {
	time			 = 0,
	onceonly		 = false,
	pausable		 = true, -- If pause
	running		 = false,
	timeaffected = true,
	persistent	 = false, -- continues on death
	delete		 = false,
	works_on_gamelost = true,
	registerSelf = true,
	timers = {}
}

function timer:__init()
	if self.registerSelf then timer.register(self) end
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

local ts = timer.timers
function timer.updatetimers(dt, timefactor, paused, gamelost)
	for i = #ts, 1, -1 do
		local v = ts[i]
		if v.delete then
			table.remove(ts, i)
		else
			v:update(dt, timefactor, paused, gamelost)
		end
	end
end

function timer.closenonessential()
	for i = #ts, 1, -1 do
		local v = ts[i]
		if not v.persistent then v.delete = true
		else 
			if v.handlereset then v:handlereset() end 
		end
	end
end

function timer.remove( t )
	t.delete = true
end

function timer.register( t )
	if t.delete then t.delete = false end
	table.insert(ts, t)
end