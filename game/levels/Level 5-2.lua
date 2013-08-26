title = 'V - Renato please add level'
chapter = 'Part 2 - Renato please do something'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = base.toRadians(180),
		shootattarget = true
	}
	local f2 = formation {
		type = 'around',
		angle = base.toRadians(-45),
		target = Vector:new{width/2, height/2},
		anglechange = base.toRadians(90),
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
		reloadStory 'Level 5-3'
	end)
end