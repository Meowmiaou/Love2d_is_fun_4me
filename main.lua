function love.load()
	char = {}
	objects = {}
	world = {}
	back = {}
	object_count = 0
	objects.speed = -7
	love.window.setMode(1500,600,{})
	width = love.graphics: getWidth()
	height = love.graphics: getHeight()
	love.graphics.setBackgroundColor(255,255,255)
	world.floor = height - height/6 					--floor is @ 1/6 of the window height
	world.score = 10
	world.highscore = 0
	world.lastscore = 0
	char.width = 30
	char.height = 30
	char.x =  100
	char.y = world.floor -char.height				-- char gets spawned on floor
	char.speed = 0
	char.charge = 0
	buffer = 0
	buffermore = true
	long = 0
	crouching = false
	player = love.graphics.newImage("Creatureofthenight.png")
	croucher = love.graphics.newImage("Rawr2.png")
	vine = love.graphics.newImage("vine.png")
	upsidevine = love.graphics.newImage("upsidevine.png")
	background = love.graphics.newImage("back.png")
	ground = love.graphics.newImage("floor.png")
	n1 = {}
	n2 = {}
	n1.x = 0
	n1.y = 0
	n2.x = width
	n2.y = 0
	back[0] = n1
	back[1] = n2
	m1 = {}
	m2 = {}
	m1.x = 0
	m1.y = world.floor
	m2.x = width
	m2.y = world.floor
	back[2] = m1
	back[3] = m2
	objects.lastpillarsize = 80
	objects.nextpillarsize = love.math.random(40,4*(height/6))
end

function love.update(dt)
	chargin()
	object_movement()
	player_movement()
	gravity()
	backgroundmovement()
	groundmovement()	
	--check_pillar_offscreen()
	collision_hori()
	collision_verti()
	pillar_timer()
	love.draw()
	buffer = (buffer + 1) % 2
	long = (long + 1)
end

function drawbackground(backs)
	if backs.x < -width then
		backs.x = width
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(background, backs.x, backs.y)
end

function backgroundmovement( ... )
	back[1].x = back[1].x -1
	back[0].x = back[0].x -1 
end

function crouchinger( ... )
	if crouching == true then
		love.graphics.setColor(255,255,255)
		love.graphics.draw(croucher, char.x, char.y)
	else
		love.graphics.setColor(255,255,255)
		love.graphics.draw(player, char.x, char.y)
	end
end

function random_pillar()   
	spawn_pillar(objects.nextpillarsize, world.floor - objects.nextpillarsize,false)
	if world.score > 9 then
	 	if love.math.random(2) == 1 then
			spawn_pillar(world.floor - objects.nextpillarsize - love.math.random(110,160), 0, true)
	 	end
	 end
	objects.nextpillarsize = love.math.random(40,4*(height/6))
end

function pillar_timer()
	if long > objects.lastpillarsize/14 + objects.nextpillarsize/6 + 45 then
		--print(long)
		random_pillar()
		long = 0
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
	if world.highscore < world.score then
		world.highscore = world.score
	end
	char = {}
	objects = {}
	object_count = 0
	objects.speed = -7
	world.lastscore = world.score
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
	objects.nextpillarsize = love.math.random(40,4*(height/6))
end

function collision_hori( ... )
	for  p = 0 , object_count - 1, 1 do
		if char.x + char.width - 7 <= objects[p].posx and objects[p].posx <= char.x + char.width then --if the pillars forward wall ist in between the the x vlaues of the character
			if not objects[p].upper then											-- if the pillar isnt coming from above
				if char.y + char.height - 3 > world.floor - objects[p].height then  --check it the "bottom" of the character is lower than the top of the pillar
					reset()
					break																--if it is reset the game
				end		
				if objects[p].gave_score == false then 							-- if it isnt check if the pillar has already added to the score
					world.score =  world.score + 1 	 								-- add the to score and mark the pillar as "gave_score"								
					objects[p].gave_score = true
				end
			end
			if objects[p].upper then
				if char.y < objects[p].posy + objects[p].height then
					reset()
				break
				end
			end
		end
	end
end


function collision_verti()
	for  p = 0 , object_count - 1, 1 do
		if char.x <= objects[p].posx + objects[p].width and objects[p].posx <= char.x + char.width then
			if not objects[p].upper then
				if char.y + char.height >= world.floor - objects[p].height then
					char.y = world.floor - objects[p].height - char.height
					char.speed = 0
				end
			end
			if objects[p].upper then
				if char.y < objects[p].height then
					char.y = objects[p].height
					char.speed = 0
				end	
			end
		end
	end
end


function chargin()
	if love.keyboard.isDown(" ")  then
		if char.y >= world.floor - char.height then	
			if buffer == 1 then
				if char.charge < 21 then
					crouching = true
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
		crouching = false
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

function spawn_pillar(h , where, supper)
	local pillar = {}
	pillar.posx = width
	pillar.posy = where
	pillar.height = h
	pillar.upper = supper
	if not supper then
		objects.lastpillarsize = h
	end
	pillar.width = 50
	pillar.gave_score = false
	objects[object_count] = pillar
	object_count = object_count + 1
end

function draw_objects()
	love.graphics.setColor(128,128,128)
	for  i = 0 , object_count - 1, 1 do
		if objects[i].upper then
			love.graphics.draw(upsidevine, objects[i].posx ,objects[i].posy - 500 + objects[i].height)
		else
		--love.graphics.rectangle("fill", objects[i].posx, objects[i].posy, objects[i].width, objects[i].height)
			love.graphics.draw(vine, objects[i].posx, objects[i].posy)
		end
	end
end

function draw_floor()
	love.graphics.setColor(50,30,30)
	love.graphics.rectangle("fill",0, world.floor, width, height - world.floor)
end


function draw_chargebar()
	love.graphics.setColor(char.charge * 10,0,0)
	love.graphics.rectangle("fill",40,height-30, char.charge*10, 10)
end

function drawground(backs)
	if backs.x < -width then
		backs.x = width
	end
	love.graphics.setColor(255,255,255)
	love.graphics.draw(ground, backs.x, backs.y)
end

function groundmovement( ... )
	back[2].x = back[2].x -7
	back[3].x = back[3].x -7 
end

function love.draw ()
	drawbackground(back[0])
	drawbackground(back[1])
	love.graphics.print("Last Score: "..world.lastscore, width-100,50)
 	love.graphics.print("Highscore: "..world.highscore, width-100,70)
	draw_objects()
	drawground(back[2])
	drawground(back[3])
	--draw_floor()
	crouchinger()
	love.graphics.setColor(255,255,255)
	love.graphics.print("Score: "..world.score, width-100,30)
	draw_chargebar()
end
