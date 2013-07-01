name = "Test Level"
fullName = "0 - The Test"

function run()
	warnEnemies = true
	warnEnemiesTime = 2
	wait(1)
	enemy()
	wait(3)
	enemy(2)
	wait(3)
	warnEnemies = false
	enemy(10)
end