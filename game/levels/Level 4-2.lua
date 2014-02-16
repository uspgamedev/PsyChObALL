title = 'IV - The Only One'
chapter = 'Part 2 - There Are Still Others'

function run()
	warnEnemies = true
	warnEnemiesTime = 0.7

	local sin, cos = math.sin, math.cos

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local super = 'superball'
	local range = 'ranged'
	local snake = 'snake'
	local vec = function(data) return Vector:new(data) end

	wait(3)
	enemy(mono, 1, { position = Vector:new{-20, height/2}, speed = Vector:new{v, 0} })
	
	wait(4)
	enemy(super, 1, { position = Vector:new{width/2, -30}, speed = Vector:new{0.3 * v, 0.3 * v}, life = 90, size = 40}, mono, {width/2, -30}, 22)
	enemy(super, 1, { position = Vector:new{width/2, height + 30}, speed = Vector:new{0.3 * v, 0.3 * v}, life = 90, size = 40}, mono, {width/2, height + 30}, 22)
	
	wait(8)
	enemy(range, 1, {timeToShoot = 2}, 4, vec{width/2, 70}, vec{width/2, -30}, nil, mono, {50, 205, 50}, 0, 26)
	enemy(range, 1, {timeToShoot = 2}, 4, vec{width/2, height - 70}, vec{width/2, height + 30}, nil, mono, {50, 205, 50}, 0, 26)
	enemy(range, 1, {timeToShoot = 2}, 4, vec{70, height/2}, vec{-30, height/2}, nil, mono, {50, 205, 50}, 0, 26)
	enemy(range, 1, {timeToShoot = 2}, 4, vec{width - 70, height/2}, vec{width + 30, height/2}, nil, mono, {50, 205, 50}, 0, 26)
	
	wait(8)

	for i = 1, 40 do
		enemy({simple}, 1, {position = vec{0, 0}, positionfollows = function(time)
			return time * width/4, (cos(time * math.pi * 4.5 / 5) + 1) * height/4 + height/3
		end})

		wait(0.25)
	end

	enemy(range, 1, nil, 8, vec{2 * width/6, 85}, vec{2 * width/6, -30}, nil, mono, {148, 0, 211}, 0, 15)
	enemy(range, 1, nil, 8, vec{4 * width/6, 85}, vec{4 * width/6 ,-30}, nil, mono, {148, 0, 211}, 0, 15)
	enemy(range, 1, nil, 8, vec{2 * width/6, height - 85}, vec{2 * width/6, height + 30}, nil, mono, {148, 0, 211}, 0, 15)
	enemy(range, 1, nil, 8, vec{4 * width/6, height - 85}, vec{4 * width/6, height + 30}, nil, mono, {148, 0, 211}, 0, 15)

	for i = 1,40 do
		enemy({divide1}, 1, {position = vec{0, 0}, positionfollows = function(time)
			return time * width/4, (cos(time * math.pi * 4.5 / 5) + 1) * height/4 + height/3
		end})

		wait(0.25)
	end

	local t = {}
	local x = 30
	local y = height - 10

	for i = 1, 5 do
		table.insert(t, {x, y})
		x = x + 50
		table.insert(t, {x, y})
		y = height - y
		table.insert(t, {x, y})
		x = x + 50
		table.insert(t, {x, y})
		y = height - 10
	end

	enemy(snake, 1, {size = 33}, 20, 400, 1, {30, -30}, unpack(t))

	t = {}
	local x = width -30
	local y = height - 10
	for i = 1, 5 do
		table.insert(t, {x, y})
		x = x - 50
		table.insert(t, {x, y})
		y = height - y
		table.insert(t, {x, y})
		x = x - 50
		table.insert(t, {x, y})	
		y = height - 10
	end

	enemy(snake, 1, {size = 33}, 20, 400, 1, {width - 30, -30}, unpack(t))

	for i = 1, 40 do
		enemy({mono}, 1, {position = vec{0, 0}, positionfollows = function(time)
			return time * width/4, (cos(time * math.pi * 4.5 / 5) + 1) * height/4 + height/3
		end})

		wait(0.25)
	end

	wait(9)
	changeToLevel('Level 4-3')
end