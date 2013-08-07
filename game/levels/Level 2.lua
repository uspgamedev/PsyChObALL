title = 'I - The Beginning of PsyChO'
chapter = 'II - The Betrayal'

function run()
	warnEnemies = true
	warnEnemiesTime = 4
	wait(5)
	enemy('simpleball', 40, formation {shootatplayer = true})
	wait(5)
	doNow ( function( timer )
		for i = 1, 8 do
			local t = imagebody:new{ coloreffect = sincityeffect, image = graphics.newImage 'resources/warn.png', scale = .3 }
			_G.enemy.__init(t)
			t:register()
		end
	end )
	wait(5)
	enemy 'bossOne'
	wait(10)

	registerTimer {
		timelimit = .5,
		funcToCall = function ( timer )
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
	}
	

end