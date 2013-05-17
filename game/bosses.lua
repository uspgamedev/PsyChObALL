module('bosses', package.seeall)

require 'bosses.superball'

function newsuperball( prototype )
	local mb = superball:new(prototype)
	table.insert(bodies, mb)
	return mb
end