title = 'III - Madness All Around'
chapter = 'Part 3 - Freedom Lost'

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
		setspeedto = vector:new{-2.4*v,0},
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
	local simple = 'simpleball'
	local divide1 = 'multiball'
	local range = 'ranged'
	local simple = 'simpleball'
	local grey = 'grayball'
	local snake = 'snake'
	local nic = 'cage'
	local vc = function(data) return vector:new(data) end

	wait(3)
	enemy(nic, 1, nil, {width/2,height/2},
		{size = 200, wait = 20, sizeGrowth = 150},
		{moveto = {2*width/3,height/2}, wait = 5}, 
		{moveto = {width/3,height/2}, wait = 5}, 
		{moveto = {210,210}, wait = 2}, 
		{moveto = {width -210,210}, wait = 5},
		{moveto = {width -210, height -210}, wait = 2},
		{moveto = {210, height -210}, wait = 5},
		{moveto = {width/2, height/2}, wait = 2},
		{size = 150, wait = 9},
		{moveto = {width/2,160}, wait = 3}, 
		{moveto = {width/2,height - 160}, wait = 3},
		{moveto = {width/2,160}, wait = 3}, 
		{moveto = {width/2,height - 160}, wait = 3},
		{moveto = {width/2,160}, wait = 3}, 
		{moveto = {width/2,height - 160}, wait = 3}
	)
	wait(3)
	enemy(simple, 1, { position = vector:new{width+20, height/2}, speed = vector:new{-1.2*v, 0} })
	wait(5)
	enemy(divide1, 4, f1)
	wait(4)
	f1.anglechange = torad(45)
	enemy(divide1, 8, f1)
	wait(4)
	enemy(divide1, 20, vform)
	wait(4)
	f2.distance = 40
	f2.angle = 180
	f2.anglechange = -f1.anglechange
	f2.speed = 1.2*v
	enemy(simple, 20, f2)
	wait(6)
	enemy(range, 1, nil, 8, vc{2*width/5, height/2}, vc{width/2, -30}, {width/3, height + 30}, divide1, {148,0,211}, 0, 13)
	enemy(range, 1, nil, 8, vc{3*width/5, height/2}, vc{width/2 ,height + 30}, {2*width/3, -30}, divide1, {148,0,211}, 0, 13)
	wait(18)
	enemy({simple,divide1}, 60, f)
	wait(200)
	doNow( function()
		if not gamelost then reloadStory 'Level 3-4' end
	end)
end