title = 'III - Madness All Around'
chapter = 'Part 1 - '

function run()
	warnEnemies = true
	warnEnemiesTime = 1.4

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local grey = 'grayball'
	local super = 'superball'

	local f2 = formation {
		type = 'vertical',
		from = 'top',
		movetorwards = 'right',
		distance = 42,
		startsat = 20,
		setspeedto = vector:new{0, 300}
	}

	local f = formation {
		type = 'horizontal',
		from = 'left',
		movetorwards = 'center',
		setspeedto = vector:new{0, 0},
		distance = 'distribute'
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

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local range = 'ranged'
	local simple = 'simpleball'
	local grey = 'grayball'
	local snake = 'snake'

	wait(4)
	enemy(snake, 1, nil, 4, 150, nil, {width/2, height+30}, {width/2, height/2}, {width + 30, height/2})
	wait(7)
	local t = {}
	enemy(snake, 1, {vulnerable=false}, 80, 200, nil, {width/2, height+41}, {width/2, height/2+41}, {width + 41, height/2+41})
	enemy(snake, 1, {vulnerable=false}, 80, 200, nil, {width/2, -41}, {width/2, height/2-41}, {-41, height/2-41})
	enemy(snake, 1, {vulnerable=false}, 80, 200, nil, {width+41, height/2}, {width/2+41, height/2}, {width/2 + 41, -41})
	enemy(snake, 1, {vulnerable=false}, 80, 200, nil, {-41, height/2}, {width/2-41, height/2}, {width/2-41, height+41})
	wait(7)
	f2.movetorwards = 'left'
	f2.startsat = width - 20
	f2.from = 'bottom'
	f2.setspeedto.y = -300
	enemy(simple, 12, f2)
	f2.movetorwards = 'right'
	f2.startsat = 20
	enemy(simple, 12, f2)
	wait(7)
	enemy(simple, 10, horizontall)
	wait(4)
	t = {}
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
<<<<<<< HEAD
=======
		table.insert(t, {x, y})
		enemy(snake, 1, {size = 5}, 40, 600, 0.5, {30, -30}, unpack(t))
>>>>>>> 419a104c51443b9956d697bd4b7873d01f727f60
		y = height - 10
	end
	enemy(snake, 1, {size = 20}, 20, 1200, 0, {30, -30}, unpack(t))
	wait(15)
	t = {}
	local x = width+30
	local y = 10
	for i = 1, 10 do
		table.insert(t, {x, y})
		table.insert(t, {width/2+40, y})
		table.insert(t, {width/2+40, y+30})
		table.insert(t, {-30, y + 30})
		enemy(snake, 2, {size = 20}, 20, 400, 0.5, unpack(t))
		y = y + 90
		t = {}
	end
	
	wait(5)
	t = {}
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
	enemy(snake, 1, {size = 5}, 40, 600, 0.5, {30, -30}, unpack(t))
	wait(40)
	--doNow( function(timer)
		--if not gamelost then reloadStory 'Level 2-4' end
	--end)
end
