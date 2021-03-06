title = 'V - Renato please add level'
chapter = 'Part 4 - The boss is here. Just write all of him up until tomorrow. Thanks'

function run()
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
	warnEnemiesTime = 0.7
	local simple = 'simpleball'
	local divide1 = 'multiball'

	wait(1)
	
	doNow( function(timer)
		local a = vartimer:new{var = 0}
		a:setAndGo(0, 255, 70)
		text:new{
			text = "Congratulation, you've reached the end. But not really, more is coming!\nThe next update of PsyChObALL will"
			.. " include two whole new levels, including The End.",
			font = getCoolFont(55),
			printmethod = graphics.printf,
			position = vector:new{width/2 - 450, height/2 - 200},
			limit = 900,
			alphafollows = a,
			align = 'center'
		}:register()
	end)
end