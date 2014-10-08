width, height = 1080, 720
require 'lux.object'
require 'Vector'
require 'List'
require 'Stack'

--mythical stuff
module('Base', package.seeall)

math.atan = error --use math.atan2

--[[
	"Localizes" Love2D tables
]]
local function fixPosIgnoreOne( func )
	return function ( first, x, y, ... )
		func(first, x*ratio, y*ratio, ...)
	end
end
local function fixPosIgnoreNone( func )
	return function ( x, y, ... )
		func(x*ratio, y*ratio, ...)
	end
end

pixel = love.graphics.newImage 'resources/pixel.png'
pixel:setFilter('linear','linear', 0)

turnLightsOffShader = love.graphics.newShader [[
	extern vec2 psychoRelativePos;
	vec4 effect(vec4 color, Image texture, vec2 tc, vec2 ppos) {
		number dist = (tc[0] - psychoRelativePos[0])*(tc[0] - psychoRelativePos[0]) + (tc[1] - psychoRelativePos[1])*(tc[1] - psychoRelativePos[1]);
		if(dist < .07) color[3] = pow(dist/.07, .4);
		return color;
	}
]]

circleShader = love.graphics.newShader [[
	extern number min;
	vec4 effect(vec4 color, Image texture, vec2 tc, vec2 ppos) {
		number dist = (tc[0] - .5)*(tc[0] - .5) + (tc[1] - .5)*(tc[1] - .5);
		if(dist > .25	|| dist < min) color[3] = 0;
		return color;
	}
]]
circleShader:send("min", 0)


local lineWidth = 1
_G.graphics = {
	arc = fixPosIgnoreOne(love.graphics.arc),
	circle = function ( mode, x, y, r )
		local xFixed, yFixed, rFixed = x*ratio, y*ratio, r*ratio
		if Cheats.image.enabled then
			if not Cheats.image.painted then
				local _, __, ___, a = graphics.getColor()
				graphics.setColor(255, 255, 255, a)
			end
			love.graphics.draw(Cheats.image.image, xFixed - rFixed, yFixed - rFixed, 
				0, 2 * rFixed / Cheats.image.image:getWidth(), 2 * rFixed / Cheats.image.image:getHeight())
		else
			-- assumes Base.circleShader is being used
			if mode == 'line' then
				local min = lineWidth*ratio + 1
				min = (((rFixed - min)/(rFixed))*((rFixed - min)/(rFixed)))/4
				if love.graphics.getLineWidth() > 1 then end--print 'asd' end
				circleShader:send('min', min)
				love.graphics.draw(pixel, xFixed - rFixed, yFixed - rFixed, 0, 2*rFixed)
				circleShader:send('min', 0) 
			else
				love.graphics.draw(pixel, xFixed - rFixed, yFixed - rFixed, 0, 2*rFixed)
			end
		end
	end,
	draw = function(d, x, y, r, sx, sy, ...) love.graphics.draw(d, x*ratio, y*ratio, r, (sx or 1)*ratio, (sy or sx or 1)*ratio, ...) end,
	drawq = function(i ,q, x, y, r, sx, sy, ...) love.graphics.draw(i, q, x*ratio, y*ratio, r, (sx or 1)*ratio, (sy or sx or 1)*ratio, ...) end,
	point = fixPosIgnoreNone(love.graphics.point),
	print = fixPosIgnoreOne(love.graphics.print),
	printf = function(t, x, y, limit, a) love.graphics.printf(t, x*ratio, y*ratio, limit*ratio, a) end,
	translate = function(x, y) 
		local tx, ty = sign(x)*math.floor(math.abs(x)*ratio), sign(y)*math.floor(math.abs(y)*ratio)
		love.graphics.translate(tx, ty)
	end,
	rectangle = function (mode, x, y, width, height) love.graphics.rectangle(mode, x*ratio, y*ratio, width*ratio, height*ratio) end,
	line = function(x1,y1,x2,y2) love.graphics.line(x1*ratio, y1*ratio, x2*ratio, y2*ratio) end,
	setLineWidth = function(l) lineWidth = l love.graphics.setLineWidth(l) end
}

_G.mouse = {
	getPosition = function()
		local x, y = love.mouse.getPosition()
		return x/ratio, y/ratio
	end,
	getX = function() return love.mouse.getX()/ratio end,
	getY = function() return love.mouse.getY()/ratio end
}

for k,v in pairs(love) do
	if type(v) == 'table' then
		if _G[k] then
			setmetatable(_G[k], { __index = v})
		else
			_G[k] = v
		end
	end
end

function defaultDraw( obj )
	graphics.setColor(ColorManager.getComposedColor(obj.variance, obj.alphaFollows and obj.alphaFollows.var or obj.alpha, obj.coloreffect))
	graphics.circle(obj.mode, obj.position[1], obj.position[2], obj.size)
end

do
	local fonts = {}
	function getFont(size)
		size = math.floor(size*ratio)
		if fonts[size] then return fonts[size] end
		fonts[size] = graphics.newFont(size)
		return fonts[size]
	end
end

do
	local coolfonts = {}
	function getCoolFont(size)
		size = math.floor(size*ratio)
		if coolfonts[size] then return coolfonts[size] end
		coolfonts[size] = graphics.newFont('resources/Nevis.ttf', size)
		return coolfonts[size]
	end
end

--[[
	Used for modules.
	If you try to access a nil value, it will access the _G one.
	If you try to set a value that already exists on _G, it will be set there,
	otherwise, it will be created on the table
]]
function globalize( t )
	t.global = _G
	t.self = { __index = t, __newindex = function ( nt, k, v )
		rawset(t, k, v)
	end}
	setmetatable(t.self, t.self)
	setmetatable(t, {
		__index = _G,
		__newindex = function ( t, k, v )
			if _G[k] ~= nil then _G[k] = v
			else rawset(t, k, v) end
		end
		})
end

setFunctionEnv = setfenv

local http = require "socket.http"

local response = http.request{ url=URL, create=function()
	local req_sock = require("socket").tcp()
	req_sock:settimeout(3)
	return req_sock
end}

function getLatestVersion()
	local version = http.request("http://uspgamedev.org/downloads/projects/psychoball/latest")
	if version then version = version:sub(1,version:len()-1) end --cutting the '\n' at the end
	return version
end

function restrainInScreen( vec )
	if vec.x > width then vec.x = width 
	elseif vec.x < 0 then vec.x = 0 end
	if vec.y > height then vec.y = height
	elseif vec.y < 0 then vec.y = 0 end
	return vec
end

function clearTable( t )
	for k in pairs(t) do t[k] = nil end
end

function sign(a)
	return a == 0 and 0 or a > 0 and 1 or -1 
end

local constDegreeToRadians = math.pi/180
function toRadians( degree )
	return degree*constDegreeToRadians
end

function doNothing()
	-- nothing, what did you expect?
end

clone = lux.object.clone

function collides( p1, r1, p2, r2 )
	if p2 == nil then
		if not (p1 and r1) then return nil end
		p2, r2 = r1.position, r1.size
		p1, r1 = p1.position, p1.size
	end
	return (r1 + r2)^2 >= (p1[1] - p2[1])^2 + (p1[2] - p2[2])^2
end