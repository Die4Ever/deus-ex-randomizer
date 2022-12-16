class BalanceAugHealing injects AugHealing;

//DXR: put a cap on the health that regen gives you
state Active
{
Begin:
Loop:
	Sleep(1.0);

	if (Player.Health < 100)
		HealPlayer(5);
	else
		Deactivate();

	Player.ClientFlash(0.5, vect(0, 0, 500));
	Goto('Loop');
}

function HealPlayer(int amount) {
    local int origHealAmount;
    origHealAmount = amount;

    HealPart(Player.HealthHead, amount);
    HealPart(Player.HealthTorso, amount);

    // fix broken limbs after the head and torso (I don't want to buff healing aug too much? but I also don't want lower levels to be preferable due to them healing more evenly?)
    HealPartMax(Player.HealthLegRight, amount, 1);
    HealPartMax(Player.HealthLegLeft, amount, 1);
    HealPartMax(Player.HealthArmRight, amount, 1);
    HealPartMax(Player.HealthArmLeft, amount, 1);

    HealPart(Player.HealthLegRight, amount);
    HealPart(Player.HealthLegLeft, amount);
    HealPart(Player.HealthArmRight, amount);
    HealPart(Player.HealthArmLeft, amount);

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

function HealPartMax(out int points, out int amt, int max)
{
	local int spill;

	points += amt;
	spill = points - max;
	if (spill > 0)
		points = max;
	else
		spill = 0;

	amt = spill;
}

// original values go from 5 to 40, but those controlled healing rate
defaultproperties
{
     LevelValues(0)=35
     LevelValues(1)=50
     LevelValues(2)=65
     LevelValues(3)=80
}
