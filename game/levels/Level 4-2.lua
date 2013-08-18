title = 'IV - The Only One'
chapter = 'Part 2 - There is Stil Others'

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
	local mono = 'monoguiaball'
	local vc = function(data) return vector:new(data) end

	wait(3)
	enemy(mono, 1, { position = vector:new{-20, height/2}, speed = vector:new{v, 0} })
	wait(4)
	enemy(super, 1, { position = vector:new{width/2, -30}, speed = vector:new{0.3*v, 0.3*v}, life = 80, size = 40}, mono, {width/2, -30}, 22)
	enemy(super, 1, { position = vector:new{width/2, height+30}, speed = vector:new{0.3*v, 0.3*v}, life = 80, size = 40}, mono, {width/2, height+30}, 22)
	wait(8)
	enemy(range, 1, {timeToShoot = 2}, 4, vc{width/2, 70}, vc{width/2, -30}, nil, mono, {50,205,50}, 0, 26)
	enemy(range, 1, {timeToShoot = 2}, 4, vc{width/2, height - 70}, vc{width/2, height + 30}, nil, mono, {50,205,50}, 0, 26)
	enemy(range, 1, {timeToShoot = 2}, 4, vc{70, height/2}, vc{-30, height/2}, nil, mono, {50,205,50}, 0, 26)
	enemy(range, 1, {timeToShoot = 2}, 4, vc{width -70, height/2}, vc{width + 30, height/2}, nil, mono, {50,205,50}, 0, 26)
	wait(8)
	for i = 1,40 do
		enemy({simple}, 1, {position = vc{0,0}, positionfollows =
		function(time)
			return time*width/4, (math.cos(time*math.pi*4.5/5)+1)*height/4+height/3
		end
		})
		wait(0.25)
	end
	enemy(range, 1, nil, 8, vc{2*width/6, 85}, vc{2*width/6, -30}, nil, mono, {148,0,211}, 0, 15)
	enemy(range, 1, nil, 8, vc{4*width/6, 85}, vc{4*width/6 ,-30}, nil, mono, {148,0,211}, 0, 15)
	enemy(range, 1, nil, 8, vc{2*width/6, height - 85}, vc{2*width/6,height +30}, nil, mono, {148,0,211}, 0, 15)
	enemy(range, 1, nil, 8, vc{4*width/6, height - 85}, vc{4*width/6 ,height + 30}, nil, mono, {148,0,211}, 0, 15)
	for i = 1,40 do
		enemy({divide1}, 1, {position = vc{0,0}, positionfollows =
		function(time)
			return time*width/4, (math.cos(time*math.pi*4.5/5)+1)*height/4+height/3
		end
		})
		wait(0.25)
	end
	local t = {}
	local x = 30
	local y = height - 10
	for i = 1, 12 do
		table.insert(t, {x, y})
		x = x + 50
		table.insert(t, {x, y})
		y = height - y
		table.insert(t, {x, y})
		x = x + 50
		table.insert(t, {x, y})
		y = height - 10
	end
	enemy(snake, 1, {size = 30}, 20, 400, 0, {30, -30}, unpack(t))
	t = {}
	local x = width -30
	local y = height - 10
	for i = 1, 6 do
		table.insert(t, {x, y})
		x = x - 50
		table.insert(t, {x, y})
		y = height - y
		table.insert(t, {x, y})
		x = x - 50
		table.insert(t, {x, y})
		y = height - 10
	end
	enemy(snake, 1, {size = 30}, 20, 400, 0, {width-30, -30}, unpack(t))
	for i = 1,40 do
		enemy({mono}, 1, {position = vc{0,0}, positionfollows =
		function(time)
			return time*width/4, (math.cos(time*math.pi*4.5/5)+1)*height/4+height/3
		end
		})
		wait(0.25)
	end
	wait(5)
	doNow( function(timer)
		if not gamelost then reloadStory 'Level 4-3' end
	end)
end