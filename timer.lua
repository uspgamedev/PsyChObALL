module ("timer",package.seeall) do
	local Timer = {}
	Timer.__index = Timer
	
	function Timer:update(dt,timefactor,paused)
		if not self.running or (paused and self.pausable) then return end
		if self.timeaffected then dt = dt*timefactor end
		self.time = self.time + dt
		if self.time>=self.timelimit then
			self.time = self.time - self.timelimit
			if self.func then self.func(self) end
			if self.onceonly then self:stop() end
		end
	end
	
	function Timer:start(delay)
		self.time = delay or 0
		self.running = true
	end
	
	function Timer:stop()
		self.running = false
	end
	
	function new(tl,ftc,running,pausable,onceonly,timeaffected,persistent,handlereset) --timelimit,functocall
		local timer = {}
		setmetatable(timer,Timer)
		timer.time = 0
		timer.timelimit = tl
		timer.func = ftc
		if onceonly==nil then timer.onceonly = false
		else timer.onceonly = onceonly end
		if pausable==nil then timer.pausable = true
		else timer.pausable = pausable end
		if running==nil then timer.running = true
		else timer.running = running end
		if timeaffected==nil then timer.timeaffected = true
		else timer.timeaffected = timeaffected end
		if persistent==nil then timer.persistent = false
		else timer.persistent = persistent end
		timer.handlereset = handlereset
		timer.delete = false
		table.insert(ts,timer)
		return timer
	end
	
	function update(dt,timefactor,paused)
		for i,v in pairs(ts) do
			if v.delete then
			    if not td then td = {v}
			    else table.insert(td,i) end
			else
			    v:update(dt,timefactor,paused)
			end
		end
		if td then
		    for i,v in ipairs(td) do
		        table.remove(td,v)
		    end
		    td = nil
		end
	end
	
	function closenonessential()
		local todelete = {}
		for i,v in pairs(ts) do
			if not v.persistent then table.insert(todelete,i)
			else 
				if v.handlereset then v.handlereset(v) end 
			end
		end
		local a = 0
		for j,k in pairs(todelete) do
			table.remove(ts,k-a)
			a = a + 1
		end
	end
end
