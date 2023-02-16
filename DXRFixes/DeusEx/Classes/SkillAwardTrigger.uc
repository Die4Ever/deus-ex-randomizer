class SkillAwardTrigger injects SkillAwardTrigger;

function Trigger(Actor Other, Pawn Instigator)
{
    Super.Trigger(Other, Instigator);
    if(bTriggerOnceOnly && #var(PlayerPawn)(Instigator) != None)
        Tag = '';
}
