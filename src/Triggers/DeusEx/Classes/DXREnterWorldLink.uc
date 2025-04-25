class DXREnterWorldLink extends Info;

var ScriptedPawn targets[16];
var int num_targets;

static function DXREnterWorldLink Create(Actor watch, ScriptedPawn target)
{
    local DXREnterWorldLink link;
    foreach watch.AllActors(class'DXREnterWorldLink', link, watch.name) {
        if(link.num_targets >= ArrayCount(link.targets)) continue;
        link.targets[link.num_targets++] = target;
        return link;
    }
    link = watch.spawn(class'DXREnterWorldLink',, watch.name);
    link.SetBase(watch);
    link.targets[0] = target;
    link.num_targets = 1;
    return link;
}

event BaseChange()
{
    local Actor A;
    local int i;

    //log(self $ ".BaseChange() " $ tag $ base @ targets[0] @ num_targets);
    if(base != None) return;

    for(i=0; i<num_targets; i++) {
        if(targets[i] == None) continue;
        targets[i].EnterWorld();
        targets[i].Falling();
    }

    if (Event != '')
        foreach AllActors(class 'Actor', A, Event)
            A.Trigger(Self, None);

    Destroy();
}
