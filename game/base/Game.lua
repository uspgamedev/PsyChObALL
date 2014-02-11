module 'Game'

keyboard = {
	isPressed = {}
}
state = nil

local doSwitchState = false
local nextState = nil

function switchState( st )
	doSwitchState = true
	nextState = st
end

function resetState()
	switchState(state)
end

function update( dt )
	if doSwitchState then
		doSwitchState = false

		if state then
			state:destroy()
		end

		state = nextState

		if state then
			state:create()
		end
	end
	if state then
		state:update(dt)
	end
end

function draw()
	if state then
		state:draw()
	end
end

function mousePressed(x, y, btn)
	if state then
		state:mousePressed(x, y, btn)
	end
end

function mouseReleased(x, y, btn)
	if state then
		state:mouseReleased(x, y, btn)
	end
end

function keyPressed( key )
	keyboard.isPressed[key] = true
	if state then
		state:keyPressed(key)
	end
end

function keyReleased( key )
	keyboard.isPressed[key] = false
	if state then
		state:keyReleased(key)
	end
end

function joystickPressed( joynum, btn )
	if state then
		state:joystickPressed(joynum, btn)
	end
end

function joystickReleased( joynum, btn )
	if state then
		state:joystickReleased(joynum, btn)
	end
end