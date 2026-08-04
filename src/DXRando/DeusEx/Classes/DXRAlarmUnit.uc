class DXRAlarmUnit injects #var(prefix)AlarmUnit;

function Tick(float deltaTime)
{
    local bool wasConfused;

    wasConfused = bConfused;
    Super.Tick(deltaTime);

    if (wasConfused && !bConfused){
        //put the skin back into the idle mode instead of the active mode
        SetLightState(false);
    }
}

//Allow alarm panels to be disabled by an EMP blast
//Normally the "untrigger" doesn't happen when a panel is confused
function UnTrigger(Actor Other, Pawn Instigator)
{
    local bool wasConfused;

    wasConfused = bConfused;
    bConfused = False;
    Super.UnTrigger(Other,Instigator);
    bConfused = wasConfused;
}


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
        SetLightState(false); //Hacking an active panel leaves it with a black texture for some reason
    }
}

//Compartmentalize the HDTP/Not-HDTP logic into one place
function SetLightState(bool bOn)
{
    if (IsDXRHDTP()){
        if (bOn){
        #ifdef gmdxnotae
            MultiSkins[1] = Texture'HDTPAlarmUnittex2';
            MultiSkins[2] = Texture'HDTPAlarmUnittex2';
        #elseif gmdxae
            MultiSkins[1] = class'HDTPLoader'.static.GetTexture("HDTPAlarmUnittex2");
            MultiSkins[2] = class'HDTPLoader'.static.GetTexture("HDTPAlarmUnittex2");
        #elseif revision
            MultiSkins[1] = MultiSkins[7];
            MultiSkins[2] = MultiSkins[7];
        #endif
        } else {
        #ifdef gmdxnotae
            MultiSkins[1] = Texture'HDTPAlarmUnittex1';
        #elseif gmdxae
            MultiSkins[1] = class'HDTPLoader'.static.GetTexture("HDTPAlarmUnittex1");
        #elseif revision
            MultiSkins[1] = MultiSkins[6];
        #endif
            MultiSkins[2] = Texture'PinkMaskTex';

        }
    } else {
        if (bOn){
            MultiSkins[1] = Texture'AlarmUnitTex2';
        } else {
            MultiSkins[1] = Texture'PinkMaskTex';
        }
    }
}

function bool IsDXRHDTP()
{
    local bool isThisHDTP;

    #ifdef gmdxnotae
        isThisHDTP=true;
    #elseif revision
        //Revision has the vanilla mesh set as Default.Mesh, and HDTP as something else
        //Revision stores the "on" texture in slot 7 and (half of) the "off" texture in slot 6
        isThisHDTP = (Mesh!=Default.Mesh);
    #elseif gmdxae
        return IsHDTP();
    #endif

    return isThisHDTP;

}

auto state Active
{

}
