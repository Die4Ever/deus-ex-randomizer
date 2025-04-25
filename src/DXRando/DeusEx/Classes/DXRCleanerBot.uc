class DXRCleanerBot injects CleanerBot;

function Tick(float deltaTime)
{
    // the way vanilla is coded, CleanerBots will go into the 'AvoidingPawn' state after being disabled
    if (EMPHitPoints == 0) {
        Super(Robot).Tick(deltaTime);
    } else {
        Super.Tick(deltaTime);
    }
}

#ifdef injections
state Wandering
{
    ignores EnemyNotVisible;

Begin:
    destPoint = None;

GoHome:
    bAcceptBump = false;
    TweenToWalking(0.15);
    WaitForLanding();
    FinishAnim();
    PlayWalking();

Wander:
    PickDestination();

Moving:
    // Move from pathnode to pathnode until we get where we're going
    PlayWalking();
    MoveTo(destLoc, GetWalkingSpeed());

Pausing:
    if (destLoc == Location)
        Sleep(1.0);
    Goto('Wander');

ContinueWander:
ContinueFromDoor:
    FinishAnim();
    PlayWalking();
    Goto('Wander');
}
#endif
