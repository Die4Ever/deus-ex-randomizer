class SkillAwardCrate extends DXRBigContainers;

var travel int NumSkillPoints;
var string SkillAwardMessage;

function Destroyed()
{
    local #var(PlayerPawn) player;

    if (HitPoints > 0) {
        Super.Destroyed();
        return;
    }

    if (#var(PlayerPawn)(Instigator) != None) {
        player = #var(PlayerPawn)(Instigator);
    } else {
        player = #var(PlayerPawn)(GetPlayerPawn());
    }

    if (NumSkillPoints > 0 && player != None) {
        player.SkillPointsAvail += NumSkillPoints; // don't call SkillPointsAdd() to avoid increasing SkillPointsTotal
        player.ClientMessage(NumSkillPoints $ " skill points awarded");
        player.ClientMessage(SkillAwardMessage);
    }

    Super.Destroyed();
}

defaultproperties
{
    ItemName="Skill Award Crate"
    SkillAwardMessage="Skill Award Crate Bonus"
    Skin=Texture'BlankWoodenCrate'
    HitPoints=1
    FragType=Class'DeusEx.WoodFragment'
    bBlockSight=True
    Mesh=LodMesh'DeusExDeco.CrateBreakableMed'
    CollisionRadius=34.000000
    CollisionHeight=24.000000
    Mass=50.000000
    Buoyancy=60.000000
}
