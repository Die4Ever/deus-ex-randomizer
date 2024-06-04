class GoalInfo extends Object;

struct GInfo
{
    var string goalName; // can't be a name or else it can't be set in defaultproperties for some reason
    var string text1, text2;
};

var GInfo infos[3];

// can never be perfect because some goals have multiple possible texts
static function string GetGoalText(coerce string goalName)
{
    local GInfo inf;
    local int i;

    for (i = 0; i < ArrayCount(default.infos); i++) {
        inf = default.infos[i];
        if (inf.goalName == goalName) {
            return inf.text1 $ inf.text2;
        }
    }
    return "";
}

defaultproperties
{
    infos(0)=(goalName="KillPage",text1="(Join Illuminati)  Kill Bob Page and clear the way for the former Illuminati leaders to restore an age-old secret government.  Rule the world with compassion and an invisible hand alongside Morgan Everett.")
    infos(1)=(goalName="DeactivateLocks",text1="(New Dark Age)  First go to the coolant control room at the northwest corner of Sector 4 and cut ",text2="off coolant to the reactors, then return to the reactor lab in Sector 3 to finish the job.  Destroying the global communications hub will plunge the world into another dark age -- dark but perhaps free from global tyranny.")
    infos(2)=(goalName="DestroyArea51",text1="(Merge with Helios AI)  Deactivate the uplink locks on the Aquinas Router at the east end of Sector 4, thus allowing Helios to exchange information with your augmentations.  Together with Helios, administrate the world with absolute knowledge and reason.")
}
