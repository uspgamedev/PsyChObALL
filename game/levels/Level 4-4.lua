title = 'IV - The Only One'
chapter = 'Part 4 - '

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
	enemy 'bossFour'
	wait(15)

	registerTimer {
		timelimit = .5,
		funcToCall = function ( timer )
			if not next(enemies.bossfour.bodies) then
				text:new {
					text = 'There can be only one',
					speed = vector:new{v, v},
					size = 40,
					position = vector:new{0,0},
					handleDelete = function () lives = lives + 2 reloadStory 'Level 5-1' end
				}:register()
				timer:remove()
			end
		end
	}
end