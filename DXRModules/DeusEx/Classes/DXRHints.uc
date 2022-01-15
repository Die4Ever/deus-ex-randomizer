class DXRHints extends DXRBase transient;

var #var PlayerPawn  _player;

// if this hints array is too long, then no one will ever see the best hints
var string hints[100];
var string details[100];
var int numHints;

simulated function InitHints()
{
    local int mission;
    local string map;

    AddHint("Alcohol can fix dead legs.");
    AddHint("You can carry 5 fire extinguishers in 1 inventory slot.", "They are very useful for stealthily killing multiple enemies.");

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
    if(dxr.flags.crowdcontrol) {
        AddHint("Viewers, you could've prevented this.", "Or maybe you caused it.");
    }

    mission = dxr.dxInfo.missionNumber;
    map = dxr.localURL;
    if(mission < 1 || mission > 15) {
        // mission number is invalid
    }
    else if(mission <= 4) {
    }
    else if(mission <= 9) {
    }
    else if(mission <= 15) {
        AddHint("Try not dying.");
    }

    // ~= is case insensitive equality
    switch(dxr.dxInfo.missionNumber) {
        case 1:
            if(map ~= "01_NYC_UNATCOIsland") {
                if(dxr.flags.settings.passwordsrandomized > 0)
                    AddHint("Passwords have been randomized.", "Don't even try smashthestate!");
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the terrorist commander is randomized.");
            }
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        case 6:
            break;
        case 8:
            break;
        case 9:
            break;
        case 10:
            break;
        case 11:
            break;
        case 12:
            break;
        case 14:
            break;
        case 15:
            break;
    };
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
    // don't use the stable rng that we use for other things, needs to be different every time
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
