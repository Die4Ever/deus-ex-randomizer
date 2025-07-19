class DXRandoCrowdControlPawn extends ScriptedPawn;

var float LastUsed;

const CCPawnLifespan = 300;

function BeginPlay()
{
    Super.BeginPlay();
    LastRenderTime = Level.TimeSeconds; //Hack to keep it out of stasis
    LastUsed=Level.TimeSeconds;
    bStasis=False;
}

simulated function Tick(float deltaTime)
{
    Super.Tick(deltaTime);

    //Get rid of the Crowd Control pawn after a while
    //so it isn't ticking away constantly
    if (Level.TimeSeconds > LastUsed+CCPawnLifespan){
        Destroy();
    }

    LastRenderTime = Level.TimeSeconds; //Hack to keep it out of stasis
    bStasis=False;
}

simulated function UsePawn()
{
    LastUsed=Level.TimeSeconds;
}

defaultproperties
{
     bInvincible=True
     bInWorld=False
     bImportant=True
     bPlayIdle=False
     bAvoidAim=False
     bReactProjectiles=False
     bFearShot=False
     bFearIndirectInjury=False
     bFearCarcass=False
     bFearDistress=False
     bFearAlarm=False
     bCanTurnHead=False
     bCanStrafe=False
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     BindName="CrowdControlPawn"
     bAlwaysRelevant=True
     bHidden=True
     bMovable=False
     bDetectable=False
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Physics=PHYS_None
     bHighlight=False
     bHasShadow=False
}
