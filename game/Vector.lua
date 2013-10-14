require "lux.object"

Vector = lux.object.new {
	0,		-- x-axis
	0,		-- y-axis
	__type = "Vector"
}

function Vector:__tostring()
	return ('['..self[1]..', '..self[2]..']')
end

local getmetatable = getmetatable
function Vector:__index(n)
	if n=='x' then return self[1]
	elseif n=='y' then return self[2]
	else return getmetatable(self)[n] end
end

local rawset = rawset
function Vector:__newindex(i, v)
	if i=='x' then self[1] = v
	elseif i=='y' then self[2] = v
	else rawset(self,i,v) end
end

local type = type
--	returns first + second
function Vector.__add( first, second )
	if type(first) == 'number' then
		return Vector:new {
			second[1] + first,
			second[2] + first
		}
	elseif type(second) == 'number' then
		return Vector:new {
			first[1] + second,
			first[2] + second
		}
	else --both are Vectors
		return Vector:new {
			first[1] + second[1],
			first[2] + second[2]
		}
	end
end

--	returns first - second
function Vector.__sub( first, second)
	if type(first) == 'number' then
		return Vector:new {
			second[1] - first,
			second[2] - first
		}
	elseif type(second) == 'number' then
		return Vector:new {
			first[1] - second,
			first[2] - second
		}
	else --both are Vectors
		return Vector:new {
			first[1] - second[1],
			first[2] - second[2]
		}
	end
end

--	returns first*second
function Vector.__mul( first, second )
	if type(first) == 'number' then
		return Vector:new {
			second[1] * first,
			second[2] * first
		}
	elseif type(second) == 'number' then
		return Vector:new {
			first[1] * second,
			first[2] * second
		}
	else --both are Vectors
		return Vector:new {
			first[1] * second[1],
			first[2] * second[2]
		}
	end
end

--	returns first/second
function Vector.__div( first, second )
	if type(first) == 'number' then
		return Vector:new {
			first / second[1],
			first / second[2]
		}
	elseif type(second) == 'number' then
		return Vector:new {
			first[1] / second,
			first[2] / second
		}
	else --both are Vectors
		return Vector:new {
			first[1] / second[1],
			first[2] / second[2]
		}
	end
end

--	returns -first
function Vector.__unm( first )
	return Vector:new {
		-first[1],
		-first[2]
	}
end

--	checks if first == second
function Vector.__eq( first, second )
	return (first[1] == second[1]) and (first[2] == second[2])
end

function Vector:negate()
	self[1] = -self[1]
	self[2] = -self[2]

	return self
end

function Vector:set(x, y)
	if x == nil or type(x) == 'number' then
		self[1] = x or self[1]
		self[2] = y or self[2]
	else
		self[1] = x[1]
		self[2] = x[2]
	end

	return self
end

function Vector:add(x, y)
	if x==nil or type(x)=='number' then
		self[1] = self[1] + (x or 0)
		self[2] = self[2] + (y or 0)
	else
		self[1] = self[1] + x[1]
		self[2] = self[2] + x[2]
	end
	
	return self
end

function Vector:sub(x, y)
	if x==nil or type(x)=='number' then
		self[1] = self[1] - (x or 0)
		self[2] = self[2] - (y or 0)
	else
		self[1] = self[1] - x[1]
		self[2] = self[2] - x[2]
	end
	
	return self
end

function Vector:mult( x, y )
	self[1] = self[1] * (x or 1)
	self[2] = self[2] * (y or x or 1)
	
	return self
end

function Vector:div( x, y )
	self[1] = self[1] / (x or 1)
	self[2] = self[2] / (y or x or 1)
	
	return self
end


function Vector:equals(x, y)
	if y then
		return (self[1] == x) and (self[2] == y)
	else
		return (self[1] == x[1]) and (self[2] == x[2])
	end
end

function Vector:distsqr(x, y)
	if y then
		return (self[1]-x)^2 + (self[2]-y)^2
	else
		return (self[1]-x[1])^2 + (self[2]-x[2])^2
	end
end

function Vector:dist(x, y)
	return math.sqrt(self:distsqr(x,y))
end

function Vector:unpack()
	return self[1], self[2]
end

function Vector:lengthsqr()
	return self[1]^2 + self[2]^2
end

local sqrt = math.sqrt
function Vector:length()
	return sqrt(self:lengthsqr())
end

function Vector:normalized()
	return self/self:length()
end

function Vector:normalize()
	local length = self:length()
	return self:div(length,length)
end

function Vector:reset()
	self[1], self[2] = nil, nil
	return self
end

local msin, mcos = math.sin, math.cos
function Vector:rotate( rad )
	local sin, cos = msin(rad), mcos(rad)
	self[1], self[2] = 
		cos*self[1] - sin*self[2],
		sin*self[1] + cos*self[2]
	return self
end

function Vector:rotated( rad )
	return Vector:new{self[1], self[2]}:rotate()
end