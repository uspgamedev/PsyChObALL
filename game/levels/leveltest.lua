name = "Test Level"
fullName = "0 - The Test"

function run()
	warnEnemies = true
	warnEnemiesTime = 2
	wait(1)
	enemy()
	wait(3)
	enemy('grayball', 2)
	wait(3)
	warnEnemies = false
	enemy('seeker', 3)
end