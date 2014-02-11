require 'base.Group'

State = Group:new {
	__type = 'State'
}

-- override these, but don't forget to call super!

function State:create()

end

function State:destroy()
	self:kill()
	self:clearAll()
end

function State:mousePressed(x, y, btn)

end

function State:mouseReleased(x, y, btn)

end

function State:keyPressed( key )

end

function State:keyReleased( key )

end

function State:joystickPressed( joynum, btn )

end

function State:joystickReleased( joynum, btn )

end