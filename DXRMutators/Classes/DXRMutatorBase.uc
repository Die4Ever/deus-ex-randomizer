class DXRMutatorBase extends Mutator;

function BeginPlay()
{
    local string s;
    local DeusExPlayer p;

    Super.BeginPlay();
    p = DeusExPlayer(GetPlayerPawn());
    if(p == None) {
        log("ERROR: " $ self @ "BeginPlay()" @ Owner @ "unable to find DeusExPlayer");
        return;
    }
    s = string(p.FlagBase.GetInt('Rando_merchants'));
    p.ClientMessage(self @ "Rando_merchants" @ s);
    p.ClientMessage(self @ "I was compiled with #var(package)");
}

function ScoreKill(Pawn Killer, Pawn Other)
{
    log(self@"ScoreKill"@Killer@Other);
    Super.ScoreKill(Killer, Other);
}

simulated event PostRender( canvas Canvas )
{
    log(self@"PostRender"@Canvas);
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation,
						out Vector Momentum, name DamageType)
{
    log(self@"MutatorTakeDamage"@Victim@InstigatedBy);
    Super.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}
