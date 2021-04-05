class DXRMapExit injects MapExit;

function Touch(Actor Other)
{
    if( DeusExPlayer(Other) == None )
        return;// the player isn't the one touching us!
    
    Super.Touch(Other);
}
