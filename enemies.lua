local math = require("math")
--статы мобов
local enemies_start_pos={
{x=6,y=15 ,type=1,A=5,B=12}
-- ,{x=35,y=13,type=1,A=31,B=42}
,{x=18,y=12,type=2,t1=1,t2=3}
-- ,{x=23,y=15,type=1,A=20,B=28}
}

enemy_options={
[1]={
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
},
[2]={
    type=2,
    file="stone_monster.png",
    sprite_options=monster2_sprite_options,
    sprite_sheet = monster2_sprite_sheet,
    sequence=sequences_monster2,
    height = 60,
    width = 65,
    throw_flag=true,
    scaling_fix=1.3,
    y_fix=-5
}
}
local enemies_count=#enemies_start_pos


--спавнить одного
function enemySpawn (start_pos,level)
    local enemy = {}
  for key, value in pairs(enemy_options[start_pos.type]) do
    enemy[key]=value
  end

  enemy.scaling=enemy.height/enemy.sprite_options.height*enemy.scaling_fix
  enemy.rect = display.newRect((start_pos.x-0.5)*level.block_size,(start_pos.y-0.5)*level.block_size,enemy.width,enemy.height)
  enemy.rect.sprite= display.newSprite(enemy.sprite_sheet, enemy.sequence)
--  enemy.sprite:setSequence("walk")
  enemy.rect.sprite.yScale = enemy.scaling
  enemy.rect.sprite.xScale = enemy.scaling
  enemy.rect.sprite.x=(start_pos.x-0.5)*level.block_size
  enemy.rect.sprite.y=(start_pos.y-0.5)*level.block_size+enemy.y_fix
  enemy.rect.sprite:play()
  enemy.rect.alpha=0
  physics.addBody(enemy.rect,"dynamic",{density=3.0,bounce = 1,friction =0.0})
  enemy.rect.isFixedRotation = true
  enemy.rect.id = "enemy"
  enemy.rect.num = 1
  camera:add(enemy.rect,1)
  camera:add(enemy.rect.sprite,1)
  if enemy.type==1 then
     enemy.A = (start_pos.A+0.5)*level.block_size
     enemy.B = (start_pos.B-0.5)*level.block_size
  end
  if enemy.type==2 then
    enemy.t1 = start_pos.t1
    enemy.t2 = start_pos.t2
    enemy.time_throw = 0
    enemy.time_before_throw = math.random(enemy.t1,enemy.t2)*100
  end
  return enemy
end


--спавнить всех
function spawnthemall (level)
  local enemies = {}

  for i=1,enemies_count do
      enemies[i]=enemySpawn(enemies_start_pos[i],level)
    end
  return enemies
end

--диспавнить одного
function enemyKill (enemy)
    display.remove(enemy.sprite)
  display.remove(enemy)


  -- --костыль
  -- table.remove(enemy)
end
--убить всех мобов
function killallenemies (enemies)
  for i , enemy in ipairs(enemies) do
       enemyKill(enemy.rect)
  end
end

--передвижение мобов
function enemySpriteOrientation (enemy)
  -- if enemy.rect then
  --   print(enemy.rect.id)
  enemy.vx,enemy.vy=enemy.rect:getLinearVelocity()

  if enemy.vx > 0  then
        enemy.rect.sprite.xScale = -enemy.scaling
      end
  if enemy.vx < 0  then
        enemy.rect.sprite.xScale = enemy.scaling
    end
    -- if onGround(enemy.rect) then
          enemy.rect.sprite:play()
    -- else enemy.sprite:pause() end
  enemy.rect.sprite.x = enemy.rect.x
  enemy.rect.sprite.y = enemy.rect.y+enemy.y_fix

-- else   table.remove(enemy)
--   print("logging")
-- end
end

function enemyWalk (enemy)

  if left_x(enemy.rect)<=enemy.A then
     enemy.A_pos_flag = false
     enemy.B_pos_flag = true
  end
  if right_x(enemy.rect)>=enemy.B then
     enemy.A_pos_flag = true
     enemy.B_pos_flag = false
  end

  if left_x(enemy.rect)>enemy.A and enemy.A_pos_flag then
      enemy.rect:setLinearVelocity(-enemy.speed,enemy.vy)
  end
  if right_x(enemy.rect)<enemy.B and enemy.B_pos_flag then
      enemy.rect:setLinearVelocity(enemy.speed,enemy.vy)
  end
end

function stoneCreate (x,y)
  local stone = display.newSprite(stoneball_sprite_sheet, sequences_stoneball)
  stone:play()
  camera:add(stone,1)
  local scaling = 0.5
  stone.xScale = scaling
  stone.yScale = scaling
  stone.height = (stone.height-10)*scaling
  stone.width = (stone.width-4)*scaling
    physics.addBody(stone, "dynamic",{radius=15,density=5.0})
    stone.isFixedRotation= true
    stone.x = x
    stone.y= y
    stone.id="stone"
    return stone
end

function stoneDestroy (stone)
  display.remove(stone)
end


function enemyThrow (enemy,player,stones)

  local stone = stoneCreate(enemy.rect.x,top_y(enemy.rect))

  local t = 2
  local vxfix =1.3
  local vyfix = 1.9
  -- if math.abs(player.x-enemies[i].rect.x)<
  local vx = (player.x-enemy.rect.x)/t*vxfix
  local vy = ((player.y-top_y(enemy.rect)*vyfix)/t+grav*t*t/2)
  -- local m = enemy.rect.mass
 stone:setLinearVelocity(vx,vy)
 -- stone:applyLinearImpulse(vx*m,vy*m,stone.x,stone.y)
  enemy.throw_flag=false

end

function enemyTimebeforeThrow (enemy)
  -- print(enemy.throw_flag,sec,enemy.time_throw,enemy.time_before_throw)
  if not(enemy.throw_flag) and (sec - enemy.time_throw > enemy.time_before_throw ) then

      enemy.time_throw = sec
      enemy.time_before_throw = math.random(enemy.t1,enemy.t2)*100
      enemy.throw_flag = true
  end
end
