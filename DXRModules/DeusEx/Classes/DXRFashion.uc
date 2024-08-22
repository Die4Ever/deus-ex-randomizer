#dontcompileif vmd
class DXRFashion extends DXRActorsBase transient;


simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local int lastUpdate, i;
    local bool isFemale;
    local class<Pawn> jcd;
    local DXRFashionManager f;
    Super.PlayerAnyEntry(p);

    isFemale = dxr.flagbase.GetBool('LDDPJCIsFemale');

    if(isFemale) {
        info("DXRFashion isFemale, Level.Game.Class.Name == " $ Level.Game.Class.Name);
    }

    f=class'DXRFashionManager'.static.GiveItem(p);

    info("got DXRFashion_LastUpdate: "$lastUpdate);
    if ((class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags))
        && (f.lastUpdate < dxr.dxInfo.MissionNumber || f.lastUpdate > dxr.dxInfo.MissionNumber + 2)) {
        f.RandomizeClothes(player());
    }

    f.GetDressed();
}

//Add unique clothes to racks
simulated function PreFirstEntry()
{
    local #var(injectsprefix)ClothesRack cr;
    local bool VanillaMaps;

    if (!ClothesLootingEnabled()) return; //Everything past here is "important" for clothes looting

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    if (VanillaMaps){
        switch(dxr.localURL)
        {
            case "05_NYC_UNATCOHQ":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(-496,-1160,4))); //Anna's office
                cr.lootableClothes=class'#var(prefix)AnnaNavarreCarcass';

                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(1025,-791,4))); //Sam's Armoury
                cr.lootableClothes=class'#var(prefix)SamCarterCarcass';

                //fall through to the rest of the UNATCO HQ spawns
            case "01_NYC_UNATCOHQ":
            case "03_NYC_UNATCOHQ":
            case "04_NYC_UNATCOHQ":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(1438,-728,-13))); //Alex's closet
                cr.lootableClothes=class'#var(prefix)AlexJacobsonCarcass';

                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(1282,503,13))); //Jaime's closet
                cr.lootableClothes=class'#var(prefix)JaimeReyesCarcass';
                break;

            case "02_NYC_SMUG":
            case "04_NYC_SMUG":
            case "08_NYC_SMUG":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(-760,1439,278),rot(0,16328,0))); //next to bed
                cr.lootableClothes=class'#var(prefix)SmugglerCarcass';
                break;

            case "03_NYC_BATTERYPARK":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(-3994,357,415))); //In first shanty town hut
                cr.lootableClothes=class'#var(prefix)HarleyFilbenCarcass';
                break;

            case "06_HONGKONG_WANCHAI_STREET":
                foreach AllActors(class'#var(injectsprefix)ClothesRack',cr){ //The two clothes racks in Jock's apartment
                    cr.lootableClothes = class'#var(prefix)JockCarcass';
                }
                break;

            case "06_HONGKONG_WANCHAI_UNDERWORLD":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(-783,-2856,-301))); //back room of Lucky Money
                cr.lootableClothes=class'#var(prefix)MaxChenCarcass';
                break;

            case "06_HONGKONG_WANCHAI_MARKET":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(1097,-246,-197))); //Luminous Path compound training room, near beds
                cr.lootableClothes=class'#var(prefix)GordonQuickCarcass';
                break;

            case "06_HONGKONG_TONGBASE":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(-2008,588,-34),rot(0,16328,0))); //Next to hot tub
                cr.lootableClothes=class'#var(prefix)TracerTongCarcass';
                break;

            case "09_NYC_GRAVEYARD":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(-1175,-87,-275),rot(0,16328,0))); //Next to Stanton's computer
                cr.lootableClothes=class'#var(prefix)StantonDowdCarcass';
                break;

            case "11_PARIS_CATHEDRAL":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(4776,-661,-827),rot(0,16328,0))); //Near Gunther's vanilla spot
                cr.lootableClothes=class'#var(prefix)GuntherHermannCarcass';
                break;

            case "11_PARIS_EVERETT":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(-216,2223,244),rot(0,16328,0))); //In Everett's lab
                cr.lootableClothes=class'#var(prefix)MorganEverettCarcass';
                break;

            case "12_VANDENBERG_COMPUTER":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(1135,2137,-1620))); //Entry floor computer lab overlooking milnet uplink
                cr.lootableClothes=class'#var(prefix)GarySavageCarcass';
                break;

            case "15_AREA51_ENTRANCE":
                cr = #var(injectsprefix)ClothesRack(Spawnm(class'#var(injectsprefix)ClothesRack',,,vect(5304,130,-159),rot(0,16328,0))); //Near Gunther's vanilla spot
                cr.lootableClothes=class'#var(prefix)BobPageCarcass';
                break;
        }
    }

    //Any remaining clothes racks without specific clothes can get random generic ones
    foreach AllActors(class'#var(injectsprefix)ClothesRack',cr){
        if (cr.lootableClothes==None){
            cr.lootableClothes=RandomGenericClothes();
        }
    }
}

simulated function class<#var(DeusExPrefix)Carcass> RandomGenericClothes()
{
    switch(Rand(20))
    {
        case 0:  return class'#var(prefix)Male1Carcass';
        case 1:  return class'#var(prefix)Male2Carcass';
        case 2:  return class'#var(prefix)Male3Carcass';
        case 3:  return class'#var(prefix)Male4Carcass';
        case 4:  return class'#var(prefix)Female1Carcass';
        case 5:  return class'#var(prefix)Female2Carcass';
        case 6:  return class'#var(prefix)Female3Carcass';
        case 7:  return class'#var(prefix)Female4Carcass';
        case 8:  return class'#var(prefix)BumFemaleCarcass';
        case 9:  return class'#var(prefix)BumMaleCarcass';
        case 10: return class'#var(prefix)BumMale2Carcass';
        case 11: return class'#var(prefix)BumMale3Carcass';
        case 12: return class'#var(prefix)LowerClassMaleCarcass';
        case 13: return class'#var(prefix)LowerClassMale2Carcass';
        case 14: return class'#var(prefix)LowerClassFemaleCarcass';
        case 15: return class'#var(prefix)BusinessMan1Carcass';
        case 16: return class'#var(prefix)BusinessMan2Carcass';
        case 17: return class'#var(prefix)BusinessMan3Carcass';
        case 18: return class'#var(prefix)Businesswoman1Carcass';
        case 19: return class'#var(prefix)MichaelHamnerCarcass';
    }
    return None;
}

function AddDXRCredits(CreditsWindow cw)
{
    local DXRFashionManager f;

    if (IsOctoberUnlocked()) {
        f=class'DXRFashionManager'.static.GiveItem(player());

        cw.PrintHeader("Fashion");
        cw.PrintText("Number of Clothes in Closet:"@f.numClothes);
        cw.PrintText("Number of Outfit Changes:"@f.GetNumOutfitChanges(player()));
        cw.PrintLn();
    }
}
