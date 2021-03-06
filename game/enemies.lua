module('enemies', package.seeall)

bodies = {}

function init()
	--[[superball]]
	superball.addtimer = timer:new {
		timelimit = 30,
		works_on_gamelost = false,
		persistent = true
	}

	local possiblePositions = {vector:new{30, 30}, vector:new{width - 30, 30}, vector:new{width - 30, height - 30}, vector:new{30, height - 30}}
	function superball.addtimer:funcToCall()
		if #bodies.superball > math.floor(gametime/90) then self.timelimit = 2 return end
		superball.list:push(superball:new{ position = possiblePositions[math.random(4)]:clone() })
		self.timelimit = 30
	end

	function superball.addtimer:handlereset()
		self:stop()
	end

	superball.releasetimer = timer:new {
		timelimit = 30,
		works_on_gamelost = false,
		persistent = true
	}

	function superball.releasetimer:funcToCall()
		if #superball.bodies > math.floor(gametime/90) then self.timelimit = 2 return end
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
	for k, v in ipairs(filesystem.getDirectoryItems 'enemies') do
		local name = v:sub(0,v:len() - 4)
		require('enemies.' .. name)
		bodies[name] = {name = name}
		self[name].bodies = bodies[name]
		self[name]:paintOn(p)
		self[name].list = list:new{}
		self['new' .. name] = function ( prototype )
			return self[name]:new(prototype)
		end
	end
end

function clear()
	for k in pairs(bodies) do
		cleartable(bodies[k])
	end
end