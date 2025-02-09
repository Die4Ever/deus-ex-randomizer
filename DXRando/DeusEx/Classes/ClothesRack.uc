class DXRClothesRack injects #var(prefix)ClothesRack;

var #var(PlayerPawn) p;
var bool bAlreadyUsed;
var class<#var(DeusExPrefix)Carcass> lootableClothes;

function Timer()
{
    local DXRCameraModes camera;

    foreach AllActors(class'DXRCameraModes',camera)
        break;

    if (p!=None && camera!=None) {
        if(#defined(injections||revision) && camera.GetExpectedCameraMode() == camera.CM_ThirdPerson) {
            camera.EnableTempFixedCamera(true);
            SetTimer(0.75,False);
        } else {
            camera.DisableTempCamera();
        }
    }
}

function Frob(actor Frobber, Inventory frobWith)
{
#ifndef vmd
    local DXRFashionManager fashion;
#endif
    local DXRCameraModes camera;
    local DXRando dxr;

    Super.Frob(Frobber, frobWith);

    // only 1 player at a time, otherwise the previous player will be stuck in 3rd person forever
    if(#defined(multiplayer) && p!=None) return;

#ifndef vmd
    if (#var(PlayerPawn)(Frobber) != None){
        p = #var(PlayerPawn)(Frobber);

        //Check if the rack has clothes available to loot
        fashion = class'DXRFashionManager'.static.GiveItem(p);
        if (fashion.IngestCarcass(lootableClothes)){
            if (Level.NetMode==NM_Standalone){
                DeusExRootWindow(p.rootWindow).hud.receivedItems.RemoveItems();
                DeusExRootWindow(p.rootWindow).hud.receivedItems.AddItem(fashion,1);
            }
            p.ClientMessage("Took a set of clothes off the rack!");
            return;
        }

        p.ClientMessage("Time for some new clothes!",, true);

        foreach AllActors(class'DXRCameraModes',camera)
            break;
        dxr = class'DXRando'.default.dxr;
        if (dxr == None)
            return;

        if (fashion!=None) {
            if (class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)){
                fashion.RandomizeClothes(p);
            } else {
                if (fashion.HasSkinOverrides()){
                    fashion.ClearSkinOverrides();
                } else {
                    fashion.RandomizeClothes(p);
                }
            }
            fashion.GetDressed();

            if (camera != None && camera.IsFirstPersonGame() && p.bBehindView == False && !dxr.flags.IsSpeedrunMode()) {
                camera.EnableTempThirdPerson(true);
                SetTimer(0.75,False);
            }
        }

        if (!bAlreadyUsed){
            bAlreadyUsed=true;
            class'DXREvents'.static.MarkBingo("ChangeClothes");
        }

    }
#endif
}

defaultproperties
{
    bHighlight=true
}
