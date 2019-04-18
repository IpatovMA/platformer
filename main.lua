-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local perspective = require("perspective")
local camera = perspective.createView()

local math = require("math")
math.randomseed(os.time())

local physics = require("physics")
physics.start()

--system.activate( "multitouch" )

local fileName = 'map.txt'
local filePath = system.pathForFile(fileName)
local map_data = io.open(filePath, "r")

local player = display.newRect(0,0,32,64)
player.x = 100
player.y = display.contentCenterY*1.5
player:setFillColor(1,1,0)
camera:add(player, 1)
physics.addBody(player,"dynamic",{density=1.0,bounce = 0,friction = 1.0})
player.isFixedRotation = true

local block_size=50

local map_width = 0
local map_heigth = 0

local y = display.contentCenterY/1.5
local block = {}
local block_count = 1
local i = 1
for line in map_data:lines() do
  local x = 0 --смещение от каря уровня
  local b = 0 --подсчет длины уровня
  for j=1,100 do
    B=string.match(line, "%a", j)

    if B=="B" then
      block[block_count] = {
        rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
        id = "block"}

      block[block_count].rect:setFillColor(math.random(),math.random(),math.random())
      physics.addBody(block[block_count].rect,"static",{bounce = 0,friction = 1.0})
      camera:add(block[block_count].rect,2)
      b=b+1
      block_count=block_count+1
    end
map_width = math.max(map_width,b) --подсчет длины уровня
  end
  i=i+1
end
io.close( map_data )
--block[1].rect:setFillColor(0.5)

--print(block_count)

map_heigth=i*block_size
map_width=map_width*block_size

--камера
camera:setFocus(player)
camera:track()
camera:setBounds(display.contentCenterX, map_width - display.contentCenterX, display.contentCenterY, display.contentCenterY)

--[[


]]

--управение
local up_flag = false
local down_flag = false
local left_flag = false
local rigth_flag = false
local ongraund_flag = false

local function walkplayer (event)
  if (rigth_flag) then
  --  player.x = player.x + 15
      player:applyLinearImpulse(1,0,player.x,player.y-32 )
--    return true
  end
  if (left_flag) then
  --  player.x = player.x - 15
  player:applyLinearImpulse( -1,0,player.x,player.y-32)
--    return true
  end
  if (up_flag) then
--player.y= player.y - 10Angular
--player:setLinearVelocity( 0,-45 )
  player:applyLinearImpulse( 0, -2,player.x,player.y)
    --player:setLinearVelocity( 0, -128 )
  --  return true
  end
  if (down_flag) then
  --  player:setLinearVelocity( 0, -32 )
  --  return true
  end
  if (ongraund_flag) then
    print("grnd")
  --  return true
  end
end
local function isongraundq (obj)
  ongraund_flag=PhysicsContact.isTouching(obj,block)
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

-- Local collision handling
local function isongraund( event )
  for i=1,block_count do
    print( event.player)        --the first object in the collision
--    print( event.block[i].id)
--    block[i].rect:setFillColor(0.5)
  end
       --the second object in the collision
--    event.other.rect:setFillColor(0.5)
end
player.collision = isongraund
player:addEventListener( "collision",isongraund )
Runtime:addEventListener("key", keyboardcontrol);
Runtime:addEventListener( "enterFrame", walkplayer )
