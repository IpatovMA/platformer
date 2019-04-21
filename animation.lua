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
      name = "stay",
      start = 1,
      count = 4,
      time = 1000,
      loopCount = 0,
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
          frames = {1,2,3,2},
          time = 1500,
          loopCount = 0,
          loopDirection = "forward"
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


function makeBackground(backgroundImage,level)
  local scaling = display.actualContentHeight /backgroundImage.height
  for i = 1,math.ceil(level.width*level.block_size/backgroundImage.width/scaling+1) do
    local background = {}
    background[i] = display.newImageRect( backgroundImage.fileName ,backgroundImage.width*scaling, display.actualContentHeight )
    background[i].x = backgroundImage.width*scaling*(i-1)
    background[i].y = display.contentCenterY
    camera:add(background[i], 2)

  end
end
