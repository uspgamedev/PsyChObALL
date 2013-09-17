-- dependencies
local Timer = Timer
local type, min, max = type, math.min, math.max
local ColorManager = {}
setfenv(1, ColorManager)

colorCycleTime = 10
currentEffect = nil
local maincolor = {0,0,0,0}

function init()
	timer = Timer:new{
		timelimit  = 300,
		pausable   = false,
		persistent = true,
		running = true
	}
end

function getComposedColor( x, alpha, effect )
	return applyEffect(effect, getRawColor(x, alpha))
end

local xt = colorCycleTime
function getRawColor(x, alpha)
	x = ((x or 0) + timer.time) % colorCycleTime
	local r, g, b
	if x <= xt / 3 then
		r = 100					  -- 100%
		g = 100 * x / (xt / 3) -- 0->100%
		b = 0						  -- 0%
	elseif x <= xt / 2 then
		r = 100 * (1 - ((x - xt / 3) / (xt / 2 - xt / 3)))	-- 100->0%
		g = 100 - 20 * ((x - xt / 3) / (xt / 2 - xt / 3))	-- 100->80%
		b = 05															-- 0%
	elseif x <= 7 * xt / 12 then
		r = 05																-- 0%
		g = 80 - 20 * ((x - xt / 2) / (7 * xt / 12 - xt / 2))	-- 80->60%
		b = 60 * ((x - xt / 2) / (7 * xt / 12 - xt / 2))		-- 0->60%
	elseif x <= 255 * xt / 360 then
		r = 11 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12))		 -- 0->11%
		g = 60 - 49 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12)) -- 60->11%
		b = 60 + 10 * ((x - 7 * xt / 12) / (255 * xt / 360 - 7 * xt / 12)) -- 60->70%
	elseif x <= 318 * xt / 360 then
		r = 11 + 59 * ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))  -- 11->70%
		g = 11 * (1 - ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))) -- 11->0%
		b = 70 - 10 * ((x - 255 * xt / 360) / (318 * xt / 360 - 255 * xt / 360))  -- 70->60%
	else
		r = 70 + 30 * ((x - 318 * xt / 360) / (xt - 318 * xt / 360))  -- 70->100%
		g = 0 																		  -- 0%
		b = 60 * (1 - ((x - 318 * xt / 360) / (xt - 318 * xt / 360))) -- 60->0%
	end
	maincolor[1], maincolor[2], maincolor[3], maincolor[4] = r * 2.55, g * 2.55, b * 2.55, alpha or 255
	return maincolor
end

function applyEffect( effect, color )
	return (effect or currentEffect) and (effect or currentEffect)(color) or color
end

--[[ Effects Applied to Colors ]]
function invertEffect( color )
	color[1], color[2], color[3] =
		255 - color[1], 255 - color[2], 255 - color[3]
	return color
end

function noLSDEffect( color )
	local gray = (color[1] + color[2] + color[3]) / 3
	color[1], color[2], color[3] = 
		color[1] + (gray - color[1])/1.1,
		color[2] + (gray - color[2])/1.1,
		color[3] + (gray - color[3])/1.1
	return color
end

function sinCityEffect( color )
	local gray = (color[1] + color[2] + color[3]) / 3
	color[1], color[2], color[3] =  gray + (255 - gray)/5, 0, 0
	return color
end

-- create your own colorEffect
function getColorEffect( r, g, b, change )
	change = change or 60
	if type(r) == 'table' then --consider all VarTimers
		if type(change) ~= 'table' then change = {var = change} end
		return function ( color )
			color[1], color[2], color[3] = 
					color[1]*change.var/255 + min(max(r.var - change.var/2, 0), 255 - change.var),
					color[2]*change.var/255 + min(max(g.var - change.var/2, 0), 255 - change.var),
					color[3]*change.var/255 + min(max(b.var - change.var/2, 0), 255 - change.var)
			return color
		end
	else --conside all numbers
		local consteffect = change/255
		r = min(max(r - change/2, 0), 255 - change)
		g = min(max(g - change/2, 0), 255 - change)
		b = min(max(b - change/2, 0), 255 - change)
		return function ( color )
			color[1], color[2], color[3] = 
					color[1]*consteffect + r,
					color[2]*consteffect + g,
					color[3]*consteffect + b
			return color
		end
	end
end

return ColorManager