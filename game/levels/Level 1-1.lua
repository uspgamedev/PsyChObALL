title = 'I - The Beginning of PsyChO'
chapter = 'Part 1 - The Arrival'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = vector:new{width/2, height/2},
		anglechange = torad(180),
		shootattarget = true
	}
	local f2 = formation {
		type = 'around',
		angle = torad(-45),
		target = vector:new{width/2, height/2},
		anglechange = torad(90),
		shootattarget = true
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

	warnEnemies = true
	warnEnemiesTime = 0.7
	local simple = 'simpleball'
	local divide1 = 'multiball'
	
	doNow( function(timer)
		reloadStory 'Level 3-3'
	end)

	wait(1)
	enemy(simple, 1, { position = vector:new{-20, height/2}, speed = vector:new{v, 0} })
	wait(3)
	enemy(simple, 2, f1)
	wait(2.5)
	enemy(simple, 5, verticalt)
	wait(2.5)
	enemy(simple, 5, verticalb)
	wait(1.5)
	horizontalr.speed = 2*v
	horizontall.speed = 2*v
	enemy(simple, 5, horizontall)
	wait(1.5)
	enemy(simple, 5, horizontalr)
	wait(1)
	f2.speed = 2*v
	enemy(simple, 4, f2)
	wait(2.5)
	enemy(simple, 10, verticalt)
	enemy(simple, 10, verticalb)
	wait(2.0)
	f1.anglechange = torad(360/15)
	f1.adapt = false
	f1.speed = 1.4*v
	f1.radius = 600
	enemy(simple, 15, f1)
	wait(4)
	doNow( function(timer)
		if not gamelost then reloadStory 'Level 1-2' end
	end)
end