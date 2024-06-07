class DXRSkill merges Skill;
// merges instead of injects, because: Error, DeusEx.Skill's superclass must be Engine.Actor, not DeusEx.SkillInjBase

// IncLevel is mostly vanilla, but with a message when upgrading
function bool IncLevel(optional DeusExPlayer usePlayer)
{
    local DeusExPlayer localPlayer;

    // First make sure we're not maxed out
    if (CurrentLevel < 3)
    {
        // If "usePlayer" is passed in, then we want to use this
        // as the basis for making our calculations, temporarily
        // overriding whatever this skill's player is set to.

        if (usePlayer != None)
            localPlayer = usePlayer;
        else
            localPlayer = Player;

        // Now, if a player is defined, then check to see if there enough
        // skill points available.  If no player is defined, just do it.
        if (localPlayer != None)
        {
            if ((localPlayer.SkillPointsAvail >= Cost[CurrentLevel]))
            {
                // decrement the cost and increment the current skill level
                localPlayer.SkillPointsAvail -= GetCost();
                CurrentLevel++;
                localPlayer.ClientMessage(SkillName $ " upgraded to " $ skillLevelStrings[CurrentLevel]);
                return True;
            }
        }
        else
        {
            CurrentLevel++;
            log(SkillName $ " upgraded to " $ skillLevelStrings[CurrentLevel]);
            return True;
        }
    }

    return False;
}
