-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
perspective = require("perspective")
camera = perspective.createView()
display.setStatusBar( display.HiddenStatusBar )
system.activate( "multitouch" )

local math = require("math")
math.randomseed(os.time())

local physics = require("physics")
physics.start()
physics.setGravity(0,9.8)
grav =9.8
require("mapbuild")
require("animation")
require("enemies")

local uiGroop = display.newGroup()



--массив с врагами

 local enemies = {}
 local stoneTable = {}

--построение карты

 local level = {
  fileName = 'map.txt',
  block_size=50,
  width = 50,
  height = 25,
}

level.mapdata = mapread (level)
level.map,level.border = mapbild (level)

--спаун мобов
local enemies = spawnthemall(level) --массив врагов


--бэкграунд
local backgroundImage = {
  fileName="background.png",
  height=2400,
  width=3400
}

makeBackground(backgroundImage,level)

--таймер
sec = 0
level.time = display.newText(sec/100, display.contentCenterX, 20, native.systemFont, 40 )
 level.time:setFillColor(math.random(),math.random(),math.random())
 level.time.align = "center"
local timer_show = function()
  sec = sec + 1
   level.time.text = sec/100
end

--пресонаж

local player_options = {
  -- id="player",
  start_x= 100,
  start_y = display.contentCenterY*1.3,
  width =32,
  height = 64,
  vx=0,
  vy=0,
  key_flag = false
}

local player = display.newRect(player_options.start_x,player_options.start_y,player_options.width,player_options.height)
player.alpha = 0
camera:add(player, 1)
physics.addBody(player,"dynamic",{density=3.0,bounce = 0,friction = 1.0})
player.isFixedRotation = true
player.id="player"

--золото счетчик
local gold = {count = 0}
  gold.show = display.newText( gold.count, display.contentCenterX + display.actualContentWidth/2.4, 30, native.systemFont, 40)
  gold.show:setFillColor(1,1,0)
  gold.sprite = display.newSprite( coin_sprite_sheet, sequences_coin )
  gold.sprite:setSequence("shine")
  gold.sprite.yScale = 0.13
  gold.sprite.xScale = 0.13
  gold.sprite.x=display.contentCenterX + display.actualContentWidth/2.2
  gold.sprite.y=30
  gold.sprite:play()

--индикатор ключа
local keypic = display.newImageRect( "key.png",level.block_size*0.7,level.block_size*0.7)
keypic.x=display.contentCenterX + display.actualContentWidth/2.2
keypic.y=80
function keyShow (flag)
  if flag then
    keypic.alpha = 1
  else keypic.alpha = 0
  end
end

--  --спрайт
local player_sprite = display.newSprite( knight_sprite_sheet, sequences_knight )
  local spriteScale =player_options.height/(50)
  local knight_yfix=-3
  player_sprite.yScale = spriteScale
  player_sprite.xScale = spriteScale
  camera:add(player_sprite, 1)


local function spriteOritentation(player_sprite)

      if onGround(player) then
  if player.vx==0  then
    if player_sprite.sequence ~= "idle" then
    player_sprite:setSequence("idle")
    player_sprite:play()
      end
  elseif player_sprite.sequence ~= "run" then
    player_sprite:setSequence("run")
    player_sprite:play()
      end
    else
      if player_sprite.sequence ~= "jump" then
      player_sprite:setSequence("jump")
      player_sprite:play()
    end
    end

    if player.vx > 0  then
          player_sprite.xScale =spriteScale
        end
    if player.vx < 0  then
          player_sprite.xScale = -spriteScale
      end

  --привязка спрайта персонажа
  player_sprite.x=player.x
  player_sprite.y=player.y+knight_yfix
end
      player_sprite:play()

--камера
camera:setFocus(player)
camera:track()
camera:setBounds(display.contentCenterX, level.width*level.block_size - display.contentCenterX, display.contentCenterY, display.contentCenterY)


--детекторы касаний
function onGround (obj)
  local i=math.ceil((bott_y(obj)+1)/level.block_size)
  for j=(math.ceil((left_x(obj))/level.block_size)),(math.ceil((right_x(obj))/level.block_size)) do
   if level.map[i][j].id=="block" then
     return true
   end
  end
  return false
--  return true
end

local function inLava (obj)
  local i=math.ceil((bott_y(obj)+1)/level.block_size)
  for j=(math.ceil((left_x(obj))/level.block_size)),(math.ceil((right_x(obj))/level.block_size)) do
   if level.map[i][j].id=="lava" then
     return true
   end
  end
  return false
end

local function catchItem (obj)
  for i = math.ceil((top_y(obj)-1)/level.block_size),math.ceil((bott_y(obj)+1)/level.block_size) do
    for j=(math.ceil((left_x(obj)-1)/level.block_size)),(math.ceil((right_x(obj)+1)/level.block_size)) do
     if level.map[i][j].id=="gold" then
       level.map[i][j].id="air"
       level.map[i][j].rect.alpha = 0
       gold.count=gold.count+1
       gold.show.text=gold.count
     end
     if level.map[i][j].id=="key" then
       level.map[i][j].id="air"
       level.map[i][j].rect.alpha = 0
       player.key_flag = true
     end
    end
  end
  return false
end



--смерть персонажа, перезагрузка уровня
function player_death ()
  player.x = player_options.start_x
  player.y = player_options.start_y
  player:setLinearVelocity(0)
  sec=0
  gold.count=0
  gold.show.text=gold.count
  player.key_flag = false

  killallenemies (enemies)

    level.map,enemies = rebuildmap(level)
     enemies = spawnthemall(level) --массив врагов
  destroyAllStones(stoneTable)
end

--управение
local up_flag = false
local down_flag = false
local left_flag = false
local right_flag = false

local walkspeed = 200
local jampspeed = 300


local function walkplayer ()
    -- print(up_flag,right_flag,onGround(player),player.vy )
  -- if not(onGround(player)) then
 --      player:applyLinearImpulse(0,0.9,player.x,player.y)
 --  end

 --  if player.vy and player.vy ~=0 then
 --
 -- end
 if (right_flag) then
   if not(onGround(player)) then
     local vy = player.vy

     player:setLinearVelocity(walkspeed/1.3, vy-0.0001*grav)
   else player:setLinearVelocity(walkspeed, player.vy )
   end
 end
 if (left_flag) then
   if not(onGround(player)) then
     local vy = player.vy

     player:setLinearVelocity(-walkspeed/1.3,vy-0.0001*grav )
   else player:setLinearVelocity(-walkspeed, player.vy )end
 end
 if up_flag and (onGround(player)) then
  player:setLinearVelocity(player.vx/1.3, -jampspeed )
 end
 if (down_flag) then
   player_death ()
 end


  -- --убираем скольжение
  --  if not(left_flag) and player.vx and player.vx<0 and (onGround(player)) then
  --    player:setLinearVelocity(0,player.vy)
  --    print("(l)")
  --  end
  --  if not(right_flag) and player.vx and player.vx>0 and (onGround(player)) then
  --    player:setLinearVelocity(0,player.vy)
  --    print("(r)")
  --  end
  --  print((right_flag))
  --  if not(right_flag) and not(left_flag) and not(up_flag) then
  --     player:setLinearVelocity(0)
  --  end
end
--управеление с клавиатруы
local function keyboardcontrol(event)
 if (event.keyName == 'd' and event.phase == 'down') then
   right_flag=true
 else right_flag=false
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

local function onGlobalCollision( event )
    --   print( event.object1.id )       --the first object in the collision
      -- print( event.object2.id )
  if event.object1.id== "enemy" and event.object2.id=="player" then
    if bott_y(event.object2)-10>top_y(event.object1) then
    timer.performWithDelay( 1, player_death ,1 )
    else
      -- timer.performWithDelay( 1, enemyKill(event.other) ,1 )
     event.object1.sprite:setFillColor(1,0,0,0.3)
     event.object1.id= "none"
      end
  end
  --прыжок на монстра
  if event.object2.id== "enemy" and event.object1.id=="player" then
    if bott_y(event.object1)-10>top_y(event.object2) then
    timer.performWithDelay( 1, player_death ,1 )
    else
      -- timer.performWithDelay( 1, enemyKill(event.other) ,1 )
     event.object2.sprite:setFillColor(1,0,0,0.3)
     event.object2.id= "none"
      end
  end
  --камень попадает в игрока
  if event.object2.id== "stone" and event.object1.id=="player" then
    timer.performWithDelay( 1, player_death ,1 )
    timer.performWithDelay( 1, stoneDestroy(event.object2) ,1 )
  end
  -- камень падает на землю
  if event.object1.id~= "player" and event.object1.id~= "enemy"  and event.object2.id=="stone" then
    timer.performWithDelay( 1, stoneDestroy(event.object2) ,1 )
  end
end
Runtime:addEventListener( "collision", onGlobalCollision )


--управление на экране
local Ui = {}
local button_size = 180
for i =1, 6 do
  Ui[i]= display.newImageRect(buttons_sheet, i , button_size, button_size)
  Ui[i].x=display.contentCenterX+Ui[i].width*((i-1)%3 - 1)
  Ui[i].y=display.contentCenterY*2.1-Ui[i].height + Ui[i].height*math.floor((i-1)/3)
  Ui[i].alpha = 0.7
  Ui[i].id=i
end

local function touchUi(event)
  print(left_flag,up_flag,right_flag)
  -- print(event.x,event.y)
  for i=1,6 do
    -- if event.x>left_x(Ui[i]) and event.x<right_x(Ui[i]) and event.y>top_y(Ui[i]) and event.y<bott_y(Ui[i]) then
    if inarea(event,Ui[i]) then
      -- print(i)
      if i <=3 and (event.phase == "began" or event.phase == "moved")then
        up_flag = true
      else
          up_flag = false
        end
      if (i == 1 or i==4) and (event.phase == "began" or event.phase == "moved")then
        left_flag = true
      else
          left_flag = false
      end
      if (i == 3 or i == 6)and (event.phase == "began" or event.phase == "moved") then
        right_flag = true
        else
          right_flag = false
        end
      if i == 5 then
        --пока пусто
        else  --и тут
      end
    Ui[i]:setFillColor(0.93, 0.56, 0.56, 0.5)
  else
    Ui[i]:setFillColor(1,1,1)
  end
  if event.phase == "ended" or event.phase == "canceled" then
        Ui[i]:setFillColor(1,1,1)
  end
  end
end

Runtime:addEventListener( "touch", touchUi )
--проверка в реальном времени.
local function gameLoop ()

  --таймер
  timer_show()
  --отображение индикатора ключа
  keyShow(player.key_flag)
  --упал в лаву?
  if inLava(player) then
    player_death()
  end
  --взял монету или ключ?
  catchItem(player)
  --скорость персонажа
  player.vx,player.vy = player:getLinearVelocity()
  --управление спрайтом персонажа
  spriteOritentation(player_sprite)
  --управление спрайтами и передвижением врагов и камнями
  for i=1,#enemies do
      enemySpriteOrientation (enemies[i])
      if enemies[i].type==1 then
        enemyWalk (enemies[i])
      end
      if enemies[i].type==2 then
        if math.abs(player.x-enemies[i].rect.x)<display.actualContentWidth then
          enemyTimebeforeThrow (enemies[i])
          if enemies[i].throw_flag then
          enemyThrow(enemies[i],player,stoneTable)

        end
      end
      end
  end

walkplayer()

  --упал в пустоту?
  if bott_y(player)>=(level.height-0.2)*level.block_size then
    player_death()
  end

end

gameLoopTimer = timer.performWithDelay( 1, gameLoop, 0 )
