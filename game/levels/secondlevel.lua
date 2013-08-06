name = 'Level 2'
fullName = 'II - The Betrayal'

function run()
	warnEnemies = true
	warnEnemiesTime = 4
	wait(5)
	enemy('simpleball', 40, formation {shootatplayer = true})
	wait(5)
	timer:new {
		running = true,
		time = -time,
		timelimit = 0,
		onceonly = true,
		funcToCall = function (timer)
			for i = 1, 10 do
				local t = text:new{ text = '!', font = getCoolFont(95), coloreffect = sincityeffect}
				_G.enemy.__init(t)
				t:register()
			end
		end
	}
	
end