require("animation")
require("enemies")
--координаты
--x
right_x = function (obj)
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
function mapbild (level)

    local x = -level.block_size/2
    local y = -level.block_size/2
    local coinScaling = level.block_size/coin_sprite_options.height*0.9
    local lavaScaling = level.block_size/lava_sprite_options.height

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
          map[i][j].rect:setSequence("rotate")
          map[i][j].rect.yScale = coinScaling
          map[i][j].rect.xScale = coinScaling
          map[i][j].rect.x=j*level.block_size+x
          map[i][j].rect.y=i*level.block_size+y
          map[i][j].rect:play()
          -- map[i][j].rect.id = "gold"
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

      camera:add(map[i][j].rect,1)
    end
  end
  local border = {
    left =display.newRect(1,level.height*level.block_size/2,10,level.height*level.block_size),
    top =display.newRect(level.width*level.block_size/2,1,level.width*level.block_size,10),
    right =display.newRect(level.width*level.block_size,level.height*level.block_size/2,10,level.height*level.block_size),
    bott =display.newRect(level.width*level.block_size/2,level.height*level.block_size,level.width*level.block_size,10),
  }
  for side, rect in pairs(border)do
    physics.addBody(border[side],"static")
    border[side].alpha = 0
    camera:add(border[side],1)
  end


  return map,border
end

function rebuildmap (level)
  local x = -level.block_size/2
  local y = -level.block_size/2
  for i=1,level.height do
    for j=1,level.width do
      if level.mapdata[i][j] == "G" and level.map[i][j].id ~="gold" then
      level.map[i][j].id = "gold"
       level.map[i][j].rect.alpha = 1
       end

    end
    end


    return level.map
    end
