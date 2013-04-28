module("list",package.seeall)

local List = {}
List.__index = List

function List:push(x)
	self[self.last] = x
	self.last = self.last + 1
end

function List:pop()
	if self.first==self.last then print("list empty") return end
	local x = self[self.first]
	self[self.first] = nil
	self.first = self.first + 1
	return x
end

function new()
	local list = {first=1,last=1}
	setmetatable(list,List)
	return list
end
