effect = body:new {
	size	 = 3,
	__type   = 'effect',
	noShader = true,
	bodies = {}
}

effect.spriteBatch = love.graphics.newSpriteBatch(base.pixel, 1200, 'dynamic')
local effectCount = 0
local allEffects = {}
local canClear = true
setmetatable(allEffects, {__mode = 'v'})
local clearTimer = timer:new{
		timelimit = 3,
		pausable = false,
		persistent = true,
		funcToCall = function(t)
			t:stop()
			canClear = true
		end
	}

function effect:start()
	body.start(self)
	self.etc = 0
	table.insert(allEffects, self)
	self:addToBatch()
	if effectCount > 1195 and canClear then
		canClear = false
		clearTimer:start() -- prevents clearing for another 3 seconds

		effectCount = 0
		effect.spriteBatch:clear()
		effect.spriteBatch:bind()
		for _, e in pairs(allEffects) do
			e:addToBatch()
		end
		effect.spriteBatch:unbind()
	end
end

function effect:addToBatch()
	if self.delete or effectCount > 1197 then return end
	self.id = effect.spriteBatch:add(self.x, self.y, 0, self.size)
	effectCount = effectCount + 1
end

function effect:draw()
	local color = ColorManager.getComposedColor(self.variance + ColorManager.timer.time, 255, self.coloreffect)
	if self.id then
		effect.spriteBatch:setColor(unpack(color))
		effect.spriteBatch:set(self.id, self.x, self.y, 0, self.size)
	else
		graphics.setColor(color)
		graphics.draw(base.pixel, self.x, self.y, 0, self.size)
	end
end

function effect:update(dt)
	body.update(self, dt)
	self.etc = self.etc + dt

	self.delete = self.delete or self.etc > self.timetogo
end

function effect:handleDelete()
	body.handleDelete(self)
	if not self.id then return end
	effect.spriteBatch:set(self.id, 0, 0, 0, 0, 0)
end

function effect:clear()
	for k, e in pairs(self.bodies) do
		e:handleDelete()
		self.bodies[k] = nil
	end
end

function neweffects(based_on, times)
	times = math.ceil(times/2)
	--local speedinfluence = based_on.speed * .6
	if (based_on.alpha or (based_on.alphafollows and based_on.alphafollows.var) or 1) == 0 then return end
	for i = 1, times do
		local e = effect:new{
			position = based_on.position + {based_on.size * (2 * math.random() - 1),based_on.size * (2 * math.random() - 1)},
			variance = based_on.variance,
			coloreffect = based_on.coloreffect,
			alpha = based_on.alpha,
			alphafollows = based_on.alphafollows
		}

		e.speed:set(e.position):sub(based_on.position):normalize():mult(math.random() * v, math.random() * v)

		e.timetogo = math.random(50,130) / 100
		e:start()
		
		table.insert(effect.bodies, e)
	end
end