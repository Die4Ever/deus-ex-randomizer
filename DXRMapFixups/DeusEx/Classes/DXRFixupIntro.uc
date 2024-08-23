class DXRFixupIntro extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local Actor a;
    local #var(DeusExPrefix)Mover dxm;

    switch(dxr.localURL) {
    case "INTRO":
        //Remove trap door under MJ12 hand that causes Z-Fighting
        foreach AllActors(class'#var(DeusExPrefix)Mover',dxm,'trap_door'){
            DestroyMover(dxm);
        }
        break;
    }
}
