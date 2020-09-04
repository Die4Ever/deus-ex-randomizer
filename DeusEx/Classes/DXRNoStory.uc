class DXRNoStory expands DXRBase;

function AnyEntry()
{
    local ScriptedPawn a;
    local DataLinkTrigger d;
    Super.AnyEntry();

    foreach AllActors(class'ScriptedPawn', a) {
        if( a.BindName == "" ) continue;
        a.BindName = "";
        a.ConBindEvents();
    }
    foreach AllActors(class'DataLinkTrigger', d) {
        d.Destroy();
    }
}
