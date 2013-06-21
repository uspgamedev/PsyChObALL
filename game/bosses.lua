module('bosses', package.seeall)

require 'bosses.superball'

bodies = {}

function newsuperball( prototype )
	local mb = superball:new(prototype)
	table.insert(bodies, mb)
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