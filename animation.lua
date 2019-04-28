player_sprite_options =
{
    width = 36,
    height = 36,
    numFrames = 18
}

player_sprite_sheet = graphics.newImageSheet("playersprite.png",player_sprite_options)
sequences_player = {
   {
        name = "run",
        start = 7,
        count = 6,
        time = 600,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
      name = "idle",
      start = 1,
      count = 4,
      time = 1000,
      loopCount = 0,
      loopDirection = "forward"
    }
}


kinght_sprite_options =
{
    width = 94.4,
    height = 75.1,
    numFrames = 70
}

knight_sprite_sheet = graphics.newImageSheet("knight.png",kinght_sprite_options)
sequences_knight = {
   {
        name = "run",
        start = 60,
        count = 10,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
      name = "idle",
      start = 21,
      count = 10,

      time = 1500,
      loopCount = 0,
      loopDirection = "bounce"
    },
    {
         name = "jump",
         start = 30,
         count = 5,
         time = 600,
         loopCount = 1,
         loopDirection = "forward"
     }
}
coin_sprite_options =
{
    width = 256,
    height = 256,
    numFrames = 12
}

coin_sprite_sheet = graphics.newImageSheet("star-coin.png",coin_sprite_options)
sequences_coin= {
   {
        name = "rotate",
        start = 1,
        count = 6,
        time = 900,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
         name = "shine",
         start = 7,
         count = 6,
         time = 1000,
         loopCount = 0,
         loopDirection = "forward"
     }
  }

lava_sprite_options =
  {
      width = 32,
      height = 32,
      numFrames = 3
  }
lava_sprite_sheet = graphics.newImageSheet("lava.png",lava_sprite_options)
sequences_lava= {
     {
          name = "bul'k",
          start=1,
          count=3,
          time = 1500,
          loopCount = 0,
          loopDirection = "bounce"
      }
    }

monster1_sprite_options =
  {
      width = 451,
      height = 508,
      numFrames = 26
  }
monster1_sprite_sheet = graphics.newImageSheet("green_monster.png",monster1_sprite_options)
sequences_monster1= {
     {
          name = "walk",
          start = 1,
          count = 26,
          time = 800,
          loopCount = 0,
          loopDirection = "forward"
      }
    }

    monster2_sprite_options =
      {
          width = 543,
          height = 498,
          numFrames = 14
      }
monster2_sprite_sheet = graphics.newImageSheet("stone_monster.png",monster2_sprite_options)
sequences_monster2= {
     {
          name = "idle",
          start = 1,
          count = 14,
          time = 1000,
          loopCount = 0,
          loopDirection = "forward"
      }
    }

stoneball_sprite_options =
{
width = 72,
height = 72,
numFrames = 19
}
stoneball_sprite_sheet = graphics.newImageSheet("stoneball.png",stoneball_sprite_options)
sequences_stoneball= {
{
    name = "rotate",
    start = 1,
    count = 19,
    time = 800,
    loopCount = 0,
    loopDirection = "forward"
}
}

buttons_options =
{
width = 200,
height = 200,
numFrames = 6
}
buttons_sheet = graphics.newImageSheet("button.png",buttons_options)

door_sprite_options =
{
width = 61,
height = 85,
numFrames = 5
}
door_sprite_sheet = graphics.newImageSheet("door.png",door_sprite_options)
sequences_door= {
{
    name = "open",
    start = 1,
    count = 5,
    time = 800,
    loopCount = 1,
    loopDirection = "forward"
}
}


function makeBackground(backgroundImage,level)
  local scaling = display.contentHeight /backgroundImage.height
  for i = 1,math.ceil(level.width*level.block_size/backgroundImage.width/scaling+1) do
    local background = {}
    background[i] = display.newImageRect( backgroundImage.fileName ,backgroundImage.width*scaling, display.contentHeight )
    background[i].x = backgroundImage.width*scaling*(i-1)
    background[i].y = display.contentCenterY
    camera:add(background[i], 2)

  end
end
function makeMoreAlpha (obj)
  obj.alpha = obj.alpha - 0.1

end
-- function removedisplayobj (obj)
--
-- end
