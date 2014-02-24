title = 'I - The Fall of PsyChO'
chapter = 'Part 3 - The Big One'

function run()
	doNow (function()
		local img = graphics.newImage 'resources/warn.png'
		local warns = ImageBody.bodies:getObjects(8)
		for i = 1, 8 do
			local t = warns[i]:revive()
			t.coloreffect = ColorManager.sinCityEffect
			t.image = img
			t.scale = .3
			Enemy.randomizePosition(t)
			t:register()
		end

		local texts = Text.bodies:getObjects(6)
		for i = 1, 6 do
			local t = texts[i]:revive()
			t.text = "BOSS"
			t.font = Base.getFont(40)
			Enemy.randomizePosition(t)
			t:register()
		end

		local t = Text.bodies:getFirstDead():revive()
		t.text = "TODO: Make better Boss introduction...."
		t.font = Base.getCoolFont(50)
		t.position:set(-100, -30)
		t.speed:set(v, v)
		t:register()
	end)

	wait(5)
	enemy 'bossOne'

	wait(15)

	registerTimer {
		timeLimit = 1,
		callback = function ( timer )
			if Enemies.bossOne.bodies:countAlive() == 0 then
				local t = Text.bodies:getFirstDead():revive()
				t.text = 'The start of the end\n  TODO: Create EndLevel screen with scores and stuff'
				t.speed:set(v, v)
				t.position:set(0, 0)
				t.font = Base.getCoolFont(40)
				t.kill = function(self)
					Text.kill(self)

					if not Levels.currentLevel.wasSelected then
						psycho:addLife()
						psycho:addLife()
						AdventureState:runLevel('Level 2-1')
					else
						local te = Text.bodies:getFirstDead():revive()
						te.text = "Level 1 boss killed. Press ESC or P and return to the menu."
						te.font = Base.getCoolFont(50)
						te.printFunction = graphics.printf
						te.position:set(width/2 - 400, height/2 + 20)
						te.limit = 800
						te.align = 'center'
						te:register()
					end
				end
				t:register()

				timer:remove()
			end
		end
	}
end

