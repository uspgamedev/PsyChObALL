title = 'IV - The Only One'
chapter = 'Part 1 - Like Sheep'

function run()
	warnEnemies = true
	warnEnemiesTime = 0.7

	local simple = 'simpleball'
	local divide1 = 'multiball'
	local grey = 'grayball'
	local super = 'superball'

	local horizontalr = formation {
		type = 'horizontal',
		from = 'right'
	}

	local horizontall2 = formation {
		type = 'horizontal',
		from = 'left'
	}

	local horizontall = formation {
		type = 'horizontal',
		from = 'left'
	}

	local verticalt = formation {
		type = 'vertical',
		from = 'top'
	}

	local verticalb = formation {
		type = 'vertical',
		from = 'bottom'
	}


	local vform = formation {
		type = 'V',
		startpoint = vector:new{23, -1020},
		size = width,
		growth = 1010,
		setspeedto = vector:new{0, v}
	}
	
	local f1 = formation {
		type = 'around',
		angle = 0,
		target = vector:new{width/2, height/2},
		anglechange = torad(180),
		shootattarget = true,
		adapt = false
	}
	local f2 = formation {
		type = 'vertical',
		from = 'top',
		movetorwards = 'right',
		distance = 42,
		startsat = width/2-200,
		setspeedto = vector:new{0, 300}
	}

	local f3 = formation {
		type = 'around',
		angle = torad(-45),
		target = vector:new{width/2, height/2},
		anglechange = torad(45),
		shootattarget = true
	}
	local simple = 'simpleball'
	local divide1 = 'multiball'
	local range = 'ranged'
	local simple = 'simpleball'
	local grey = 'grayball'
	local snake = 'snake'
	local nic = 'cage'
	local vc = function(data) return vector:new(data) end
	local mono = 'monoguiaball'
	
	wait(3)
	for i = 1,25 do
		enemy(divide1, 1, {position = vc{0,0}, positionfollows =
		function(time)
			return time*width/4, (math.cos(time*math.pi*4.5/5)+1)*height/4+height/3
		end
		})
		wait(0.25)
	end
	wait(3)
	horizontall.copy = { position = vc{0,0}, positionfollows = function(time)
			local x = time*width/2.2
			return x, (math.cos(time*math.pi/4*10)+1)*40-40
		end
	}
	for i = 1,60 do
		enemy({simple,divide1}, 4, horizontall)
		wait(0.15)
		horizontall2.speed = v
		if i == 20 or i == 30 or i == 45 then
			enemy({divide1,simple},7,horizontall2)
		end
		if i == 25 or i == 35 then
			enemy({divide1,simple},8,horizontall2)
		end
		if i == 40 or i == 50 then
			enemy({divide1,simple},7,horizontall2)
		end
	end
	wait(4)
	for i = 1,67 do
		if i == 1 then
			f3.speed = 1.78*v
			f3.adapt = false
			enemy({simple,simple,divide1}, 8, f3)
		end
		if i == 10 then
			f3.speed = 2.2*v
			enemy(grey, 8, f3)
		end
		if i == 12 then
			f3.speed = 1*v
			f3.distance = 30
			enemy(divide1, 12, f3)
		end
		enemy({divide1,simple,divide1}, 1, {position = vc{0,0}, positionfollows =
		function(time)
			local x = time*width/10
			if x <= (width-height)/2 then return x, height/2
			elseif x <= (width+height)/2 then
				return x, math.sqrt( (height/2)^2 -(x-width/2)^2)+height/2
			elseif x <= (width + 3*height)/2 then
				x = width + height - x
				return x, -math.sqrt( (height/2)^2 -(x-width/2)^2)+height/2
			else
				x = width + height - x
				return x, height/2
			end
			
		end
		})
		wait(0.45)
		if i == 20 then
			doNow( function()
				wait(30)
				enemy(nic, 1, nil, {width/2,height/2},
				{size = 100, wait = 10, sizeGrowth = 150},
				{moveto = {7*width/8,height/2}, wait = 5}, 
				{moveto = {width/8,height/2}, wait = 8},
				{moveto = {width/2,height/2}, wait = 4.5}, 
				{destroy = true, sizeGrowth = 230}
				)
			end)
		end
		if i == 25 or i == 35 then
			enemy({grey,divide1},12,vform)
		end
		if i == 30 or i == 40 then
			horizontall2.speed = 1.2*v
			horizontalr.speed = 1.2*v
			enemy({simple,divide1}, 8, horizontall2)
			enemy({divide1,simple}, 9, horizontalr)
		end
		if i == 50 then
			horizontall.copy = { position = vc{0,0}, positionfollows = function(time)
			local x = time*width/5
			return x, (math.cos(time*math.pi/10*30)+1)*40-40
		end
	} 
			enemy({simple,divide1}, 5, horizontall)
		end
		if i == 60 then
			f3.adapt = true
			f3.speed = 2*v
			f3.distance = 0
			enemy(simple, 8, f3)
		end
	end
	wait(6) 
	f2.from = 'bottom'
	f2.setspeedto.y = -300
	enemy(grey, 11, f2)
	wait(1)
	f2.movetorwards = 'left'
	f2.startsat = width - 20
	enemy(grey, 11, f2)
	f2.from = 'bottom'
	f2.setspeedto.y = -300
	enemy(grey, 11, f2)
	f2.movetorwards = 'right'
	f2.startsat = 20
	enemy(grey, 11, f2)
	wait(3)
	enemy(super, 1, { position = vector:new{width/2, -30}, speed = vector:new{0.5*v, 0.5*v}, life = 40, size = 50}, divide1, nil, 5)
	enemy(super, 1, { position = vector:new{width/2, height+30}, speed = vector:new{0.5*v, 0.5*v}, life = 80, size = 70}, simple, nil, 5)
	wait(10)
	doNow( function(timer)
		print(levelselected)
		if not levelselected then
			if not gamelost then reloadStory 'Level 4-2' end
		else
			text:new{
				text = "Part Completed. Press ESC or P and return to the menu.", --ou algum outro texto
				font = getCoolFont(50),
				printmethod = graphics.printf,
				position = vector:new{width/2 - 400, height/2 - 50},
				limit = 800,
				align = 'center'
			}:register()
		end
	end)
end
