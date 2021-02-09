class Barrel1 injects Barrel1;

event TravelPreAccept()
{
    local string old_skin;
    Super.TravelPreAccept();
    if( HandleTravel() )
        BeginPlay();
}

function bool HandleTravel()
{
    local int old_skin;
    local DeusExPlayer player;

    foreach AllActors(class'DeusExPlayer', player) { break; }
    if( player == None || player.CarriedDecoration != Self ) {
        return false;
    }

    old_skin = int(Level.game.ParseOption( "?" $ Level.GetLocalURL(), "barrel1_skin" ));
    switch(old_skin) {
        case 0:
            SkinColor = SC_Biohazard;
            break;
        case 1:
            SkinColor = SC_Blue;
            break;
        case 2:
            SkinColor = SC_Brown;
            break;
        case 3:
            SkinColor = SC_Rusty;
            break;
        case 4:
            SkinColor = SC_Explosive;
            break;
        case 5:
            SkinColor = SC_FlammableLiquid;
            break;
        case 6:
            SkinColor = SC_FlammableSolid;
            break;
        case 7:
            SkinColor = SC_Poison;
            break;
        case 8:
            SkinColor = SC_RadioActive;
            break;
        case 9:
            SkinColor = SC_Wood;
            break;
        case 10:
            SkinColor = SC_Yellow;
            break;
    }
    player.UpdateURL("barrel1_skin", "", false);
    return true;
}

function PreTravel()
{
    local DeusExPlayer player;
    foreach AllActors(class'DeusExPlayer', player) { break; }
    if( player != None && player.CarriedDecoration == Self ) {
        player.UpdateURL("barrel1_skin", string(SkinColor), false);
    }
}
