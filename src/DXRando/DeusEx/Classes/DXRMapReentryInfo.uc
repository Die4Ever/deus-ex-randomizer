class DXRMapReentryInfo extends Info;

var int mapEntryCounter;

static function DXRMapReentryInfo Get(Actor a)
{
    local DXRMapReentryInfo s, first;
    local int i;

    i=0;
    foreach a.AllActors(class'DXRMapReentryInfo', s) {
        if(i > 0) s.Destroy();
        else first = s;
        i++;
    }

    if(first == None) {
        first = a.Spawn(class'DXRMapReentryInfo');
    }

    return first;
}

static function DXRMapReentryInfo TickEntry(Actor a)
{
    local DXRMapReentryInfo s;

    s = Get(a);
    if(s != None) s.mapEntryCounter += 1;
    return s;
}

defaultproperties
{
    mapEntryCounter=0
}
