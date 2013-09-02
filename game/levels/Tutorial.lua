title = 'TUTORIAL'
chapter = 'Learning how to ball'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = base.toRadians(180),
		shootattarget = true
	}

	warnEnemies = true
	warnEnemiesTime = 0.7
	local simple = 'simpleball'
	local welcome = Text:new{
		text = "Welcome to PsyChObALL",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 1},
		align = 'center'
	}

	local wasd = Text:new{
		text = "Use WASD or the directional keys to move\nHold shift to move slowly",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local aim = Text:new{
		text = "Use your mouse to aim and left click to shoot",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local hit = Text:new{
		text = "Hit enemies to increase your score\n If you get hit you will die",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local space = Text:new{
		text = "Hold space to charge ultrablast, and release to use it\nHold it longer for more balls",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 0},
		align = 'center'
	}
	local pause = Text:new{
		text = "Press P or ESC to pause the game",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local music = Text:new{
		text = "Press '<' or '>' to change the volume\n and press M to mute",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local remember = Text:new{
		text = "Remember, we all have psycho within ourselves\n Also you can replay this tutorial on the practice screen",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphafollows = VarTimer:new{var = 1},
		align = 'center'
	}

	doNow(function()
		welcome:register()
		welcome.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 1.5,
		funcToCall = function()
			welcome.alphafollows:setAndGo(254, 1, 100)
			welcome.alphafollows.alsoCall = function() welcome.delete = true end
		end
	}
	wait(3)
	doNow(function()
		wasd:register()
		wasd.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.5,
		funcToCall = function()
			wasd.alphafollows:setAndGo(254, 1, 100)
			wasd.alphafollows.alsoCall = function() wasd.delete = true end
		end
	}
	wait(0.5)
	enemy(simple, 1, { position = Vector:new{width+20, height/2}, speed = Vector:new{-1.65*v, 0} })
	wait(4)
	doNow(function()
		aim:register()
		aim.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.0,
		funcToCall = function()
			aim.alphafollows:setAndGo(254, 1, 100)
			aim.alphafollows.alsoCall = function() aim.delete = true end
		end
	}
	wait(0.5)
	enemy(simple, 1, { position = Vector:new{width+20, height/2}, speed = Vector:new{-1.65*v, 0} })
	enemy(simple, 1, { position = Vector:new{-20, height/2}, speed = Vector:new{1.65*v, 0} })
	wait(3.5)
	doNow(function()
		hit:register()
		hit.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.0,
		funcToCall = function()
			hit.alphafollows:setAndGo(254, 1, 100)
			hit.alphafollows.alsoCall = function() hit.delete = true end
		end
	}

	wait(1.5)
	enemy(simple, 1, { position = Vector:new{-20, height/2}, speed = Vector:new{1.65*v, 0} })
	enemy(simple, 1, { position = Vector:new{width+20, height/2}, speed = Vector:new{-1.65*v, 0} })
	enemy(simple, 1, { position = Vector:new{width/2, -20}, speed = Vector:new{0, 1.65*v} })
	enemy(simple, 1, { position = Vector:new{width/2, height+20}, speed = Vector:new{0, -1.65*v} })
	wait(1.5)

	doNow(function()
		space:register()
		space.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 4,
		funcToCall = function()
			space.alphafollows:setAndGo(254, 1, 100)
			space.alphafollows.alsoCall = function() space.delete = true end
		end
	}
	wait(3.5)
	f1.anglechange = base.toRadians(360/15)
	f1.adapt = false
	f1.speed = 1.4*v
	f1.radius = 600
	enemy(simple, 15, f1)
	wait(2.2)
	doNow(function()
		pause:register()
		pause.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 2.5,
		funcToCall = function()
			pause.alphafollows:setAndGo(254, 1, 100)
			pause.alphafollows.alsoCall = function() pause.delete = true end
		end
	}
	wait(3)
	doNow(function()
		music:register()
		music.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.5,
		funcToCall = function()
			music.alphafollows:setAndGo(254, 1, 100)
			music.alphafollows.alsoCall = function() music.delete = true end
		end
	}
	wait(3)
	doNow(function()
		remember:register()
		remember.alphafollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 4.5,
		funcToCall = function()
			remember.alphafollows:setAndGo(254, 1, 100)
			remember.alphafollows.alsoCall = function() remember.delete = true end
		end
	}
	wait(5.5)
	doNow( function(timer)
			Text:new{
				text = "Tutorial Completed. Press ESC or P and return to the menu.",
				font = getCoolFont(50),
				printmethod = graphics.printf,
				position = Vector:new{width/2 - 400, height/2 + 20},
				limit = 800,
				align = 'center'
			}:register()
	end)
end