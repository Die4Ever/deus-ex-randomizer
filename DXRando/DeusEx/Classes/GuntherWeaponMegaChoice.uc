class GuntherWeaponMegaChoice extends WeaponMegaChoice;

static function class<Actor> GetSelfClass()
{
    return class'GuntherWeaponMegaChoice';
}

static function Name GetWeaponConversationName()
{
    return 'GuntherRescued';
}

function GenerateWeaponChoice()
{
    local Conversation c;
    local ConEvent ce;
    local ConEventChoice megaChoiceEv,choiceEv;
    local ConChoice assaultChoice,stealthChoice,pistolChoice,knifeChoice,nothingChoice,noHelpChoice,choiceIter;
    local int numChoices;

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

    numChoices = 0;
    megaChoiceEv.ChoiceList = None;
    if (p.FindInventoryType(class'WeaponAssaultGun')!=None){
        assaultChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = assaultChoice;
        numChoices++;
    }
    if (p.FindInventoryType(class'WeaponPistol')!=None){
        pistolChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = pistolChoice;
        numChoices++;
    }
    if (p.FindInventoryType(class'WeaponStealthPistol')!=None){
        stealthChoice.nextChoice=megaChoiceEv.ChoiceList;
        megaChoiceEv.ChoiceList = stealthChoice;
        numChoices++;
    }
    if (p.FindInventoryType(class'WeaponCombatKnife')!=None){
        knifeChoice.nextChoice=megaChoiceEv.ChoiceList;
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
