title = 'III - Madness All Around'
chapter = 'Part 2 - ...Like Waves in the Ocean'

function run()
	warnEnemies = true
	warnEnemiesTime = 0.7

	local sin, cos = math.sin, math.cos

	local f = formation {
		type = 'func',
		func = function(x)
			return sin(x * 200) * (height/2 - 50) + height/2
		end,
		side = 'right',
		setSpeed = Vector:new{-2.4 * v, 0},
		distance = 30
	}

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local super = 'superball'

	wait(3)
	enemy(simple, 60, f)

	wait(2.5)
	f.setSpeed = Vector:new{-1.6 * v, 0}
	f.func = function(x)
		return sin(x * 200) * (height/2 - 180) + height/2 - 180
	end
	enemy(divide1, 80, f)

	f.func = function(x)
		return sin(x * 200) * (height/2 - 180) + height/2 + 180
	end
	enemy(divide1, 80, f)
	
	wait(8)
	f.func = function(x)
		return cos(x * 200) * (height/2 - 50) + height/2 + 50
	end
	f.distance = 60
	enemy({simple, divide1}, 100, f)

	f.func = function(x)
		return cos(x * 200) * (height/2 - 50) + height/2 - 50
	end
	f.side = 'left'
	f.setSpeed = Vector:new{1.6 * v,0}
	enemy({simple,divide1}, 100, f)
	
	wait(19)
	f.distance = 30
	f.side = 'bottom'
	f.setSpeed = Vector:new{0, -0.7 * v}
	f.func = function(x)
		return -sin(x * 200) * (width/2 - 30) + width/2
	end
	enemy(simple, 100, f)

	f.setSpeed = Vector:new{0, 0.7 * v}
	f.side = 'top'
	f.func = function(x)
		return sin(x * 200) * (width/2 - 30) + width/2
	end
	enemy(simple, 100, f)

	wait(6)
	enemy(super, 1, { position = Vector:new{width/2, height + 30}, speed = Vector:new{0.6 * v, v}, life = 180, size = 40}, divide1, {width/2, height + 30}, 16)
	
	wait(18)
	f.distance = 60
	f.side = 'bottom'
	f.setSpeed = Vector:new{0, -0.7 * v}
	f.func = function(x)
		return cos(x * 200) * (width/2 - 30) + width/2
	end
	enemy({simple, divide1}, 100, f)
	
	f.setSpeed = Vector:new{0, 0.7 * v}
	f.side = 'top'
	f.func = function(x)
		return cos(x * 200) * (width/2 - 30) + width/2
	end
	enemy({simple, divide1}, 100, f)

	f.func = function(x)
		return cos(x * 200) * (height/2 - 50) + height/2 + 50
	end
	f.side = 'right'
	f.setSpeed = Vector:new{-0.7 * v, 0}
	enemy({simple, divide1}, 100, f)
	
	f.func = function(x)
		return cos(x * 200) * (height/2 - 50) + height/2 - 50
	end
	f.side = 'left'
	f.setSpeed = Vector:new{0.7 * v, 0}
	enemy({simple,divide1}, 100, f)
	enemy(simple, 100, f)
	
	wait(40)
	changeToLevel('Level 3-3')
end