local global = _G
module('RecordsManager', package.seeall)
local currentScore, blastScore, lifeScore
local gameTime, multiplier
local resetMultiplierTimer
local beatBestTime, beatBestScore, beatBestMultiplier

function init()
	resetMultiplierTimer = Timer:new {
		timelimit  = 2.2,
		persistent = true,
		works_on_gameLost = false
	}

	function resetMultiplierTimer:funcToCall() -- resets multiplier
		if multiplier >= 10 and ColorManager.currentEffect ~= ColorManager.noLSDEffect then 
			global.timefactor = 1.0
			ColorManager.currentEffect = nil
		end
		multiplier = 1
		self:stop()
	end

	resetMultiplierTimer.handleReset = resetMultiplierTimer.funcToCall
end

function reset()
	currentScore, blastScore, lifeScore = 0, 0, 0
	gameTime = 0
	multiplier = 1
	beatBestTime, beatBestScore, beatBestMultiplier = false, false, false
end

function getScore()
	return currentScore
end

function getMultiplier()
	return multiplier
end

function getGameTime()
	return gameTime
end

function getStoryHighScore()
	return records.story.bestRuns[1] and math.max(records.story.bestRuns[1].score, currentScore) or currentScore
end

function manageHighScore()
	if not onGame() then return end
	if state == survival then
		RecordsManager.update(0)
	elseif psycho.continuesUsed == 0 and Levels.currentLevel.name_ ~= 'Tutorial' and not Levels.currentLevel.wasSelected then
		local br = records.story.bestRuns
		if #br < 5 or br[5].score < currentScore then
			local i = 1
			while i <= #br and br[i].score > currentScore do
				i = i + 1
			end
			beatBestScore = i
			table.insert(br, i, {
				score = currentScore,
				level = Levels.currentLevel.name_
			})
			br[6] = nil -- in case it was already full
		end
	end
end

function addScore( score )
	if global.onGame() and not DeathManager.gameLost then
		score = score * multiplier
		local onStory = state == story
		if onStory and Levels.currentLevel then Levels.currentLevel.score = Levels.currentLevel.score + score end
		currentScore = currentScore + score

		blastScore = blastScore + score
		while blastScore >= (onStory and 4000 or 7000) do
			blastScore = blastScore - (onStory and 2000 or 7000)
			psycho.ultraCounter = psycho.ultraCounter + 1
		end

		if onStory then
			lifeScore = lifeScore + score
			while lifeScore >= 15000 do
				lifeScore = lifeScore - 15000
				psycho:addLife()
			end
		end
	end
end

function addMultiplier( mult )
	multiplier = multiplier + mult
	resetMultiplierTimer:start(0)

	if not DeathManager.gameLost and multiplier >= 10 and (multiplier - mult) < 10 and ColorManager.currentEffect ~= ColorManager.noLSDEffect then
		global.timefactor = 1.1
		ColorManager.currentEffect = ColorManager.invertEffect
	end
end

function update( dt )
	gameTime = gameTime + dt
	if state == survival then
		local s = records.survival
		if gameTime > s.time then s.time = gameTime; beatBestTime = true end
		if currentScore > s.score then s.score = currentScore; beatBestScore = true end
		if multiplier > s.multiplier then s.multiplier = multiplier; beatBestMultiplier = true end
	end
end

function drawRecords()
	if Cheats.usedDevMode then
		graphics.setFont(Base.getCoolFont(20))
		graphics.print("Your scores didn't count, cheater!", 382, 215)
		return
	end
	if state == survival then
		graphics.setFont(Base.getFont(35))
		if beatBestMultiplier then
			graphics.print("You beat the best time!", 260, 100)
		end	
		if beatBestScore then
			graphics.print("You beat the best score!", 290, 140)
		end
		if beatBestMultiplier then
			graphics.print("You beat the best multiplier!", 320, 180)
		end
	else
		if beatBestScore then
			graphics.setFont(Base.getFont(35))
			graphics.print(string.format("You were #%d!", beatBestScore), 260, 100)
		end
	end
end