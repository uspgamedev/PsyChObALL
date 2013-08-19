title = 'I - The Fall of PsyChO'
chapter = 'Part 3 - The Big One'

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
	enemy 'bossOne'
	wait(15)

	registerTimer {
	timelimit = .5,
	funcToCall = function ( timer )
   if not next(enemies.bossOne.bodies) then
   text:new {
   text = 'The start of the end',
   speed = vector:new{v, v},
   size = 40,
   position = vector:new{0,0},
   handleDelete = function ()
   if not levelselected then
   lives = lives + 2 reloadStory 'Level 2-1' 
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

