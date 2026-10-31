state("retroarch")
{    
    byte levelID : "genesis_plus_gx_libretro.dll", 0x80CC4C;
    //int inGameTime : "genesis_plus_gx_libretro.dll", 0x80CCC6; //No need to use
    bool isPaused : "genesis_plus_gx_libretro.dll", 0x80CFCA;
    byte difficulty : "genesis_plus_gx_libretro.dll", 0x80EE66; //Game ends before on easy
    byte gameState : "genesis_plus_gx_libretro.dll", 0x80BC6E;  //0 = ingame, 1 = menu, 2 = starting loading screen, 46 = menu cinematics
    byte endOflevelTriggered : "genesis_plus_gx_libretro.dll", 0x80CF7C;  //Fade out screen trigger
    bool isDead : "genesis_plus_gx_libretro.dll", 0x80CF86; //Character is dead
    byte menuButtonSelected : "genesis_plus_gx_libretro.dll", 0x80BC72; //Character is dead
}   

startup
{    
    settings.Add("Disclosure", true, "Only for Genesis Plus GX v1.7.4, other versions may not work");
    settings.Add("Debug", false, "Debug", "Disclosure");
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

    vars.finalLevel = 0;

    if (settings["Debug"])
        print("Autisplitter bound to Havoc"); 
}

start
{
    //Start game button pressed
    if(current.menuButtonSelected == 0 && (old.gameState == 1 && current.gameState == 2))
    {
        vars.finalLevel = vars.finalLevelsByDifficulty[current.difficulty];
        if (settings["Debug"])
            print("Havoc run started with difficulty: " + current.difficulty);            
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