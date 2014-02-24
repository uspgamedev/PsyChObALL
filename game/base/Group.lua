require 'base.Basic'

Group = Basic:new {
	length = 0,
	class = Basic, -- class of objects it contains
	__type = 'Group'
}

function Group:add( obj )
	self.length = self.length + 1
	self[self.length] = obj
end

function Group:update( dt )
	for i = 1, self.length, 1 do
		if self[i].alive and self[i].active then
			self[i]:update(dt)
		end
	end
end

function Group:draw()
	for i = 1, self.length, 1 do
		if self[i].alive and self[i].active then
			self[i]:draw()
		end
	end
end

function Group:kill()
	for i = 1, self.length, 1 do
		if self[i].alive then
			self[i]:kill()
		end
	end
end

function Group:revive()
	for i = 1, self.length, 1 do
		if not self[i].alive then
			self[i]:revive()
		end
	end
end

function Group:countAlive()
	local count = 0
	for i = 1, self.length, 1 do
		if self[i].alive then count = count + 1 end
	end

	return count
end

function Group:forEach( func )
	for i = 1, self.length, 1 do
		func(self[i])
	end
end

function Group:forEachAlive( func )
	for i = 1, self.length, 1 do
		if self[i].alive and self[i].active then
			func(self[i])
		end
	end
end

function Group:forEachDead( func ) -- doesn't matter if it is active
	for i = 1, self.length, 1 do
		if not self[i].alive then
			func(self[i])
		end
	end
end

function Group:getFirstDead()
	for i = 1, self.length, 1 do
		if not self[i].alive then
			self[i].alive = true
			return self[i]
		end
	end
	local obj = self.class:new{}
	self:add(obj)
	return obj
end

function Group:getFirstAlive()
	-- returns nil if there are no alive
	for i = 1, self.length, 1 do
		if self[i].alive then
			return self[i]
		end
	end
end

function Group:getObjects( n )
	local basics = {}
	local count = 0

	for i = 1, self.length, 1 do -- recycling objects that are already dead
		if not self[i].alive then
			count = count + 1
			basics[count] = self[i]
			if count == n then return basics end
		end
	end

	while count < n do -- creating new objects if necessary
		count = count + 1
		basics[count] = self.class:new{}
		self:add(basics[count])
	end

	return basics
end

function Group:reviveObjects(n, ...)
	local count = 0

	for i = 1, self.length, 1 do -- recycling objects that are already dead
		if not self[i].alive then
			count = count + 1
			self[i]:revive(...)
			if count == n then return end
		end
	end

	while count < n do -- creating new objects if necessary
		count = count + 1
		local obj = self.class:new{}
		obj:revive(...)
		self:add(obj)
	end
end

function Group:clearAll() -- clears the group, doesn't kill any bodies
	for i = self.length, 1, -1 do
		self[i] = nil
	end

	self.length = 0
end

function Group:clearDead()
	local newSize = 0

	for i = 1, self.length, 1 do -- moving alive ones to the beginning
		if self[i].alive then
			newSize = newSize + 1
			self[newSize] = self[i]
		end
	end

	for i = newSize + 1, self.length, 1 do -- clearing the rest
		self[i] = nil
	end

	self.length = newSize
end

function Group:debug()
	for i = 1, self.length, 1 do
		io.write(i, ' -> ', tostring(self[i]), '\n')
	end
end