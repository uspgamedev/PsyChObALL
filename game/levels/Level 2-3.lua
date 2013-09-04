title = 'II - There and Back Again'
chapter = 'Part 3 - Big Brother'

function run()
	warnEnemies = true
	warnEnemiesTime = 1.4

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local grey = 'grayball'
	local super = 'superball'

	local f = formation {
		type = 'horizontal',
		from = 'left',
		movetorwards = 'center',
		setspeedto = Vector:new{0, 0},
		distance = 'distribute'
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

	wait(2)
	for i = 1, 8 do
		wait(.8)
		f.from = 'left'
		f.setspeedto.x = 360
		enemy(simple, i, f)
		f.from = 'right'
		f.setspeedto.x = -360
		enemy(divide1, i, f)
	end
	wait(4)
	enemy(super, 1, { position = Vector:new{width/2, -30}, speed = Vector:new{v, v}, life = 120, size = 80}, simple, {width/2, -30}, 8)
	wait(9)
	enemy(super, 1, { position = Vector:new{width/2, -30}, speed = Vector:new{1.2*v, v}, life = 80, size = 50}, simple, {width/2, -30}, 12)
	enemy(super, 1, { position = Vector:new{width/2, height+30}, speed = Vector:new{v, 1.2*v}, life = 60, size = 50}, divide1, {width/2, height+30}, 12)
	wait(11)
	enemy(super, 1, { position = Vector:new{width/2, height+30}, speed = Vector:new{v, v}, life = 120, size = 80}, divide1, {width/2, height+30}, 13)
	wait(3)
	enemy(divide1, 7, horizontalr)
	wait(1)
	enemy(divide1, 7, horizontall)
	wait(7)
	enemy(super, 1, { position = Vector:new{width/2, -30}, speed = Vector:new{0.4*v, 0.4*v}, life = 40, size = 30}, grey, {width/2, -30}, 9)
	enemy(super, 1, { position = Vector:new{width/2, height+30}, speed = Vector:new{0.4*v, 0.4*v}, life = 40, size = 30}, grey, {width/2, height+30}, 9)
	enemy(super, 1, { position = Vector:new{-30, height/2}, speed = Vector:new{0.4*v, 0.4*v}, life = 40, size = 30}, grey, {-30, height/2}, 10)
	enemy(super, 1, { position = Vector:new{width+30, height/2}, speed = Vector:new{0.4*v, 0.4*v}, life = 40, size = 30}, grey, {width+30, height/2}, 10)
	wait(2)
	enemy(grey, 5, horizontalr)
	wait(4)
	enemy({divide1,grey}, 7, horizontall)
	wait(4)
	enemy(grey, 7, horizontalr)
	wait(2)
	enemy(grey, 7, horizontall)
	wait(4)
	doNow( function(timer)
		if not levelselected then
			if not DeathManager.gameLost then reloadStory 'Level 2-4' end
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