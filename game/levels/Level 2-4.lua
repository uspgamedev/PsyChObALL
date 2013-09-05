title = 'II - There and Back Again'
chapter = 'Part 4 - Violent Love with Friends'

function run()
	doNow ( function(timer )
		for i = 1, 8 do
			local t = ImageBody:new{ coloreffect = ColorManager.sinCityEffect, image = graphics.newImage 'resources/warn.png', scale = .3 }
			Enemy.__init(t)
			t:register()
		end
		Text:new { text = "BOSS INCOMING", font = getFont(40), position = Vector:new{ -100, -30 }, speed = Vector:new{v,v} }:register()
	end )
	wait(5)
	enemy 'bossTwo'
	wait(15)

	registerTimer {
		timelimit = .5,
		funcToCall = function ( timer )
			if not next(Enemies.bossTwo.bodies) then
				Text:new {
					text = 'No turning back',
					speed = Vector:new{v, v},
					size = 40,
					position = Vector:new{0,0},
					handleDelete = function ()
						if not Levels.currentLevel.wasSelected then
							psycho:addLife()
							psycho:addLife()
							reloadStory 'Level 3-1' 
						else
							Text:new{
								text = "Part Completed. Press ESC or P and return to the menu.", --ou algum outro texto
								font = getCoolFont(50),
								printmethod = graphics.printf,
								position = Vector:new{width/2 - 400, height/2 + 20},
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