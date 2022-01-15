class DXRHints extends DXRBase transient;

var #var PlayerPawn  _player;
var string hints[100];
var string details[100];
var int numHints;

simulated function InitHints()
{
    AddHint("Try not dying.");
    AddHint("Alcohol can fix dead legs.");
    if(dxr.flags.settings.medbots > 0) {
        AddHint("Medbots are randomized.", "Don't expect to find them in the usual locations.");
    }
    else if(dxr.flags.settings.medbots == 0) {
        AddHint("Medbots are disabled.", "Good luck.");
    }
    if(dxr.flags.settings.repairbots > 0) {
        AddHint("Repair bots are randomized.", "Don't expect to find them in the usual locations.");
    }
    else if(dxr.flags.settings.repairbots == 0) {
        AddHint("Repair bots are disabled.", "Good luck.");
    }
    AddHint("You can carry 5 fire extinguishers in 1 inventory slot.", "They are very useful for stealthily killing multiple enemies.");
}

simulated function AddHint(string hint, optional string detail)
{
    hints[numHints] = hint;
    details[numHints] = detail;
    numHints++;
}

simulated function PlayerRespawn(#var PlayerPawn  player)
{
    Super.PlayerRespawn(player);
    _player = player;
    SetTimer(1, true);
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    Super.PlayerAnyEntry(player);
    if(numHints==0) {
        InitHints();
    }
    _player = player;
    SetTimer(1, true);
}

simulated function int GetHint()
{
    return Rand(numHints);
}

simulated function Timer()
{
    local int hint;
    if(_player.Health > 0) return;
    SetTimer(0, false);
    hint = GetHint();
    class'DXRBigMessage'.static.CreateBigMessage(_player, hints[hint], details[hint]);
}

function RunTests()
{
    local int i, ln;
    Super.RunTests();

    for(i=0; i<numHints; i++) {
        ln = Len(hints[i]);
        test(ln < 100, "length " $ ln $ " of hint: "$hints[i]);

        ln = Len(details[i]);
        test(ln < 100, "length " $ ln $ " of hint detail: "$details[i]);
    }
}
