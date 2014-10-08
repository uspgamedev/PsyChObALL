require 'GameState'

AdventureState = GameState:new {
	currentLevel = nil
}

function AdventureState:runLevel( levelName, reloadEverything, levelWasSelected )
	if levelName and levelName ~= 'Tutorial' and levelName > RecordsManager.records.story.lastLevel then RecordsManager.records.story.lastLevel = levelName end
	if Game.state ~= self or reloadEverything then
		self.levelWasSelected = levelWasSelected
		self.levelName = levelName
		Game.switchState(self)
	else
		Effect:clear()
		Timer.closeOldTimers()

		Levels.runLevel(levelName)
		if levelWasSelected then
			Levels.currentLevel.wasSelected = true
		end
	end
end

function AdventureState:create()
	GameState.create(self)

	state = story
	psycho:revive()

	SoundManager.changeSong(SoundManager.music['Limitless'])
	resetVars()

	SoundManager.restart()

	for _, enemy in pairs(Enemies.bodies) do
		self:add(enemy.bodies)
	end

	for _, added in ipairs {CircleEffect, Effect, Shot, ImageBody, Text, Warning, DeathManager.DeathEffect} do
		self:add(added.bodies)
	end

	table.sort(self, function(a, b) return (a.ord or a.class.ord) < (b.ord or b.class.ord) end) --sort by painting order

	mouse.setGrabbed(true)

	Effect:clear()
	Timer.closeOldTimers()

	Levels.runLevel(self.levelName)
	if self.levelWasSelected then
		Levels.currentLevel.wasSelected = true
	end
end