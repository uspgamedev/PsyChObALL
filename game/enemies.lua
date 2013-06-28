module('enemies', package.seeall)

require 'enemies.superball'

bodies = {}

function newsuperball( prototype )
	local mb = superball:new(prototype)
	table.insert(bodies, mb)
	return mb
end

function init()
	--[[for k, v in ipairs(filesystem.enumerate 'enemies') do
		local name = v:sub(0,v:len() - 4)
		require('enemies.' .. name)
		bodies[name] = {}
	end]]
	--[[superball]]
	superballtimer = timer:new {
		timelimit = 30,
		works_on_gamelost = false,
		persistent = true
	}

	local possiblePositions = {vector:new{30, 30}, vector:new{width - 30, 30}, vector:new{width - 30, height - 30}, vector:new{30, height - 30}}
	function superballtimer:funcToCall()
		if #bodies > math.floor(totaltime/90) then self.timelimit = 2 return end
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

function iterate()
	local id, current = next(bodies)
	local i, v
	return function ()
		i, v = next(current, i)
		if i == nil then
			id, current = next(bodies, id)
			if id == nil then return end
			i, v = next(current)
		end
		return i, v, current
	end
end