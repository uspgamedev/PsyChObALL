Timer = lux.object.new {
	time			 = 0,
	onceOnly		 = false,
	pausable		 = true, -- If pause
	running		 = false,
	timeAffected = true,
	persistent	 = false, -- continues on death
	delete		 = false,
	works_on_gameLost = true,
	registerSelf = true,
	timers = {}
}

function Timer:__init()
	if self.registerSelf then Timer.register(self) end
end

function Timer:update(dt, timefactor, paused)
	if not self.running or (paused and self.pausable) or (DeathManager.gameLost and not self.works_on_gameLost) then return end
	if self.timeAffected then dt = dt * timefactor end
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
		if self.onceOnly then self:remove() end
	end
end

function Timer:start(delay)
	self.time = delay or self.time
	self.running = true
end

function Timer:stop()
	self.running = false
	self.time = 0
end

local ts = Timer.timers
function Timer.updatetimers(dt, timefactor, paused)
	for i = #ts, 1, -1 do
		local v = ts[i]
		if v.delete then
			table.remove(ts, i)
		else
			v:update(dt, timefactor, paused)
		end
	end
end

function Timer.closeOldTimers()
	for i = #ts, 1, -1 do
		local v = ts[i]
		if not v.persistent then v.delete = true
		else 
			if v.handleReset then v:handleReset() end 
		end
	end
end

function Timer.remove( t )
	t.delete = true
	t.running = false
	t.time = 0
end

function Timer.register( t )
	if t.delete then t.delete = false end
	table.insert(ts, t)
end