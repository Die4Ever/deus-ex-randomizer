class DXRJCDentonMaleCarcass injects JCDentonMaleCarcass;

function PostPostBeginPlay()
{
    local DXRFashionManager fashion;
    local #var(PlayerPawn) p;

    Super.PostPostBeginPlay();

    //Make sure JC's dressed
    foreach AllActors(class'#var(PlayerPawn)',p) break;
    fashion = class'DXRFashionManager'.static.GiveItem(p);
    if (fashion!=None){
        fashion.GetDressed();
    }
}
