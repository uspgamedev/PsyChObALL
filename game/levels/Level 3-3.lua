title = 'III - Madness All Around'
chapter = 'Part 3 - Freedom Lost'

function run()
	warnEnemies = true
	warnEnemiesTime = 0.7

	local sin, cos = math.sin, math.cos

	local f1 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		angleDelta = Base.toRadians(90),
		shootAtTarget = true
	}
	
	local vform = formation {
		type = 'V',
		startLocation = Vector:new{width + 23, 20},
		size = height - 10,
		growth = 1010,
		setSpeed = Vector:new{-v, 0},
		vertical = true
	}

	local f = formation {
		type = 'func',
		func = function(x)
			return sin(x * 200) * (height/2 - 50) + height/2
		end,
		side = 'right',
		setSpeed = Vector:new{-1.65 * v, 0},
		distance = 30
	}

	local f2 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		angleDelta = Base.toRadians(180),
		shootAtTarget = true,
		adapt = false
	}

	local f3 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/4},
		angleDelta = Base.toRadians(360 / 20),
		shootAtTarget = true,
		adapt = false,
		distance = 40
	}

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local nic = 'cage'
	local vec = function(data) return Vector:new(data) end

	wait(2)
	enemy(nic, 1, nil, {width/2, height/2},
		{size = 200, wait = 20, sizeGrowth = 300},
		{moveto = {2 * width/3, height/2}, wait = 5}, 
		{moveto = {width/3, height/2}, wait = 5}, 
		{moveto = {210, 210}, wait = 1, speed = v * 0.7}, 
		{moveto = {width - 210, 210}, wait = 3},
		{moveto = {width - 210, height - 210}, wait = 1},
		{moveto = {210, height - 210}, wait = 3},
		{moveto = {width/2, height/2}, wait = 5},
		{size = 150, wait = 9, speed = v/2.5},
		{moveto = {width/2, 160}, wait = 3/2}, 
		{moveto = {width/2, height - 160}, wait = 3},
		{moveto = {width/2, 160}, wait = 3}, 
		{moveto = {width/2, height - 160}, wait = 3/2},
		{moveto = {width/2, height/2}, wait = 4},
		{moveto = {width - 160, height/2}, wait = 6/2, speed = v/2.5}, 
		{moveto = {160, height/2}, wait = 6 * 2/5 + 1, speed = v},
		{moveto = {width - 160, height/2}, wait = 7, speed = v/2.5},
		{moveto = {160, height/2}, wait = 6 * 2/5 + 1, speed = v},
		{moveto = {width - 160, height/2}, wait = 7/2, speed = v/2.5}, 
		{moveto = {width/2, height/2}, wait = 3},
		{destroy = true, sizeGrowth = 460})

	wait(5)
	enemy(simple, 1, { position = Vector:new{width + 20, height/2}, speed = Vector:new{-1.2 * v, 0} })

	wait(5)
	enemy(divide1, 4, f1)
	
	wait(4)
	f1.angleDelta = Base.toRadians(45)
	enemy(divide1, 8, f1)
	
	wait(4)
	enemy(divide1, 20, vform)
	
	wait(4)
	f2.distance = 40
	f2.angle = 180
	f2.angleDelta = -f1.angleDelta
	f2.speed = 1.2 * v
	enemy(simple, 20, f2)
	
	wait(6)
	enemy(range, 1, {timeToShoot = 1.3}, 8, vec{2 * width/5, height/2}, vec{width/2, -30}, {width/3, height + 30}, divide1, {148, 0, 211}, 0, 8)
	enemy(range, 1, {timeToShoot = 1.3}, 8, vec{3 * width/5, height/2}, vec{width/2, height + 30}, {2 * width/3, -30}, divide1, {148, 0, 211}, 0, 8)
	
	wait(9)
	f3.angleDelta = 0
	f3.shootAtTarget = true
	f3.target = Vector:new{width/2, height/2}
	f3.angle = Base.toRadians(0)
	f3.center = Vector:new{width/2, height/2}
	enemy({simple, divide1}, 20, f3)
	
	f3.angle = Base.toRadians(45)
	enemy({simple, divide1}, 20, f3)
	
	f3.angle = Base.toRadians(90)
	enemy({simple, divide1}, 20, f3)
	
	f3.angle = Base.toRadians(135)
	enemy({simple, divide1}, 20, f3)
	
	f3.angle = Base.toRadians(180)
	enemy({simple, divide1}, 20, f3)
	
	f3.angle = Base.toRadians(-45)
	enemy({simple, divide1}, 20, f3)
	
	f3.angle = Base.toRadians(-90)
	enemy({simple, divide1}, 20, f3)
	
	f3.angle = Base.toRadians(-135)
	enemy({simple, divide1}, 20, f3)
	
	wait(9)
	enemy({simple, divide1, simple}, 180, f)
	
	wait(13.5)
	f.setSpeed = Vector:new{-1.1 * v, 0}
	f.func = function(x)
		return sin(x * 200) * (height/2 - 180) + height/2 - 180
	end
	enemy({divide1,simple}, 210, f) -- you shouldn't create them all at the same time, it makes the game slower
	
	f.func = function(x)
		return sin(x * 200) * (height/2 - 180) + height/2 + 180
	end
	enemy({divide1, simple}, 210, f) -- you shouldn't create them all at the same time, it makes the game slower
	
	wait(30)
	changeToLevel('Level 3-4')
end