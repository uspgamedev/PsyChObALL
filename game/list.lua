require 'lux.object'

list = lux.object.new {
	first = 1,
	last = 1
}

function list:push(x)
	self[self.last] = x
	self.last = self.last + 1
end

function list:pop()
	if self.first == self.last then print("list empty") return nil end
	local x = self[self.first]
	self[self.first] = nil
	self.first = self.first + 1
	return x
end
