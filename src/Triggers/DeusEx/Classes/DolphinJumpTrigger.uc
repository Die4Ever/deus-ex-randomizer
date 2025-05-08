#compileif injections || revision
class DolphinJumpTrigger extends BingoTrigger;

static function DolphinJumpTrigger CreateDolphin(PlayerPawn p)
{
    local DolphinJumpTrigger t;

    // keep height number in sync with DXREvents GetBingoGoalHelpText
    t = p.Spawn(class'DolphinJumpTrigger',,, p.Location+vect(0,0,184));
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
    Destroy();
}

defaultproperties
{
    CollisionRadius=32
    CollisionHeight=32
    bDestroyOthers=true
    bingoEvent="DolphinJump"
}
