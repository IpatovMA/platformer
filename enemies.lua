-- type1_AB_pos = {
-- [1]={A=6,B=12},
-- [2]={A=31,B=42},
-- [3]={A=5,B=13},
-- [4]= {A=20,B=28}
-- }


local enemies_start_pos={
[1]={x=8,y=11 ,type=1,A=6,B=12},
[2]={x=35,y=12,type=1,A=31,B=42},
[3]={x=7,y=14,type=1,A=5,B=13},
[4]={x=23,y=14,type=1,A=20,B=28}

}
local enemies_count=#enemies_start_pos

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

function enemySpawn (start_pos,level)
    local enemy = {}
  for key, value in pairs(enemy_options[start_pos.type]) do
    enemy[key]=value
  --  print(key,value)
  end
  for key, value in pairs(enemy) do
    print(key,value)
  end

  enemy.scaling=enemy.height/enemy.sprite_options.height*enemy.scaling_fix
  enemy.rect = display.newRect(start_pos.x*level.block_size,start_pos.y*level.block_size,enemy.width,enemy.height)
  enemy.sprite= display.newSprite(enemy.sprite_sheet, enemy.sequence)
--  enemy.sprite:setSequence("walk")
  enemy.sprite.yScale = enemy.scaling
  enemy.sprite.xScale = enemy.scaling
  enemy.sprite.x=start_pos.x*level.block_size
  enemy.sprite.y=start_pos.y*level.block_size+enemy.y_fix
  enemy.sprite:play()
  enemy.rect.alpha=1
  physics.addBody(enemy.rect,"dynamic",{density=3.0,bounce = 0.5,friction = 1.0})
  enemy.rect.isFixedRotation = true
  camera:add(enemy.rect,1)
  camera:add(enemy.sprite,1)
  if enemy.type==1 then
     enemy.A = (start_pos.A+0.5)*level.block_size
     enemy.B = (start_pos.B-0.5)*level.block_size
  end
  --enemy.A_pos = x
  -- print(enemy.A_pos)
    -- print(m,enemies[m].rect.x)

  return enemy
end

-- function setABpositions (enemy)
--   local i = 1
-- for l=1,enemies_count do
--   if enemy.type==1 then
--      enemy.A = (type1_AB_pos[i].A+0.5)*level.block_size
--      enemy.B = (type1_AB_pos[i].B-0.5)*level.block_size
--       -- print(i,enemies[i].A)
--      i=i+1
--   end
-- end
-- end

function spawnthemall (level)
  local enemies = {}
  for i=1,enemies_count do
  --  enemies[i] =enemy_options[enemies_start_pos[i].type]

  end
  -- for i=1,enemies_count do
  --     print(i,enemies[i].name)
  -- end
  for i=1,enemies_count do
      enemies[i]=enemySpawn(enemies_start_pos[i],level)

    -- for m=1,i do
    --     print(i,m,enemies[m].rect.x)
    -- end
    -- print(i,enemies[i].rect.x)
  --   enemies[i] ={
  --       name='green_monster',
  --       type=1,
  --       file="green_monster.png",
  --       sprite_options=monster1_sprite_options,
  --       sprite_sheet = monster1_sprite_sheet,
  --       sequence=sequences_monster1,
  --       speed = 100,
  --       height = 60,
  --       width = 50,
  --       scaling_fix=1.5,
  --       y_fix=-5,
  --       A_pos_flag=false,
  --       B_pos_flag=true
  --   }
  --
  --
  --   enemies[i].scaling=enemies[i].height/enemies[i].sprite_options.height*enemies[i].scaling_fix
  --   enemies[i].rect = display.newRect(enemies_start_pos[i].x*level.block_size,enemies_start_pos[i].y*level.block_size,enemies[i].width,enemies[i].height)
  --   enemies[i].sprite= display.newSprite(enemies[i].sprite_sheet, enemies[i].sequence)
  -- --  enemy.sprite:setSequence("walk")
  --   enemies[i].sprite.yScale = enemies[i].scaling
  --   enemies[i].sprite.xScale = enemies[i].scaling
  --   enemies[i].sprite.x=enemies_start_pos[i].x*level.block_size
  --   enemies[i].sprite.y=enemies_start_pos[i].y*level.block_size+enemies[i].y_fix
  --   enemies[i].sprite:play()
  --   enemies[i].rect.alpha=1
  --   physics.addBody(enemies[i].rect,"dynamic",{density=3.0,bounce = 0.5,friction = 1.0})
  --   enemies[i].rect.isFixedRotation = true
  --   camera:add(enemies[i].rect,1)
  --   camera:add(enemies[i].sprite,1)
  --   if enemies[i].type==1 then
  --      enemies[i].A = (enemies_start_pos[i].A+0.5)*level.block_size
  --      enemies[i].B = (enemies_start_pos[i].B-0.5)*level.block_size
    -- end


  end
  for i=1,enemies_count do
      print(i,enemies[i].rect.x)
  end
  -- setABpositions(enemies[i])
  return enemies
end
