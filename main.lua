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
--physics.setGravity(0,12)

local module = require("module")

--построение карты
-- local background = display.newImageRect( "background.png", display.actualContentWidth, display.actualContentHeight )
-- background.x = display.contentCenterX
-- background.y = display.contentCenterY
local fileName = 'map.txt'
local block_size=50
local map_width = 80
local map_height = 15
local map = mapbild (fileName,block_size,map_width,map_height)

--таймер
local sec = 0
local level_time = display.newText(sec, display.contentCenterX, 20, native.systemFont, 40 )
 level_time:setFillColor(math.random(),math.random(),math.random())
local timer_show = function()
  sec = sec +1
   level_time.text = sec
end
timer.performWithDelay( 1000, timer_show ,-1 )

--пресонаж
local start_player_position_x = 100
local start_player_position_y = display.contentCenterY

local player = display.newRect(start_player_position_x,start_player_position_y,32,64)
player:setFillColor(1,0.8,0)
camera:add(player, 1)
physics.addBody(player,"dynamic",{density=3.0,bounce = 0,friction = 1.0})
player.isFixedRotation = true

local gold = {count = 0}
gold.show = display.newText(gold.count, display.contentCenterX + display.actualContentWidth/2.2, 20, native.systemFont, 40)
gold.show:setFillColor(1,1,0)

--камера

camera:setFocus(player)
camera:track()
camera:setBounds(display.contentCenterX, map_width*block_size - display.contentCenterX, display.contentCenterY/2, display.contentCenterY*1.5)

--детекторы касаний
local function onGround (obj)
local i=math.ceil((bott_y(obj)+1)/block_size)
  for j=(math.ceil((left_x(obj))/block_size)),(math.ceil((rigth_x(obj))/block_size)) do
   if map[i][j].id=="block" then
     return true
   end
  end
  return false
end

local function onSpikes (obj)
local i=math.ceil((bott_y(obj)+1)/block_size)
  for j=(math.ceil((left_x(obj))/block_size)),(math.ceil((rigth_x(obj))/block_size)) do
   if map[i][j].id=="spike" then
     return true
   end
  end
  return false
end

local function catchGold (obj)
for i = math.ceil((top_y(obj)-1)/block_size),math.ceil((bott_y(obj)+1)/block_size) do
  for j=(math.ceil((left_x(obj)-1)/block_size)),(math.ceil((rigth_x(obj)+1)/block_size)) do
   if map[i][j].id=="gold" then
     map[i][j].id="air"
     --physics.removeBody(map[i][j].rect)
     map[i][j].rect.alpha = 0
     gold.count=gold.count+1
     gold.show.text=gold.count

   end
  end
end
  return false
end

local function eventChecker ()
  if onSpikes(player) then
    player_death()
  end
  if catchGold(player)then

  end
end

Runtime:addEventListener( "enterFrame", eventChecker )
--смерть персонажа, перезагрузка уровня
function player_death ()
  player.x = start_player_position_x
  player.y = start_player_position_y
  sec=0
  gold.count=0
  gold.show.text=gold.count
  map=mapConnect (map,rebuildGold(fileName,block_size,map_width,map_height),block_size,map_width,map_height)
end

--управение
local up_flag = false
local down_flag = false
local left_flag = false
local rigth_flag = false

local walkspeed = 300
local jampspeed = 350

local function walkplayer (event)
  local vx,vy = player:getLinearVelocity()
 if (rigth_flag) then
   if not(onGround(player)) then
     player:setLinearVelocity(walkspeed/1.3, vy )
   else player:setLinearVelocity(walkspeed, vy )
   end
 end
 if (left_flag) then
   if not(onGround(player)) then
     player:setLinearVelocity(-walkspeed/1.3, vy )
   else player:setLinearVelocity(-walkspeed, vy )end
 end
 if up_flag and (onGround(player)) then
  player:setLinearVelocity(vx/1.3, -jampspeed )
 end
 if (down_flag) then
 end
 -- if not(rigth_flag) and not(left_flag) and not(up_flag) then
 --    player:setLinearVelocity(0)
 -- end
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

Runtime:addEventListener("key", keyboardcontrol)
Runtime:addEventListener( "enterFrame", walkplayer )
