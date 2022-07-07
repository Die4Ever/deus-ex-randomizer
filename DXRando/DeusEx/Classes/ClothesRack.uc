class DXRClothesRack injects #var(prefix)ClothesRack;

var #var(PlayerPawn) p;
var bool bAlreadyUsed;

function Timer()
{
   if (p!=None) {
       p.bBehindView = False;
       p = None;
   }
}

function Frob(actor Frobber, Inventory frobWith)
{
#ifndef vmd
    local DXRFashion fashion;
#endif
    local DXRando dxr;

    Super.Frob(Frobber, frobWith);

    // only 1 player at a time, otherwise the previous player will be stuck in 3rd person forever
    if(#defined(multiplayer) && p!=None) return;

#ifndef vmd
    if (#var(PlayerPawn)(Frobber) != None){
        p = #var(PlayerPawn)(Frobber);
        p.ClientMessage("Time for some new clothes!",, true);
        foreach AllActors(class'DXRFashion',fashion)
            break;

        if (fashion!=None) {
            fashion.RandomizeClothes(p);
            fashion.GetDressed();

            if (p.bBehindView == False) {
                p.bBehindView = True;
                SetTimer(0.75,False);
            }
        }

        if (!bAlreadyUsed){
            bAlreadyUsed=true;
            foreach AllActors(class'DXRando', dxr) {
                class'DXREvents'.static.MarkBingo(dxr,"ChangeClothes");
            }
        }

    }
#endif
}

