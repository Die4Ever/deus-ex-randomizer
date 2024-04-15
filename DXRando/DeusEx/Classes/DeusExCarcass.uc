class DXRDeusExCarcass injects DeusExCarcass;

function InitFor(Actor Other)
{
	if (Other != None)
	{
		if (bAnimalCarcass) {
            if (Other.IsA('ScriptedPawn'))
            {
                itemName = ScriptedPawn(Other).Default.FamiliarName $ " Carcass";
                if (ScriptedPawn(Other).FamiliarName != ScriptedPawn(Other).Default.FamiliarName)
                    itemName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
            }
            else
                itemName = msgAnimalCarcass;
        }
        else
        {
            if (bNotDead)
                itemName = msgNotDead;
            if (Other.IsA('ScriptedPawn'))
                itemName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
        }

		Mass           = Other.Mass;
		Buoyancy       = Mass * 1.2;
		MaxDamage      = 0.8*Mass;
		if (ScriptedPawn(Other) != None)
			if (ScriptedPawn(Other).bBurnedToDeath)
				CumulativeDamage = MaxDamage-1;

		SetScaleGlow();

		// Will this carcass spawn flies?
		if (bAnimalCarcass)
		{
			if (FRand() < 0.2)
				bGenerateFlies = true;
		}
		else if (!Other.IsA('Robot') && !bNotDead)
		{
			if (FRand() < 0.1)
				bGenerateFlies = true;
			bEmitCarcass = true;
		}

		if (Other.AnimSequence == 'DeathFront')
			Mesh = Mesh2;

		// set the instigator and tag information
		if (Other.Instigator != None)
		{
			KillerBindName = Other.Instigator.BindName;
			KillerAlliance = Other.Instigator.Alliance;
		}
		else
		{
			KillerBindName = Other.BindName;
			KillerAlliance = '';
		}
		Tag = Other.Tag;
		Alliance = Pawn(Other).Alliance;
		CarcassName = Other.Name;
	}
}

defaultproperties
{
    msgNotDead="Unconscious Body"
}
