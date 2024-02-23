class DXRButtonHoverHint extends DXRTeleporterHoverHint;

static function class<Actor> GetSelfClass()
{
    return class'DXRButtonHoverHint';
}

function String GetHintText()
{
    local String destStr;

    destStr = Super.GetHintText();

    if (baseActor!=None){
        baseActor.FamiliarName = destStr;
        baseActor.UnfamiliarName = destStr;
    }

    return ""; //Don't actually show any text
}
