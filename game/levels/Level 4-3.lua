title = 'IV - The Only One'
chapter = 'Part 3 - Followers'

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
		target = Vector:new{width/2, height/2},
		anglechange = Base.toRadians(90),
		shootattarget = true
	}

	local f = formation {
		type = 'func',
		func = function(x)
			return math.sin(x*200)*(height/2-50)+height/2
		end,
		side = 'right',
		setspeedto = Vector:new{-1.65*v,0},
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
		startpoint = Vector:new{width+23, 20},
		size = height-10,
		growth = 1010,
		setspeedto = Vector:new{-v, 0},
		vertical = true
	}

	local f2 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = Base.toRadians(180),
		shootattarget = true,
		adapt = false
	}

	local f3 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/4},
		anglechange = Base.toRadians(360/20),
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
	local sek = 'seeker'
	local mono = 'monoguiaball'
	local vc = function(data) return Vector:new(data) end

	wait(3)
	enemy(sek, 1, nil, 7, Vector:new{width/2, -30})
	wait(8)
	enemy(sek, 1, { position = Vector:new{-30, height/2} }, 15, Vector:new{width/2, -30})
	enemy(sek, 1, { position = Vector:new{width+30, height/2} }, 15, Vector:new{width/2, height-30})
	enemy(sek, 1, { position = Vector:new{width/2, height+30} }, 15, Vector:new{width + 30, height/2})
	wait(5.5)
	enemy(super, 1, { position = Vector:new{width/2, height+30}, speed = Vector:new{v, v}, life = 120, size = 90}, divide1, {width/2, height+30}, 12)
	wait(3)
	local t = {}
	local x = width+30
	local y = 10
	for i = 1, 9 do
		table.insert(t, {x, y})
		table.insert(t, {width/2+40, y})
		table.insert(t, {width/2+40, y+45})
		table.insert(t, {width+30, y + 45})
		enemy(snake, 2, {size = 19}, 10, 200, 0.3, unpack(t))
		t = {}
		table.insert(t, {width-x, y})
		table.insert(t, {width/2-40, y})
		table.insert(t, {width/2-40, y+45})
		table.insert(t, {-30, y + 45})
		enemy(snake, 2, {size = 19}, 10, 200, 0.3, unpack(t))
		y = y + 90
		t = {}
	end
	wait(10)
	enemy(sek, 1, nil, 18, Vector:new{width/2, -30})
	enemy(sek, 1, nil, 20, Vector:new{width/2, height-30})
	wait(3.5)
	enemy(nic, 1, nil, {width/2,height/2},
		{size = 180, wait = 25, sizeGrowth = 300},
		{size = 300, wait = 15, sizeGrowth = 300},
		{size = 100, wait = 5, sizeGrowth = 32},
		{destroy = true, sizeGrowth = 460}
	)
	wait(10)
	enemy(super, 1, { position = Vector:new{width/2, height+30}, speed = Vector:new{0.4*v, 0.75*v}, life = 140, size = 60}, mono, {width/2, height+30}, 19)
	wait(6)
	for i = 1,3 do
		enemy(sek, 1, { speed = Vector:new{(0.8-0.1*i)*v - 30,(0.8-0.1*i)*v}}, 11-2*i, Vector:new{width/2, height-30})
		wait(2.5)
	end
	wait(7)
	enemy(sek, 1, { position = Vector:new{-30, 2*height/5}, speed = Vector:new{0.3*v, 0.3*v} }, 13, Vector:new{-30, 2*height/5})
	enemy(sek, 1, { position = Vector:new{-30, 3*height/5}, speed = Vector:new{0.3*v, 0.3*v} }, 10, Vector:new{-30, 3*height/5})
	enemy(sek, 1, { position = Vector:new{-30, 4*height/5}, speed = Vector:new{0.3*v, 0.3*v} }, 10, Vector:new{-30, 4*height/5})
	enemy(sek, 1, { position = Vector:new{width+30, 2*height/5}, speed = Vector:new{0.3*v, 0.3*v} }, 7, Vector:new{width+30, 2*height/5})
	enemy(sek, 1, { position = Vector:new{width+30, 3*height/5}, speed = Vector:new{0.3*v, 0.3*v} }, 7, Vector:new{width+30, 3*height/5})
	enemy(sek, 1, { position = Vector:new{width+30, 4*height/5}, speed = Vector:new{0.3*v, 0.3*v} }, 7, Vector:new{width+30, 4*height/5})
	wait(19)
	doNow( function(timer)
		if not Levels.currentLevel.wasSelected then
			if not DeathManager.gameLost then reloadStory 'Level 4-4' end
		else
			Text:new{
				text = "Part Completed. Press ESC or P and return to the menu.", --ou algum outro texto
				font = Base.getCoolFont(50),
				printmethod = graphics.printf,
				position = Vector:new{width/2 - 400, height/2 + 20},
				limit = 800,
				align = 'center'
			}:register()
		end
	end)
end