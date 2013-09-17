local lux = lux
local Stack
setfenv(1, {}) -- Restricts access to other stuff

Stack = lux.object.new {
	size = 0,
	__type = 'Stack'
}

function Stack:push(x)
	self.size = self.size + 1
	self[self.size] = x
end

function Stack:pop()
	if self.size == 0 then return nil end
	local x = self[self.size]
	self[self.size] = nil
	self.size = self.size - 1
	return x
end

function Stack:peek()
	return self[self.size]
end

function Stack:clear()
	for i = 1, self.size, 1 do
		self[i] = nil
	end
	self.size = 0
end

return Stack