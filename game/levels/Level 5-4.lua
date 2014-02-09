title = 'V - Renato please add level'
chapter = 'Part 4 - The boss is here. Just write all of him up until tomorrow. Thanks'

function run()
	enemy 'bossLast'
	wait(10000)


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

	wait(1)
	
	doNow( function(timer)
		local a = VarTimer:new{var = 0}
		a:setAndGo(0, 255, 70)
		Text:new{
			text = "Congratulation, you've reached the end. But not really, more is coming!\nThe next update of PsyChObALL will"
			.. " include two whole new levels, including The End.",
			font = Base.getCoolFont(55),
			printmethod = graphics.printf,
			position = Vector:new{width/2 - 450, height/2 - 200},
			limit = 900,
			alphaFollows = a,
			align = 'center'
		}:register()
	end)
end