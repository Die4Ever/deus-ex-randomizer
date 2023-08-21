class BalanceAugHealing injects AugHealing;

//DXR: put a cap on the health that regen gives you
state Active
{
Begin:
Loop:
    Sleep(1.0);

    if (NeedsHeal())
        HealPlayer(6); // 6 health at a time because 6 body parts
    else
        Deactivate();

    Player.ClientFlash(0.5, vect(0, 0, 500));
    Goto('Loop');
}

function HealPlayer(int amount) {
    local int origHealAmount;
    origHealAmount = amount;

    while(amount > 0 && NeedsHeal()) {
        HealPartOne(Player.HealthHead, amount);
        HealPartOne(Player.HealthTorso, amount);
        HealPartOne(Player.HealthLegRight, amount);
        HealPartOne(Player.HealthLegLeft, amount);
        HealPartOne(Player.HealthArmRight, amount);
        HealPartOne(Player.HealthArmLeft, amount);
    }

    Player.GenerateTotalHealth();

    amount = origHealAmount - amount;

    if (amount == 1)
        Player.ClientMessage(Sprintf(Player.HealedPointLabel, amount));
    else if (amount > 0)
        Player.ClientMessage(Sprintf(Player.HealedPointsLabel, amount));
    else
        Deactivate();
}

function HealPart(out int points, out int amt)
{
    local int max;

    max = Int(LevelValues[CurrentLevel]);
    HealPartMax(points, amt, max);
}

function HealPartOne(out int points, out int amt)
{
    HealPartMax(points, amt, points+1);
}

function HealPartMax(out int points, out int amt, int max)
{
    local int spill;

    max = Min(max, Player.default.HealthTorso);
    max = Min(max, LevelValues[CurrentLevel]);

    if(points >= max) return;
    if(amt <= 0) return;

    points += amt;
    spill = points - max;
    if (spill > 0)
        points = max;
    else
        spill = 0;

    amt = spill;
}

function bool NeedsHeal()
{
    local int i;
    i = Int(LevelValues[CurrentLevel]);
    return Player.HealthHead < Min(i, Player.default.HealthHead)
        || Player.HealthTorso < Min(i, Player.default.HealthTorso)
        || Player.HealthLegRight < Min(i, Player.default.HealthLegRight)
        || Player.HealthLegLeft < Min(i, Player.default.HealthLegLeft)
        || Player.HealthArmRight < Min(i, Player.default.HealthArmRight)
        || Player.HealthArmLeft < Min(i, Player.default.HealthArmLeft);
}

// original values go from 5 to 40, but those controlled healing rate, EnergyRate of 120
defaultproperties
{
     EnergyRate=140
     LevelValues(0)=25
     LevelValues(1)=40
     LevelValues(2)=55
     LevelValues(3)=70
}
