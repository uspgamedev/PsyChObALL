require 'lux.object'

timer = lux.object.new {
	time 		 = 0,
	onceonly 	 = false,
	pausable 	 = true, -- If pause
	running 	 = true,
	timeaffected = true,
	persistent 	 = false, -- continues on death
	delete 		 = false
}

function timer:__init()
	table.insert(timer.ts,self)
end

function timer:update(dt,timefactor,paused)
	if not self.running or (paused and self.pausable) then return end
	if self.timeaffected then dt = dt*timefactor end
	self.time = self.time + dt
	if self.time>=self.timelimit then
		self.time = self.time - self.timelimit
		if self.funcToCall then self.funcToCall(self) end
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


function timer.updatetimers(dt,timefactor,paused)
	local todelete
	for i,v in pairs(timer.ts) do
		if v.delete then
		    if not todelete then todelete = {v}
		    else table.insert(todelete,i) end
		else
		    v:update(dt,timefactor,paused)
		end
	end
	if todelete then
	    for i,v in ipairs(todelete) do
	        table.remove(todelete,v)
	    end
	end
end

function timer.closenonessential()
	local todelete = {}
	for i,v in pairs(timer.ts) do
		if not v.persistent then table.insert(todelete,i)
		else 
			if v.handlereset then v.handlereset(v) end 
		end
	end
	local a = 0
	for j,k in pairs(todelete) do
		table.remove(timer.ts,k-a)
		a = a + 1
	end
end