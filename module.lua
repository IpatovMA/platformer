--координаты разных точке объекта

rigth_top = function (obj)
  local x = obj.x + obj.width/2
  local y = obj.y - obj.height/2
  return x,y
end

 left_top = function (obj)
  local x = obj.x - obj.width/2
  local y = obj.y - obj.height/2
  return x,y
end

 rigth_bott = function (obj)
  local x = obj.x + obj.width/2
  local y = obj.y + obj.height/2
  return x,y
end

 left_bott = function (obj)
  local x = obj.x - obj.width/2
  local y = obj.y + obj.height/2
  return x,y
end
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
for i=0,25 do
  local x = display.newRect(i*50,display.contentCenterY,5,display.actualContentHeight)
  camera:add(x,1)
  x:setFillColor(0,0,1)

end
for i=0,display.actualContentHeight/50 do
  local x = display.newRect(display.contentCenterX,i*50,5000,5)
    camera:add(x,1)
    x:setFillColor(0,0,1)

end
