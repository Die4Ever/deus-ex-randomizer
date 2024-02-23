class DXRButtonHoverHint extends DXRTeleporterHoverHint;

var bool nameSet;

static function class<Actor> GetSelfClass()
{
    return class'DXRButtonHoverHint';
}

//Self destruct as soon as the name has been set
function bool ShouldSelfDestruct()
{
    return nameSet;
}

function String GetHintText()
{
    local String destStr;

    destStr = Super.GetHintText();

    if (baseActor!=None){
        baseActor.FamiliarName = destStr;
        baseActor.UnfamiliarName = destStr;
        nameSet=True;
    }

    return ""; //Don't actually show any text
}

defaultproperties
{
    nameSet=False
}
