class ExitGameTrigger extends Info;

// used for automated tests of loading saves
// with the exit command commented out, manually spawn in game before making the save file

function PostPostBeginPlay()
{
    Enable('Tick');
}

function Tick(float d)
{
    log("TIME: " $ self $ " exiting game");
    ConsoleCommand("Exit");
}

defaultproperties
{
    bAlwaysTick=True
}
