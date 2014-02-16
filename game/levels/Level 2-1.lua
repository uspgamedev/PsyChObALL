title = 'II - There and Back Again'
chapter = 'Part 1 - Eclipse'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/4},
		angleDelta = Base.toRadians(360/20),
		shootAtTarget = true,
		adapt = false,
		distance = 40
	}

	local verticalt = formation {
		type = 'vertical',
		from = 'top',
		speed = 1.5*v
	}

	local verticalb = formation {
		type = 'vertical',
		from = 'bottom',
		speed = 1.5*v
	}

	local horizontall = formation {
		type = 'horizontal',
		from = 'left',
		speed = 1.5*v
	}

	local horizontalr = formation {
		type = 'horizontal',
		from = 'right',
		speed = 1.5*v
	}

	local vform = formation {
		type = 'V',
		startLocation = Vector:new{-320, 23},
		size = height,
		growth = -650,
		vertical = true,
		setSpeed = Vector:new{1.6*v, 0}
	}

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local range = 'ranged'

	local vec = function(data) return Vector:new(data) end
	
	warnEnemies = true
	warnEnemiesTime = 1.4

	wait(4)
	enemy({simple,divide1}, 16, vform)

	vform.growth = 650
	vform.startLocation = vec {width + 320, 23}
	vform.setSpeed = vec {-1.6 * v, 0}
	enemy({simple,divide1}, 16, vform)
	
	wait(4)
	enemy({simple,divide1}, 40, f1)

	f1.angle = 180
	enemy({simple,divide1}, 40, f1)
	
	warnEnemiesTime = 1
	
	wait(15)
	enemy(range, 1, nil, 4, vec {width/2, 70}, vec {width/2, -30}, nil, simple, {50, 205, 50}, 0, 26)
	enemy(range, 1, nil, 4, vec {width/2, height - 70}, vec {width/2, height + 30}, nil, simple, {50, 205, 50}, 0, 26)
	enemy(range, 1, nil, 4, vec {70, height/2}, vec {-30, height/2}, nil, simple, {50, 205, 50}, 0, 26)
	enemy(range, 1, nil, 4, vec {width - 70, height/2}, vec {width + 30, height/2}, nil, simple, {50, 205, 50}, 0, 26)
	
	wait(8)
	enemy(range, 1, nil, 4, vec {70, 70}, vec {-30, -30}, nil, simple, {255, 255, 0}, Base.toRadians(45), 18)
	enemy(range, 1, nil, 4, vec {70, height - 70}, vec {-30, height + 30}, nil, simple, {255, 255, 0}, Base.toRadians(45), 18)
	enemy(range, 1, nil, 4, vec {width - 70, height - 70}, vec {width + 30, height + 30}, nil, simple, {255, 255, 0}, Base.toRadians(45), 18)
	enemy(range, 1, nil, 4, vec {width - 70, 70}, vec {width + 30, -30}, nil, simple, {255, 255, 0}, Base.toRadians(45), 18)
	
	wait(10)
	enemy(range, 1, nil, 8, vec {width/2, height/3}, vec {2*width/3, -30}, {width/3, height + 30}, divide1, {148, 0, 211}, 0, 8)
	enemy(range, 1, nil, 8, vec {width/2, 2*height/3}, vec {width/3 ,height + 30}, {2*width/3, -30}, divide1, {148, 0, 211}, 0, 8)
	
	wait(10)
	enemy(range, 1, nil, 4, vec {70, 70}, vec {-30, -30}, nil, simple, {50, 205, 50}, 0, 12)
	enemy(range, 1, nil, 4, vec {70, height - 70}, vec {-30, height + 30}, nil, simple, {50, 205, 50}, 0, 12)
	enemy(range, 1, nil, 4, vec {width - 70, height - 70}, vec {width + 30, height + 30}, nil, simple, {50, 205, 50}, 0, 12)
	enemy(range, 1, nil, 4, vec {width - 70, 70}, vec {width + 30, -30}, nil, simple, {50, 205, 50}, 0, 12)
	
	f1.angleDelta = 0
	f1.shootAtTarget = true
	f1.target = Vector:new{width/2, height/2}
	f1.angle = Base.toRadians(0)
	f1.center = Vector:new{width/2, height/2}
	enemy({simple,divide1}, 20, f1)

	f1.angle = Base.toRadians(45)
	enemy({simple,divide1}, 20, f1)

	f1.angle = Base.toRadians(90)
	enemy({simple,divide1}, 20, f1)

	f1.angle = Base.toRadians(135)
	enemy({simple,divide1}, 20, f1)

	f1.angle = Base.toRadians(180)
	enemy({simple,divide1}, 20, f1)

	f1.angle = Base.toRadians(-45)
	enemy({simple,divide1}, 20, f1)

	f1.angle = Base.toRadians(-90)
	enemy({simple,divide1}, 20, f1)

	f1.angle = Base.toRadians(-135)
	enemy({simple,divide1}, 20, f1)

	wait(5)
	enemy(simple, 7, horizontall)
	enemy(simple, 7, horizontalr)

	wait(2)
	enemy(simple, 12, verticalt)
	enemy(simple, 12, verticalb)

	wait(8)
	f1.angleDelta = Base.toRadians(360 / 20)
	f1.angle = Base.toRadians(0)
	enemy({simple,divide1}, 16, f1)

	f1.angle = Base.toRadians(45)
	enemy({simple,divide1}, 16, f1)

	f1.angle = Base.toRadians(90)
	enemy({simple,divide1}, 16, f1)

	f1.angle = Base.toRadians(135)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(180)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(-45)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(-90)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(-135)
	enemy({simple,divide1}, 16, f1)
	
	f1.target = Vector:new{width/2, height/2}
	f1.angle = Base.toRadians(0)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(45)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(90)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(135)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(-45)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(-90)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(-135)
	enemy({simple,divide1}, 16, f1)
	
	f1.angle = Base.toRadians(-180)
	enemy({simple,divide1}, 16, f1)

	wait(10)
	changeToLevel('Level 2-2')
end