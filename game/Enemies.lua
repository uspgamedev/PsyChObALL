module('Enemies', package.seeall)

bodies = {}

function init()

end

function paintOn( self, p )
	for k, v in ipairs(filesystem.enumerate 'enemies') do
		local name = v:sub(0, v:len() - 4)
		require('enemies.' .. name)
		self[name].bodies = rawget(self[name], 'bodies') or Group:new{}
		self[name].bodies.class = self[name]
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