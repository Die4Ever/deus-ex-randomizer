class DXRNames extends DXRBase transient;

function FirstEntry()
{
    local #var(prefix)ScriptedPawn p;
    local #var(prefix)BoneSkull skull;
#ifdef hx
    local HXCarcass c;
#else
    local #var(DeusExPrefix)Carcass c;
#endif
    Super.FirstEntry();

    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) return;

    SetSeed( "DXRNames" );

    foreach AllActors(class'#var(prefix)ScriptedPawn', p)
    {
        GiveRandomName(dxr, p);
    }

#ifdef hx
    foreach AllActors(class'HXCarcass', c)
#else
    foreach AllActors(class'#var(DeusExPrefix)Carcass', c)
#endif
    {
        if (c.itemName == "Dead Body") {
            if (c.BindName == "PaulDentonCarcass") {
                c.itemName = "Paul Denton (Dead)";
            } else {
                c.itemName = RandomName(dxr) $ " (Dead)";
            }
        } else if (c.itemName == "Animal Carcass") {
            switch(c.class) {
                case class'CatCarcass':
                    c.itemName = "Cat (Dead)";
                    break;
                case class'DobermanCarcass':
                    c.itemName = "Doberman (Dead)";
                    break;
                case class'GrayCarcass':
                    c.itemName = "Gray (Dead)";
                    break;
                case class'GreaselCarcass':
                    c.itemName = "Greasel (Dead)";
                    break;
                case class'KarkianBabyCarcass':
                case class'KarkianCarcass':
                    c.itemName = "Karkian (Dead)";
                    break;
                case class'MuttCarcass':
                    c.itemName = "Dog (Dead)";
                    break;
                case class'PigeonCarcass':
                    c.itemName = "Pigeon (Dead)";
                    break;
                case class'RatCarcass':
                    c.itemName = "Rat (Dead)";
                    break;
                case class'SeagullCarcass':
                    c.itemName = "Seagull (Dead)";
            }
        }
        else if (c.itemName == "Unconscious") {
            c.itemName = RandomName(dxr) $ " (Unconscious)";
        }
    }

    foreach AllActors(class'#var(prefix)BoneSkull', skull) {
        skull.ItemName = RandomName(dxr, None);
        if(chance_single(1))
            skull.ItemName = "Murray";
    }
}

static function GiveRandomName(DXRando dxr, ScriptedPawn p)
{
    if( p.bImportant || p.bIsSecretGoal ) return;
    p.UnfamiliarName = RandomName(dxr, p);
    p.FamiliarName = p.UnfamiliarName;
}

static function string RandomName(DXRando dxr, optional Actor a)
{
    if ( a != None && a.IsA('#var(prefix)Robot') ) {
        return Caps(RandomNamePart(dxr, 2,4)) $ "-" $ dxr.rng(1001);
    }

    if( dxr.rng(2) == 0 ) {
        return RandomNamePart(dxr, 2, 4) @ RandomNamePart(dxr, 2, 4);
    }

    return RandomNamePart(dxr, 2, 6);
}

static function string RandomNamePart(DXRando dxr, int min, int max)
{
    local string n;
    local bool vowel;
    local int length, num_vowels, num_cons, i, a;
    local string vowels, cons, s;

    vowels = "aeiouy";
    //cons = "bcdfghjklmnpqrstvwxz";
    cons = "bcdfghjklmnprstvwx";

    num_vowels = Len(vowels);
    num_cons = Len(cons);

    length = dxr.rng(max-min+1)+min;
    if( dxr.rng(2) == 0 ) vowel = true;

    for( i=0; i < length; i++ ) {
        if( vowel ) {
            vowel = false;
            a = dxr.rng(num_vowels)+1;
            s = Left(vowels, a);
            s = Right(s, 1);
            n = n $ s;
        } else {
            vowel = true;
            a = dxr.rng(num_cons)+1;
            s = Left(cons, a);
            s = Right(s, 1);
            n = n $ s;
        }
        if ( i == 0 ) n = Caps(n);
    }

    if(WordInStr(Caps(n), "FAG", 3, true) != -1 || WordInStr(Caps(n), "RAPE", 4, true) != -1) {
        return RandomNamePart(dxr, min, max);
    }
    return n;
}
