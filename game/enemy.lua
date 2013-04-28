module ("enemy",package.seeall)

require "effect"
require "circleEffect"
require "shot"

local Enemy = {}
Enemy.__index = Enemy
local global = _G

function Enemy:handleDelete()
	if self.diereason=="shot" then
		global.score = global.score + (self.size/3)*global.multiplier
		effect.new(self.x,self.y,10)
		global.multiplier = global.multiplier + (self.size/30)
		if not global.multtimer.running then global.multtimer:start()
		else global.multtimer.time = 0 end
		if global.multiplier>=10 and not (global.currentPE == global.noLSD_PE) then
			song:setPitch(1.05)
			global.timefactor= 1.1

			global.currentPE = global.invertPE
			global.currentPET = global.invertPET
			if not global.inverttimer.running then global.inverttimer:start()
			else global.inverttimer.time = 0 end
		end
		if self.size>=15 then circleEffect.new(self,10,100,600,global.width) end
	elseif self.size>=15 then global.score = global.score - 3*global.multiplier end
	if self.size>=10 then 
		for i=1,3 do
			local e = new(self.size-5)
			e.x = self.x
			e.y = self.y
			e.Vx = math.random(v)-v/2 + 1.3*self.Vx
			e.Vy = math.random(v)-v/2 + 1.3*self.Vy
			if e.Vy+e.Vx<10 then e.Vy = signum(self.Vy)*math.random(3*v/4,v) end
			e.variance = self.variance
			table.insert(bodies,e)
		end
	end
	effect.new(self.x,self.y,4)
end


function Enemy:draw()
	self.color = color(global.colortimer.time+self.variance)
	love.graphics.setColor(self.color)
	love.graphics.circle("fill",self.x,self.y,self.size)
end

function Enemy:update(dt)
	for i,v in pairs(shot.bodies) do
		if (v.size+self.size)*(v.size+self.size)>=(v.x-self.x)*(v.x-self.x)+(v.y-self.y)*(v.y-self.y) then
			self.collides = true
			v.collides = true
			self.diereason = "shot"
			break
		end
	end
	self.x = self.x + self.Vx*dt
	self.y = self.y + self.Vy*dt
	return not(self.collides or self.x<-self.size or self.y<-self.size or self.x-self.size>global.width or self.y-self.size> global.height)
end

function new(s)
	s = s or 15
	local enemy = {}
	setmetatable(enemy,Enemy)
	local side = math.random(4)
	if		side==1 then --top
		enemy.x = math.random(15,love.graphics.getWidth()-s-1)
		enemy.y = 1
		enemy.Vy = math.random(v,v+50)
		local n = -1
		if enemy.x<love.graphics.getWidth()/2 then n = 1 end
		enemy.Vx = n*math.random(0,v)
		n = nil
	elseif	side==2 then --bottom
		enemy.x = math.random(15,love.graphics.getWidth()-s-1)
		enemy.y = love.graphics.getHeight()-1
		enemy.Vy = -math.random(v,(v+50))
		local n = -1
		if enemy.x<love.graphics.getWidth()/2 then n = 1 end
		enemy.Vx = n*math.random(0,v)
		n = nil
	elseif	side==3 then --left
		enemy.x = 1
		enemy.y = math.random(15,love.graphics.getHeight()-s-1)
		enemy.Vx = math.random(v,v+50)
		local n = -1
		if enemy.y<love.graphics.getHeight()/2 then n = 1 end
		enemy.Vy = n*math.random(0,v)
		n = nil
	elseif side==4 then --right
		enemy.x = love.graphics.getWidth()-1
		enemy.y = math.random(15,love.graphics.getHeight()-s-1)
		enemy.Vx = -math.random(v,v+50)
		local n = -1
		if enemy.y<love.graphics.getHeight()/2 then n = 1 end
		enemy.Vy = n*math.random(0,v)
		n = nil
	end
	enemy.variance = math.random(global.colortimer.timelimit*1000)/1000
	enemy.color = color(math.random(0,100*global.colortimer.timelimit)/100)
	enemy.size = s
	enemy.typ = "enemy"
	enemy.collides = false
	enemy.diereason = "leftscreen"
	s = nil
	
	return enemy
end