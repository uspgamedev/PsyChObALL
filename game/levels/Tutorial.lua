title = 'TUTORIAL'
chapter = 'Learning how to ball'

function run()
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = vector:new{width/2, height/2},
		anglechange = torad(180),
		shootattarget = true
	}

	warnEnemies = true
	warnEnemiesTime = 0.7
	local simple = 'simpleball'

	wait(3)
	--"Welcome to PsyChObALL"
	wait(6)
	--"Use WASD or the directional keys to move"
	wait(6)
	--"Hold shift to move slowly"
	wait(4)
	--"Use your mouse to aim and left click to shoot"
	wait(4)
	--"Hit enemies to increase your score\n if you get hit you will die"
	wait(6)
	-- ^ texto acima nao da fade
	enemy(simple, 1, { position = vector:new{-20, height/2}, speed = vector:new{v, 0} })
	wait(3)
	--texto da fade
	wait(3)
	--Hold space to charge ultrablast,\n and release to use it
	wait(3)
	--^texto acima nao da fade
	f1.anglechange = torad(360/15)
	f1.adapt = false
	f1.speed = 1.4*v
	f1.radius = 600
	enemy(simple, 15, f1)
	wait(6)
	--texto da fade
	--"Remember, we all have psycho within ourselves"
	wait(4)
	doNow( function(timer)
		if not levelselected then
			if not gamelost then reloadStory 'Level 1-1' end
		else
			text:new{
				text = "Tutorial Completed. Press ESC or P and return to the menu.",
				font = getCoolFont(50),
				printmethod = graphics.printf,
				position = vector:new{width/2 - 400, height/2 + 20},
				limit = 800,
				align = 'center'
			}:register()
		end
	end)
end