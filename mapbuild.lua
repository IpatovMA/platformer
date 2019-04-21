require("animation")
--координаты
--x
rigth_x = function (obj)
  local x = obj.x + obj.width/2
  return x
end

 left_x = function (obj)
  local x = obj.x - obj.width/2
  return x
end
--y
top_y = function (obj)
  local y = obj.y - obj.height/2
  return y
end

bott_y = function (obj)
  local y = obj.y + obj.height/2
  return y
end
--сетка
-- for i=0,25 do
--   local x = display.newRect(i*50,display.contentCenterY,5,display.actualContentHeight)
--   camera:add(x,1)
--   x:setFillColor(0,0,1)
-- end
-- for i=0,display.actualContentHeight/50 do
--   local x = display.newRect(display.contentCenterX,i*50,5000,5)
--     camera:add(x,1)
--     x:setFillColor(0,0,1)
-- end

--построение карты
function mapread (level)
  local filePath = system.pathForFile(level.fileName)
  local file = io.open(filePath, "r")
  local mapdata = {}

   for  i=1,level.height do
    mapdata[i]={}
    local line = file:read("*l")
      for j=1,level.width do
        mapdata[i][j]=string.match(line, "%a", j)

      end
  end

  io.close( file )

  return mapdata
end
function mapbild (level,enemies)

    local x = -level.block_size/2
    local y = -level.block_size/2
    local coinScaling = level.block_size/coin_sprite_options.height*0.9
    local lavaScaling = level.block_size/lava_sprite_options.height
    local l = 0 -- счетчик врагов
    local map = {}
  for i=1,level.height do
    map[i] = {}
    for j=1,level.width do
      --пустые блоки
      if level.mapdata[i][j] ==  "z"then
        map[i][j] = {
          rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
          id = "air"
        }
        map[i][j].rect.alpha = 0

      end
      --твердые блоки
      if level.mapdata[i][j] == "B" then
        map[i][j] = {
          rect=display.newImageRect("blocktexture.png",level.block_size,level.block_size),
          id = "block"
        }
        map[i][j].rect.x=j*level.block_size+x
        map[i][j].rect.y=i*level.block_size+y
        physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})

      end
      --голда
      if level.mapdata[i][j] == "G" then
          map[i][j] = {
            --rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
            rect  = display.newSprite( coin_sprite_sheet, sequences_coin ),
            id = "gold"
          }
          map[i][j].rect:setSequence("shine")
          map[i][j].rect.yScale = coinScaling
          map[i][j].rect.xScale = coinScaling
          map[i][j].rect.x=j*level.block_size+x
          map[i][j].rect.y=i*level.block_size+y
          map[i][j].rect:play()
      end
      --лава
      if level.mapdata[i][j] == "L" then
        map[i][j] = {
        --  rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
          rect  = display.newSprite( lava_sprite_sheet, sequences_lava),
          id = "lava"
        }
        map[i][j].rect:setSequence("bul'k")
        map[i][j].rect.yScale = lavaScaling
        map[i][j].rect.xScale = lavaScaling
        map[i][j].rect.x=j*level.block_size+x
        map[i][j].rect.y=i*level.block_size+y
        map[i][j].rect:play()
        --physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
      end
      --монстер
      if level.mapdata[i][j] == "M" then
        map[i][j] = {
        rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
          --rect  = display.newSprite( lava_sprite_sheet, sequences_lava),
          id = "air"
        }
        map[i][j].rect.x=j*level.block_size+x
        map[i][j].rect.y=i*level.block_size+y
        map[i][j].rect.alpha = 0
        l=l+1--счетчик врагов+1
        enemies[l] = enemySpawn(map[i][j].rect.x,map[i][j].rect.y,1)
        -- print(l,enemies[l].A_pos,enemies[1].A_pos)
      end

      camera:add(map[i][j].rect,1)
    end
  end
  local border = {
    left =display.newRect(1,level.height*level.block_size/2,1,level.height*level.block_size),
    top =display.newRect(level.width*level.block_size/2,1,level.width*level.block_size,1),
    rigth =display.newRect(level.width*level.block_size,level.height*level.block_size/2,1,level.height*level.block_size),
    bott =display.newRect(level.width*level.block_size/2,level.height*level.block_size,level.width*level.block_size,1),
  }
  for side, rect in pairs(border)do
    physics.addBody(border[side],"static")
    border[side].alpha = 0
    camera:add(border[side],1)
  end
  return map,border,l
end

function rebuildmap (level,enemies)
  local x = -level.block_size/2
  local y = -level.block_size/2
  local l = 0 --счетчик врагов
  for i=1,level.height do

    for j=1,level.width do
      if level.mapdata[i][j] == "G" and level.map[i][j].id ~="gold" then
      level.map[i][j].id = "gold"
       level.map[i][j].rect.alpha = 1
       end
       if level.mapdata[i][j] == "M" then
         l=l+1--счетчик врагов+1
         enemies[l] = enemySpawn(j*level.block_size+x,i*level.block_size+y,1)
         -- print(l,enemies[l].A_pos,enemies[1].A_pos)
    end
    end
    end
    return level.map,enemies,l
    end

enemy_options={
    {
    name='green_monster',
    type=1,
    file="green_monster.png",
    sprite_options=monster1_sprite_options,
    sprite_sheet = monster1_sprite_sheet,
    sequence=sequences_monster1,
    speed = 100,
    height = 60,
    width = 50,
    scaling_fix=1.5,
    y_fix=-5,
    A_pos_flag=false,
    B_pos_flag=true
  }
}

function enemySpawn (x,y,type)

 local enemy=enemy_options[type]
  enemy.scaling=enemy.height/enemy.sprite_options.height*enemy.scaling_fix
  enemy.rect = display.newRect(x,y,enemy.width,enemy.height)
  enemy.sprite= display.newSprite(enemy.sprite_sheet, enemy.sequence)
--  enemy.sprite:setSequence("walk")
  enemy.sprite.yScale = enemy.scaling
  enemy.sprite.xScale = enemy.scaling
  enemy.sprite.x=x
  enemy.sprite.y=y+enemy.y_fix
  enemy.sprite:play()
  enemy.rect.alpha=1
  physics.addBody(enemy.rect,"dynamic",{density=3.0,bounce = 0.5,friction = 1.0})
  enemy.rect.isFixedRotation = true
  camera:add(enemy.rect,1)
  camera:add(enemy.sprite,1)
  enemy.A_pos = x
  print(enemy.A_pos)

  return enemy
end
