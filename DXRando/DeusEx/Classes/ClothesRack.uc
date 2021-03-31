class DXRClothesRack injects ClothesRack;

var DeusExPlayer p;

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
    
    if (Frobber.IsA('DeusExPlayer')){
        p = DeusExPlayer(Frobber);
        p.ClientMessage("Time for some new clothes!",, true);
        foreach AllActors(class'DXRFashion',fashion)
            break;
        
        if (fashion!=None) {
            fashion.RandomizeClothes();
            fashion.GetDressed();
        
            if (p.bBehindView == False) {
                p.bBehindView = True;
                SetTimer(0.75,False);
            }
        }

    }
}
