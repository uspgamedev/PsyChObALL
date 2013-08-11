title = 'II - There and Back Again'
chapter = 'Part 1 - Eclipse'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = vector:new{width/2, height/4},
		anglechange = torad(360/20),
		shootattarget = true,
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
		startpoint = vector:new{-320, 23},
		size = height,
		growth = -650,
		vertical = true,
		setspeedto = vector:new{1.6*v, 0}
	}

	local line = formation {
	type = 'line',
	startpoint = nil, --vector
	dx = 0, dy = 0,
	distribute = true,
	distribute_between = nil --vector
}
	local simple = 'simpleball'
	local divide1 = 'multiball'
	local range = 'ranged'

	local vc = function(data) return vector:new(data) end
	warnEnemies = true


	warnEnemiesTime = 1.4
	wait(4)
	enemy({simple,divide1}, 16, vform)
	vform.growth = 650
	vform.startpoint = vc{width+320, 23}
	vform.setspeedto = vc{-1.6*v, 0}
	enemy({simple,divide1}, 16, vform)
	wait(4)
	enemy({simple,divide1}, 40, f1)
	f1.angle = 180
	enemy({simple,divide1}, 40, f1)
	warnEnemiesTime = 1
	wait (15)
	enemy(range, 1, nil, 4, vc{width/2, 70}, vc{width/2, -30}, --[[{nil},]] simple, {50,205,50}, 0, 26)
	enemy(range, 1, nil, 4, vc{width/2, height - 70}, vc{width/2, height + 30}, --[[{nil},]] simple, {50,205,50}, 0, 26)
	enemy(range, 1, nil, 4, vc{70, height/2}, vc{-30, height/2}, --[[{nil},]] simple, {50,205,50}, 0, 26)
	enemy(range, 1, nil, 4, vc{width -70, height/2}, vc{width + 30, height/2}, --[[{nil},]] simple, {50,205,50}, 0, 26)
	wait(8)
	enemy(range, 1, nil, 4, vc{70, 70}, vc{-30, -30}, --[[{nil},]] simple, {255,255,0}, torad(45), 18)
	enemy(range, 1, nil, 4, vc{70, height - 70}, vc{-30, height + 30}, --[[{nil},]] simple, {255,255,0}, torad(45), 18)
	enemy(range, 1, nil, 4, vc{width -70, height - 70}, vc{width +30, height + 30}, --[[{nil},]] simple, {255,255,0}, torad(45), 18)
	enemy(range, 1, nil, 4, vc{width -70, 70}, vc{width +30, -30}, --[[{nil},]] simple, {255,255,0}, torad(45), 18)
	wait(10)
	enemy(range, 1, nil, 8, vc{width/2, height/3}, vc{2*width/3, -30}, --[[{width/3, height + 30},]] divide1, {148,0,211}, 0, 8)
	enemy(range, 1, nil, 8, vc{width/2, 2*height/3}, vc{width/3 ,height + 30}, --[[{2*width/3, -30},]] divide1, {148,0,211}, 0, 8)
	wait(10)
	enemy(range, 1, nil, 4, vc{70, 70}, vc{-30, -30}, --[[{nil},]] simple, {50,205,50}, 0, 14)
	enemy(range, 1, nil, 4, vc{70, height - 70}, vc{-30, height + 30}, --[[{nil},]] simple, {50,205,50}, 0, 14)
	enemy(range, 1, nil, 4, vc{width -70, height - 70}, vc{width +30, height + 30}, --[[{nil},]] simple, {50,205,50}, 0, 14)
	enemy(range, 1, nil, 4, vc{width -70, 70}, vc{width +30, -30}, --[[{nil},]] simple, {50,205,50}, 0, 14)
	f1.anglechange = 0
	f1.angle = torad(0)
	f1.center = vector:new{width/2, height/2}
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(45)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(90)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(135)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(180)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-45)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-90)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-135)
	enemy({simple,divide1}, 20, f1)
	wait(5)
	enemy(divide1, 7, horizontall)
	enemy(divide1, 7, horizontalr)
	wait(2)
	enemy(simple, 12, verticalt)
	enemy(simple, 12, verticalb)
	wait(8)
	f1.anglechange = torad(360/20)
	f1.angle = torad(0)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(45)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(90)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(135)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(180)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-45)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-90)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-135)
	enemy({simple,divide1}, 20, f1)
	f1.target = vector:new{width/2, 3*height/4}
	f1.angle = torad(0)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(45)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(90)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(135)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-45)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-90)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-135)
	enemy({simple,divide1}, 20, f1)
	f1.angle = torad(-180)
	enemy({simple,divide1}, 20, f1)
	wait(10)
	doNow( function()
		reloadStory 'Level 2-2'
	end)

end