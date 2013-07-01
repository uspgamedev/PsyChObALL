module('enemies', package.seeall)

bodies = {}

function newsuperball( prototype )
	local mb = superball:new(prototype)
	table.insert(bodies.superball, mb)
	return mb
end

function init()
	--[[superball]]
	superballtimer = timer:new {
		timelimit = 30,
		works_on_gamelost = false,
		persistent = true
	}

	local possiblePositions = {vector:new{30, 30}, vector:new{width - 30, 30}, vector:new{width - 30, height - 30}, vector:new{30, height - 30}}
	function superballtimer:funcToCall()
		if #bodies.superball > math.floor(totaltime/90) then self.timelimit = 2 return end
		newsuperball{ position = possiblePositions[math.random(4)]:clone() }
		self.timelimit = 30
	end

	function superballtimer:handlereset()
		self:stop()
	end
	--[[End of superball]]
end

function restart()
	superballtimer:start(0)
end

function paintOn( self, p )
	for k, v in ipairs(filesystem.enumerate 'enemies') do
		local name = v:sub(0,v:len() - 4)
		require('enemies.' .. name)
		bodies[name] = {}
		p[name] = bodies[name]
	end
end

function clear()
	for k in pairs(bodies) do
		cleartable(bodies[k])
	end
end