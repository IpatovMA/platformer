
--статы мобов
local enemies_start_pos={
{x=8,y=12 ,type=1,A=5,B=12}
-- ,{x=35,y=13,type=1,A=31,B=42}
-- ,{x=7,y=15,type=1,A=3,B=3}
-- ,{x=23,y=15,type=1,A=20,B=28}
}

enemy_options={
[1]={
    name='monster',
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
  if rigth_x(enemy.rect)>=enemy.B then
     enemy.A_pos_flag = true
     enemy.B_pos_flag = false
  end

  if left_x(enemy.rect)>enemy.A and enemy.A_pos_flag then
      enemy.rect:setLinearVelocity(-enemy.speed,enemy.vy)
  end
  if rigth_x(enemy.rect)<enemy.B and enemy.B_pos_flag then
      enemy.rect:setLinearVelocity(enemy.speed,enemy.vy)
  end
end
