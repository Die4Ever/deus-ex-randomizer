#compileif injections || revision
class DolphinJumpTrigger extends BingoTrigger;

static function DolphinJumpTrigger CreateDolphin(#var(PlayerPawn) p)
{
    local DolphinJumpTrigger t;

    if(p.Velocity.Z < 24 || p.bOnLadder) return None;
<<<<<<< HEAD
    foreach p.AllActors(class'DolphinJumpTrigger', t) { break; }
    // keep height number in sync with DXREvents GetBingoGoalHelpText
    if(t == None) {
        t = p.Spawn(class'DolphinJumpTrigger',,, p.Location+vect(0,0,160));
    }
    else {
        t.SetLocation(p.Location+vect(0,0,160));
        t.SetCollision(true, false, false);
    }
=======
    // keep height number in sync with DXREvents GetBingoGoalHelpText
    t = p.Spawn(class'DolphinJumpTrigger',,, p.Location+vect(0,0,160));
>>>>>>> 9a23925e (dolphin jump tweaks)
    t.SetTimer(0.55, false);
}

function bool IsRelevant(actor Other)
{
    local #var(PlayerPawn) p;
    p = #var(PlayerPawn)(Other);
    if(p != None) {
        return p.Physics == PHYS_Falling && !p.bOnLadder;
    }
    return false;
}

function Timer()
{
    SelfDestruct();
}

function SelfDestruct()
{
    SetCollision(false,false,false);
}

defaultproperties
{
    CollisionRadius=36
    CollisionHeight=36
    bDestroyOthers=true
    bingoEvent="DolphinJump"
}
