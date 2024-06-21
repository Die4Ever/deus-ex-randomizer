class GilbertWeaponMegaChoice extends WeaponMegaChoice;

var bool bHasWeaponPistol,bHasWeaponStealthPistol,bHasWeaponSawedOffShotgun,bHasWeaponCombatKnife,bHasWeaponMiniCrossbow;

function GenerateWeaponChoice()
{
    local Conversation c;
    local ConEvent ce, insertPoint;
    local ConEventChoice megaChoiceEv,choiceEv;
    local ConChoice sawedOffChoice,stealthChoice,pistolChoice,knifeChoice,crossbowChoice,noHelpChoice,choiceIter;

    // Check for weapons in inventory only once, and store the result in a variable
    bHasWeaponPistol          = p.FindInventoryType(class'WeaponPistol') != None;
    bHasWeaponStealthPistol   = p.FindInventoryType(class'WeaponStealthPistol') != None;
    bHasWeaponSawedOffShotgun = p.FindInventoryType(class'WeaponSawedOffShotgun') != None;
    bHasWeaponCombatKnife     = p.FindInventoryType(class'WeaponCombatKnife') != None;
    bHasWeaponMiniCrossbow    = p.FindInventoryType(class'WeaponMiniCrossbow') != None;

    if (!(bHasWeaponPistol || bHasWeaponStealthPistol || bHasWeaponSawedOffShotgun || bHasWeaponCombatKnife || bHasWeaponMiniCrossbow)){
        return; //Just let it fall through as normal, no changes needed
    }

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
                    if (pistolChoice == None && InStr(choiceIter.choiceText,"have my pistol")!=-1){
                        pistolChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (stealthChoice == None && InStr(choiceIter.choiceText,"have my stealth pistol")!=-1){
                        stealthChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (sawedOffChoice == None && InStr(choiceIter.choiceText,"have my sawed-off shotgun")!=-1){
                        sawedOffChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (knifeChoice == None && InStr(choiceIter.choiceText,"have my knife")!=-1){
                        knifeChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (crossbowChoice == None && InStr(choiceIter.choiceText,"have my mini-crossbow")!=-1){
                        crossbowChoice = CreateConChoiceCopy(c, choiceIter);
                    } else if (noHelpChoice == None && InStr(choiceIter.choiceText,"rather not arm a civilian")!=-1){
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
        pistolChoice==None || stealthChoice==None || sawedOffChoice==None ||
        knifeChoice==None || crossbowChoice==None || noHelpChoice==None){

        log("ERROR: GilbertWeaponMegaChoice failed to find all conversation options!  Is there a conversation altering mod installed?");
        log("insertPoint: "$insertPoint);
        log("pistolChoice: "$pistolChoice);
        log("stealthChoice: "$stealthChoice);
        log("sawedOffChoice: "$sawedOffChoice);
        log("knifeChoice: "$knifeChoice);
        log("crossbowChoice: "$crossbowChoice);
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

    if (bHasWeaponMiniCrossbow){
        crossbowChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = crossbowChoice;
    }
    if (bHasWeaponCombatKnife){
        knifeChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = knifeChoice;
    }
    if (bHasWeaponSawedOffShotgun){
        sawedOffChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = sawedOffChoice;
    }
    if (bHasWeaponStealthPistol){
        stealthChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = stealthChoice;
    }
    if (bHasWeaponPistol){
        pistolChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = pistolChoice;
    }
}

defaultproperties
{
    convoName=InterruptFamilySquabble
}
