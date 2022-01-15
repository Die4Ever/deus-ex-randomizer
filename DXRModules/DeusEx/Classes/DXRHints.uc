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

    AddHint("Alcohol and medkits will heal your legs first", "if they are completely broken");
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
    if(dxr.flags.crowdcontrol > 0) {
        AddHint("Viewers, you could've prevented this.", "Or maybe you caused it.");
        AddHint("Don't forget you (the viewer!) can", "use Crowd Control to influence the game!");
    }
    
    if (dxr.flags.settings.goals > 0) {
        //Add this one in once the wiki actually has that info
        //AddHint("Check the Deus Ex Randomizer wiki for information about randomized objective locations!");
    }
    
    AddHint("You can carry 5 fire extinguishers in 1 inventory slot.", "They are very useful for stealthily killing multiple enemies.");
    AddHint("Pepper spray and fire extinguishers can incapacitate an enemy", "letting you sneak past them");
    AddHint("Ever tried to extinguish a fire with a toilet?");
    
    
    mission = dxr.dxInfo.missionNumber;
    map = dxr.localURL;
    if(mission < 1 || mission > 15) {
        // mission number is invalid
    }
    else if(mission <= 4) {
        AddHint("Melee attacks from behind do bonus damage!");
        AddHint("The flashlight (F12) no longer consumes energy when used.", "Go wild with it!");
        AddHint("The flashlight (F12) can be used to attract the attention of guards");
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
            if (map ~= "04_NYC_NSFHQ") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the computer to open","the door on the roof is randomized.");
            }

            break;
        case 5:
            if (map ~= "05_NYC_UnatcoMJ12Lab") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("Pauls location in the lab is randomized.");
            } else if (map ~= "05_NYC_UnatcoHQ") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("Alex Jacobsons location in UNATCO HQ is randomized.");
            }

            break;
        case 6:
            if (map ~= "06_hongkong_mj12lab") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the computer with the ROM Encoding is randomized.");
            }
            break;
        case 8:
            break;
        case 9:
            if (map ~= "09_nyc_graveyard") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of the signal jammer is randomized.");
            } else if (map ~= "09_nyc_shipbelow") {
                 if(dxr.flags.settings.goals > 0)
                    AddHint("The locations of the tri-hull weld points are randomized.");
           
            }

            break;
        case 10:
            break;
        case 11:
            if (map ~= "11_paris_cathedral") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The location of Gunther and the computer is randomized.");
            }

            break;
        case 12:
            if (map ~= "12_vandenberg_cmd") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("The locations of the power generator keypads are randomized.");
            }
            break;
        case 14:
            if (map ~= "14_oceanlab_silo") {
                if(dxr.flags.settings.goals > 0)
                    AddHint("Howard Strong is now on a random floor of the missile silo.");
            }

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
    SetTimer(15, true);
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
