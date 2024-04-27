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
        //Original barrel textures
        switch(SkinColor){
            case SC_Explosive:
                Skin=Texture'Barrel1Tex5';
                break;
            case SC_FlammableLiquid:
                Skin=Texture'Barrel1Tex6';
                break;
            case SC_FlammableSolid:
                Skin=Texture'Barrel1Tex7';
                break;
            case SC_Poison:
                Skin=Texture'Barrel1Tex8';
                break;
            case SC_Biohazard:
                Skin=Texture'Barrel1Tex1';
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
}

function Trigger(Actor Other, Pawn Instigator)
{
    TakeDamage(50,Instigator,Location,vect(0,0,0),'shot'); //Destroy the barrel if it is triggered
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
