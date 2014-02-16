title = 'IV - The Only One'
chapter = 'Part 3 - Followers'

function run()
	warnEnemies = true
	warnEnemiesTime = 0.7

	local divide1 = 'multiball'
	local super = 'superball'
	local range = 'ranged'
	local snake = 'snake'
	local nic = 'cage'
	local sek = 'seeker'
	local mono = 'monoguiaball'
	local vec = function(data) return Vector:new(data) end

	wait(3)
	enemy(sek, 1, nil, 5.3, Vector:new{width/2, -30})
	
	wait(5.8)
	enemy(sek, 1, { position = Vector:new{-30, height/2} }, 15, Vector:new{width/2, -30})
	enemy(sek, 1, { position = Vector:new{width+30, height/2} }, 15, Vector:new{width/2, height-30})
	enemy(sek, 1, { position = Vector:new{width/2, height+30} }, 15, Vector:new{width + 30, height/2})
	
	wait(5.5)
	enemy(super, 1, { position = Vector:new{width/2, height+30}, speed = Vector:new{v, v}, life = 120, size = 90}, divide1, {width/2, height+30}, 12)
	
	wait(3)
	local x = width + 30
	local y = 10

	for i = 1, 9 do
		local t = {}
		table.insert(t, {x, y})
		table.insert(t, {width/2 + 40, y})
		table.insert(t, {width/2 + 40, y + 45})
		table.insert(t, {width + 30, y + 45})
		enemy(snake, 2, {size = 19}, 10, 200, 0.3, unpack(t))
		t = {}
		table.insert(t, {width - x, y})
		table.insert(t, {width/2 - 40, y})
		table.insert(t, {width/2 - 40, y + 45})
		table.insert(t, {-30, y + 45})
		enemy(snake, 2, {size = 19}, 10, 200, 0.3, unpack(t))
		y = y + 90
	end

	wait(10)
	enemy(sek, 1, nil, 18, Vector:new{width/2, -30})
	enemy(sek, 1, nil, 20, Vector:new{width/2, height - 30})

	wait(1.5)
	enemy(nic, 1, nil, {width/2, height/2},
		{size = 180, wait = 22, sizeGrowth = 300},
		{size = 300, wait = 15, sizeGrowth = 300},
		{size = 100, wait = 5, sizeGrowth = 32},
		{destroy = true, sizeGrowth = 460})

	wait(5)
	enemy(sek, 1, nil, 15.5, Vector:new{-30, height/2})
	enemy(sek, 1, nil, 15.5, Vector:new{width + 30, height/2})
	
	wait(5)
	enemy(super, 1, { position = Vector:new{width/2, height + 30}, speed = Vector:new{0.4 * v, 0.75 * v}, life = 140, size = 60}, mono, {width/2, height + 30}, 19)
	
	wait(4)
	
	for i = 1, 3 do
		enemy(sek, 1, { speed = Vector:new{(0.8 - 0.1 * i) * v - 30, (0.8 - 0.1 * i) * v}}, 11 - 2 * i, Vector:new{width/2, height - 30})
		wait(2.5)
	end
	
	wait(2.5)
	enemy(sek, 1, { position = Vector:new{-30, 2 * height/5}, speed = Vector:new{0.3 * v, 0.3 * v} }, 13, Vector:new{-30, 2 * height/5})
	enemy(sek, 1, { position = Vector:new{-30, 4 * height/5}, speed = Vector:new{0.3 * v, 0.3 * v} }, 10, Vector:new{-30, 4 * height/5})
	enemy(sek, 1, { position = Vector:new{width + 30, 2 * height/5}, speed = Vector:new{0.3 * v, 0.3 * v} }, 7, Vector:new{width + 30, 2 * height/5})
	enemy(sek, 1, { position = Vector:new{width + 30, 4 * height/5}, speed = Vector:new{0.3 * v, 0.3 * v} }, 7, Vector:new{width + 30, 4 * height/5})

	wait(4)
	enemy(range, 1, nil, 6, vec{width/2, 45}, vec{width/2, -30}, nil, mono, {50, 205, 50}, 0, 15)
	enemy(range, 1, nil, 6, vec{width/2, height - 45}, vec{width/2, height + 30}, nil, mono, {50, 205, 50}, 0, 15)
	enemy(range, 1, nil, 4, vec{45, height/2}, vec{-30, height/2}, nil, mono, {50, 205, 50}, 0, 15)
	enemy(range, 1, nil, 4, vec{width -45, height/2}, vec{width + 30, height/2}, nil, mono, {50, 205, 50}, 0, 15)

	wait(17)
	changeToLevel('Level 4-4')
end