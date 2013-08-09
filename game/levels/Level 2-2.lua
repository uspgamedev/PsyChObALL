title = 'II - There and Back Again'
chapter = 'Part 2 - Darkness'


function run()
	warnEnemies = true
	warnEnemiesTime = .5
	
	local f1 = formation {
		type = 'horizontal',
		from = 'left',
		movetorwards = 'down',
		distance = 42,
		startsat = 20,
		setspeedto = vector:new{300,0}
	}
	local f2 = formation {
		type = 'vertical',
		from = 'top',
		movetorwards = 'right',
		distance = 42,
		startsat = 20,
		setspeedto = vector:new{0, 300}
	}
	local simple = 'simpleball'
	local divide1 = 'multiball'
	local grey = 'grayball'
	
	wait(3)
	enemy(grey, 1, { position = vector:new{-20, height/2}, speed = vector:new{v, 0} })
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
		setspeedto = vector:new{0, 0},
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
	end
	for i = 5, 1, -1 do
		wait(.8)
		f.from = 'left'
		f.setspeedto.x = 300
		enemy(grey, i, f)
		f.from = 'right'
		f.setspeedto.x = -300
		enemy(grey, i, f)
	end
end