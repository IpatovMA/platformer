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
function mapbild (level)

    local x = -level.block_size/2
    local y = -level.block_size/2
    local map = {}
  for i=1,level.height do
    map[i] = {}
    for j=1,level.width do
      --пустые блоки
      if level.mapdata[i][j] == "z" then
        map[i][j] = {
          rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
          id = "air"
        }
        map[i][j].rect.alpha = 0
        camera:add(map[i][j].rect,1)
      end
      --твердые блоки
      if level.mapdata[i][j] == "B" then
        map[i][j] = {
          rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
          id = "block"
        }
        map[i][j].rect:setFillColor(0.37, 0.56, 0.58)
        physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
        camera:add(map[i][j].rect,1)
      end
      --голда
      if level.mapdata[i][j] == "G" then
        map[i][j] = {
          rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
          id = "gold"
        }
        map[i][j].rect:setFillColor(1,1,0)
        camera:add(map[i][j].rect,1)
      end
      --шипы, чтобы протестить умирание персонажа
      if level.mapdata[i][j] == "A" then
        map[i][j] = {
          rect=display.newRect(j*level.block_size+x,i*level.block_size+y,level.block_size,level.block_size),
          id = "spike"
        }
        map[i][j].rect:setFillColor(1)
        physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
        camera:add(map[i][j].rect,1)
      end
    end
  end
  return map
end

function rebuildmap (level)

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
-- --связка двух карт в одну, у второй приоритет
-- function mapConnect (map1,map2,level.block_size,level.width,level.height)
--   for i=1,level.height do
--     for j=1,level.width do
--       if map2[i][j].rect then
--         -- if map1[i][j]~=map2[i][j]then
--       --  physics.removeBody(map1[i][j].rect)
--         display.remove(map1[i][j].rect)
--         map1[i][j]=map2[i][j]
--       --  physics.addBody(map1[i][j].rect,"static",{bounce = 0,friction = 1.0})
--         print(i,j)
--       -- end
--     end
--     end
--     end
--     return map1
-- end
