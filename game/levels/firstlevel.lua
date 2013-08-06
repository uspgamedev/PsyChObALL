name = 'Level 1'
fullName = 'I - The Beginning of PsyChO'

function run()
	warnEnemies = true
	warnEnemiesTime = .7

	local sides = {'top', 'bottom', 'left', 'right'}
	wait(3)
	local side = math.random(4)
	enemy('simpleball', 10, {side = sides[side]})
	table.remove(sides, side)
	wait(1)
	side = math.random(3)
	enemy('simpleball', 10, {side = sides[side]})
	table.remove(sides, side)
	wait(1)
	side = math.random(2)
	enemy('simpleball', 10, {side = sides[side]})
	table.remove(sides, side)
	wait(1)
	enemy('simpleball', 10, {side = sides[1]})
	side, sides = nil, nil

	timer:new {
		time = -time,
		timelimit = .5,
		running = true,
		funcToCall = function(timer)
			if not next(enemies.simpleball.bodies) then
				timer:remove()
				reloadStory 'Level 2'
			end
		end
	}
end