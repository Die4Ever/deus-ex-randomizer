class DXRStatLog extends StatLog;

function LogEventString( string EventString )
{
    //Don't actually log anything from this
    //Log( EventString );
}

//Any time the player picks up an item.  Note that if the pickup stacks,
//this won't actually trigger again (It's just adding to the stack count).
function LogPickup(Inventory Item, Pawn Other)
{
    local DeusExPlayer dxp;

    if ( (Other == None) || (Other.PlayerReplicationInfo == None) || (Item == None) )
        return;

    //dxp=DeusExPlayer(Other);

    //if (dxp!=None){
    //    dxp.ClientMessage(Name$" Player just picked up "$Item.Name);
    //}
}

//Called any
function LogItemActivate(Inventory Item, Pawn Other)
{
    local DXRando dxr;
    local string className;

    if ( (Item == None) )
        return;

    //This guards against ChargedPickups reactivating after a level transition
    if ( (Item.bActive) )
        return;

    //I don't know who wrote the code for flares, but they must have
    //had something else really important on their mind, because
    //flares are just completely fucked, and spawn a new one when
    //you activate them (which isn't bActive or in the Activated state)
    if ( (Item.IsA('Flare') && Flare(Item).gen!=None) ) {
        return;
    }

    className = String(Item.Class);
    //Strip any package names for simplicity
    className = class'DXRInfo'.static.ReplaceText(className,"DeusEx.","");
    className = class'DXRInfo'.static.ReplaceText(className,"HX.HX","");
    foreach AllActors(class'DXRando',dxr){
        class'DXREvents'.static.MarkBingo(dxr,className$"_Activated");
    }
}
