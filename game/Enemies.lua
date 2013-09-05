module('Enemies', package.seeall)

bodies = {}

function init()
	--[[superball]]
	superball.addtimer = Timer:new {
		timelimit = 30,
		works_on_gameLost = false,
		persistent = true
	}

	local possiblePositions = {Vector:new{30, 30}, Vector:new{width - 30, 30}, Vector:new{width - 30, height - 30}, Vector:new{30, height - 30}}
	function superball.addtimer:funcToCall()
		if #superball.bodies > math.floor(gametime/90) then self.timelimit = 2 return end
		superball.list:push(superball:new{ position = possiblePositions[math.random(4)]:clone() })
		self.timelimit = 30
	end

	function superball.addtimer:handlereset()
		self:stop()
	end

	superball.releasetimer = Timer:new {
		timelimit = 30,
		works_on_gameLost = false,
		persistent = true
	}

	function superball.releasetimer:funcToCall()
		if superball.list.first == superball.list.last then self.timelimit = 2 return end
		superball.list:pop():register()
		self.timelimit = 30
	end
	--[[End of superball]]
end

function restartSurvival()
	superball.addtimer:start(5)
	superball.releasetimer:start(0)
end

function restartStory()
	superball.addtimer:stop()
	superball.releasetimer:stop()
end

function paintOn( self, p )
	for k, v in ipairs(filesystem.enumerate 'enemies') do
		local name = v:sub(0,v:len() - 4)
		require('enemies.' .. name)
		self[name].bodies = rawget(self[name], 'bodies') or {}
		bodies[name] = self[name]
		self[name]:paintOn(p)
		self[name].list = List:new{}
		self['new' .. name] = function ( prototype )
			return self[name]:new(prototype)
		end
	end
end

function clear()
	for k, b in pairs(bodies) do
		b:clear()
	end
end