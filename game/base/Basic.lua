Basic = lux.object.new {
	alive = true,
	active = true,
	__type = 'Basic'
}

function Basic:kill()
	self.alive = false
end

function Basic:update( dt )

end

function Basic:draw()

end

function Basic:recycle()
	self.active = true
	self.alive = true
	
	return self
end