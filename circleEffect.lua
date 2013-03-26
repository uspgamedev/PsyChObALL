require "global"
module ("circleEffect",package.seeall) do
	local CircleEffect = {}
	CircleEffect.__index = CircleEffect
	
	function CircleEffect:draw()
        if self.lw then love.graphics.setLine(self.lw) end
        love.graphics.setColor(color(global.colortimer.time*self.var,nil,self.alpha))
        love.graphics.circle("line",self.x,self.y,self.size)
        if self.lw then love.graphics.setLine(4) end
    end
	
    function CircleEffect:update(dt)
        self.size = self.size + self.sizeGrowth*dt
        return self.size<self.maxsize
    end
	
    function CircleEffect:handleDelete()
    
    end
	
	function new(ci,lw,alpha,growth,maxsize)
		local c = {}
		setmetatable(c,CircleEffect)
		c.alpha = alpha or 10
		c.x = ci.x
		c.y = ci.y
		c.size = ci.size
		c.maxsize = maxsize or love.graphics.getWidth()/1.9
		c.sizeGrowth = growth or math.random(120,160)		
		c.typ = "circle"
		c.var = math.random(30,300)/100
		c.lw = lw
		table.insert(bodies,c)
	end
end