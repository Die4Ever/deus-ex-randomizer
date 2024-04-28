class DXRBarrel1 injects #var(prefix)Barrel1;

var travel ESkinColor _SkinColor;

function BeginPlay()
{
    bExplosive=Default.bExplosive;
    explosionDamage=Default.explosionDamage;
    explosionRadius=Default.explosionRadius;
    Super.BeginPlay();
    bInvincible = false;
    _SkinColor = SkinColor;
}

function PostPostBeginPlay()
{
    UpdateBarrelTexture();
    AdjustBarrelBehaviour();
}

function AdjustBarrelBehaviour()
{
    switch(SkinColor){
        //Merge explosive barrel behaviour into a single type
        case SC_Explosive:
        case SC_FlammableLiquid:
        case SC_FlammableSolid:
            //Intent is to make these all behave like SC_FlammableSolid
            bExplosive = True;
            explosionDamage = 200;
            explosionRadius = class'Barrel1'.Default.ExplosionRadius;
            HitPoints=8;
            ItemName = "Explosive Barrel";
            break;
        case SC_Wood:
            FragType=class'WoodFragment';
            ItemName = "Wooden Barrel";
            break;
        case SC_Poison:
        case SC_Biohazard:
            ItemName = "Poison Gas Barrel";
            break;
        case SC_RadioActive:
            ItemName = "Radioactive Barrel";
            break;
        default:
            ItemName = "Barrel";
            break;
    }

}

function UpdateBarrelTexture()
{
    if (class'MenuChoice_BarrelTextures'.static.IsEnabled(self)){
        //Update skins with nice colour-coded striped barrels
        switch(SkinColor){
            case SC_Explosive:
            case SC_FlammableLiquid:
            case SC_FlammableSolid:
                Skin=Texture'RedExplosiveBarrel';
                break;
            case SC_Poison:
            case SC_Biohazard:
                Skin=Texture'GreenPoisonBarrel';
                break;
            case SC_RadioActive:
                Skin=Texture'YellowRadioactiveBarrel';
                break;
        }
    } else {
        //Original barrel textures (merged)
        switch(SkinColor){
            case SC_Explosive:
            case SC_FlammableSolid:
            case SC_FlammableLiquid:
                Skin=Texture'Barrel1Tex6';
                break;
            case SC_Biohazard:
            case SC_Poison:
                Skin=Texture'Barrel1Tex8';
                break;
            case SC_RadioActive:
                Skin=Texture'Barrel1Tex9';
                break;
        }
    }
}

event TravelPostAccept()
{
    Super.TravelPostAccept();
    SkinColor = _SkinColor;
    BeginPlay();
    UpdateBarrelTexture();
    AdjustBarrelBehaviour();
}

function Trigger(Actor Other, Pawn Instigator)
{
    TakeDamage(50,Instigator,Location,vect(0,0,0),'shot'); //Destroy the barrel if it is triggered
}

function Destroyed()
{
    local Vector HitLocation, HitNormal, EndTrace;
    local Actor hit;
    local WinePool pool;

    if (SkinColor==SC_Wood){
        // trace down about 20 feet if we're not in water
        if (!Region.Zone.bWaterZone)
        {
            EndTrace = Location - vect(0,0,320);
            hit = Trace(HitLocation, HitNormal, EndTrace, Location, False);
            pool = spawn(class'WinePool',,, HitLocation+HitNormal, Rotator(HitNormal));
            if (pool != None)
                pool.maxDrawScale = CollisionRadius / 10.0;
        }
    }

    Super.Destroyed();
}

auto state Active
{
    function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
    {
        //Don't get zapped by electricity
        //Prevents the big smoke cloud in airfield that lags everything
        if (damageType=='Shocked'){
            return;
        }

        Super.TakeDamage(Damage,instigatedBy,hitLocation,momentum,damageType);
    }
}
