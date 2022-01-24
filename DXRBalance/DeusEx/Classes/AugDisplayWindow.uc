class AugDisplayWindow injects AugmentationDisplayWindow;

var Actor drawQueue[128];
var int drawQueueLen;

function DrawVisionAugmentation(GC gc)
{
    local int i;
    drawQueueLen = 0;

    Super.DrawVisionAugmentation(gc);

    for(i=0; i<drawQueueLen; i++) {
        DrawBrush(drawQueue[i], gc);
        drawQueue[i] = None;
    }
    drawQueueLen = 0;
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
    else if ( (A.IsA('Mover') || A.IsA('Decoration')) && A.bVisionImportant && !A.bHidden)
        return true;
    else
        return False;
}


function SetSkins(Actor actor, out Texture oldSkins[9])
{
    local vector forwards, backwards;
    local float dist;

    if(actor.Mesh == None) {
        dist = VSize(Player.Location - actor.Location);
        forwards = Player.Location + (Vector(Player.ViewRotation) * dist);
        backwards = Player.Location + (Vector(Player.ViewRotation) * (-dist));
        if( VSize(actor.Location - forwards) < VSize(actor.Location - backwards) )
            drawQueue[drawQueueLen++] = actor;
    }
    else
        Super.SetSkins(actor, oldSkins);
}

function ResetSkins(Actor actor, Texture oldSkins[9])
{
    if(actor.Mesh == None) {}
    else
        Super.ResetSkins(actor, oldSkins);
}

function DrawBrush(Actor a, GC gc)
{
    local float boxTLX, boxTLY, boxBRX, boxBRY, width, height;
    class'FrobDisplayWindow'.static.GetActorBox(self, a, 1, boxTLX, boxTLY, boxBRX, boxBRY);
    
    width = boxBRX - boxTLX;
    height = boxBRY - boxTLY;
    //log(self$" DrawBrush "$a @ width @ height);
    gc.DrawPattern(boxTLX, boxTLY, width, height, 0, 0, Texture'Virus_SFX');
    //gc.DrawText(boxTLX, boxTLY, width, height, a.name @ a.bHidden);
}
