function love.load()
	char = {}
	objects = {}
	world = {}
	object_count = 0
	objects.speed = -4
	width = love.graphics: getWidth()
	height = love.graphics: getHeight()
	love.graphics.setBackgroundColor(255,255,255)
	world.floor = height - height/6 					--floor is @ 1/6 of the window height
	world.score = 0
	char.width = 30
	char.height = 30
	char.x =  100
	char.y = world.floor -char.height				-- char gets spawned on floor
	char.speed = 0
	char.charge = 0
	buffer = true
	buffermore = true
	random_pillar()
end

function love.update(dt)
	chargin()
	object_movement()
	player_movement()
	gravity()
	check_pillar_offscreen()
	love.draw()
end

function random_pillar(arg)   -- arg is the position in objects the random pillar is going to get
	spawn_pillar(love.math.random(20,4*(height/6)), arg)
end

function check_pillar_offscreen( ... )
	for  h = 0 , object_count - 1, 1 do 
		if objects[h].posx + objects[h].width + 50 < 0 then
			world.score = world.score + 1
			if buffer then
				objects.speed = objects.speed - 1
				buffer = false
			else buffer = true
			end
			random_pillar(h)
		end
	end
end

function gravity ()
	if buffermore then
		char.speed = char.speed + 1
		buffermore = false
	else buffermore = true
	end
end

function chargin()
	if love.keyboard.isDown(" ")  then
		if buffer == true then
			if char.charge < 21 then
				char.charge = char.charge + 1
			end
			buffer = false
		else buffer = true
		end
	end
end

function love.keyreleased(key)
	if  key == " " then
		char.speed = - char.charge
		char.charge = 0
	end
end

function player_movement( ... )
	char.y = char.y + char.speed
	if char.y + char.height >world.floor then
		char.speed = 0
		char.y = world.floor - char.height
	end
end

function object_movement()
	for  j = 0 , object_count - 1, 1 do
		objects[j].posx = objects[j].posx + objects.speed
	end
end

function collision(x1,y1,w1,h1,x2,y2,w2,h2) --x1,y1 top left coordinate	w1,h1 width and height
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function draw_char( ... )
	love.graphics.setColor(255,0,255)
	love.graphics.rectangle("fill", char.x, char.y, char.width, char.height)
end

function spawn_pillar(h, argu)
	if argu == nil then  --if the pillar is new
		argu = object_count
		object_count = object_count + 1
	end
	local pillar = {}
	pillar.posx = width
	pillar.height = h
	pillar.width = 50
	objects[argu] = pillar
end

function draw_objects()
	love.graphics.setColor(110,50,0)
	for  i = 0 , object_count - 1, 1 do
		love.graphics.rectangle("fill", objects[i].posx, world.floor - objects[i].height, objects[i].width, objects[i].height)
	end
end

function draw_floor()
	love.graphics.setColor(0,100,0)
	love.graphics.rectangle("fill",0, world.floor, width, height - world.floor)
end

function love.draw ()
	draw_floor()
	draw_objects()
	draw_char()
	love.graphics.setColor(0,0,0)
end
