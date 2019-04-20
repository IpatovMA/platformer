player_sprite_options =
{
    width = 36,
    height = 36,
    numFrames = 18
}

player_sprite_sheet = graphics.newImageSheet("playersprite.png",player_sprite_options)
sequences_player_run = {
   {
        name = "run",
        start = 7,
        count = 6,
        time = 800,
        loopCount = 0,
        loopDirection = "forward"
    }
}
