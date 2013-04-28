module ("shot",package.seeall)
	
local Shot = {}
Shot.__index = Shot
local global = _G

function Shot:handleDelete()
	global.score = global.score- 2*((global.multiplier-1)/2 + 0.85)
	effect.new(self.x,self.y,7)
end
function Shot:draw()   
	love.graphics.setColor(color(self.variance+global.colortimer.time))
    love.graphics.circle("fill",self.x,self.y,self.size)
end
function Shot:update(dt)
    self.x = self.x + self.Vx*dt
    self.y = self.y + self.Vy*dt
    return not(self.collides or self.x<-self.size or self.y<-self.size or self.x+self.size>love.graphics.getWidth() or self.y+self.size> love.graphics.getHeight())
end

function new(x,y,Vx,Vy)
	local shot = {}
	setmetatable(shot,Shot)
	shot.x = x
	shot.y = y
	shot.Vx = Vx
	shot.Vy = Vy
	shot.size = 4
	shot.typ = "shot"
	shot.collides = false
	shot.variance = math.random(0,100*global.colortimer.timelimit)/100
	
	return shot
end
