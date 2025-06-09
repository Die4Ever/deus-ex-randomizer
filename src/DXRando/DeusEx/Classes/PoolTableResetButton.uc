class PoolTableResetButton extends #var(prefix)Switch1;

var PoolTableManager ptm;

function BeginPlay()
{
    local PoolTableManager poolMan;

    Super.BeginPlay();

    foreach RadiusActors(class'PoolTableManager',poolMan,150){
        if (ptm==None){
            ptm = poolMan;
        } else {
            if (VSize(Location-poolMan.Location) < VSize(Location-ptm.Location)){
                ptm = poolMan;
            }
        }
    }
}

function Frob(Actor Frobber, Inventory frobWith)
{
    Super(DeusExDecoration).Frob(Frobber, frobWith); //Skip the regular Switch1 logic to toggle the switch and play sounds

    PlaySound(sound'PoolballClack',,1.5);
    PlayAnim('Off');

    if (ptm!=None){
        ptm.ResetPoolTable();
    }
}

defaultproperties
{
    ItemName="Pool Table Reset"
}
