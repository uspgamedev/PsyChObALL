local abs, random = math.abs, math.random

bossFive = Body:new {
	size = 125,
	irisSize = 55,
	ord = 8,
	variance = 4,
	maxHealth = 100,
	--shader = Base.circleShader,
	__type = 'bossFive'
}
Body.makeClass(bossFive)

function bossFive:__init()
	self.position:set(-self.size - 10, -self.size - 10)
	self.speed:set(v, v)
	self.irisPosition = Vector:new{0, 0}
	self.pupilSize = VarTimer:new{}
	local funkShrink
	local funcGrow = function(timer) timer:setAndGo(27, 32, 1 + random()) timer.alsoCall = funcShrink end
	funcShrink = function(timer) timer:setAndGo(32, 27, 1 + random()) timer.alsoCall = funcGrow end
	funcGrow(self.pupilSize)
	self.health = bossFive.maxHealth
end

function bossFive:bounceInScreen()
	if self.x + self.size >= width then
		self.Vx = -abs(self.Vx)
	elseif self.x - self.size <= 0 then
		self.Vx = abs(self.Vx)
	end

	if self.y + self.size >= height then
		self.Vy = -abs(self.Vy)
	elseif self.y - self.size <= 0 then
		self.Vy = abs(self.Vy)
	end
end

local auxVec = Vector:new{0, 0}
function bossFive:update( dt )
	self.position:add(auxVec:set(self.speed):mult(dt))
	self:bounceInScreen()
	self.irisPosition:set(psycho.position):sub(self.position):div(5)
	local l = self.irisPosition:length()
	if l > 35 then self.irisPosition:mult(35/l) end

	for _, v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			v.collides = true
			v.explosionEffects = true
			if self.health > 0 then 
				self.health = self.health - 1
			else
				self.delete = true
			end
		end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end
end

local eyeballImage = graphics.newImage 'resources/eyeball.png'
function bossFive:draw()
	graphics.setColor(255, 255, 255)
	graphics.draw(eyeballImage, self.position[1] - self.size, self.position[2] - self.size)

	--drawing pupil
	graphics.setPixelEffect(Base.circleShader)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.coloreffect))
	graphics.circle('fill', self.position[1] + self.irisPosition[1], self.position[2] + self.irisPosition[2], self.irisSize)
	graphics.setColor(0, 0, 0)
	graphics.circle('fill', self.position[1] + self.irisPosition[1], self.position[2] + self.irisPosition[2], self.pupilSize.var)
	graphics.setPixelEffect()
end

function bossFive:handleDelete()
	Effect.createEffects(self, 300)
end