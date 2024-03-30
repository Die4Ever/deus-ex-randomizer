class DXRAugDefense injects AugDefense;

// ------------------------------------------------------------------------------
// FindNearestProjectile()
// DEUS_EX AMSD Exported to a function since it also needs to exist in the client
// TriggerDefenseAugHUD;
// DXRando: ignore bStuck projectiles, we can't do this in the super because we need it to return the 2nd closest projectile if there is a stuck one
//          also only track projectiles to a certain distance, to reduce energy usage and annoyance
// ------------------------------------------------------------------------------

simulated function DeusExProjectile FindNearestProjectile()
{
    local DeusExProjectile proj, minproj;
    local float dist, mindist;
    local bool bValidProj;

    minproj = None;
    mindist = 999999;
    foreach RadiusActors(class'DeusExProjectile', proj, LevelValues[CurrentLevel] + 160, player.Location)
    {
        if (Level.NetMode != NM_Standalone)
            bValidProj = !proj.bIgnoresNanoDefense;
        else
            bValidProj = (!proj.IsA('Cloud') && !proj.IsA('Tracer') && !proj.IsA('GreaselSpit') && !proj.IsA('GraySpit'));

        if (!bValidProj) continue;
        if (proj.bStuck) continue;

        // make sure we don't own it
        if (proj.Owner != Player)
        {
            // MBCODE : If team game, don't blow up teammates projectiles
            if (!((TeamDMGame(Player.DXGame) != None) && (TeamDMGame(Player.DXGame).ArePlayersAllied(DeusExPlayer(proj.Owner),Player))))
            {
                // make sure it's moving fast enough
                if (VSize(proj.Velocity) > 100)
                {
                    dist = VSize(Player.Location - proj.Location);
                    if (dist < mindist)
                    {
                        mindist = dist;
                        minproj = proj;
                    }
                }
            }
        }
   }

   if(minproj != None) {
        TickUse();
    }

   return minproj;
}

// DXRando: just reduce the volume on the sounds lol
state Active
{
    function Timer()
    {
        local DeusExProjectile minproj;
        local float mindist;

        minproj = None;

        // DEUS_EX AMSD Multiplayer check
        if (Player == None)
        {
            SetTimer(0.1,False);
            return;
        }

        if (Player.energy <= 0) return;

        // In multiplayer propagate a sound that will let others know their in an aggressive defense field
        // with range slightly greater than the current level value of the aug
        if ( (Level.NetMode != NM_Standalone) && ( Level.Timeseconds > defenseSoundTime ))
        {
            Player.PlaySound(Sound'AugDefenseOn', SLOT_Interact, 1.0, ,(LevelValues[CurrentLevel]*1.33), 0.75);
            defenseSoundTime = Level.Timeseconds + defenseSoundDelay;
        }

        //DEUS_EX AMSD Exported to function call for duplication in multiplayer.
        minproj = FindNearestProjectile();

        // if we have a valid projectile, send it to the aug display window
        if (minproj != None)
        {
            bDefenseActive = True;
            mindist = VSize(Player.Location - minproj.Location);

            // DEUS_EX AMSD In multiplayer, let the client turn his HUD on here.
            // In singleplayer, turn it on normally.
            if (Level.Netmode != NM_Standalone)
                TriggerDefenseAugHUD();
            else
            {
                SetDefenseAugStatus(True,CurrentLevel,minproj);
            }

            // play a warning sound
            Player.PlaySound(sound'GEPGunLock', SLOT_None, 0.5,,, 2.0);

            if (mindist < LevelValues[CurrentLevel])
            {
                minproj.bAggressiveExploded=True;
                minproj.Explode(minproj.Location, vect(0,0,1));
                Player.PlaySound(sound'ProdFire', SLOT_None,,,, 2.0);
            }
        }
        else
        {
            if ((Level.NetMode == NM_Standalone) || (bDefenseActive))
                SetDefenseAugStatus(False,CurrentLevel,None);
            bDefenseActive = false;
        }
    }

Begin:
    SetTimer(0.1, True);
}


// vanilla is mpEnergyDrain=35, EnergyRate=10, vanilla AugBallistic is mpEnergyDrain=90, EnergyRate=60
defaultproperties
{
    bAutomatic=true
    mpEnergyDrain=60.000000
    EnergyRate=30.000000
}
