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
function mapread (fileName,map_width,map_height)
  local filePath = system.pathForFile(fileName)
  local file = io.open(filePath, "r")
  local mapdata = {}

   for  i=1,map_height do
    mapdata[i]={}
    local line = file:read("*l")
      for j=1,map_width do
        mapdata[i][j]=string.match(line, "%a", j)

      end
  end

  io.close( file )
  print(mapdata[1][1])
  return mapdata
end
function mapbild (mapdata,block_size,map_width,map_height)

    local x = -block_size/2
    local y = -block_size/2
    local map = {}
  for i=1,map_height do
    map[i] = {}
    for j=1,map_width do
      --пустые блоки
      if mapdata[i][j] == "z" then
        map[i][j] = {
          rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
          id = "air"
        }
        map[i][j].rect.alpha = 0
        camera:add(map[i][j].rect,1)
      end
      --твердые блоки
      if mapdata[i][j] == "B" then
        map[i][j] = {
          rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
          id = "block"
        }
        map[i][j].rect:setFillColor(0.37, 0.56, 0.58)
        physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
        camera:add(map[i][j].rect,1)
      end
      --голда
      if mapdata[i][j] == "G" then
        map[i][j] = {
          rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
          id = "gold"
        }
        map[i][j].rect:setFillColor(1,1,0)
        --physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
        camera:add(map[i][j].rect,1)
      end
      --шипы, чтобы протестить умирание персонажа
      if mapdata[i][j] == "A" then
        map[i][j] = {
          rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
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

function rebuildmap (mapdata,map,map_width,map_height)
--  local x = -block_size/2
--  local y = -block_size/2



  for i=1,map_height do

    for j=1,map_width do
      if mapdata[i][j] == "G" and map[i][j].id ~="gold" then
        -- map[i][j] = {
        --   rect=display.newRect(j*block_size+x,i*block_size+y,block_size,block_size),
        --   id = "gold"
        -- }
      map[i][j].id = "gold"
       map[i][j].rect.alpha = 1
    --    map[i][j].rect:setFillColor(1,1,0)
    --    physics.addBody(map[i][j].rect,"static",{bounce = 0,friction = 1.0})
    --    camera:add(map[i][j].rect,1)
      end
    end
    end
    return map
    end
--связка двух карт в одну, у второй приоритет
function mapConnect (map1,map2,block_size,map_width,map_height)
  for i=1,map_height do
    for j=1,map_width do
      if map2[i][j].rect then
        -- if map1[i][j]~=map2[i][j]then
      --  physics.removeBody(map1[i][j].rect)
        display.remove(map1[i][j].rect)
        map1[i][j]=map2[i][j]
      --  physics.addBody(map1[i][j].rect,"static",{bounce = 0,friction = 1.0})
        print(i,j)
      -- end
    end
    end
    end
    return map1
end
