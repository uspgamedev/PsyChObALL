title = 'II - There and Back Again'
chapter = 'Part 4 - Violent Love with Friends'

function run()
	doNow ( function( timer )
		for i = 1, 8 do
			local t = imagebody:new{ coloreffect = ColorManager.sinCityEffect, image = graphics.newImage 'resources/warn.png', scale = .3 }
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
					handleDelete = function ()
						if not levelselected then
							lives = lives + 2
							reloadStory 'Level 3-1' 
						else
							text:new{
								text = "Part Completed. Press ESC or P and return to the menu.", --ou algum outro texto
								font = getCoolFont(50),
								printmethod = graphics.printf,
								position = vector:new{width/2 - 400, height/2 - 50},
								limit = 800,
								align = 'center'
							}:register()
						end
					end
				}:register()
				timer:remove()
			end
		end
	}
end