class DXRAlarmUnit injects #var(prefix)AlarmUnit;

function HackAction(Actor Hacker, bool bHacked)
{
    if (bHacked && !bDisabled){
        class'DXREvents'.static.MarkBingo("AlarmUnitHacked");
    }

    Super.HackAction(Hacker, bHacked);

    if (bHacked){
        //Normally the units are only disabled if
        //they are hacked while going off, which
        //is stupid.  This will prevent them from
        //being triggered again after being hacked.
        //This has to happen after the Super, otherwise
        //the panel won't be Untrigger'd, so it will
        //keep alarming after being hacked while active.
        bDisabled = True;
    }
}

auto state Active
{

}
