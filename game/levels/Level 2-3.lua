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
		setspeedto = vector:new{0, 0},
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
	enemy(super, 1, { position = vector:new{width/2, -30}, speed = vector:new{v, v}, life = 120, size = 80}, simple, {width/2, -30}, 8)
	wait(9)
	enemy(super, 1, { position = vector:new{width/2, -30}, speed = vector:new{v, v}, life = 60, size = 50}, simple, {width/2, -30}, 12)
	enemy(super, 1, { position = vector:new{width/2, height+30}, speed = vector:new{v, v}, life = 60, size = 50}, simple, {width/2, height+30}, 12)
	wait(13)
	enemy(super, 1, { position = vector:new{width/2, height+30}, speed = vector:new{v, v}, life = 120, size = 80}, divide1, {width/2, height+30}, 13)
	wait(3)
	enemy(simple, 7, horizontalr)
	wait(3)
	enemy(simple, 7, horizontall)
	wait(7)
	enemy(super, 1, { position = vector:new{width/2, -30}, speed = vector:new{0.5*v, 0.5*v}, life = 20, size = 40}, grey, {width/2, -30}, 9)
	enemy(super, 1, { position = vector:new{width/2, height+30}, speed = vector:new{0.5*v, 0.5*v}, life = 20, size = 40}, grey, {width/2, height+30}, 9)
	enemy(super, 1, { position = vector:new{-30, height/2}, speed = vector:new{0.5*v, 0.5*v}, life = 20, size = 40}, grey, {-30, height/2}, 10)
	enemy(super, 1, { position = vector:new{width+30, height/2}, speed = vector:new{0.5*v, 0.5*v}, life = 20, size = 40}, grey, {width+30, height/2}, 10)
	wait(12)
	doNow( function(timer)
		if not levelselected then
			if not gamelost then reloadStory 'Level 2-4' end
		else
			text:new{
				text = "Part Completed. Press ESC or P and return to the menu.", --ou algum outro texto
				font = getCoolFont(50),
				printmethod = graphics.printf,
				position = vector:new{width/2 - 400, height/2 - 50},
				limit = 800,
				align = 'center'
			}:register()
		end
	end)
end