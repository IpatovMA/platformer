-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
perspective = require("perspective")
 Trajectory = require( "dmc_library.dmc_trajectory" )
camera = perspective.createView()
display.setStatusBar( display.HiddenStatusBar )
system.activate( "multitouch" )

local math = require("math")
math.randomseed(os.time())

local physics = require("physics")
physics.start()
physics.setGravity(0,15)
grav =15
require("mapbuild")
require("animation")
require("enemies")

-- startGameLoop()--старт отсчета игрового вермени

--массив с врагами

 local enemies = {}
 local stoneTable = {}

 local player_options = {
   width =32,
   height = 64,
   vx=0,
   vy=0,
   key_flag = false
 }
--построение карты

 local level = {
  fileName = 'map.txt',
  block_size=50,
  width = 50,
  height = 30,
}

level.mapdata = mapread (level)
level.map,level.border,player_options.start_x,player_options.start_y = mapbild (level)

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
-- level.time = display.newText(sec/100, display.contentCenterX, 20, native.systemFont, 40 )
--  level.time:setFillColor(math.random(),math.random(),math.random())
--  level.time.align = "center"
local timer_show = function()
  sec = sec + 1
   -- level.time.text = sec/100
end

--пресонаж
local player = display.newRect(player_options.start_x,player_options.start_y,player_options.width,player_options.height)
player.alpha =0
camera:add(player, 1)
physics.addBody(player,"dynamic",{density=3.0,bounce = 0,friction = 0.0})
player.isFixedRotation = true
player.id="player"

--  --спрайт персонажа
player.sprite = display.newSprite( knight_sprite_sheet, sequences_knight )
  local spriteScale =player_options.height/(level.block_size)
  player.sprite.anchorX=0.3
  player.sprite.anchorY=0.55
  player.sprite.yScale = spriteScale
  player.sprite.xScale = spriteScale
  camera:add(player.sprite, 1)


local function spriteOritentation(sprite)

      if onGround(player) then
  if player.vx==0  then
    if sprite.sequence ~= "idle" then
    sprite:setSequence("idle")
    sprite:play()
      end
  elseif sprite.sequence ~= "run" then
    sprite:setSequence("run")
    sprite:play()
      end
    else
      if sprite.sequence ~= "jump" then
      sprite:setSequence("jump")
      sprite:play()
    end
    end

    if player.vx > 0  then
          sprite.xScale =spriteScale
        end
    if player.vx < 0  then
          sprite.xScale = -spriteScale
      end

  --привязка спрайта персонажа
  sprite.x=player.x
  sprite.y=player.y
end
      player.sprite:play()

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

  --действие -открытие двери-
   -- кнопка перезагразки после прохождения
    local  relaunchButton = display.newText("relaunch", display.contentCenterX, display.contentCenterY+150, native.systemFont, 80)
    relaunchButton.alpha = 0
    local relaunch_flag = false
    local relaunchTrue = function()
      relaunch_flag = true
      relaunchButton.alpha = 1
    end
     local stext= "locked"
    local screentext = display.newText(stext, display.contentCenterX, display.contentCenterY, native.systemFont, 130 )
        screentext.alpha = 0

  local function action ()
    local textdisappear = function()
      makeMoreAlpha(screentext)
    end
    local textremove = function()
      display.remove(obj)
    end
    local playerdisappear = function()
      makeMoreAlpha(player.sprite)
    end

    if inarea(player,level.map.door)then

      if not(level.map.door.open) and player.key_flag  then
          level.map.door:play()
          level.map.door.open = true
        elseif not(level.map.door.open) then
          stext = "locked"
              screentext:setFillColor(0.32, 0.01, 0.01)
          screentext.text = stext
            screentext.alpha = 1
          timer.performWithDelay( 100, textdisappear,10)
      else
        stext = "COMPLETE"
        screentext.text = stext
          screentext:setFillColor(0.63, 0.94, 0.77)
        screentext.alpha = 1
        timer.performWithDelay( 50, playerdisappear,10)
          timer.performWithDelay( 500, relaunchTrue,1)
        timer.pause(gameLoopTimer)

      end
    end
  end

local function player_death ()
  timer.pause(gameLoopTimer)
    stext= "YOU DIED"
    screentext:setFillColor(0.32, 0.01, 0.01)
    screentext.text = stext
    screentext.alpha = 1

    player.sprite:setSequence("death")
      player.sprite.anchorY=0.3
    player.sprite.anchorX=0.7
    player.sprite:play()
    player:setLinearVelocity(0)
    physics.addBody(player.sprite,{bounce=0.1,friction=10})
    player.sprite.isFixedRotation=true
    player.id = "dead"
    relaunchTrue()
end

--управение
local up_flag = false
  local down_flag = false
  local left_flag = false
  local right_flag = false

  local walkspeed = 200
  local jampspeed = 320
  local inAirWalk = 1


local function walkplayer ()
   local vy = player.vy

   if (right_flag) then
     if not(onGround(player)) then
       player:setLinearVelocity(walkspeed/inAirWalk, vy-0.0001*grav)
     else
       player.x=player.x+1 -- сдвинуть с места, потому что он застревает на стыках блоков, хз как так
       player:setLinearVelocity(walkspeed, player.vy )
     end
   end
   if (left_flag) then
     if not(onGround(player)) then
           player:setLinearVelocity(-walkspeed/inAirWalk,vy-0.0001*grav )
     else
       player.x=player.x-1-- сдвинуть с места, потому что он застревает на стыках блоков, хз как так
       player:setLinearVelocity(-walkspeed, player.vy )
     end
   end
   if up_flag and (onGround(player)) then
    player:setLinearVelocity(player.vx/inAirWalk, -jampspeed )
   end
   -- if (down_flag) then
   --   relaunch_level ()
   -- end


    -- --убираем скольжение
     if not(left_flag) and player.vx<0 and (onGround(player)) then
       player:setLinearVelocity(0,vy-0.0001*grav )
     end
     if not(right_flag) and player.vx>0 and (onGround(player)) then
       player:setLinearVelocity(0,vy-0.0001*grav )
     end
     if not(right_flag) and not(left_flag) and not(up_flag)  then
        player:setLinearVelocity(0,vy-0.0001*grav )
     end
     -- -- своя графитация
     -- if not(onGround(player)) then
     --    player:setLinearVelocity(player.vx,vy-0.0001*grav )
     -- end
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
   if (event.keyName == 'f' and event.phase == 'down') then
     action()
   end
  end

  Runtime:addEventListener("key", keyboardcontrol)

local function onGlobalCollision( event )
    -- print(event.object1.id, event.object2.id)
    if event.object1.id== "enemy" and event.object2.id=="player" then
      if bott_y(event.object2)-10>top_y(event.object1) then
      timer.performWithDelay( 1, player_death ,1 )
      else
        timer.performWithDelay( 1, enemyKill(event.object1,enemies) ,1 )
       -- event.object1.sprite:setFillColor(1,0,0,0.3)
       -- event.object1.id= "none"
        end
      end
      --    прыжок на монстра
    if event.object2.id== "enemy" and event.object1.id=="player" then
      if bott_y(event.object1)-10>top_y(event.object2) then
      timer.performWithDelay( 1, player_death ,1 )
      else
        timer.performWithDelay( 1, enemyKill(event.object2,enemies) ,1 )
       -- event.object2.sprite:setFillColor(1,0,0,0.3)
       -- event.object2.id= "none"
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
    if event.object2.id== "player" and event.object1.id=="lava" then
      timer.performWithDelay( 1, player_death ,1 )

    end

  end
  Runtime:addEventListener( "collision", onGlobalCollision )

--управление на экране
local Ui = {}

local button_size = 180
  for i =1, 6 do
    Ui[i]= display.newImageRect(buttons_sheet, i , button_size, button_size)
    Ui[i].x=display.contentCenterX+Ui[i].width*((i-1)%3 - 1)
    Ui[i].y=display.actualContentHeight+ Ui[i].height*(math.floor((i-1)/3)-1.6)
    Ui[i].alpha = 0.7
    Ui[i].id=i
  end

local function touchUi(event)
    for i=1,6 do
      if inarea(event,Ui[i]) then
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
             action()
        end
      Ui[i]:setFillColor(0.93, 0.56, 0.56, 0.5)
      else
        Ui[i]:setFillColor(1,1,1)
      end
      if event.phase == "ended" or event.phase == "canceled" then
            Ui[i]:setFillColor(1,1,1)
             up_flag = false
               left_flag = false
               right_flag = false
      end
    end


    if  relaunch_flag and inarea(event,relaunchButton) then
      relaunch_level()
    end
  end
Runtime:addEventListener( "touch", touchUi )



--проверка в реальном времени.
local function gameLoop ()
  --таймер
  timer_show()
  --отображение индикатора ключа
  keyShow(player.key_flag)

  --взял монету или ключ?
  catchItem(player)
  --скорость персонажа
  player.vx,player.vy = player:getLinearVelocity()
  --управление спрайтом персонажа
  spriteOritentation(player.sprite)
  --управление спрайтами и передвижением врагов и камнями
  for i=1,#enemies do
    if enemies[i].rect.sprite then
      enemySpriteOrientation (enemies[i])
      if enemies[i].type==1 then
        enemyWalk (enemies[i])
      end
      if enemies[i].type==2 then
        if math.abs(player.x-enemies[i].rect.x)<display.actualContentWidth then
          enemyTimebeforeThrow (enemies[i])
          if enemies[i].throw_flag then
            -- кидает камень и ориентирует спрайт
        enemyThrow(enemies[i],player,stoneTable)

        end
      end
      end
    end
  end

  if not(relaunch_flag) and relaunchButton.alpha == 1 then
    relaunchButton.alpha = 0
  end

  walkplayer()

  --упал в пустоту?
  if bott_y(player)>=(level.height-0.2)*level.block_size then
      player_death()
    end

end

  gameLoopTimer = timer.performWithDelay( 1, gameLoop, 0 )

-- перезагрузка уровня
function relaunch_level ()
  player.x = player_options.start_x
  player.y = player_options.start_y
  physics.removeBody(player.sprite)
  player.id = "player"
  player.sprite.alpha = 1
  player.sprite.anchorY=0.5
  player.sprite.anchorX=0.3
  sec=0
  gold.count=0
  gold.show.text=gold.count
  player.key_flag = false
  relaunch_flag= false
  screentext.alpha = 0
  killallenemies (enemies)

    level.map,enemies = rebuildmap(level)
     enemies = spawnthemall(level) --массив врагов
  destroyAllStones(stoneTable)
  timer.resume( gameLoopTimer )
end
