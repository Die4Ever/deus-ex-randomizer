class GuntherWeaponMegaChoice extends WeaponMegaChoice;

var bool bHasWeaponAssaultGun,bHasWeaponStealthPistol,bHasWeaponPistol,bHasWeaponCombatKnife;

function GetWeapons()
{
    bHasWeaponPistol=(p.FindInventoryType(class'WeaponPistol')!=None);
    bHasWeaponStealthPistol=(p.FindInventoryType(class'WeaponStealthPistol')!=None);
    bHasWeaponAssaultGun=(p.FindInventoryType(class'WeaponAssaultGun')!=None);
    bHasWeaponCombatKnife=(p.FindInventoryType(class'WeaponCombatKnife')!=None);
}

function GenerateWeaponChoice()
{
    local Conversation c;
    local ConEvent ce, insertPoint;
    local ConEventChoice megaChoiceEv,choiceEv;
    local ConChoice assaultChoice,stealthChoice,pistolChoice,knifeChoice,nothingChoice,noHelpChoice,choiceIter;
    local int numChoices;

    c = GetConversation(convoName);
    ce = c.eventList;

    while (ce!=None){
        if (insertPoint==None && ce.nextEvent!=None && ce.nextEvent.eventType==ET_CheckObject){
            insertPoint=ce;
        } else if (ce.eventType==ET_Choice){
            choiceEv = ConEventChoice(ce);
            if (choiceEv.ChoiceList!=None){
                choiceIter=choiceEv.ChoiceList;
                while(choiceIter!=None){
                    if (InStr(choiceIter.choiceText,"assault gun")!=-1){
                        assaultChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"stealth pistol")!=-1){
                        stealthChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"Take my pistol")!=-1){
                        pistolChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"Take my knife")!=-1){
                        knifeChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"not very well armed")!=-1){
                        nothingChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"handle the enemy")!=-1){
                        noHelpChoice = choiceIter;
                    }
                    choiceIter=choiceIter.nextChoice;
                }
                choiceIter = None;
            }
        }
        ce = ce.nextEvent;
    }

    if (insertPoint==None ||
        assaultChoice==None || stealthChoice==None || pistolChoice==None ||
        knifeChoice==None || nothingChoice==None || noHelpChoice==None){

        log("ERROR: GuntherWeaponMegaChoice failed to find all conversation options!  Is there a conversation altering mod installed?");
        log("insertPoint: "$insertPoint);
        log("assaultChoice: "$assaultChoice);
        log("stealthChoice: "$stealthChoice);
        log("pistolChoice: "$pistolChoice);
        log("knifeChoice: "$knifeChoice);
        log("nothingChoice: "$nothingChoice);
        log("noHelpChoice: "$noHelpChoice);
        return;
    }

    if (assaultChoice.flagRef!=None || stealthChoice.flagRef!=None || pistolChoice.flagRef!=None || knifeChoice.flagRef!=None){
        log("GuntherWeaponMegaChoice found a flag ref on at least one of the conversation options...  You must have a conversation altering mod installed? Confix?");
    }

    megaChoiceEv = new(c) class'ConEventChoice';
    megaChoiceEv.eventType=ET_Choice;
    megaChoiceEv.nextEvent = insertPoint.nextEvent;
    insertPoint.nextEvent = megaChoiceEv;
    megaChoiceEv.conversation = c;
    megaChoiceEv.bClearScreen = true;
    megaChoiceEv.label="megachoice";

    numChoices = 0;
    megaChoiceEv.ChoiceList = None;

    //Confix adds flagrefs to the weapon choices, so just remove any flagrefs if they exist.
    //Should at least make them work.
    if (bHasWeaponAssaultGun){
        assaultChoice.nextChoice=megaChoiceEv.ChoiceList;
        assaultChoice.flagRef=None;
        megaChoiceEv.ChoiceList = assaultChoice;
        numChoices++;
    }
    if (bHasWeaponPistol){
        pistolChoice.nextChoice=megaChoiceEv.ChoiceList;
        pistolChoice.flagRef=None;
        megaChoiceEv.ChoiceList = pistolChoice;
        numChoices++;
    }
    if (bHasWeaponStealthPistol){
        stealthChoice.nextChoice=megaChoiceEv.ChoiceList;
        stealthChoice.flagRef=None;
        megaChoiceEv.ChoiceList = stealthChoice;
        numChoices++;
    }
    if (bHasWeaponCombatKnife){
        knifeChoice.nextChoice=megaChoiceEv.ChoiceList;
        knifeChoice.flagRef=None;
        megaChoiceEv.ChoiceList = knifeChoice;
        numChoices++;
    }
    if (numChoices==0){
        nothingChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = nothingChoice;
    }

    noHelpChoice.nextChoice=megaChoiceEv.ChoiceList;
    megaChoiceEv.ChoiceList = noHelpChoice;
}

defaultproperties
{
    convoName=GuntherRescued
}
