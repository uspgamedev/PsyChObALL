module('soundmanager', package.seeall)
require 'lux.functional'

function init()
	menusong = audio.newSource("resources/Flying Carrots 2.mp3")
	limitlesssong = audio.newSource("resources/Limitless.mp3")
	survivalsong = limitlesssong
	currentsong = menusong
	songsetpoints = {}
	songsetpoints[survivalsong] = {0,49,95}
	survivalsong:setLooping(true)
	survivalsong:setVolume(muted and 0 or volume/100)
	limitlesssong:setLooping(true)
	limitlesssong:setVolume(muted and 0 or volume/100)
	songsetpoints[limitlesssong] = {0}
	menusong:setLooping(true)
	menusong:setVolume(muted and 0 or volume/100)
	menusong:play()
	songfadeout = Timer:new{
		timelimit	 = .01,
		running		 = false,
		pausable		 = false,
		timeaffected = false,
		persistent	 = true
	}

	function songfadeout:funcToCall() -- song fades out
		if muted then return end
		if currentsong:getVolume() <= (.02 * volume / 100) then 
			currentsong:setVolume(0) 
			self:stop()
		else currentsong:setVolume(currentsong:getVolume() - .02) end
	end

	songfadein = Timer:new{
		timelimit	 = .03,
		running		 = false,
		pausable		 = false,
		timeaffected = false,
		persistent	 = true
	}

	function songfadein:funcToCall() -- song fades in
		if muted or gamelost then return end
		if currentsong:getVolume() >= (.98 * volume / 100) then 
			currentsong:setVolume(volume / 100)
			self:stop()
		else currentsong:setVolume((currentsong:getVolume() + .02)) end
	end

	--fadein  = lux.functional.bindleft(songfadein.start,  songfadein)
	fadeout  = lux.functional.bindleft(songfadeout.start, songfadeout)

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
	soundquadindex = muted and 7 or math.ceil(volume/20) + 1
end

function changeSong( to )
	currentsong:stop()
	currentsong = to
	to:setVolume(muted and 0 or volume/100)
	to:setPitch(1)
	to:play()
end

function setPitch( p )
	currentsong:setPitch(p)
end

function restart()
	currentsong:seek(songsetpoints[currentsong][math.random(#songsetpoints[currentsong])])
	currentsong:setVolume(0)

	if not muted then songfadein:start() end
end

function reset()
	if muted then
		currentsong:setVolume(0)
	else
		currentsong:setVolume(volume / 100)
	end
	currentsong:setPitch(1.0)
end

function keypressed( key )
	if muted then
		if key == 'm' then
			muted = false
			soundquadindex = math.ceil(volume/20) + 1
			if not gamelost then currentsong:setVolume(volume / 100) end
		end
	else
		if key == '.' and volume < 100 then
			volume = volume + 10
			soundquadindex = math.ceil(volume/20) + 1
			if not gamelost then
				currentsong:setVolume(volume / 100)
			end
		elseif key == ',' and volume > 0 then
			volume = volume - 10
			soundquadindex = math.ceil(volume/20) + 1
			if not gamelost and not songfadein.running then
				currentsong:setVolume(volume / 100)
			end
		elseif key == 'm' then
			muted = true
			soundquadindex = 7
			currentsong:setVolume(0)
		end
	end
end

function drawSoundIcon( x, y )
	graphics.drawq(soundimage, soundquads[soundquadindex], x, y)
end