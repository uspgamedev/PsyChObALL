require "lux.object"

vector = lux.object.new {
	0,		-- x-axis
	0,		-- y-axis
	__type = "vector"
}

function vector:__tostring()
	return ('['..self[1]..', '..self[2]..']')
end

function vector:__index(n)
	if n=='x' then return self[1]
	elseif n=='y' then return self[2]
	elseif n=='w' then return self[3]
	elseif n=='z' then return self[4]
	else return getmetatable(self)[n] end
end

function vector:__newindex(i, v)
	if i=='x' then self[1] = v
	elseif i=='y' then self[2] = v
	elseif i=='w' then self[3] = v
	elseif i=='z' then self[4] = v
	else rawset(self,i,v) end
end

--	returns first + second
function vector.__add( first, second )
	if type(first) == 'number' then
		return vector:new {
			second[1] + first,
			second[2] + first
		}
	elseif type(second) == 'number' then
		return vector:new {
			first[1] + second,
			first[2] + second
		}
	else --both are vectors
		return vector:new {
			first[1] + second[1],
			first[2] + second[2]
		}
	end
end

--	returns first - second
function vector.__sub( first, second)
	if type(first) == 'number' then
		return vector:new {
			second[1] - first,
			second[2] - first
		}
	elseif type(second) == 'number' then
		return vector:new {
			first[1] - second,
			first[2] - second
		}
	else --both are vectors
		return vector:new {
			first[1] - second[1],
			first[2] - second[2]
		}
	end
end

--	returns first*second
function vector.__mul( first, second )
	if type(first) == 'number' then
		return vector:new {
			second[1] * first,
			second[2] * first
		}
	elseif type(second) == 'number' then
		return vector:new {
			first[1] * second,
			first[2] * second
		}
	else --both are vectors
		return vector:new {
			first[1] * second[1],
			first[2] * second[2]
		}
	end
end

--	returns first/second
function vector.__div( first, second )
	if type(first) == 'number' then
		return vector:new {
			first / second[1],
			first / second[2]
		}
	elseif type(second) == 'number' then
		return vector:new {
			first[1] / second,
			first[2] / second
		}
	else --both are vectors
		return vector:new {
			first[1] / second[1],
			first[2] / second[2]
		}
	end
end

--	returns -first
function vector.__unm( first )
	return vector:new {
		-first[1],
		-first[2]
	}
end

--	checks if first == second
function vector.__eq( first, second )
	return (first[1] == second[1]) and (first[2] == second[2])
end

function vector:set(x, y)
	if x == nil or type(x) == 'number' then
		self[1] = x or self[1]
		self[2] = y or self[2]
	else
		self[1] = x[1]
		self[2] = x[2]
	end

	return self
end

function vector:add(x, y)
	if x==nil or type(x)=='number' then
		self[1] = self[1] + (x or 0)
		self[2] = self[2] + (y or 0)
	else
		self[1] = self[1] + x[1]
		self[2] = self[2] + x[2]
	end
	
	return self
end

function vector:sub(x, y)
	if x==nil or type(x)=='number' then
		self[1] = self[1] - (x or 0)
		self[2] = self[2] - (y or 0)
	else
		self[1] = self[1] - x[1]
		self[2] = self[2] - x[2]
	end
	
	return self
end

function vector:mult( x, y )
	if x==nil or type(x)=='number' then
		self[1] = self[1] * (x or 1)
		self[2] = self[2] * (y or x or 1)
	else
		self[1] = self[1] * x[1]
		self[2] = self[2] * x[2]
	end
	
	return self
end

function vector:div( x, y )
	if x==nil or type(x)=='number' then
		self[1] = self[1] / (x or 1)
		self[2] = self[2] / (y or x or 1)
	else
		self[1] = self[1] / x[1]
		self[2] = self[2] / x[2]
	end
	
	return self
end


function vector:equals(x, y)
	if y then
		return (self[1] == x) and (self[2] == y)
	else
		return (self[1] == x[1]) and (self[2] == x[2])
	end
end

function vector:distsqr(x, y)
	if y then
		return (self[1]-x)^2 + (self[2]-y)^2
	else
		return (self[1]-x[1])^2 + (self[2]-x[2])^2
	end
end

function vector:dist(x, y)
	return math.sqrt(self:distsqr(x,y))
end

function vector:unpack()
	return self[1], self[2], self[3], self[4]
end

function vector:lengthsqr()
	return self[1]^2 + self[2]^2
end

function vector:length()
	return math.sqrt(self:lengthsqr())
end

function vector:normalized()
	return self/self:length()
end

function vector:normalize()
	local length = self:length()
	return self:div(length,length)
end

function vector:reset()
	return self:set(0, 0)
end