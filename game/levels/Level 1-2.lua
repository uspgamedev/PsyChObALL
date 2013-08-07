title = 'I - The Beginning of PsyChO'
chapter = 'Part 2 - The Betrayal'

function run()
	--[[local vform = formation {
		type = 'V',
		startpoint = vector:new{60, -420},
		size = width - 60,
		growth = 400,
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
	warnEnemiesTime = 4
	wait(5)
	enemy('simpleball', 20, formation { type = 'around', anglechange = torad(360/20), adapt = false, radius = 600, shootatplayer = true})
	warnEnemiesTime = 0.7
	wait(5)

	wait(4)
	horizontalr.speed = v
	enemy(divide1, 2, horizontalr)
	wait(3.0)
	enemy(simple, 2, f2)
	f2.angle = torad (135)
	enemy(divide1, 2, f2)
	wait(2.0)
	enemy(divide1, 2, f2)
	f2.angle = torad (-45)
	enemy(simple, 2, f2)
	wait(2.0)
	enemy(divide1, 4, f2)
	warnEnemiesTime = 2
	wait(3.0)
	enemy(simple, 21, vform)
	warnEnemiesTime = 0.7
	wait(4.0)
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


	doNow ( function( timer )
		for i = 1, 8 do
			local t = imagebody:new{ coloreffect = sincityeffect, image = graphics.newImage 'resources/warn.png', scale = .3 }
			_G.enemy.__init(t)
			t:register()
		end
		text:new { text = "BOSS INCOMING", font = getFont(40), position = vector:new{ -100, -30 }, speed = vector:new{v,v} }:register()
	end )
	wait(5)]]
	enemy 'bossOne'
	wait(10)

	registerTimer {
		timelimit = .5,
		funcToCall = function ( timer )
			if not next(enemies.bossOne.bodies) then
				text:new {
					text = 'The end of the beginning',
					speed = vector:new{v, v},
					size = 40,
					position = vector:new{0,0},
					handleDelete = function () reloadStory 'Test Level' end
				}:register()
				timer:remove()
			end
		end
	}
	

end