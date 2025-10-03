class BobbyPossessionEffect extends Info;

var float lastPossessionTime;
struct LitData {
    var Actor a;
    var int brightness;
    var float ScaleGlow;
    var bool bUnlit;
};
struct ZoneData {
    var ZoneInfo z;
    var int brightness;
};

var LitData lits[1024];
var ZoneData zones[128];
var int num_lits, num_zones;
var float last_scale;

var Bobby oldBob;
var BobbyFake faker;
var DXRHalloween halloween;

const range=1200; // if another effect wants to be spawned within this range, need to copy original values

function PreTravel()
{// stalkers get recreated on travel
    oldBob = None;
    faker = None;
}

//#region init
static function Create(Bobby bob, BobbyFake faker, DXRHalloween halloween)
{
    local BobbyPossessionEffect effect;

    effect = faker.Spawn(class'BobbyPossessionEffect');
    if(effect == None) { // just in case
        if(!bob.bDeleteMe) {
            bob.bTransient = false;
            bob.Destroy();
        }
        PossessFake(faker, halloween);
        return;
    }

    effect.oldBob = bob;
    bob.bTransient = false;
    effect.faker = faker;
    effect.halloween = halloween;
}

static function PossessFake(BobbyFake faker, DXRHalloween h)
{
    local Bobby bob;

    if(faker.health <= 0) return;
    faker.SetCollision(false,false,false);
    bob = faker.Spawn(class'Bobby',,, faker.Location, faker.Rotation);
    bob.InitStalker(h);
    faker.Destroy();
    bob.Spawn(class'WeepingAnnaLight'); // tiny light, fade in and fade out quickly, almost a strobe
    bob.PlaySound(Sound'DeusExSounds.Generic.GlassBreakSmall',, 2,, 600, 0.5);
}

function BeginPlay()
{
    local Actor a;
    local ZoneInfo z;
    local BobbyPossessionEffect effect;
    local int i;
    local LitData data;
    local ZoneData zdata;

    lastPossessionTime = Level.TimeSeconds;
    num_lits = 0;
    num_zones = 0;

    foreach RadiusActors(class'Actor', a, range) {
        if(ZoneInfo(a)!=None) continue;
        if(#var(PlayerPawn)(a.Owner) != None) continue;
        if(a.LightBrightness==0 && a.bUnlit==false) continue;
        lits[num_lits].a = a;
        lits[num_lits].brightness = a.LightBrightness;
        lits[num_lits].bUnlit = a.bUnlit;
        lits[num_lits].ScaleGlow = a.ScaleGlow;
        num_lits++;
    }
    foreach AllActors(class'ZoneInfo', z) {
        zones[num_zones].z = z;
        zones[num_zones].brightness = z.AmbientBrightness;
        num_zones++;
    }

    foreach RadiusActors(class'BobbyPossessionEffect', effect, range+16) {
        if(effect == self) continue;
        for(i=0; i<num_lits; i++) {
            data = effect.GetLitData(lits[i].a);
            if(data.a != lits[i].a) continue;
            lits[i] = data;
        }
    }

    // zones need to copy without range
    foreach AllActors(class'BobbyPossessionEffect', effect) {
        if(effect == self) continue;
        for(i=0; i<num_zones; i++) {
            zdata = effect.GetZoneData(zones[i].z);
            if(zdata.z != zones[i].z) continue;
            zones[i] = zdata;
        }
    }
}

//#region sync
function LitData GetLitData(Actor a)
{
    local int i;
    local LitData blank;

    for(i=0; i<num_lits; i++) {
        if(lits[i].a == a) return lits[i];
    }

    return blank;
}

function ZoneData GetZoneData(ZoneInfo z)
{
    local int i;
    local ZoneData blank;

    for(i=0; i<num_zones; i++) {
        if(zones[i].z == z) return zones[i];
    }

    return blank;
}

//#region tick
function Tick(float delta)
{
    local int i;
    local float scale, actualScale;
    local BobbyPossessionEffect effect;

    scale = (Abs(LifeSpan/default.LifeSpan - 0.5) - 0.2) * 32;
    scale = FClamp(scale, 0, 1);

    if(scale~=0 || scale > last_scale) {
        if(oldBob!=None && !oldBob.bDeleteMe) {
            oldBob.bTransient = false;
            oldBob.Destroy();
        }
        oldBob = None;
        if(faker!=None) {
            PossessFake(faker, halloween);
            faker = None;
        }
    }

    actualScale = scale;
    foreach RadiusActors(class'BobbyPossessionEffect', effect, range+16) {
        if(effect==self) continue;
        scale = FMin(scale, effect.last_scale); // sync
    }

    for(i=0; i<num_lits; i++) {
        if(lits[i].a == None) continue;
        lits[i].brightness = Max(lits[i].a.LightBrightness, lits[i].brightness); // just in case it was changed by something else
        if(lits[i].a.bUnlit) lits[i].bUnlit = true;
        lits[i].ScaleGlow = FMax(lits[i].a.ScaleGlow, lits[i].ScaleGlow);
        lits[i].a.bUnlit = scale > 0.8;
        lits[i].a.LightBrightness = lits[i].brightness * scale;
        lits[i].a.ScaleGlow = lits[i].ScaleGlow * scale;
    }
    for(i=0; i<num_zones; i++) {
        zones[i].brightness = Max(zones[i].z.AmbientBrightness, zones[i].brightness);
        zones[i].z.AmbientBrightness = zones[i].brightness * scale;
    }

    if(!(scale ~= last_scale)) GetPlayerPawn().ConsoleCommand("FLUSH");

    last_scale = actualScale;
}

//#region destroyed
function Destroyed()
{
    local int i;
    for(i=0; i<num_lits; i++) {
        if(lits[i].a == None) continue;
        lits[i].a.LightBrightness = lits[i].brightness;
        lits[i].a.bUnlit = lits[i].bUnlit;
        lits[i].a.ScaleGlow = lits[i].ScaleGlow;
    }
    num_lits = 0;
    for(i=0; i<num_zones; i++) {
        zones[i].z.AmbientBrightness = zones[i].brightness;
    }
    num_zones = 0;
    GetPlayerPawn().ConsoleCommand("FLUSH");

    Super.Destroyed();
}

defaultproperties
{
    LifeSpan=2.5
    last_scale=1.01
}
