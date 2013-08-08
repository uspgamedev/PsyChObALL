title = 'I - The Beginning of PsyChO'
chapter = 'Part 2 - The Betrayal'

function run()
	local vform = formation {
		type = 'V',
		startpoint = vector:new{23, -1020},
		size = width,
		growth = 810,
		setspeedto = vector:new{0, v}
	}

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

	local horizontalr = formation {
		type = 'horizontal',
		from = 'right'
	}

	local horizontall = formation {
		type = 'horizontal',
		from = 'left'
	}

	local simple = 'simpleball'
	local divide1 = 'multiball'

	warnEnemies = true
	warnEnemiesTime = 4
	wait(5)
	enemy('simpleball', 20, formation { type = 'around', anglechange = torad(360/20), adapt = false, radius = 600, shootatplayer = true})
	warnEnemiesTime = 0.7

	wait(4)
	horizontalr.speed = v
	enemy(divide1, 2, horizontalr)
	wait(4.0)
	f2.speed = 1.6*v
	enemy(divide1, 4, f2)
	wait(3.0)
	enemy(divide1, 4, f2)
	f2.speed = 1.2*v
	f2.angle = torad (0)
	enemy(divide1, 4, f2)
	f2.angle = torad (45/2)
	enemy(divide1, 4, f2)
	wait(4.0)
	horizontall.speed = 1.5*v
	horizontalr.speed = 1.5*v
	enemy(divide1, 8, horizontall)
	enemy(divide1, 9, horizontalr)
	warnEnemiesTime = 2
	wait(4.0)
	enemy(simple, 21, vform)
	warnEnemiesTime = 0.7
	wait(4.0)
	f1.anglechange = torad(360/15)
	f1.adapt = false
	f1.speed = 1.4*v
	f1.radius = 600
	f1.distance = 40
	f1.angle = 0
	f1.anglechange = f1.anglechange*(math.random() < .5 and -1 or 1)
	enemy(simple, 15, f1)
	wait(4.0)
	f1.distance = 40
	f1.angle = 180
	f1.anglechange = -f1.anglechange
	f1.speed = 1.6*v
	enemy(simple, 20, f1)
	wait(5)
	doNow( function(timer)
		reloadStory 'Level 1-3'
	end)
end