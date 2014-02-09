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