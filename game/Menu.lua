Menu = lux.object.new {
	__type = 'Menu'
}

Menu.__init = {
	components = {},
	alphaFollows = VarTimer:new{var = 255, pausable = false}
}

function Menu:addComponent( component )
	component.alphaFollows = self.alphaFollows
	component:start()
	component.menu = self.index
	table.insert(self.components, component)
end

function Menu:draw()
	for i = #self.components, 1, -1 do
		self.components[i]:draw()
	end
end

function Menu:update( dt )
	for i = #self.components, 1, -1 do
		self.components[i]:update(dt)
	end
end

function Menu:open()
	self.alphaFollows.var = 255
	state = self.index
end

function Menu:close()
	for k, component in ipairs(self.components) do
		if component.close then component:close() end
		self.components[k] = nil
	end
end