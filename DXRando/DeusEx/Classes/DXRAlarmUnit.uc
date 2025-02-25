class DXRAlarmUnit injects #var(prefix)AlarmUnit;

function HackAction(Actor Hacker, bool bHacked)
{
    Super.HackAction(Hacker, bHacked);

    if (bHacked)
    {
        //Normally the units are only disabled if
        //they are hacked while going off, which
        //is stupid.  This will prevent them from
        //being triggered again after being hacked
        bDisabled = True;
    }
}

auto state Active
{

}
