class GilbertWeaponMegaChoice extends WeaponMegaChoice;

function bool HasNoWeapons()
{
    if (p.FindInventoryType(class'WeaponSawedOffShotgun')!=None) return False;
    if (p.FindInventoryType(class'WeaponPistol')!=None) return False;
    if (p.FindInventoryType(class'WeaponStealthPistol')!=None) return False;
    if (p.FindInventoryType(class'WeaponCombatKnife')!=None) return False;
    if (p.FindInventoryType(class'WeaponMiniCrossbow')!=None) return False;
    return True;
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
        if (ce.nextEvent!=None && ce.nextEvent.eventType==ET_CheckObject && insertPoint==None){
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

    megaChoiceEv = new(c) class'ConEventChoice';
    megaChoiceEv.eventType=ET_Choice;
    megaChoiceEv.nextEvent = insertPoint.nextEvent;
    insertPoint.nextEvent = megaChoiceEv;
    megaChoiceEv.conversation = c;
    megaChoiceEv.bClearScreen = true;
    megaChoiceEv.label="megachoice";

    megaChoiceEv.ChoiceList = None;

    if (p.FindInventoryType(class'WeaponCombatKnife')!=None){
        knifeChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = knifeChoice;
    }
    if (p.FindInventoryType(class'WeaponSawedOffShotgun')!=None){
        sawedOffChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = sawedOffChoice;
    }
    if (p.FindInventoryType(class'WeaponPistol')!=None){
        pistolChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = pistolChoice;
    }
    if (p.FindInventoryType(class'WeaponStealthPistol')!=None){
        stealthChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = stealthChoice;
    }
    if (p.FindInventoryType(class'WeaponMiniCrossbow')!=None){
        crossbowChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = crossbowChoice;
    }

    noHelpChoice.nextChoice=megaChoiceEv.ChoiceList;
    megaChoiceEv.ChoiceList = noHelpChoice;
}

defaultproperties
{
    convoName=InterruptFamilySquabble
}
