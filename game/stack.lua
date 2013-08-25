stack = lux.object.new {
	size = 0
}

function stack:push(x)
	self.size = self.size + 1
	self[self.size] = x
end

function stack:pop()
	if self.size == 0 then print("stack empty") return nil end
	local x = self[self.size]
	self[self.size] = nil
	self.size = self.size - 1
	return x
end

function stack:peek()
	if self.size == 0 then print("stack empty") end
	return self[self.size]
end

function stack:clear()
	for i = 1, self.size, 1 do
		self[i] = nil
	end
	self.size = 0
end