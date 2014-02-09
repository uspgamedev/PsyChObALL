module 'Game'

state = nil

function switchState( st )
	if state then
		state:destroy()
	end

	state = st

	if state then
		state:create()
	end
end

function resetState()
	switchState(state)
end

function update( dt )
	if state then
		state:update(dt)
	end
end

function draw()
	if state then
		state:draw()
	end
end