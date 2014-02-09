Basic = lux.object.new {
	alive = true,
	__type = 'Basic'
}

function Basic:kill()
	self.alive = false
end

function Basic:update( dt )

end

function Basic:draw()

end