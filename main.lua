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
-- physics.setGravity(0,0)
require("mapbuild")
require("animation")

--построение карты
local level = {
  fileName = 'map.txt',
  block_size=50,
  width = 80,
  height = 25,
}

level.mapdata = mapread (level)
level.map = mapbild (level)

--бэкграунд
local backgroundImage = {
  fileName="background.png",
  height=2400,
  width=3400
}

makeBackground(backgroundImage,level)

--таймер
local sec = 0
level.time = display.newText(sec, display.contentCenterX, 20, native.systemFont, 40 )
 level.time:setFillColor(math.random(),math.random(),math.random())
local timer_show = function()
  sec = sec +1
   level.time.text = sec
end
timer.performWithDelay( 1000, timer_show ,-1 )

--пресонаж

local player_options = {
  start_x= 100,
  start_y = display.contentCenterY*1.3,
  width =32,
  height = 64,
  vx=0,
  vy=0
}

local player = display.newRect(player_options.start_x,player_options.start_y,player_options.width,player_options.height)
player.alpha = 0
camera:add(player, 1)
physics.addBody(player,"dynamic",{density=3.0,bounce = 0,friction = 1.0})
player.isFixedRotation = true
--  --золото счетчик

local gold = {count = 0}
gold.show = display.newText(gold.count, display.contentCenterX + display.actualContentWidth/2.4, 20, native.systemFont, 40)
gold.show:setFillColor(1,1,0)
gold.sprite = display.newSprite( coin_sprite_sheet, sequences_coin )
gold.sprite:setSequence("shine")
gold.sprite.yScale = 0.13
gold.sprite.xScale = 0.13
gold.sprite.x=display.contentCenterX + display.actualContentWidth/2.2
gold.sprite.y=20
gold.sprite:play()
--  --спрайт
local player_sprite = display.newSprite( player_sprite_sheet, sequences_player )
local spriteScale = player_options.height/(player_sprite_options.height-3)
player_sprite.yScale = spriteScale
player_sprite.xScale = spriteScale
camera:add(player_sprite, 1)

local function spriteOritentation(player_sprite)
if player.vx==0  then
  if player_sprite.sequence ~= "stay" then
  player_sprite:setSequence("stay")
    end
else
  if player_sprite.sequence ~= "run" then
  player_sprite:setSequence("run")
    end
  end
  if player.vx > 0  then
        player_sprite.xScale =spriteScale
      end
  if player.vx < 0  then
        player_sprite.xScale = -spriteScale
    end

  if onGround(player) then
        player_sprite:play()
      else player_sprite:pause() end

--привязка спрайта персонажа
player_sprite.x=player.x
player_sprite.y=player.y
end

--камера

camera:setFocus(player)
camera:track()
camera:setBounds(display.contentCenterX, level.width*level.block_size - display.contentCenterX, display.contentCenterY, display.contentCenterY)

--детекторы касаний
function onGround (obj)
local i=math.ceil((bott_y(obj)+1)/level.block_size)
  for j=(math.ceil((left_x(obj))/level.block_size)),(math.ceil((rigth_x(obj))/level.block_size)) do
   if level.map[i][j].id=="block" then
     return true
   end
  end
  return false
end

local function onSpikes (obj)
local i=math.ceil((bott_y(obj)+1)/level.block_size)
  for j=(math.ceil((left_x(obj))/level.block_size)),(math.ceil((rigth_x(obj))/level.block_size)) do
   if level.map[i][j].id=="spike" then
     return true
   end
  end
  return false
end

local function catchGold (obj)
  for i = math.ceil((top_y(obj)-1)/level.block_size),math.ceil((bott_y(obj)+1)/level.block_size) do
    for j=(math.ceil((left_x(obj)-1)/level.block_size)),(math.ceil((rigth_x(obj)+1)/level.block_size)) do
     if level.map[i][j].id=="gold" then
       level.map[i][j].id="air"
       level.map[i][j].rect.alpha = 0
       gold.count=gold.count+1
       gold.show.text=gold.count
     end
    end
  end
  return false
end

--проверка в реальном времени
local function eventChecker ()
  if onSpikes(player) then
    player_death()
  end
  catchGold(player)
  player.vx,player.vy = player:getLinearVelocity()
  spriteOritentation(player_sprite)
end

Runtime:addEventListener( "enterFrame", eventChecker )

--смерть персонажа, перезагрузка уровня
function player_death ()
  player.x = player_options.start_x
  player.y = player_options.start_y
  player:setLinearVelocity(0)
  sec=0
  gold.count=0
  gold.show.text=gold.count
  level.map = rebuildmap(level)

end

--управение
local up_flag = false
local down_flag = false
local left_flag = false
local rigth_flag = false

local walkspeed = 300
local jampspeed = 350


local function walkplayer (event)

 if (rigth_flag) then
   if not(onGround(player)) then
     player:setLinearVelocity(walkspeed/1.3, player.vy )
   else player:setLinearVelocity(walkspeed, player.vy )
   end
 end
 if (left_flag) then
   if not(onGround(player)) then
     player:setLinearVelocity(-walkspeed/1.3, player.vy )
   else player:setLinearVelocity(-walkspeed, player.vy )end
 end
 if up_flag and (onGround(player)) then
  player:setLinearVelocity(player.vx/1.3, -jampspeed )
 end
 if (down_flag) then
   player_death ()
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
