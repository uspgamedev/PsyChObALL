title = 'IV - The Only One'
chapter = 'Part 4 - Cloud of Despair'

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

		local t = Text.bodies:getFirstAvailable():revive()
		t.text = "TODO: Make better Boss introduction...."
		t.font = Base.getCoolFont(50)
		t.position:set(-100, -30)
		t.speed:set(v, v)
		t:register()
	end)

	wait(5)
	enemy 'bossFour'

	wait(15)

	registerTimer {
		timeLimit = 1,
		callback = function ( timer )
			if Enemies.bossFour.bodies:countAlive() == 0 then
				local t = Text.bodies:getFirstAvailable():revive()
				t.text = 'The Journey won\'t last forever\n  TODO: Create EndLevel screen with scores and stuff'
				t.speed:set(v, v)
				t.position:set(0, 0)
				t.font = Base.getCoolFont(40)
				t.kill = function(self)
					Text.kill(self)

					if not Levels.currentLevel.wasSelected then
						psycho:addLife()
						psycho:addLife()
						AdventureState:runLevel('Level 5-1')
					else
						local te = Text.bodies:getFirstAvailable():revive()
						te.text = "Level 4 boss killed. Press ESC or P and return to the menu."
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