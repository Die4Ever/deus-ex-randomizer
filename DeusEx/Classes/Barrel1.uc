class Barrel1 injects Barrel1;

event TravelPreAccept()
{
    Super.TravelPreAccept();
    if( HandleTravel() )
        BeginPlay();
}

function bool HandleTravel()
{
    local DeusExPlayer player;

    foreach AllActors(class'DeusExPlayer', player) { break; }
    if( player == None || player.CarriedDecoration != Self ) {
        return false;
    }

    SetPropertyText("SkinColor", Level.game.ParseOption( "?" $ Level.GetLocalURL(), "barrel1_skin" ));
    player.UpdateURL("barrel1_skin", "", false);
    return true;
}

function PreTravel()
{
    local DeusExPlayer player;
    foreach AllActors(class'DeusExPlayer', player) { break; }
    if( player != None && player.CarriedDecoration == Self ) {
        player.UpdateURL("barrel1_skin", GetPropertyText("SkinColor"), false);
    }
}

auto state Active
{
}
