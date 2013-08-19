title = 'IV - The Only One'
chapter = 'Part 3 - '

function run()
	warnEnemies = true
	warnEnemiesTime = 0.7

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local grey = 'grayball'
	local super = 'superball'

	local f1 = formation {
		type = 'around',
		angle = 0,
		target = vector:new{width/2, height/2},
		anglechange = torad(90),
		shootattarget = true
	}

	local f = formation {
		type = 'func',
		func = function(x)
			return math.sin(x*200)*(height/2-50)+height/2
		end,
		side = 'right',
		setspeedto = vector:new{-1.65*v,0},
		distance = 30
	}

	local verticalt = formation {
		type = 'vertical',
		from = 'top'
	}

	local verticalb = formation {
		type = 'vertical',
		from = 'bottom'
	}

	local horizontall = formation {
		type = 'horizontal',
		from = 'left'
	}

	local horizontalr = formation {
		type = 'horizontal',
		from = 'right'
	}

	local vform = formation {
		type = 'V',
		startpoint = vector:new{width+23, 20},
		size = height-10,
		growth = 1010,
		setspeedto = vector:new{-v, 0},
		vertical = true
	}

	local f2 = formation {
		type = 'around',
		angle = 0,
		target = vector:new{width/2, height/2},
		anglechange = torad(180),
		shootattarget = true,
		adapt = false
	}

	local f3 = formation {
		type = 'around',
		angle = 0,
		target = vector:new{width/2, height/4},
		anglechange = torad(360/20),
		shootattarget = true,
		adapt = false,
		distance = 40
	}
	local simple = 'simpleball'
	local divide1 = 'multiball'
	local range = 'ranged'
	local simple = 'simpleball'
	local grey = 'grayball'
	local snake = 'snake'
	local nic = 'cage'
	local vc = function(data) return vector:new(data) end

	doNow( function(timer)
		if not gamelost then reloadStory 'Level 4-3' end
	end)
end