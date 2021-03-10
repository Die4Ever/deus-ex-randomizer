class DynamicTeleporter extends Teleporter;

var float proxCheckTime;
var float Radius;

simulated function Tick(float deltaTime)
{
    local DeusExPlayer Player;
    Super.Tick(deltaTime);
    proxCheckTime += deltaTime;
    if (proxCheckTime > 0.1)//every 100ms
    {
        proxCheckTime = 0;
        foreach RadiusActors(class'DeusExPlayer', Player, Radius)
        {
            Touch(Player);
        }
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
	Touch(Instigator);
}

defaultproperties
{
    bGameRelevant=True
    bCollideActors=False
    bStatic=False
    Radius=160
}
