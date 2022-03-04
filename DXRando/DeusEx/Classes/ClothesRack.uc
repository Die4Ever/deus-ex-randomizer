#ifdef injections
class DXRClothesRack injects ClothesRack;
#else
class DXRClothesRack extends #var prefix ClothesRack;
#endif

var #var PlayerPawn  p;

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

    Super.Frob(Frobber, frobWith);

    // only 1 player at a time, otherwise the previous player will be stuck in 3rd person forever
    if(#defined multiplayer && p!=None) return;

#ifndef vmd
    if (#var PlayerPawn (Frobber) != None){
        p = #var PlayerPawn (Frobber);
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

    }
#endif
}

