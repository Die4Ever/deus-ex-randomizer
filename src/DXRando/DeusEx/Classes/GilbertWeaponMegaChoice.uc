class GilbertWeaponMegaChoice extends WeaponMegaChoice;

var bool bHasWeaponPistol,bHasWeaponStealthPistol,bHasWeaponSawedOffShotgun,bHasWeaponCombatKnife,bHasWeaponMiniCrossbow;

function bool HasNoWeapons()
{
    return (!bHasWeaponPistol && !bHasWeaponStealthPistol && !bHasWeaponSawedOffShotgun && !bHasWeaponCombatKnife && !bHasWeaponMiniCrossbow);
}

function GetWeapons()
{
    bHasWeaponPistol=(p.FindInventoryType(class'WeaponPistol')!=None);
    bHasWeaponStealthPistol=(p.FindInventoryType(class'WeaponStealthPistol')!=None);
    bHasWeaponSawedOffShotgun=(p.FindInventoryType(class'WeaponSawedOffShotgun')!=None);
    bHasWeaponCombatKnife=(p.FindInventoryType(class'WeaponCombatKnife')!=None);
    bHasWeaponMiniCrossbow=(p.FindInventoryType(class'WeaponMiniCrossbow')!=None);
}

function GenerateWeaponChoice()
{
    local Conversation c;
    local ConEvent ce, insertPoint;
    local ConEventChoice megaChoiceEv,choiceEv;
    local ConChoice sawedOffChoice,stealthChoice,pistolChoice,knifeChoice,crossbowChoice,noHelpChoice,choiceIter;

    if (HasNoWeapons()){
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
                    //Pistol, Stealth Pistol, Sawed off, Knife, Crossbow
                    if (InStr(choiceIter.choiceText,"sawed-off shotgun")!=-1){
                        sawedOffChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"have my stealth pistol")!=-1){
                        stealthChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"have my pistol")!=-1){
                        pistolChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"have my knife")!=-1){
                        knifeChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"have my mini-crossbow")!=-1){
                        crossbowChoice = choiceIter;
                    } else if (InStr(choiceIter.choiceText,"rather not arm a civilian")!=-1){
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
        sawedOffChoice==None || stealthChoice==None || pistolChoice==None ||
        knifeChoice==None || crossbowChoice==None || noHelpChoice==None){

        log("ERROR: GilbertWeaponMegaChoice failed to find all conversation options!  Is there a conversation altering mod installed?");
        log("insertPoint: "$insertPoint);
        log("sawedOffChoice: "$sawedOffChoice);
        log("stealthChoice: "$stealthChoice);
        log("pistolChoice: "$pistolChoice);
        log("knifeChoice: "$knifeChoice);
        log("crossbowChoice: "$crossbowChoice);
        log("noHelpChoice: "$noHelpChoice);
        return;
    }

    if (sawedOffChoice.flagRef!=None || stealthChoice.flagRef!=None || pistolChoice.flagRef!=None ||
        knifeChoice.flagRef!=None || crossbowChoice.flagRef!=None){
        log("GilbertWeaponMegaChoice found a flag ref on at least one of the conversation options...  You must have a conversation altering mod installed? Confix?");
    }

    megaChoiceEv = new(c) class'ConEventChoice';
    megaChoiceEv.eventType=ET_Choice;
    megaChoiceEv.nextEvent = insertPoint.nextEvent;
    insertPoint.nextEvent = megaChoiceEv;
    megaChoiceEv.conversation = c;
    megaChoiceEv.bClearScreen = true;
    megaChoiceEv.label="megachoice";

    megaChoiceEv.ChoiceList = None;

    //Confix adds flagrefs to the weapon choices, so just remove any flagrefs if they exist.
    //Should at least make them work.
    if (bHasWeaponCombatKnife){
        knifeChoice.nextChoice=megaChoiceEv.ChoiceList;
        knifeChoice.flagRef=None;
        megaChoiceEv.ChoiceList = knifeChoice;
    }
    if (bHasWeaponSawedOffShotgun){
        sawedOffChoice.nextChoice=megaChoiceEv.ChoiceList;
        sawedOffChoice.flagRef=None;
        megaChoiceEv.ChoiceList = sawedOffChoice;
    }
    if (bHasWeaponPistol){
        pistolChoice.nextChoice=megaChoiceEv.ChoiceList;
        pistolChoice.flagRef=None;
        megaChoiceEv.ChoiceList = pistolChoice;
    }
    if (bHasWeaponStealthPistol){
        stealthChoice.nextChoice=megaChoiceEv.ChoiceList;
        stealthChoice.flagRef=None;
        megaChoiceEv.ChoiceList = stealthChoice;
    }
    if (bHasWeaponMiniCrossbow){
        crossbowChoice.nextChoice=megaChoiceEv.ChoiceList;
        crossbowChoice.flagRef=None;
        megaChoiceEv.ChoiceList = crossbowChoice;
    }

    noHelpChoice.nextChoice=megaChoiceEv.ChoiceList;
    megaChoiceEv.ChoiceList = noHelpChoice;
}

defaultproperties
{
    convoName=InterruptFamilySquabble
}
