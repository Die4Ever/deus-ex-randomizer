class GuntherWeaponMegaChoice extends WeaponMegaChoice;

var bool bHasWeaponAssaultGun,bHasWeaponStealthPistol,bHasWeaponPistol,bHasWeaponCombatKnife;

function GenerateWeaponChoice()
{
    local Conversation c;
    local ConEvent ce, insertPoint;
    local ConEventChoice megaChoiceEv,choiceEv;
    local ConChoice assaultChoice,stealthChoice,pistolChoice,knifeChoice,nothingChoice,noHelpChoice,choiceIter;

    // Check for weapons in inventory only once, and store the result in a variable
    bHasWeaponAssaultGun    = p.FindInventoryType(class'WeaponAssaultGun') != None;
    bHasWeaponStealthPistol = p.FindInventoryType(class'WeaponStealthPistol') != None;
    bHasWeaponPistol        = p.FindInventoryType(class'WeaponPistol') != None;
    bHasWeaponCombatKnife   = p.FindInventoryType(class'WeaponCombatKnife') != None;

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
                    if (assaultChoice == None && InStr(choiceIter.choiceText,"Take my assault gun")!=-1){
                        assaultChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (stealthChoice == None && InStr(choiceIter.choiceText,"Take my stealth pistol")!=-1){
                        stealthChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (pistolChoice == None && InStr(choiceIter.choiceText,"Take my pistol")!=-1){
                        pistolChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (knifeChoice == None && InStr(choiceIter.choiceText,"Take my knife")!=-1){
                        knifeChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (nothingChoice == None && InStr(choiceIter.choiceText,"not very well armed")!=-1){
                        nothingChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (noHelpChoice == None && InStr(choiceIter.choiceText,"handle the enemy")!=-1){
                        noHelpChoice = CreateConChoiceCopy(c, choiceIter);
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

    megaChoiceEv = new(c) class'ConEventChoice';
    megaChoiceEv.eventType=ET_Choice;
    megaChoiceEv.nextEvent = insertPoint.nextEvent;
    insertPoint.nextEvent = megaChoiceEv;
    megaChoiceEv.conversation = c;
    megaChoiceEv.bClearScreen = true;
    megaChoiceEv.label="megachoice";

    // Start with noHelpChoice at the end of the chain, then work backwards through the other choices
    megaChoiceEv.ChoiceList = noHelpChoice;

    if (bHasWeaponCombatKnife){
        knifeChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = knifeChoice;
    }
    if (bHasWeaponPistol){
        pistolChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = pistolChoice;
    }
    if (bHasWeaponStealthPistol){
        stealthChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = stealthChoice;
    }
    if (bHasWeaponAssaultGun){
        assaultChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = assaultChoice;
    }
    if (megaChoiceEv.ChoiceList == noHelpChoice){
        nothingChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = nothingChoice;
    }
}

defaultproperties
{
    convoName=GuntherRescued
}
