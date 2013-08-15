bossLast = body:new{
	size = 100, -- almost unused
	width = 200,
	height = 200,
	variance = 5,
	angle = nil, --vartimer
	__type = 'bossLast'
}

function bossLast:draw()
	graphics.push()
	graphics.setColor(color(colortimer.time + self.variance, 255, self.coloreffect))
	graphics.translate(self.x, self.y)
	graphics.rotate(self.angle.var)
	graphics.rectangle(self.mode, -self.size, -self.size, self.width, self.height)
	graphics.pop()
end

function bossLast:update( dt )
	body.update(self, dt)
	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function bossLast:__init()
	self.position:set(width/2, height/2)
	self.angle = vartimer:new{var = 0, pausable = true}
	--self.angle:setAndGo(0, 100, math.pi/4)
end

local pointInsideRect = function(x, y, w, h, x2, y2)
		if x2 > x + w then return false end
		if x2 < x then return false end
		if y2 < y then return false end
		if y2 > y + h then return false end
		return true
	end
local pointInsideCircle = function(x, y, size, x2, y2)
		return (x2 - x)^2 + (y2 - y)^2 <= size^2
	end
local abc = function(x1, y1, x2, y2)
		if x1 == x2 then
			return 1, 0, -y1
		end
		local m = (y2-y1)/(x2-x1)
		local k = y1 - m*x1
		if k ~= y2 - m*x2 then error(k .. '    ' .. y2 - m*x2) end
		return m, -1, k
	end
local lineCollidesWithCircle  = function ( x, y, size, p1, p2 )
	local a, b, c = abc(p1[1], p1[2], p2[1], p2[2])
	return ((a*x + b*y + c)^2)/(a^2 - b^2) <= size^2
end
function bossLast:collidesWith( pos, size ) --rectangle with circle
	if not size then
		size = pos.size
		pos = pos.position
	end

	local p1, p2, p3, p4 = 
		vector:new{-self.size, -self.size}:rotate(self.angle.var):add(self.position),
		vector:new{self.size, -self.size}:rotate(self.angle.var):add(self.position),
		vector:new{-self.size, self.size}:rotate(self.angle.var):add(self.position),
		vector:new{self.size, self.size}:rotate(self.angle.var):add(self.position)
	local fixedpos = vector:new{pos[1] - self.x,pos[2] - self.y}:rotate(-self.angle.var):add(self.position)

	print(pointInsideRect(self.x - self.size, self.y - self.size, self.width, self.height, unpack(fixedpos)),
					lineCollidesWithCircle(pos[1], pos[2], size, p1, p2),
					lineCollidesWithCircle(pos[1], pos[2], size, p2, p3),
					lineCollidesWithCircle(pos[1], pos[2], size, p3, p4),
					lineCollidesWithCircle(pos[1], pos[2], size, p4, p1))
	return pointInsideRect(self.x - self.size, self.y - self.size, self.width, self.height, unpack(fixedpos)) or
					lineCollidesWithCircle(pos[1], pos[2], size, p1, p2) or
					lineCollidesWithCircle(pos[1], pos[2], size, p2, p3) or
					lineCollidesWithCircle(pos[1], pos[2], size, p3, p4) or
					lineCollidesWithCircle(pos[1], pos[2], size, p4, p1)
end
