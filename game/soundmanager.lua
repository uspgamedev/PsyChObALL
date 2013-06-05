module('soundmanager', package.seeall)
require 'lux.functional'

function init()
	song = audio.newSource("resources/Phantom - Psychodelic.ogg")
	song:setLooping(true)
	song:play()

	songsetpoints = {20,123,180,308,340}
	songfadeout = timer:new{
		timelimit	 = .01,
		running		 = false,
		pausable		 = false,
		timeaffected = false,
		persistent	 = true
	}

	function songfadeout:funcToCall() -- song fades out
		if muted then return end
		if song:getVolume() <= (.02 * volume / 100) then 
			song:setVolume(0) 
			self:stop()
		else song:setVolume(song:getVolume() - .02) end
	end

	songfadein = timer:new{
		timelimit	 = .03,
		running		 = false,
		pausable		 = false,
		timeaffected = false,
		persistent	 = true
	}

	function songfadein:funcToCall() -- song fades in
		if muted or gamelost then return end
		if song:getVolume() >= (.98 * volume / 100) then 
			song:setVolume(volume / 100)
			self:stop()
		else song:setVolume((song:getVolume() + .02)) end
	end

	--fadein  = lux.functional.bindleft(songfadein.start,  songfadein)
	fadeout  = lux.functional.bindleft(songfadeout.start, songfadeout)
	setPitch = lux.functional.bindleft(song.setPitch, song)

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
	soundquadindex = muted and 7 or volume/20 + 1
end

function restart()
	song:seek(songsetpoints[math.random(#songsetpoints)])
	song:setVolume(0)

	if not muted then songfadein:start() end
end

function reset()
	if muted then
		song:setVolume(0)
	else
		song:setVolume(volume / 100)
	end
	song:setPitch(1.0)
end

function processKey( key )
	if muted then
		if key == 'm' then
			muted = false
			soundquadindex = volume/20 + 1
			if not gamelost then song:setVolume(volume / 100) end
		end
	else
		if key == '.' and volume < 100 then
			volume = volume + 20
			soundquadindex = volume/20 + 1
			if not gamelost then
				song:setVolume(volume / 100)
			end
		elseif key == ',' and volume > 0 then
			volume = volume - 20
			soundquadindex = volume/20 + 1
			if not gamelost and not songfadein.running then
				song:setVolume(volume / 100)
			end
		elseif key == 'm' then
			muted = true
			soundquadindex = 7
			song:setVolume(0)
		end
	end
end

function drawSoundIcon( x, y )
	graphics.drawq(soundimage, soundquads[soundquadindex], x, y)
end