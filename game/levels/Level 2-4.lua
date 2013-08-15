title = 'II - There and Back Again'
chapter = 'Part 4 - Violent Love with Friends'

function run()
	doNow ( function( timer )
		for i = 1, 8 do
			local t = imagebody:new{ coloreffect = sincityeffect, image = graphics.newImage 'resources/warn.png', scale = .3 }
			_G.enemy.__init(t)
			t:register()
		end
		text:new { text = "BOSS INCOMING", font = getFont(40), position = vector:new{ -100, -30 }, speed = vector:new{v,v} }:register()
	end )
	wait(5)
	enemy 'bossTwo'
	wait(15)

	registerTimer {
		timelimit = .5,
		funcToCall = function ( timer )
			if not next(enemies.bossTwo.bodies) then
				text:new {
					text = 'No turning back',
					speed = vector:new{v, v},
					size = 40,
					position = vector:new{0,0},
					handleDelete = function () lives = lives + 1 reloadStory 'Level 3-1' end
				}:register()
				timer:remove()
			end
		end
	}
end