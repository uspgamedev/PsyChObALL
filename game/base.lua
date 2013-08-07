width, height = 1080, 720

--mythical stuff
base = {}

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

love.graphics.getHeight = nil
love.graphics.getWidth  = nil

graphics = {
	arc = fixPosIgnoreOne(love.graphics.arc),
	circle = function ( mode, x, y, r ) love.graphics.circle(mode, x*ratio, y*ratio, r*ratio)	end,
	draw = function(d, x, y, r, sx, sy, ...) love.graphics.draw(d, x*ratio, y*ratio, r, (sx or 1)*ratio, (sy or 1)*ratio, ...) end,
	drawq = function(i ,q, x, y, r, sx, sy, ...) love.graphics.drawq(i, q, x*ratio, y*ratio, r, (sx or 1)*ratio, (sy or 1)*ratio, ...) end,
	point = fixPosIgnoreNone(love.graphics.point),
	print = fixPosIgnoreOne(love.graphics.print),
	printf = function(t, x, y, limit, a) love.graphics.printf(t, x*ratio, y*ratio, limit*ratio, a) end,
	translate = fixPosIgnoreNone(love.graphics.translate),
	rectangle = function (mode, x, y, width, height) love.graphics.rectangle(mode, x*ratio, y*ratio, width*ratio, height*ratio) end,
	line = function(x1,y1,x2,y2) love.graphics.line(x1*ratio, y1*ratio, x2*ratio, y2*ratio) end
}
mouse = {
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

--[[
	Used for modules.
	If you try to access a nil value, it will access the _G one.
	If you try to set a value that already exists on _G, it will be set there,
	otherwise, it will be created on the table
]]
function base.globalize( t )
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

local http = require "socket.http"

response = http.request{ url=URL, create=function()
	local req_sock = require("socket").tcp()
	req_sock:settimeout(3)
	return req_sock
end}

function base.getLatestVersion()
	local version = http.request("http://uspgamedev.org/downloads/projects/psychoball/latest")
	version = version:sub(1,version:len()-1) --cutting the '\n' at the end
	return version
end

function restrainInScreen( vec )
	if vec.x > width then vec.x = width 
	elseif vec.x < 0 then vec.x = 0 end
	if vec.y > height then vec.y = height
	elseif vec.y < 0 then vec.y = 0 end
	return vec
end

function cleartable( t )
	for k in pairs(t) do t[k] = nil end
end

local constrad = math.pi/180
function torad( degree )
	return degree*constrad
end

function donothing()
	-- nothing
end