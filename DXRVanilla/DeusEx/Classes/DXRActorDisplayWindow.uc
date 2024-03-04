class DXRActorDisplayWindow injects ActorDisplayWindow;

var bool         bShowCustom;
var string       customAttrib;

function ShowCustom(bool bShow)
{
    bShowCustom = bShow;
}

function Bool IsCustomVisible()
{
	return bShowCustom;
}

function SetCustomAttrib(string newCustomAttrib)
{
    customAttrib = newCustomAttrib;
}

function String GetCustomAttrib(){
    return customAttrib;
}


//Actually need to do stuff in here to output the information selected above
function DrawWindow(GC gc)
{
    Super.DrawWindow(gc);
}
