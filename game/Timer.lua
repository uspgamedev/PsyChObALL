Timer = lux.object.new {
	time			 = 0,
	onceOnly		 = false,
	pausable		 = true, -- If pause
	running		 = false,
	timeAffected = true,
	persistent	 = false, -- continues on death
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
		self:funcToCall(dt)
		return
	end 

	if self.time >= self.timelimit then
		self.time = self.time - self.timelimit

		if self.funcToCall then	self:funcToCall()	end
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

local pairs = pairs
function Timer.updateTimers(dt, timefactor, paused)
	for timer in pairs(Timer.timers) do
		timer:update(dt, timefactor, paused)
	end
end

function Timer.closeOldTimers()
	for timer in pairs(Timer.timers) do
		if not timer.persistent then
			timer:remove()
		else
			if timer.handleReset then timer:handleReset() end
		end
	end
end

function Timer.remove( t )
	Timer.timers[t] = nil
end

function Timer.register( t )
	Timer.timers[t] = true
end