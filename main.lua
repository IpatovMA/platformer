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

local module = require("module")

--построение карты
local fileName = 'map.txt'
local filePath = system.pathForFile(fileName)
local file = io.open(filePath, "r")

local block_size=50
local map_width = 80
local map_height = 10

local x = 1
local y = display.contentCenterY/1.5
local map = {}
local block_count = 1

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
    if map[i][j] == "B" then
      map[i][j] = {
        rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
        id = "block"
      }
      map[i][j].rect:setFillColor(math.random(),math.random(),math.random())
      physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
      camera:add(map[i][j].rect,2)
    end
    if map[i][j] == "G" then
      map[i][j] = {
        rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
        id = "gold"
      }
      map[i][j].rect:setFillColor(0,1,0)
      physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
      camera:add(map[i][j].rect,2)
    end
  end
end



--пресонаж
local player = display.newRect(0,0,32,64)
player.x = 100
player.y = display.contentCenterY*1.5
player:setFillColor(1,1,0)
camera:add(player, 1)
physics.addBody(player,"dynamic",{density=1.0,bounce = 0,friction = 1.0})
player.isFixedRotation = true


--камера
map_height=map_height*block_size
map_width=map_width*block_size
camera:setFocus(player)
camera:track()
camera:setBounds(display.contentCenterX, map_width - display.contentCenterX, display.contentCenterY, display.contentCenterY)

--управение
 local up_flag = false
 local down_flag = false
 local left_flag = false
 local rigth_flag = false
 local ongraund_flag =false

 local function onGround (obj)
 local i=math.floor((bott_y(obj)-display.contentCenterY/1.5)/block_size)+1
    for j=math.ceil(left_x(obj)/block_size),math.ceil(rigth_x(obj)/block_size) do
     if map[i][j].rect then
       print(i,j)
       return true
    else return false end
    end
end

local function walkplayer (event)
 if (rigth_flag) then
  player.x = player.x + 10
 end
 if (left_flag) then
  player.x = player.x - 10
 end
 if up_flag and (onGround(player)) then
      player.y = player.y - 40
 end
 if (down_flag) then
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


Runtime:addEventListener("key", keyboardcontrol);
Runtime:addEventListener( "enterFrame", walkplayer )
