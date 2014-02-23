module('SoundManager', package.seeall)
require 'lux.functional'

local setPoints
local fadeOutTimer
local fadeInTimer

function init()
	music = {}

	music['Flying Carrots 2'] = audio.newSource("resources/Flying Carrots 2.mp3")
	music['Limitless'] = audio.newSource("resources/Limitless.mp3")


	setPoints = {}
	setPoints[music['Limitless']] = {0, 49, 95}
	music['Limitless']:setLooping(true)
	music['Limitless']:setVolume(muted and 0 or volume/100)

	music['Flying Carrots 2']:setLooping(true)
	music['Flying Carrots 2']:setVolume(muted and 0 or volume/100)

	currentSong = music['Flying Carrots 2']
	music['Flying Carrots 2']:play()

	fadeOutTimer = Timer:new{
		timeLimit	 = .01,
		running		 = false,
		pausable		 = false,
		timeAffected = false,
		persistent	 = true
	}

	function fadeOutTimer:callback() -- song fades out
		if muted then self:remove() return end
		if currentSong:getVolume() <= (.02 * volume / 100) then 
			currentSong:setVolume(0) 
			self:remove()
		else currentSong:setVolume(currentSong:getVolume() - .02 * volume / 100) end
	end

	function fadeOutTimer:handleReset()
		self:remove()
		currentSong:setVolume(0)
	end

	fadeInTimer = Timer:new{
		timeLimit	 = .03,
		running		 = false,
		pausable		 = false,
		timeAffected = false,
		persistent	 = true
	}

	function fadeInTimer:callback() -- song fades in
		if muted or DeathManager.gameLost then self:remove() return end
		if currentSong:getVolume() >= (.98 * volume / 100) then 
			currentSong:setVolume(volume / 100)
			self:remove()
		else currentSong:setVolume((currentSong:getVolume() + .02 * volume / 100)) end
	end

	function fadeInTimer:handleReset()
		self:remove()
		currentSong:setVolume(muted and 0 or volume / 100)
	end

	soundimage = graphics.newImage("resources/SoundIcons.png")
	soundquads = {
		graphics.newQuad(200, 0, 40, 40, 300, 40),
		graphics.newQuad(160, 0, 40, 40, 300, 40),
		graphics.newQuad(120, 0, 40, 40, 300, 40),
		graphics.newQuad(80,  0, 40, 40, 300, 40),
		graphics.newQuad(40,  0, 40, 40, 300, 40),
		graphics.newQuad(0,   0, 40, 40, 300, 40),
		graphics.newQuad(240, 0, 40, 40, 300, 40)
	}

	iconIndex = muted and 7 or math.ceil(volume/20) + 1
end

function fadeOut()
	fadeOutTimer:register()
	fadeOutTimer:start(0)
end

function changeSong( newSong )
	currentSong:stop()

	currentSong = newSong
	if newSong then
		newSong:setVolume(muted and 0 or volume/100)
		newSong:setPitch(1)
		newSong:play()
	end
end

function setPitch( p )
	currentSong:setPitch(p)
end

function restart()
	currentSong:seek(setPoints[currentSong][math.random(#setPoints[currentSong])])
	currentSong:setVolume(0)

	if not muted then fadeInTimer:register() fadeInTimer:start(0) end
end

function reset()
	if muted then
		currentSong:setVolume(0)
	else
		currentSong:setVolume(volume / 100)
	end

	currentSong:setPitch(1.0)
end

function keypressed( key )
	if muted then
		if key == 'm' then
			muted = false
			if not DeathManager.gameLost then currentSong:setVolume(volume / 100) end
		end
	else
		if key == '.' and volume < 100 then
			volume = volume + 10
			if not DeathManager.gameLost then
				currentSong:setVolume(volume / 100)
			end
		elseif key == ',' and volume > 0 then
			volume = volume - 10
			if not DeathManager.gameLost and not fadeInTimer.running then
				currentSong:setVolume(volume / 100)
			end
		elseif key == 'm' then
			muted = true
			currentSong:setVolume(0)
		end
	end

	iconIndex = muted and 7 or math.ceil(volume/20) + 1
end

function drawSoundIcon( x, y )
	graphics.drawq(soundimage, soundquads[iconIndex], x, y)
end