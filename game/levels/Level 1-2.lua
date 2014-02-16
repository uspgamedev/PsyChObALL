title = 'I - The Fall of PsyChO'
chapter = 'Part 2 - The Betrayal'

function run()
	local vform = formation {
		type = 'V',
		startLocation = Vector:new{23, -1020},
		size = width,
		growth = 810,
		setSpeed = Vector:new{0, 2 * v}
	}

	local f1 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		angleDelta = Base.toRadians(180),
		shootAtTarget = true
	}

	local f2 = formation {
		type = 'around',
		angle = Base.toRadians(-45),
		target = Vector:new{width/2, height/2},
		angleDelta = Base.toRadians(90),
		shootAtTarget = true
	}

	local horizontalr = formation {
		type = 'horizontal',
		from = 'right'
	}

	local horizontall = formation {
		type = 'horizontal',
		from = 'left'
	}

	local verticalt = formation {
		type = 'vertical',
		from = 'top'
	}

	local verticalb = formation {
		type = 'vertical',
		from = 'bottom'
	}

	local simple = 'simpleball'
	local divide1 = 'multiball'

	warnEnemies = true
	warnEnemiesTime = 4

	wait(5)
	enemy(simple, 20, formation { type = 'around', angleDelta = Base.toRadians(360 / 20), adapt = false, radius = 600, shootAtPlayer = true})

	warnEnemiesTime = 0.7

	wait(4)
	horizontalr.speed = v
	enemy(divide1, 2, horizontalr)

	wait(4.0)
	f2.speed = 1.6 * v
	enemy(divide1, 4, f2)

	wait(3.0)
	enemy(divide1, 4, f2)
	f2.speed = 1.2 * v
	f2.angle = Base.toRadians (0)
	enemy(divide1, 4, f2)
	f2.angle = Base.toRadians (135 / 2)
	enemy(divide1, 4, f2)

	wait(.5)
	f2.angle = Base.toRadians (360 / 12)
	f2.angleDelta = Base.toRadians (360 / 12)
	enemy(divide1, 12, f2)
	enemy(divide1, 8, verticalt)
	enemy(divide1, 8, verticalb)

	wait(4.0)
	horizontall.speed = 1.5 * v
	horizontalr.speed = 1.5 * v
	enemy(divide1, 8, horizontall)
	enemy(divide1, 9, horizontalr)

	warnEnemiesTime = 1.2

	wait(4.0)
	enemy(simple, 21, vform)

	warnEnemiesTime = 0.7

	wait(4)
	enemy({simple, divide1}, 20, formation { type = 'around', angleDelta = Base.toRadians(360/20), adapt = false, radius = 600, shootAtPlayer = true})

	wait(4.0)
	f1.angleDelta = Base.toRadians(360 / 15)
	f1.adapt = false
	f1.speed = 1.4 * v
	f1.radius = 600
	f1.distance = 40
	f1.angle = 0
	f1.angleDelta = f1.angleDelta * (math.random() < .5 and -1 or 1)
	enemy(simple, 15, f1)

	wait(4.0)
	f1.distance = 40
	f1.angle = 180
	f1.angleDelta = -f1.angleDelta
	f1.speed = 1.6 * v
	enemy(simple, 20, f1)

	wait(5)
	changeToLevel('Level 1-3')
end