#ifdef injections
class DXRClothesRack injects ClothesRack;
#else
class DXRClothesRack extends ClothesRack;
#endif

var #var PlayerPawn  p;

function Timer()
{
   if (p!=None) {
       p.bBehindView = False;
   }
}

function Frob(actor Frobber, Inventory frobWith)
{
    local DXRFashion fashion;

    Super.Frob(Frobber, frobWith);

    if (Frobber.IsA('#var PlayerPawn ')){
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
}
