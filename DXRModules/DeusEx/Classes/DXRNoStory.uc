class DXRNoStory expands DXRBase;

function AnyEntry()
{
    Super.AnyEntry();
    RemoveStory();
}

function RemoveStory()
{
    local ScriptedPawn a;
    local DataLinkTrigger d;
    foreach AllActors(class'ScriptedPawn', a) {
        if( a.BindName == "" ) continue;
        a.BindName = "";
        a.ConBindEvents();
    }
    foreach AllActors(class'DataLinkTrigger', d) {
        d.Destroy();
    }
}
