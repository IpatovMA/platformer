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

--массив с врагами
-- --СДЕЛАТЬ ЛОКАЛЬНЫМ
 enemies = {}
local enemies_count


--построение карты
local level = {
  fileName = 'map.txt',
  block_size=50,
  width = 50,
  height = 20,
}

level.mapdata = mapread (level)
level.map,level.border,enemies_count = mapbild (level,enemies)

local enemies_B_pos = {12*level.block_size,28*level.block_size,42*level.block_size,2*level.block_size} --массив с точками Б для мобов, которые ходят
for l=1,enemies_count do
  local i = 1
  if enemies[l].type==1 then
     enemies[l].B_pos= enemies_B_pos[i]-level.block_size*0.5
     i=i+1
  end
end

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

--золото счетчик
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
    -- print("s")
      end
  else
    if player_sprite.sequence ~= "run" then
    player_sprite:setSequence("run")
      end
      if player.vx > 0  then
            player_sprite.xScale =spriteScale
            -- print("r")
          end
      if player.vx < 0  then
            player_sprite.xScale = -spriteScale
            -- print("l")

        end
    end


    if onGround(player) then
          player_sprite:play()
        else player_sprite:pause() end
    -- print(player.vx,player.vy)
  --привязка спрайта персонажа
  player_sprite.x=player.x
  player_sprite.y=player.y
end

local function enemySpriteOrientation (enemy)
  enemy.vx,enemy.vy=enemy.rect:getLinearVelocity()
  -- print(enemy.vx,enemy.vy,enemy.scaling)
  if enemy.vx > 0  then
        enemy.sprite.xScale = -enemy.scaling
      end
  if enemy.vx < 0  then
        enemy.sprite.xScale = enemy.scaling
    end
    -- if onGround(enemy.rect) then
          enemy.sprite:play()
    -- else enemy.sprite:pause() end
  enemy.sprite.x = enemy.rect.x
  enemy.sprite.y = enemy.rect.y+enemy.y_fix

end

local function enemyWalk (enemy)

    -- (left_x(enemy.rect)<=enemy.A_pos) and (Aflag=false) or (Aflag= true)
    -- (rigth_x(enemy.rect)>=enemy.B_pos) and Bflag=true or Bflag=false
  if left_x(enemy.rect)<=enemy.A_pos then
     enemy.A_pos_flag = false
     enemy.B_pos_flag = true
     -- print("A")
  end
  if rigth_x(enemy.rect)>=enemy.B_pos then
     enemy.A_pos_flag = true
     enemy.B_pos_flag = false
     -- print("B")
  end
  -- print(Aflag,Bflag)
  if left_x(enemy.rect)>enemy.A_pos and enemy.A_pos_flag then
      enemy.rect:setLinearVelocity(-enemy.speed,enemy.vy)
      -- print("A")
  end
  if rigth_x(enemy.rect)<enemy.B_pos and enemy.B_pos_flag then
      enemy.rect:setLinearVelocity(enemy.speed,enemy.vy)
      -- print("B")
  end


  -- print("logging")
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
--  return true
end

local function inLava (obj)
  local i=math.ceil((bott_y(obj)+1)/level.block_size)
  for j=(math.ceil((left_x(obj))/level.block_size)),(math.ceil((rigth_x(obj))/level.block_size)) do
   if level.map[i][j].id=="lava" then
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

-- local function touchEnemy (obj)
--   for i = math.ceil((top_y(obj)-1)/level.block_size),math.ceil((bott_y(obj)+1)/level.block_size) do
--     for j=(math.ceil((left_x(obj)-1)/level.block_size)),(math.ceil((rigth_x(obj)+1)/level.block_size)) do
--      if level.map[i][j].id=="gold" then
--        level.map[i][j].id="air"
--        level.map[i][j].rect.alpha = 0
--        gold.count=gold.count+1
--        gold.show.text=gold.count
--      end
--     end
--   end
--   return false
-- end

--проверка в реальном времени
local function eventChecker ()
  --упал в лаву?
  if inLava(player) then
    player_death()
  end
  --взял монету?
  catchGold(player)
  --скорость персонажа
  player.vx,player.vy = player:getLinearVelocity()
  --управление спрайтом персонажа
  spriteOritentation(player_sprite)
  --управление спрайтами и передвижением врагов
  for i=1,enemies_count do
      enemySpriteOrientation (enemies[i])
      if enemies[i].type==1 then
        enemyWalk (enemies[i])
      --  print(i,enemies_count)
      end
      -- print(enemies[i].A_pos)
  end

  --упал в пустоту?
  if bott_y(player)>=(level.height-0.1)*level.block_size then
    player_death()
  end
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

  for i=1,enemies_count do
    print(i,enemies[i].A_pos)
    physics.removeBody(enemies[i].rect)
      display.remove(enemies[i].rect)
      display.remove(enemies[i].sprite)

      --table.remove(enemies[i])
  end

    level.map,enemies,enemies_count = rebuildmap(level,enemies)
end

--управение
local up_flag = false
local down_flag = false
local left_flag = false
local rigth_flag = false

local walkspeed = 200
local jampspeed = 250


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
