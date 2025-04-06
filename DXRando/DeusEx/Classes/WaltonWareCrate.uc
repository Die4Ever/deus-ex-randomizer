class WaltonWareCrate extends DXRBigContainers;

var travel int NumSkillPoints;

function Destroyed()
{
    local DeusExPlayer player;

    if (HitPoints > 0) {
        Super.Destroyed();
        return;
    }

    if (DeusExPlayer(Instigator) != None) {
        player = DeusExPlayer(Instigator);
    } else {
        player = DeusExPlayer(GetPlayerPawn());
    }

    if (player != None) {
        player.SkillPointsAvail += NumSkillPoints;
        //player.ClientMessage(NumSkillPoints $ " mission " $ class'DXRando'.default.dxr.dxInfo.missionNumber $ " new loop skill point bonus");
        player.ClientMessage(NumSkillPoints $ " mission " $ #var(PlayerPawn)(player).dxr.dxInfo.missionNumber $ " new loop skill point bonus");
    }

    Super.Destroyed();
}

defaultproperties
{
     ItemName="Walton's Care Package"
     Skin=Texture'WaltonWareCrate'
     HitPoints=1
     FragType=Class'DeusEx.WoodFragment'
     bBlockSight=True
     Mesh=LodMesh'DeusExDeco.CrateBreakableMed'
     CollisionRadius=34.000000
     CollisionHeight=24.000000
     Mass=50.000000
     Buoyancy=60.000000
}
