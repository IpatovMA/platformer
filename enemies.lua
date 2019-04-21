
--статы мобов
local enemies_start_pos={
[1]={x=8,y=12 ,type=1,A=5,B=12},
[2]={x=35,y=13,type=1,A=31,B=42},
[3]={x=7,y=15,type=1,A=3,B=13},
[4]={x=23,y=15,type=1,A=20,B=28}
}

enemy_options={
[1]={
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
local enemies_count=#enemies_start_pos


--спавнить одного
function enemySpawn (start_pos,level)
    local enemy = {}
  for key, value in pairs(enemy_options[start_pos.type]) do
    enemy[key]=value
  end

  enemy.scaling=enemy.height/enemy.sprite_options.height*enemy.scaling_fix
  enemy.rect = display.newRect((start_pos.x-0.5)*level.block_size,(start_pos.y-0.5)*level.block_size,enemy.width,enemy.height)
  enemy.sprite= display.newSprite(enemy.sprite_sheet, enemy.sequence)
--  enemy.sprite:setSequence("walk")
  enemy.sprite.yScale = enemy.scaling
  enemy.sprite.xScale = enemy.scaling
  enemy.sprite.x=(start_pos.x-0.5)*level.block_size
  enemy.sprite.y=(start_pos.y-0.5)*level.block_size+enemy.y_fix
  enemy.sprite:play()
  enemy.rect.alpha=0
  physics.addBody(enemy.rect,"dynamic",{density=3.0,bounce = 0.5,friction = 1.0})
  enemy.rect.isFixedRotation = true
  camera:add(enemy.rect,1)
  camera:add(enemy.sprite,1)
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

--передвижение мобов
function enemySpriteOrientation (enemy)
  enemy.vx,enemy.vy=enemy.rect:getLinearVelocity()

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
