module('Enemies', package.seeall)

bodies = {}

function init()
	for k, v in ipairs(filesystem.getDirectoryItems 'enemies') do
		local name = v:sub(0, v:len() - 4)
		require('enemies.' .. name)
		Enemies[name].bodies = rawget(Enemies[name], 'bodies') or Group:new{}
		Body.makeClass(Enemies[name])
		Enemies[name].bodies.class = Enemies[name]
		bodies[name] = Enemies[name]
	end
end

function clear()
	for k, b in pairs(bodies) do
		b:clear()
	end
end