class AugDisplayWindow injects AugmentationDisplayWindow;

var GC _gc;

function DrawVisionAugmentation(GC gc)
{
    _gc = gc;
    Super.DrawVisionAugmentation(gc);
    _gc = None;
}

function bool IsHeatSource(Actor A)
{
    if ((A.bHidden) && (Player.Level.NetMode != NM_Standalone))
        return False;
    if (A.IsA('Pawn'))
    {
        if (A.IsA('ScriptedPawn'))
            return True;
        else if ( (A.IsA('DeusExPlayer')) && (A != Player) )//DEUS_EX AMSD For multiplayer.
            return True;
        return False;
    }
    else if (A.IsA('DeusExCarcass'))
        return True;
    else if (A.IsA('FleshFragment'))
        return True;
    else if (A.bVisionImportant)
        return true;
    else
        return False;
}


function SetSkins(Actor actor, out Texture oldSkins[9])
{
    /*local Mover m;
    m = Mover(actor);
    if(m != None && _gc != None) {
        // try to draw brushes...
        DrawMover(m, _gc);
    }
    else*/ Super.SetSkins(actor, oldSkins);
}

function ResetSkins(Actor actor, Texture oldSkins[9])
{
    /*local Mover m;
    m = Mover(actor);
    if(m != None && _gc != None) {
    }
    else*/ Super.SetSkins(actor, oldSkins);
}

function DrawMover(Mover m, GC gc)
{
    local float boxTLX, boxTLY, boxBRX, boxBRY, width, height;
    class'FrobDisplayWindow'.static.GetActorBox(self, m, 1, boxTLX, boxTLY, boxBRX, boxBRY);
    
    width = boxTLX - boxBRX;
    height = boxTLY - boxBRY;
    gc.DrawTexture(boxTLX, boxTLY, width, height, 0, 0, Texture'Virus_SFX');
}
