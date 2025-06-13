// A "Weapon" to mark locations in the world
class WeaponLocFinder extends DeusExWeapon;

simulated event RenderOverlays( canvas Canvas )
{
    if ( Owner == None )
        return;
    if ( (Level.NetMode == NM_Client) && (!Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Player == None)) )
        return;
    SetLocation( Owner.Location + CalcDrawOffset() );
    SetRotation( Pawn(Owner).ViewRotation + rot(16784,0,16784));
    Canvas.DrawActor(self, false);
}

function BringUp()
{
    local #var(PlayerPawn) p;

    Super.BringUp();

    p = #var(PlayerPawn)(Owner);

    if (p!=None){
        p.ClientMessage("Toggle Scope to show marked locations");
        p.ClientMessage("Change Ammo Type to remove marked locations");
    }
}

simulated function ScopeToggle()
{
    local ActorDisplayWindow actorDisplay;
    local bool active;

    actorDisplay = DeusExRootWindow(#var(PlayerPawn)(Owner).rootWindow).actorDisplay;
    active = (actorDisplay.GetViewClass()!=None);

    active = !active;

    if (active){
        actorDisplay.SetViewClass(class'LocFinderShot');
        actorDisplay.ShowLOS(false);
        actorDisplay.ShowPos(true);
    } else {
        actorDisplay.SetViewClass(None);
    }
}

//Remove all shots when you try to switch ammo
function CycleAmmo()
{
    local LocFinderShot shots;

    foreach AllActors(class'LocFinderShot',shots)
    {
        shots.Destroy();
    }
}

//I wanted to do some adjustments to where the "weapon" shows up,
//but want the shot to actually just go straight to the crosshair location
//Just hack it
simulated function Vector ComputeProjectileStart(Vector X, Vector Y, Vector Z)
{
    local Vector origOffset, out;

    origOffset = PlayerViewOffset;
    PlayerViewOffset=vect(0,0,0);
    out=Super.ComputeProjectileStart(X,Y,Z);
    PlayerViewOffset=origOffset;
    return out;
}

simulated function PlaySelectiveFiring()
{
    //Do nothing, flare has no shooting animations
}

simulated function PlayIdleAnim()
{
    //Do nothing, flare has no idle animations
}

defaultproperties
{
     Concealability=CONC_All
     bEmitWeaponDrawn=False
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     NoiseLevel=0.000000
     EnviroEffective=ENVEFF_All
     ShotTime=1.0
     reloadTime=0.000000
     HitDamage=0
     maxRange=99999
     AccurateRange=99999
     BaseAccuracy=0
     bHasMuzzleFlash=False
     recoilStrength=1.000000
     mpHitDamage=100
     mpBaseAccuracy=0
     mpAccurateRange=99999
     mpMaxRange=99999
     AmmoName=Class'DeusEx.AmmoDart'
     ReloadCount=50
     PickupAmmoCount=50
     ProjectileClass=Class'LocFinderShot'
     InventoryGroup=2
     ItemName="Location Finder"
     FireOffset=(X=0,Y=0,Z=0)
     PlayerViewOffset=(X=18.000000,Z=-7.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Flare'
     PickupViewMesh=LodMesh'DeusExItems.Flare'
     ThirdPersonMesh=LodMesh'DeusExItems.Flare'
     Icon=Texture'DeusExUI.Icons.BeltIconFlare'
     largeIcon=Texture'DeusExUI.Icons.LargeIconFlare'
     largeIconWidth=42
     largeIconHeight=43
     invSlotsX=1
     invSlotsY=1
     Description="This shit ain't real, buddy"
     beltDescription="LOCFINDER"
     Mesh=LodMesh'DeusExItems.Flare'
     CollisionRadius=6.200000
     CollisionHeight=1.200000
     Mass=1.000000
}
