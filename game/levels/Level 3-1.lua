title = 'III - Madness All Around'
chapter = 'Part 1 - They Arrived and then Left...'

function run()
	warnEnemies = true
	warnEnemiesTime = 1.4

	local f2 = formation {
		type = 'vertical',
		from = 'top',
		movetorwards = 'right',
		distance = 42,
		startsat = 20,
		setSpeed = Vector:new{0, 300}
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
	local super = 'superball'
	local snake = 'snake'

	wait(4)
	enemy(snake, 1, nil, 4, 150, nil, {width/2, height + 30}, {width/2, height/2}, {width + 30, height/2})
	
	wait(7)
	enemy(snake, 1, {vulnerable = false}, 80, 200, nil, {width/2, height + 41}, {width/2, height/2 + 41}, {width + 41, height/2 + 41})
	enemy(snake, 1, {vulnerable = false}, 80, 200, nil, {width/2, -41}, {width/2, height/2 - 41}, {-41, height/2 - 41})
	enemy(snake, 1, {vulnerable = false}, 80, 200, nil, {width + 41, height/2}, {width/2 + 41, height/2}, {width/2 + 41, -41})
	enemy(snake, 1, {vulnerable = false}, 80, 200, nil, {-41, height/2}, {width/2 - 41, height/2}, {width/2 - 41, height + 41})
	
	wait(7)
	f2.movetorwards = 'left'
	f2.startsat = width - 20
	f2.from = 'bottom'
	f2.setSpeed.y = -300
	enemy(simple, 12, f2)

	f2.movetorwards = 'right'
	f2.startsat = 20
	enemy(simple, 12, f2)

	f2.movetorwards = 'left'
	f2.startsat = width - 20
	f2.from = 'top'
	f2.setSpeed.y = 300
	enemy(simple, 12, f2)

	f2.movetorwards = 'right'
	f2.startsat = 20
	enemy(simple, 12, f2)
	
	wait(7)
	enemy(divide1, 10, horizontall)
	enemy(divide1, 10, horizontalr)

	wait(4)
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

	enemy(super, 1, { position = Vector:new{width + 30, -30}, speed = Vector:new{0.25 * v, 0.25 * v}, life = 120, size = 60}, simple, {width/2, height + 30}, 13)
	enemy(super, 1, { position = Vector:new{width + 30, height + 30}, speed = Vector:new{0.25 * v, 0.25 * v}, life = 60, size = 50}, divide1, {width/2, height + 30}, 13)
	enemy(snake, 1, {size = 20}, 20, 1200, 0, {30, -30}, unpack(t))

	wait(17)
	t = {}
	local x = width + 30
	local y = 10

	for i = 1, 9 do
		table.insert(t, {x, y})
		table.insert(t, {width/2 + 40, y})
		table.insert(t, {width/2 + 40, y + 30})
		table.insert(t, {-30, y + 30})
		enemy(snake, 1, {size = 20}, 20, 400, 0.5, unpack(t))
		y = y + 90
		t = {}
	end
	
	wait(5)
	t = {}
	local x = 30
	local y = height - 10

	for i = 1, 20 do
		table.insert(t, {x, y})
		x = x + 50
		table.insert(t, {x, y})
		y = height - y
		table.insert(t, {x, y})
		x = x + 50
		table.insert(t, {x, y})
		y = height - 10
	end
	
	enemy(super, 1, { position = Vector:new{width/2, height + 30}, speed = Vector:new{0.2 * v, 0.25 * v}, life = 150, size = 90}, divide1, {width/2, height + 30}, 18)
	enemy(super, 1, { position = Vector:new{width/2, -30}, speed = Vector:new{0.2 * v, 0.25 * v}, life = 150, size = 90}, divide1, {width/2, height + 30}, 18)
	enemy(snake, 1, {size = 5}, 200, 600, 0.5, {30, -30}, unpack(t))
	
	wait(30)
	changeToLevel('Level 3-2')
end
