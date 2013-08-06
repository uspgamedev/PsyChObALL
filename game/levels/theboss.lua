name = 'theboss'
fullName = "BossOne"

function run()
	wait(1)
	warnEnemies = true
	warnEnemiesTime = 1
	enemy 'bossOne'

	function ending( timer )
		if not next(enemies.bossOne.bodies) then
			text:new {
				text = 'The end of the beginning',
				speed = vector:new{v, v},
				size = 40,
				position = vector:new{0,0},
				handleDelete = function () reloadStory 'Test Level' end
			}:register()
			timer:remove()
		end
	end

	timer:new{
		timelimit = .5,
		funcToCall = ending,
		running = true,
		time = -time - 1
	}
end