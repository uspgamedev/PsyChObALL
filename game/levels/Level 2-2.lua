title = 'II - There and Back Again'
chapter = 'Part 2 - Darkness'


function run()
	warnEnemies = true
	warnEnemiesTime = .7
	
	local f1 = formation {
		type = 'horizontal',
		from = 'left',
		movetorwards = 'down',
		distance = 42,
		startsat = 20,
		setspeedto = Vector:new{300,0}
	}
	local f2 = formation {
		type = 'vertical',
		from = 'top',
		movetorwards = 'right',
		distance = 42,
		startsat = 20,
		setspeedto = Vector:new{0, 300}
	}
	local f3 = formation {
		type = 'around',
		angle = 50,
		target = Vector:new{30,30},
		anglechange = 0,
		shootattarget = true,
		adapt = true,
		distance = 40
	}

	local vform = formation {
		type = 'V',
		startpoint = Vector:new{23, -1020},
		size = width,
		growth = 1010,
		setspeedto = Vector:new{0, v}
	}

	local f4 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = base.toRadians(180),
		shootattarget = true,
		shootatplayer = false
	}

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local grey = 'grayball'
	

	wait(3)
	enemy(grey, 1, { position = Vector:new{-20, height/2}, speed = Vector:new{v, 0} })
	wait(5)
	enemy(grey, 11, f2)
	f2.movetorwards = 'left'
	f2.startsat = width - 20
	enemy(grey, 11, f2)
	f2.from = 'bottom'
	f2.setspeedto.y = -300
	enemy(grey, 11, f2)
	f2.movetorwards = 'right'
	f2.startsat = 20
	enemy(grey, 11, f2)

	enemy(grey, 7, f1)
	f1.movetorwards = 'up'
	f1.startsat = height - 20
	enemy(grey, 7, f1)
	f1.from = 'right'
	f1.setspeedto.x = -300
	enemy(grey, 7, f1)
	f1.movetorwards = 'down'
	f1.startsat = 20
	enemy(grey, 7, f1)

	local f = formation {
		type = 'horizontal',
		from = 'left',
		movetorwards = 'center',
		setspeedto = Vector:new{0, 0},
		distance = 'distribute'
	}
	
	for i = 1, 5 do
		wait(.8)
		f.from = 'left'
		f.setspeedto.x = 300
		enemy(grey, i, f)
		f.from = 'right'
		f.setspeedto.x = -300
		enemy(grey, i, f)
		f1.startsat = 20
		f1.movetorwards = 'down'
		enemy(grey, 1, f1)		
		f1.startsat = height - 20
		f1.movetorwards = 'up'
		enemy(grey, 1, f1)
	end

	for i = 5, 1, -1 do
		wait(.8)
		f.from = 'left'
		f.setspeedto.x = 300
		enemy(grey, i, f)
		f.from = 'right'
		f.setspeedto.x = -300
		enemy(grey, i, f)
		f1.startsat = 20
		f1.movetorwards = 'down'
		enemy(grey, 1, f1)		
		f1.startsat = height - 20
		f1.movetorwards = 'up'
		enemy(grey, 1, f1)
	end
	wait(3)
	f1.setspeedto.x = 300
	f1.startsat = 20
	f1.from = 'left'
	f1.movetorwards = 'down'
	enemy(grey, 8, f1)
	f1.movetorwards = 'up'
	f1.startsat = height - 20
	f1.from = 'right'
	f1.setspeedto.x = -300
	enemy(grey, 8, f1)
	for i = 1, 200 do
		warnEnemies = false
		f1.setspeedto.x = 300
		f1.startsat = 314
		f1.from = 'left'
		f1.movetorwards = 'down'
		enemy(grey, 1, f1)
		f1.movetorwards = 'up'
		f1.startsat = height - 314
		f1.from = 'right'
		f1.setspeedto.x = -300
		enemy(grey, 1, f1)
		if i <= 175 then wait(0.2)
		else wait (0.3) end
		if i%10 == 0 and i<=175 then
			f1.setspeedto.x = 300
			f1.startsat = 20
			f1.from = 'left'
			f1.movetorwards = 'down'
			enemy(grey, 7, f1)
			f1.movetorwards = 'up'
			f1.startsat = height - 20
			f1.from = 'right'
			f1.setspeedto.x = -300
			enemy(grey, 7, f1)
		end
		warnEnemies = true
		if i == 16 then enemy(grey, 21, vform) end
		if i%5 == 0 and i >= 45 and i <=63 then
			vform.growth = - 600
			vform.setspeedto = Vector:new{0, -2.5*v}
			vform.startpoint = Vector:new{-900 + 10*i, height + 620}
			enemy(grey, 40, vform)
			vform.growth = 600
			vform.startpoint = Vector:new{300 + 10*i, height + 620}
			enemy(grey, 40, vform)
		end
		if i%4 == 0 and i >= 69 and i <=90 then
			vform.growth =  600
			vform.setspeedto = Vector:new{0, -2.7*v}
			vform.startpoint = Vector:new{width -2070 + 20*i, height + 620}
			enemy(grey, 40, vform)
			vform.growth = - 600
			vform.startpoint = Vector:new{width-3270 + 20*i, height + 620}
			enemy(grey, 40, vform)
		end
		if i == 120 then
				warnEnemiesTime = 4
				enemy(simple, 14, formation { type = 'around', anglechange = base.toRadians(360/14), adapt = false, radius = 600, shootatplayer = true, speed = 1.8*v})
				warnEnemiesTime = 1.3
		end
		if i == 140 then
			f4.anglechange = base.toRadians(360/18)
			f4.adapt = false
			f4.speed = 1*v
			f4.radius = 600
			f4.distance = 40
			f4.angle = 0
			f4.anglechange = f4.anglechange*(math.random() < .5 and -1 or 1)
			enemy(simple, 18, f4)
		end
		if i == 143 or i == 163 then
			f2.movetorwards = 'left'
			f2.startsat = width - 20
			f2.from = 'bottom'
			f2.setspeedto.y = -300
			enemy(grey, 11, f2)
			f2.movetorwards = 'right'
			f2.startsat = 20
			enemy(grey, 11, f2)
		end
		if i >= 180 then
			f1.setspeedto.x = 220
			f1.startsat = height/2
			f1.from = 'left'
			f1.movetorwards = 'down'
			enemy(simple, 1, f1)
			f1.movetorwards = 'up'
			f1.startsat = height/2
			f1.from = 'right'
			f1.setspeedto.x = -220
			enemy(simple, 1, f1)
		end
	end
	wait(4)
	doNow( function(timer)
		if not levelselected then
			if not gamelost then reloadStory 'Level 2-3' end
		else
			Text:new{
				text = "Part Completed. Press ESC or P and return to the menu.", --ou algum outro texto
				font = getCoolFont(50),
				printmethod = graphics.printf,
				position = Vector:new{width/2 - 400, height/2 + 20},
				limit = 800,
				align = 'center'
			}:register()
		end
	end)
end