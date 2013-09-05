title = 'TUTORIAL'
chapter = 'Learning how to ball'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = Base.toRadians(180),
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
		alphaFollows = VarTimer:new{var = 1},
		align = 'center'
	}

	local wasd = Text:new{
		text = "Use WASD or the directional keys to move\nHold shift to move slowly",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphaFollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local aim = Text:new{
		text = "Use your mouse to aim and left click to shoot",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphaFollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local hit = Text:new{
		text = "Hit enemies to increase your score\n If you get hit you will die",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphaFollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local space = Text:new{
		text = "Hold space to charge ultrablast, and release to use it\nHold it longer for more balls",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphaFollows = VarTimer:new{var = 0},
		align = 'center'
	}
	local pause = Text:new{
		text = "Press P or ESC to pause the game",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphaFollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local music = Text:new{
		text = "Press '<' or '>' to change the volume\n and press M to mute",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphaFollows = VarTimer:new{var = 1},
		align = 'center'
	}
	local remember = Text:new{
		text = "Remember, we all have psycho within ourselves\n Also you can replay this tutorial on the practice screen",
		font = getCoolFont(50),
		printmethod = graphics.printf,
		position = Vector:new{width/2 - 400, height/2 - 20},
		limit = 800,
		alphaFollows = VarTimer:new{var = 1},
		align = 'center'
	}

	doNow(function()
		welcome:register()
		welcome.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 1.5,
		funcToCall = function()
			welcome.alphaFollows:setAndGo(254, 1, 100)
			welcome.alphaFollows.alsoCall = function() welcome.delete = true end
		end
	}
	wait(3)
	doNow(function()
		wasd:register()
		wasd.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.5,
		funcToCall = function()
			wasd.alphaFollows:setAndGo(254, 1, 100)
			wasd.alphaFollows.alsoCall = function() wasd.delete = true end
		end
	}
	wait(0.5)
	enemy(simple, 1, { position = Vector:new{width+20, height/2}, speed = Vector:new{-1.65*v, 0} })
	wait(4)
	doNow(function()
		aim:register()
		aim.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.0,
		funcToCall = function()
			aim.alphaFollows:setAndGo(254, 1, 100)
			aim.alphaFollows.alsoCall = function() aim.delete = true end
		end
	}
	wait(0.5)
	enemy(simple, 1, { position = Vector:new{width+20, height/2}, speed = Vector:new{-1.65*v, 0} })
	enemy(simple, 1, { position = Vector:new{-20, height/2}, speed = Vector:new{1.65*v, 0} })
	wait(3.5)
	doNow(function()
		hit:register()
		hit.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.0,
		funcToCall = function()
			hit.alphaFollows:setAndGo(254, 1, 100)
			hit.alphaFollows.alsoCall = function() hit.delete = true end
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
		space.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 4,
		funcToCall = function()
			space.alphaFollows:setAndGo(254, 1, 100)
			space.alphaFollows.alsoCall = function() space.delete = true end
		end
	}
	wait(3.5)
	f1.anglechange = Base.toRadians(360/15)
	f1.adapt = false
	f1.speed = 1.4*v
	f1.radius = 600
	enemy(simple, 15, f1)
	wait(2.2)
	doNow(function()
		pause:register()
		pause.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 2.5,
		funcToCall = function()
			pause.alphaFollows:setAndGo(254, 1, 100)
			pause.alphaFollows.alsoCall = function() pause.delete = true end
		end
	}
	wait(3)
	doNow(function()
		music:register()
		music.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 3.5,
		funcToCall = function()
			music.alphaFollows:setAndGo(254, 1, 100)
			music.alphaFollows.alsoCall = function() music.delete = true end
		end
	}
	wait(3)
	doNow(function()
		remember:register()
		remember.alphaFollows:setAndGo(1, 254, 100)
	end)
	registerTimer {
		timelimit = 4.5,
		funcToCall = function()
			remember.alphaFollows:setAndGo(254, 1, 100)
			remember.alphaFollows.alsoCall = function() remember.delete = true end
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