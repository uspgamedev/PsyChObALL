list = lux.object.new {
	first = 1,
	last = 1
}

function list:push(x)
	if x.getWarning then x:getWarning() end
	self[self.last] = x
	self.last = self.last + 1
end

function list:pop()
	if self.first == self.last then print("list empty") return nil end
	local x = self[self.first]
	if x.freeWarning then x:freeWarning() end
	self[self.first] = nil
	self.first = self.first + 1
	return x
end

function list:clear()
	for i = self.first, self.last-1 do
		if self[i].freeWarning then self[i]:freeWarning() end
		self[i] = nil
	end
	self.first = 1
	self.last = 1
end