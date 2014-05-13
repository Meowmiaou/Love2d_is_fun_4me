function love.load()
	char = {}
	objects = {}
	world = {}
	object_count = 0
	objects.speed = -4
	love.window.setMode(1500,600,{})
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
	buffer = 0
	buffermore = true
	long = 0
	player = love.graphics.newImage("goop.png")
	objects.lastpillarsize = 100
end

function love.update(dt)
	chargin()
	object_movement()
	player_movement()
	gravity()	
	--check_pillar_offscreen()
	collision_hori()
	collision_verti()
	pillar_timer()
	love.draw()
	buffer = (buffer + 1) % 2
	long = (long + 1)
end

function random_pillar()   -- arg is the position in objects the random pillar is going to get
	spawn_pillar(love.math.random(40,4*(height/6)))
end

function pillar_timer()
	if long > objects.lastpillarsize then
		random_pillar()
		long = 0
	end
end

function check_pillar_offscreen( ... )
	for  h = 0 , object_count - 1, 1 do 
		if objects[h].posx + objects[h].width + 250 < 0 then
			world.score = world.score + 1
			if objects.speed > -11 then
				if buffermore then
					objects.speed = objects.speed - 1
					buffermore = false
				else buffermore = true
				end 
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

function reset()
	char = {}
	objects = {}
	object_count = 0
	objects.speed = -4
	world.score = 0
	char.width = 30
	char.height = 30
	char.x =  100
	char.y = world.floor -char.height	
	char.speed = 0
	char.charge = 0
	buffer = 0
	buffermore = true
	objects.lastpillarsize = 100
end

function collision_hori( ... )
	for  p = 0 , object_count - 1, 1 do
		if char.x <= objects[p].posx and objects[p].posx <= char.x + char.width then
			if char.y + char.height - 5 > world.floor - objects[p].height then
				reset()
				break
				--world.score = 0
				--objects[p].gave_score = true
			elseif objects[p].gave_score == false then 
				world.score =  world.score + 1
				objects[p].gave_score = true

			end
		end
	end
end

function collision_verti()
	for  p = 0 , object_count - 1, 1 do
		if char.x <= objects[p].posx + objects[p].width and objects[p].posx <= char.x + char.width then
			if char.y + char.height >= world.floor - objects[p].height then
				char.y = world.floor - objects[p].height - char.height
				char.speed = 0
			end
		end
	end
end


function chargin()
	if love.keyboard.isDown(" ")  then
		if char.y >= world.floor - char.height then	
			if buffer == 1 then
				if char.charge < 21 then
					char.charge = char.charge + 1
				end
			end
		end
	end
end

function love.keyreleased(key)
	if  key == " " and char.charge > 0 then
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

function draw_char( ... )
	love.graphics.setColor(255,0,255)
	love.graphics.rectangle("fill", char.x, char.y, char.width, char.height)
end

function spawn_pillar(h)
	local pillar = {}
	pillar.posx = width
	pillar.height = h
	objects.lastpillarsize = h/4 + 80
	pillar.width = 50
	pillar.gave_score = false
	objects[object_count] = pillar
	object_count = object_count + 1
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

function draw_sprite()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(player, char.x, char.y)
end

function draw_chargebar()
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",40,height-30, char.charge*10, 10)
end

function love.draw ()
	draw_floor()
	draw_objects()
	--draw_char()
	draw_sprite()
	love.graphics.setColor(0,0,0)
	love.graphics.print("Score: "..world.score, width-100,30)
	draw_chargebar()
end
