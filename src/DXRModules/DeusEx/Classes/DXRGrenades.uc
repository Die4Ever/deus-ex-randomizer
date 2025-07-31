class DXRGrenades extends DXRActorsBase transient;

struct RandomGrenadeStruct { var class<#var(prefix)ThrownProjectile> type; var float chance; };
var RandomGrenadeStruct randomgrens[4];

var config float min_rate_adjust, max_rate_adjust;

function class<#var(prefix)ThrownProjectile> PickRandomGrenade()
{
    local class<#var(prefix)ThrownProjectile> newgren;
    local float r;
    local int i;

    newgren=None;

    r = initchance();
    for (i=0;i<ArrayCount(randomgrens);i++){
        if(chance(randomgrens[i].chance,r)) newgren = randomgrens[i].type;
    }
    chance_remaining(r);

    if (newgren==None){
        //Shouldn't happen, but...
        err("Failed to pick a random grenade");
        newgren=randomgrens[0].type;
    }

    return newgren;
}

function AddRandomGrenade(class<#var(prefix)ThrownProjectile> gren, float c)
{
    local int i;
    for(i=0;i < ArrayCount(randomgrens);i++){
        if (randomgrens[i].type==None){
            randomgrens[i].type=gren;
            randomgrens[i].chance=rngrangeseeded(c,min_rate_adjust,max_rate_adjust,gren.name) ** 2;
            return;
        }
    }
}

function CheckConfig()
{
    local float total;
    local int i;

    Super.CheckConfig();

    AddRandomGrenade(class'#var(prefix)EMPGrenade',10);        //1 through the game
    AddRandomGrenade(class'#var(prefix)GasGrenade',10);       //9 through the game
    AddRandomGrenade(class'#var(prefix)LAM',15);              //18 through the game
    AddRandomGrenade(class'#var(prefix)NanoVirusGrenade',8);  //0 through the game

    //Scale to 100%
    total=0;
    for(i=0;i<ArrayCount(randomgrens);i++)
    {
        total += randomgrens[i].chance;
    }
    for(i=0;i<ArrayCount(randomgrens);i++)
    {
        randomgrens[i].chance *= 100.0/total;
    }
}

function #var(prefix)ThrownProjectile SpawnNewPlantedGrenade(class<#var(prefix)ThrownProjectile> type,
                                                             Vector loc,
                                                             Rotator rot,
                                                             name tag,
                                                             name event,
                                                             Actor owner)
{
    local #var(prefix)ThrownProjectile gren;

    gren = Spawn(type,owner,tag,loc,rot);
    if(gren == None) return gren;

    gren.PlayAnim('Open');
    gren.SetPhysics(PHYS_None);
    gren.bBounce = False;
    gren.bProximityTriggered = True;
    gren.bStuck = True;
    gren.event = event;
    gren.bHighlight = True; //HX makes thrown grenades not highlightable, and planted ones explicitly become highlighted
#ifdef hx
    gren.Time = gren.FuseLength;  //This prevents the beep when planted (only an issue in HX)
    gren.bPlayerPlaced = false;
#endif

    return gren;
}

function FirstEntry()
{
    local #var(prefix)ThrownProjectile gren;
    local #var(prefix)ThrownProjectile grens[16];
    local Vector loc;
    local Rotator rot;
    local int i;
    local name oldTag,oldEvent;
    local Actor oldOwner;

    Super.FirstEntry();
    if(dxr.flags.settings.grenadeswap <= 0) return;

    SetSeed("RandoGrenades");

    i=0;
    foreach AllActors(class'#var(prefix)ThrownProjectile',gren)
    {
        if (gren.Owner==None && chance_single(dxr.flags.settings.grenadeswap)) {
            grens[i++]=gren;
        }
    }

    for (i=0;grens[i]!=None;i++){
        loc = grens[i].Location;
        rot = grens[i].Rotation;
        oldTag = grens[i].tag;
        oldEvent=grens[i].event;
        oldOwner=grens[i].owner;
        grens[i].SetCollision(false,false,false);
        grens[i].Destroy();

        gren = SpawnNewPlantedGrenade(PickRandomGrenade(),loc,rot,oldTag,oldEvent,oldOwner);

        if (gren!=None){
            l("Spawned a new grenade "$gren.name);
        } else {
            l("Failed to spawn a replacement grenade");
        }
    }
}

simulated function AddDXRCredits(CreditsWindow cw)
{
    local int i;
    if(dxr.flags.IsZeroRando()) return;
    cw.PrintHeader( "Grenade Types" );
    for (i=0;i<ArrayCount(randomgrens);i++){
        cw.PrintText( randomgrens[i].Type.default.ItemName $ " : " $ FloatToString(randomgrens[i].chance, 1) $ "%" );
    }

    cw.PrintLn();
    cw.PrintLn();
}

defaultproperties
{
    min_rate_adjust=0.3
    max_rate_adjust=1.75
}
