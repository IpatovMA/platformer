-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
perspective = require("perspective")
camera = perspective.createView()

local math = require("math")
math.randomseed(os.time())

local physics = require("physics")
physics.start()
physics.setGravity(0,12)



--построение карты
local fileName = 'map.txt'
local filePath = system.pathForFile(fileName)
local file = io.open(filePath, "r")

local block_size=50
local map_width = 80
local map_height = 15

local x = -block_size/2
local y = -block_size/2
local map = {}

 for  i=1,map_height do
  map[i]={}
  local line = file:read("*l")
    for j=1,map_width do
      map[i][j]=string.match(line, "%a", j)
    end
end
io.close( file )

for i=1,map_height do
  for j=1,map_width do
    if map[i][j] == "z" then
      map[i][j] = {
        rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
        id = "air"--пустые блоки
      }
      camera:add(map[i][j].rect,1)
    end
    if map[i][j] == "B" then
      map[i][j] = {
        rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
        id = "block"--твердые блоки
      }
      map[i][j].rect:setFillColor(math.random(),math.random(),math.random())
      physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
      camera:add(map[i][j].rect,1)
    end
    if map[i][j] == "G" then
      map[i][j] = {
        rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
        id = "gold"--голда
      }
      map[i][j].rect:setFillColor(0,1,0)
      physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
      camera:add(map[i][j].rect,1)
    end
  end
end
--угол почему то сместился
--local conerX,conerY = left_top(map[1][1].rect)

--пресонаж
local player = display.newRect(0,0,32,64)
player.x = 115
player.y = display.contentCenterY
player:setFillColor(1,1,0)
camera:add(player, 1)
physics.addBody(player,"dynamic",{density=3.0,bounce = 0,friction = 1.0})
player.isFixedRotation = true


--камера
map_height=map_height*block_size
map_width=map_width*block_size
camera:setFocus(player)
camera:track()
camera:setBounds(display.contentCenterX, map_width - display.contentCenterX, display.contentCenterY/2, display.contentCenterY*1.5)

--управение
 local up_flag = false
 local down_flag = false
 local left_flag = false
 local rigth_flag = false


 local function onGround (obj)
   local flag = false
 local i=math.ceil((bott_y(obj)+1)/block_size)
    for j=(math.ceil((left_x(obj))/block_size)),(math.ceil((rigth_x(obj))/block_size)) do

     if map[i][j].id=="block"   then
 --       print(math.ceil((left_x(obj)+4)/block_size),math.ceil((rigth_x(obj)-4)/block_size))
 -- print(((bott_y(obj)-block_size/2+1)/block_size)+1)
 --  print(map[i][j].id)
 -- print(rigth_x(obj),(left_x(map[i][j].rect)))
       return true
     end
    end
return false
    end

-- local function onGroundcollision (self, event)
--    local i=math.floor((bott_y(self)-display.contentCenterY/1.5-block_size/2+1)/block_size)+1
--       for j=math.ceil((left_x(self))/block_size),math.ceil(rigth_x(self)/block_size) do
--         if map[i][j].id=="block"   then
--              if event.contact.isTouching(map[i][j].rect) then
--              print(i,j)
--
--              return true
--           else return false end
--       end end
-- end
--
-- player.collision = onGroundcollision
-- player:addEventListener("collision")

local walkspeed = 300
local jampspeed = 350
local verticalspeed = 0

local function walkplayer (event)
  local vx,vy = player:getLinearVelocity()
 if (rigth_flag) then
   if not(onGround(player)) then
     player:setLinearVelocity(walkspeed/1.3, vy )
   else player:setLinearVelocity(walkspeed, vy )end
 end
 if (left_flag) then
   if not(onGround(player)) then
     player:setLinearVelocity(-walkspeed/1.3, vy )
   else player:setLinearVelocity(-walkspeed, vy )end
 end
 if up_flag and (onGround(player)) then
    --  player.y = player.y - 40
  --  player:applyLinearImpulse(0,-4,player.x,player.y)
  player:setLinearVelocity(vx/1.3, -jampspeed )
--  verticalspeed=-jampspeed
 end
 if (down_flag) then
 end
-- print(onGround(player))
--onGround(player)
 -- if not(rigth_flag) and not(left_flag) then
 --    player:setLinearVelocity(0,vy )
 -- end
end

local function verticalmovement()
    if verticalspeed<0 then
        verticalspeed=verticalspeed/2
        print(verticalspeed)
    end
end

local function keyboardcontrol(event)
 if (event.keyName == 'd' and event.phase == 'down') then
   rigth_flag=true
 else rigth_flag=false
 end
 if (event.keyName == 'a' and event.phase == 'down') then
   left_flag=true
 else left_flag=false
 end
 if (event.keyName == 'w' and event.phase == 'down') then
   up_flag=true
 else up_flag=false
 end
 if (event.keyName == 's' and event.phase == 'down') then
   down_flag=true
 else down_flag=false
 end
end
local module = require("module")

Runtime:addEventListener("key", keyboardcontrol)
Runtime:addEventListener( "enterFrame", walkplayer )
player:addEventListener("enterFrame",verticalmovement)
