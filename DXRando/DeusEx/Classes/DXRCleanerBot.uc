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
