//=============================================================================
// FakeWallPlate.
//=============================================================================
class FakeWallPlate extends DeusExDecoration;

static function FakeWallPlate Create(Actor a, Vector loc, Rotator rot, float scale, optional Texture tex, optional String texName)
{
    local FakeWallPlate fwp;

    fwp = a.spawn(class'FakeWallPlate',,, loc, rot);

    fwp.DrawScale = scale;

    if (tex!=None){
        //In case you have the actual texture itself
        fwp.Skin = tex;
    } else if (texName!=""){
        fwp.Skin = Texture(DynamicLoadObject(texName, class'Texture'));
    }
}

defaultproperties
{
     bInvincible=True
     bHighlight=False
     ItemName="Wall (Do not read)"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExItems.FlatFX'
     bCollideWorld=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     ScaleGlow=0.2
     bUnlit=true;
}
