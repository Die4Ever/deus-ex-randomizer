class GilbertWeaponMegaChoice extends WeaponMegaChoice;

static function class<Actor> GetSelfClass()
{
    return class'GilbertWeaponMegaChoice';
}

static function Name GetWeaponConversationName()
{
    return 'InterruptFamilySquabble';
}

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
    local ConEvent ce;
    local ConEventChoice megaChoiceEv,choiceEv;
    local ConChoice sawedOffChoice,stealthChoice,pistolChoice,knifeChoice,crossbowChoice,noHelpChoice,choiceIter;

    if (HasNoWeapons()){
        return; //Just let it fall through as normal, no changes needed
    }

    c = GetConversation(GetWeaponConversationName());
    ce = c.eventList;

    while (ce!=None){
        if (ce.nextEvent!=None && ce.nextEvent.eventType==ET_CheckObject && megaChoiceEv==None){
            megaChoiceEv = new(c) class'ConEventChoice';
            megaChoiceEv.eventType=ET_Choice;
            megaChoiceEv.nextEvent = ce.nextEvent;
            ce.nextEvent = megaChoiceEv;
            megaChoiceEv.conversation = c;
            megaChoiceEv.bClearScreen = true;
            megaChoiceEv.label="megachoice";
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
