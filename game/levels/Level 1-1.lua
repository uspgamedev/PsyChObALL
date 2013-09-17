title = 'I - The Fall of PsyChO'
chapter = 'Part 1 - The Arrival'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = Base.toRadians(180),
		shootattarget = true
	}
	local f2 = formation {
		type = 'around',
		angle = Base.toRadians(-45),
		target = Vector:new{width/2, height/2},
		anglechange = Base.toRadians(90),
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

--	doNow( function(timer)
--		if not DeathManager.gameLost then reloadStory 'Tutorial' end
--	end)

	wait(1)
	enemy(simple, 1, { position = Vector:new{-20, height/2}, speed = Vector:new{v, 0} })
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
	f1.anglechange = Base.toRadians(360/15)
	f1.adapt = false
	f1.speed = 1.4*v
	f1.radius = 600
	enemy(simple, 15, f1)
	wait(4)
	doNow( function(timer)
		if not Levels.currentLevel.wasSelected then
			if not DeathManager.gameLost then reloadStory 'Level 1-2' end
		else
			Text:new{
				text = "Part Completed. Press ESC or P and return to the menu.", --ou algum outro texto
				font = Base.getCoolFont(50),
				printmethod = graphics.printf,
				position = Vector:new{width/2 - 400, height/2 + 20},
				limit = 800,
				align = 'center'
			}:register()
		end
	end)
end