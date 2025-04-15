//A trigger to specifically be used in Area 51 Sector 2 on the elevator down to Sector 3
//Barely a scratch?  Let the machine find out.
class Area51ScratchOMatic extends Trigger;

var int startHealth;

enum EHealthComment
{
    HC_NotInjured,
    HC_Injured,
    HC_Hurting
};

function string HealthCommentEnumToString(EHealthComment hc)
{
    switch(hc){
        case HC_NotInjured:
            //Barely a scratch.  You're a little faster on your feet then your daddy was.
            return "NotInjured";
        case HC_Injured:
            //Looks like you're bleeding, Denton, and those were only the grunts.  This is going to be easy...
            return "Injured";
        case HC_Hurting:
            //Looking pretty beat up, Denton.  Bet you go down with the next shot.
            return "Hurting";
    }
    return "NotInjured";
}

//This will be Trigger'ed by the conversation at the top (DL_Elevator),
//and then Trigger'ed again at the start of DL_Final_Page02 on the way down
function Trigger(Actor Other, Pawn Instigator)
{
    local #var(PlayerPawn) p;

    p = #var(PlayerPawn)(GetPlayerPawn());
    if (p==None) return;

    if (startHealth==-1) {
        //Initial trigger stores your health state
        startHealth=p.Health;
    } else {
        //Subsequent trigger adds the jump in the conversation
        HandleDamageResult(p.Health, p.BleedRate>0);
    }
}

function HandleDamageResult(int curHealth, bool bleeding)
{
    local int healthDiff;
    local EHealthComment cur,diff,bleed,finalRes;

    healthDiff = startHealth - curHealth;

    //Determine a comment based on how much health you lost
    if (healthDiff<10){
        diff = HC_NotInjured;
    } else if (healthDiff<50){
        diff = HC_Injured;
    } else {
        diff = HC_Hurting;
    }

    //Determine a comment based on current health
    if (curHealth<34){
        cur = HC_Hurting;
    } else if (curHealth<67){
        cur = HC_Injured;
    } else {
        cur = HC_NotInjured;
    }

    //Is the player literally bleeding?
    bleed = HC_NotInjured;
    if (bleeding){
        bleed = HC_Injured; //"Looks like you're bleeding, Denton"
    }

    log("Area51ScratchOMatic:  HealthDiff:"$diff$"  Cur:"$cur$"  Bleeding:"$bleed);

    //Find which one is worst
    finalRes = diff;
    if (cur>finalRes){
        finalRes = cur;
    }
    if (bleed>finalRes){
        finalRes = bleed;
    }

    AddConEventJump(HealthCommentEnumToString(finalRes));
}

function AddConEventJump(string jumpLabel)
{
    local Conversation c;
    local ConEventTrigger cet;
    local ConEvent ce;
    local ConEventJump cej;
    local DXRFixup fixups;

    fixups=DXRFixup(class'DXRFixup'.static.Find());

    if (fixups==None) return;

    c = fixups.GetConversation('DL_Final_Page02');
    if (c != None) {
        ce = c.eventList;
        while (ce!=None){
            if (ce.eventType==ET_Trigger){
                cet=ConEventTrigger(ce);
                if (cet.triggerTag==Tag){
                    cej = new(c) class'ConEventJump';
                    cej.eventType = ET_Jump;
                    cej.jumpLabel = jumpLabel;
                    cej.nextEvent = cet.nextEvent;
                    cet.nextEvent = cej;
                    break;
                }
            }
            ce = ce.nextEvent;
        }
    }
}

defaultproperties
{
    startHealth=-1
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
}
