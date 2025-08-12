state("retroarch")
{
    byte levelID : "genesis_plus_gx_libretro.dll", 0x7BEC4C;
    //int inGameTime : "genesis_plus_gx_libretro.dll", 0x7BECC6; //No need to use
    bool isPaused : "genesis_plus_gx_libretro.dll", 0x7BEFCA;
    byte difficulty : "genesis_plus_gx_libretro.dll", 0x7C0E66; //Game ends before on easy
    byte gameState : "genesis_plus_gx_libretro.dll", 0x7BDC6E;  //0 = ingame, 1 = menu, 2 = starting loading screen, 46 = menu cinematics
    byte endOflevelTriggered : "genesis_plus_gx_libretro.dll", 0x7BEF7C;  //Fade out screen trigger
    bool isDead : "genesis_plus_gx_libretro.dll", 0x7BEF86; //Character is dead
    byte menuButtonSelected : "genesis_plus_gx_libretro.dll", 0x7BDC72; //Character is dead
}   
startup
{    
    settings.Add("Debug");
    settings.Add("PAL");
}

init
{
    vars.finalLevelsByDifficulty = new List<int>()
    {
        4, //Easy 
        12, //Normal
        12, //Hard
        12 //Expert
    };

    //Set refresh rate to check value change aligned with game execution
    refreshRate = settings["PAL"] ? 54f : 60f;
    vars.finalLevel = 0;
}

start
{
    //Start game button pressed
    if(current.menuButtonSelected == 0 && (old.gameState == 1 && current.gameState == 2))
    {
        vars.finalLevel = vars.finalLevelsByDifficulty[current.difficulty];
        return true;
    }
    
    return false;
}

split
{
    //Check this to avoid fade out screen splitting on death
    if (current.isDead) return false; 
    
    vars.finalLevel = vars.finalLevelsByDifficulty[current.difficulty];
    //Trigger split on fade out screen start to match running rules
    if (vars.finalLevel == current.levelID)
    {
        if(current.endOflevelTriggered == 1)
        {
            if (settings["Debug"])
                print("OnLastLevel: " + vars.finalLevel.ToString() + " " + current.levelID.ToString());
            return true;

        }
    }
    //Split on level change
    return (old.levelID < current.levelID);
}

isLoading
{    
    if(current.isPaused != old.isPaused)
    {
        if (settings["Debug"])
            print(current.isPaused ? "Paused" : "Unpaused");
    }
    return current.isPaused;

}
