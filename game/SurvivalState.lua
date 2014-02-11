require 'GameState'

SurvivalState = GameState:new {}

function SurvivalState:create()
	GameState.create(self)

	SoundManager.changeSong(SoundManager.survivalsong)
	ColorManager.currentEffect = nil
	state = survival
	Enemy.addtimer:funcToCall()
	resetVars()
	Timer.closeOldTimers()

	SoundManager.restart()
	Enemies.restartSurvival()
	Enemy.addtimer:start(1.5)
	Enemy.releasetimer:start(.7)

	mouse.setGrab(true)
end