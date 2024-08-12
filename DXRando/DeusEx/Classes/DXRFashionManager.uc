#dontcompileif vmd
class DXRFashionManager extends Inventory;

enum EClothesType
{
    CT_None,
    CT_Shirt,
    CT_TrenchShirt,
    CT_Pants,
    CT_Skirt,
    CT_Jacket,
    CT_Helmet
};

enum EGender
{
    G_Male,
    G_Female,
    G_Both
};

enum EOutfitType
{
    OT_Trench,
    OT_NoTrench,
    OT_Skirt
};

struct ClothesTextures{
    var Texture tex1;
    var Texture tex2;
};

struct Clothes {
    var travel EClothesType type;
    var travel EGender gender;
    var travel String tex1;
    var travel String tex2;
};

struct CurrentOutfit {
    var travel EOutfitType curOutfit;

    //An array of strings will not travel, but this does
    var travel string skinOverride0;
    var travel string skinOverride1;
    var travel string skinOverride2;
    var travel string skinOverride3;
    var travel string skinOverride4;
    var travel string skinOverride5;
    var travel string skinOverride6;
    var travel string skinOverride7;
};

var travel bool isFemale;
var travel Clothes clothing[250];
var travel int numClothes;

const cPLAYER = 0;
const cPAUL = 1;
var travel CurrentOutfit curOutfit[2];

var travel int lastUpdate;

simulated function static DXRFashionManager GiveItem(#var(PlayerPawn) p)
{
    local DXRFashionManager f;

    if(p==None){return None;}

    f = DXRFashionManager(p.FindInventoryType(class'DXRFashionManager'));
    if( f == None )
    {
        f = p.Spawn(class'DXRFashionManager');
        f.GiveTo(p);
        f.isFemale=p.flagBase.GetBool('LDDPJCIsFemale');
        f.InitClothes(true);
        log("spawned new " $ f $ " for " $ p);
    }
    return f;
}

function Mesh ModelFromOutfitGender(EOutfitType type, bool female)
{
    switch(type){
        case OT_Trench:
            if (female){
                return LodMesh'DeusExCharacters.GFM_Trench';
            } else {
                return LodMesh'DeusExCharacters.GM_Trench';
            }
        case OT_NoTrench:
            if (female){
                return LodMesh'DeusExCharacters.GFM_TShirtPants';
            } else {
                return LodMesh'MPCharacters.mp_jumpsuit';
            }
        case OT_Skirt:
            return LodMesh'DeusExCharacters.GFM_SuitSkirt';
    }
    return None;

}

function Mesh GetCurModel()
{
    return ModelFromOutfitGender(curOutfit[cPLAYER].curOutfit,isFemale);
}

function Mesh GetCurPaulModel()
{
    return ModelFromOutfitGender(curOutfit[cPAUL].curOutfit,False);
}

function InitClothes(bool giveAll)
{
    //local class<#var(DeusExPrefix)Carcass> carcClass;

#ifndef hx
    IngestCarcass(class'JCDentonMaleCarcass');
#else
    IngestCarcass(class'HXJCDentonCarcass');
#endif
    IngestCarcass(class'#var(prefix)PaulDentonCarcass');
    IngestCarcass(class'#var(prefix)UNATCOTroopCarcass');

    if (giveAll){
        IngestCarcass(class'#var(prefix)Male1Carcass');
        IngestCarcass(class'#var(prefix)Male2Carcass');
        IngestCarcass(class'#var(prefix)Male3Carcass');
        IngestCarcass(class'#var(prefix)Male4Carcass');
        IngestCarcass(class'#var(prefix)Female1Carcass');
        IngestCarcass(class'#var(prefix)Female2Carcass');
        IngestCarcass(class'#var(prefix)Female3Carcass');
        IngestCarcass(class'#var(prefix)Female4Carcass');
        IngestCarcass(class'#var(prefix)DoctorCarcass');
        IngestCarcass(class'#var(prefix)NurseCarcass');
        IngestCarcass(class'#var(prefix)ScientistMaleCarcass');
        IngestCarcass(class'#var(prefix)ScientistFemaleCarcass');
        IngestCarcass(class'#var(prefix)BartenderCarcass');
        IngestCarcass(class'#var(prefix)JordanSheaCarcass');
        IngestCarcass(class'#var(prefix)MaxChenCarcass');
        IngestCarcass(class'#var(prefix)MaggieChowCarcass');
        IngestCarcass(class'#var(prefix)GuntherHermannCarcass');
        IngestCarcass(class'#var(prefix)AnnaNavarreCarcass');
        IngestCarcass(class'#var(prefix)MIBCarcass');
        IngestCarcass(class'#var(prefix)WIBCarcass');
        IngestCarcass(class'#var(prefix)BusinessMan3Carcass');
        IngestCarcass(class'#var(prefix)BusinessWoman1Carcass');
        IngestCarcass(class'#var(prefix)JunkieMaleCarcass');
        IngestCarcass(class'#var(prefix)JunkieFemaleCarcass');
        IngestCarcass(class'#var(prefix)LowerClassMaleCarcass');
        IngestCarcass(class'#var(prefix)LowerClassFemaleCarcass');
        IngestCarcass(class'#var(prefix)HowardStrongCarcass');
        IngestCarcass(class'#var(prefix)RachelMeadCarcass');
        IngestCarcass(class'#var(prefix)PhilipMeadCarcass');
        IngestCarcass(class'#var(prefix)MargaretWilliamsCarcass');
        IngestCarcass(class'#var(prefix)JoJoFineCarcass');
        IngestCarcass(class'#var(prefix)TiffanySavageCarcass');
        IngestCarcass(class'#var(prefix)BusinessMan1Carcass');
        IngestCarcass(class'#var(prefix)SecretaryCarcass');
        IngestCarcass(class'#var(prefix)BumMaleCarcass');
        IngestCarcass(class'#var(prefix)BumFemaleCarcass');
        IngestCarcass(class'#var(prefix)AlexJacobsonCarcass');
        IngestCarcass(class'#var(prefix)BoatPersonCarcass');
        IngestCarcass(class'#var(prefix)JoeGreeneCarcass');
        IngestCarcass(class'#var(prefix)MorganEverettCarcass');
        IngestCarcass(class'#var(prefix)CopCarcass');
        IngestCarcass(class'#var(prefix)ThugMale2Carcass');
        IngestCarcass(class'#var(prefix)ThugMale3Carcass');
        IngestCarcass(class'#var(prefix)BusinessMan2Carcass');
        IngestCarcass(class'#var(prefix)ButlerCarcass');
        IngestCarcass(class'#var(prefix)MaidCarcass');
        IngestCarcass(class'#var(prefix)ChefCarcass');
        IngestCarcass(class'#var(prefix)ChildMaleCarcass');
        IngestCarcass(class'#var(prefix)ChildMale2Carcass');
        IngestCarcass(class'#var(prefix)JanitorCarcass');
        IngestCarcass(class'#var(prefix)LowerClassMale2Carcass');
        IngestCarcass(class'#var(prefix)MechanicCarcass');
        IngestCarcass(class'#var(prefix)MichaelHamnerCarcass');
        IngestCarcass(class'#var(prefix)NathanMadisonCarcass');
        IngestCarcass(class'#var(prefix)SailorCarcass');
        IngestCarcass(class'#var(prefix)SecretServiceCarcass');
        IngestCarcass(class'#var(prefix)TracerTongCarcass');
        IngestCarcass(class'#var(prefix)BobPageCarcass');
        IngestCarcass(class'#var(prefix)HKMilitaryCarcass');
        IngestCarcass(class'#var(prefix)JosephManderleyCarcass');
        IngestCarcass(class'#var(prefix)MJ12TroopCarcass');
        IngestCarcass(class'#var(prefix)RiotCopCarcass');
        IngestCarcass(class'#var(prefix)SamCarterCarcass');
        IngestCarcass(class'#var(prefix)SoldierCarcass');
        IngestCarcass(class'#var(prefix)TerroristCarcass');
        IngestCarcass(class'#var(prefix)ChadCarcass');
        IngestCarcass(class'#var(prefix)ThugMaleCarcass');
        IngestCarcass(class'#var(prefix)TriadLumPathCarcass');
        IngestCarcass(class'#var(prefix)TriadLumPath2Carcass');
        IngestCarcass(class'#var(prefix)BumMale2Carcass');
        IngestCarcass(class'#var(prefix)BumMale3Carcass');
        IngestCarcass(class'#var(prefix)JaimeReyesCarcass');
        IngestCarcass(class'#var(prefix)HarleyFilbenCarcass');
        IngestCarcass(class'#var(prefix)GilbertRentonCarcass');
        IngestCarcass(class'#var(prefix)FordSchickCarcass');
        IngestCarcass(class'#var(prefix)GordonQuickCarcass');
        IngestCarcass(class'#var(prefix)JuanLebedevCarcass');
        IngestCarcass(class'#var(prefix)WaltonSimonsCarcass');
        IngestCarcass(class'#var(prefix)SmugglerCarcass');
        IngestCarcass(class'#var(prefix)TobyAtanweCarcass');
        IngestCarcass(class'#var(prefix)TerroristCommanderCarcass');
        IngestCarcass(class'#var(prefix)TriadRedArrowCarcass');
        IngestCarcass(class'#var(prefix)GarySavageCarcass');
        IngestCarcass(class'#var(prefix)StantonDowdCarcass');
        IngestCarcass(class'#var(prefix)JockCarcass');
        IngestCarcass(class'NervousWorkerCarcass');
    }

/*
    //Not working for some reason?
    carcClass = class<#var(DeusExPrefix)Carcass>(class'DXRando'.Default.dxr.GetClassFromString("FemJC.JCDentonFemaleCarcass",class'#var(DeusExPrefix)Carcass'));
    p.ClientMessage("Found JC Female Carcass class: " $ carcClass);
    if (carcClass!=None){
        //IngestCarcass(class'FemJC.JCDentonFemaleCarcass');
        IngestCarcass(carcClass.Default.Class);
    }
*/
}

simulated function int NumClothingForOutfitType(EOutfitType type, bool female)
{
    local int i,numChoices;
    numChoices=0;
    for (i=0;i<numClothes;i++){
        if (clothing[i].type!=CT_None && AppropriateForGender(female,clothing[i].gender)){
            switch(type){
                case OT_Trench:
                    if (clothing[i].type==CT_TrenchShirt) numChoices++; //Has trenchcoat specific clothes
                    break;
                case OT_NoTrench:
                    if (clothing[i].type==CT_Shirt) numChoices++; //Has non-trench specific clothes
                    break;
                case OT_Skirt:
                    if (clothing[i].type==CT_Skirt) numChoices++; //Has skirt specific clothes
                    break;
            }
        }
    }

    return numChoices;
}

simulated function EOutfitType PickOutfitType(bool female)
{
    local EOutfitType options[ArrayCount(clothing)];
    local int numOptions, i, num;

    num=NumClothingForOutfitType(OT_Trench,female);
    for (i=0;i<num;i++){
        options[numOptions++]=OT_Trench;
    }

    num=NumClothingForOutfitType(OT_NoTrench,female);
    for (i=0;i<num;i++){
        options[numOptions++]=OT_NoTrench;
    }

    num=NumClothingForOutfitType(OT_Skirt,female);
    for (i=0;i<num;i++){
        options[numOptions++]=OT_Skirt;
    }

    if (numOptions==0){
        return OT_Trench; //Really hope *this* doesn't happen!
    }

    return options[Rand(numOptions)];
}

simulated function bool AppropriateForGender(bool female, EGender gender)
{
    switch(gender){
        case G_Both: return True;
        case G_Female: return female;
        case G_Male: return !female;
    }
    return False; //Something went wrong
}

simulated function Clothes PickRandomClothingByType(EClothesType type, bool female)
{
    local Clothes choices[ArrayCount(clothing)];
    local int numChoices,i;

    for (i=0;i<numClothes;i++){
        if (clothing[i].type==type && AppropriateForGender(female,clothing[i].gender)){
            choices[numChoices++]=clothing[i];
        }
    }

    return choices[Rand(numChoices)];
}

simulated function ClothesTextures FetchClothesTextures(Clothes c)
{
    local ClothesTextures ct;

    if (c.tex1!=""){
        ct.tex1 = Texture(DynamicLoadObject(c.tex1,class'Texture'));
    }
    if (c.tex2!=""){
        ct.tex2 = Texture(DynamicLoadObject(c.tex2,class'Texture'));
    }

    return ct;
}

simulated function GenerateOverrides(bool female, EOutfitType outfit, out Texture newMultis[8])
{
    local int i;
    local Clothes c1,c2,c3;
    local ClothesTextures ct1,ct2,ct3;

    for (i=0;i<ArrayCount(newMultis);i++){
        newMultis[i]=None;
    }

    switch(outfit){
        case OT_Trench:
            c1=PickRandomClothingByType(CT_Pants,female);
            ct1=FetchClothesTextures(c1);
            c2=PickRandomClothingByType(CT_TrenchShirt,female);
            ct2=FetchClothesTextures(c2);
            c3=PickRandomClothingByType(CT_Jacket,female);
            ct3=FetchClothesTextures(c3);
            newMultis[2]=ct1.tex1; //Pants
            newMultis[4]=ct2.tex1; //Shirt
            newMultis[1]=ct3.tex1; //Jacket top
            newMultis[5]=ct3.tex2; //Jacket bottom
            break;
        case OT_NoTrench:
            c1=PickRandomClothingByType(CT_Pants,female);
            ct1=FetchClothesTextures(c1);
            c2=PickRandomClothingByType(CT_Shirt,female);
            ct2=FetchClothesTextures(c2);
            c3=PickRandomClothingByType(CT_Helmet,female);
            ct3=FetchClothesTextures(c3);
            if (female){
                newMultis[6]=ct1.tex1; //pants
                newMultis[7]=ct2.tex1; //shirt
                newMultis[1]=Texture'DeusExItems.Skins.PinkMaskTex'; //Hair on sides
                newMultis[2]=Texture'DeusExItems.Skins.PinkMaskTex'; //ponytail
            } else {
                newMultis[1]=ct1.tex1; //pants
                newMultis[2]=ct2.tex1; //shirt
                newMultis[6]=ct3.tex1; //Helmet
                newMultis[4]=Texture'DeusExItems.Skins.PinkMaskTex'; //Face mask, like for NSF guys
                newMultis[5]=Texture'DeusExItems.Skins.PinkMaskTex'; //Visor lens
                newMultis[7]=Texture'DeusExItems.Skins.PinkMaskTex';
            }
            break;
        case OT_Skirt:
            c1=PickRandomClothingByType(CT_Skirt,female);
            ct1=FetchClothesTextures(c1);
            newMultis[4]=ct1.tex1;
            newMultis[5]=ct1.tex2;
            newMultis[1]=Texture'DeusExItems.Skins.PinkMaskTex'; //Hairbun
            break;
    }

}

simulated function HandleGlasses(bool hasGlasses, bool female, EOutfitType outfit, out Texture newMultis[8])
{
    local int frameIdx, lensIdx;
    if (outfit==OT_NoTrench && !female) return; //Trenchcoat and Skirt both have glasses support

    if (outfit==OT_NoTrench && female){
        frameIdx=3;
        lensIdx=4;
    } else {
        frameIdx=6;
        lensIdx=7;
    }
    if (hasGlasses){
        newMultis[frameIdx]=Texture'DeusExCharacters.Skins.FramesTex4';
        newMultis[lensIdx]=Texture'DeusExCharacters.Skins.LensesTex5';
    } else {
        newMultis[frameIdx]=Texture'DeusExItems.Skins.GrayMaskTex';
        newMultis[lensIdx]=Texture'DeusExItems.Skins.BlackMaskTex';
    }
}

simulated function HandleSkirtLegs(Texture faceTex, EOutfitType outfit, out Texture newMultis[8])
{
    if (outfit!=OT_Skirt) return;

    if( String(faceTex) == "FemJC.Characters.JCDentonFemaleTex4" || String(faceTex) == "FemJC.Characters.JCDentonFemaleTex5" ){
        newMultis[3]=Texture'DeusExCharacters.Skins.Hooker1Tex1';// darker legs
    } else {
        newMultis[3] = Texture'DeusExCharacters.Skins.Female2Tex1';// legs/pants
    }
}

simulated function ClearSkinOverrides()
{
    curOutfit[cPLAYER].skinOverride0="";
    curOutfit[cPLAYER].skinOverride1="";
    curOutfit[cPLAYER].skinOverride2="";
    curOutfit[cPLAYER].skinOverride3="";
    curOutfit[cPLAYER].skinOverride4="";
    curOutfit[cPLAYER].skinOverride5="";
    curOutfit[cPLAYER].skinOverride6="";
    curOutfit[cPLAYER].skinOverride7="";
    curOutfit[cPLAYER].curOutfit=OT_Trench;

    curOutfit[cPAUL].skinOverride0="";
    curOutfit[cPAUL].skinOverride1="";
    curOutfit[cPAUL].skinOverride2="";
    curOutfit[cPAUL].skinOverride3="";
    curOutfit[cPAUL].skinOverride4="";
    curOutfit[cPAUL].skinOverride5="";
    curOutfit[cPAUL].skinOverride6="";
    curOutfit[cPAUL].skinOverride7="";
    curOutfit[cPAUL].curOutfit=OT_Trench;
}

//Checks the player for any skin overrides
simulated function bool HasSkinOverrides()
{
    if (curOutfit[cPLAYER].skinOverride0!="") return True;
    if (curOutfit[cPLAYER].skinOverride1!="") return True;
    if (curOutfit[cPLAYER].skinOverride2!="") return True;
    if (curOutfit[cPLAYER].skinOverride3!="") return True;
    if (curOutfit[cPLAYER].skinOverride4!="") return True;
    if (curOutfit[cPLAYER].skinOverride5!="") return True;
    if (curOutfit[cPLAYER].skinOverride6!="") return True;
    if (curOutfit[cPLAYER].skinOverride7!="") return True;
    return False;
}

simulated function PullSkinOverride(CurrentOutfit current, out Texture overrides[8])
{
    local int i;

    for (i=0;i<ArrayCount(overrides);i++){overrides[i]=None;}
    if (current.skinOverride0!=""){overrides[0]=Texture(DynamicLoadObject(current.skinOverride0,class'Texture'));}
    if (current.skinOverride1!=""){overrides[1]=Texture(DynamicLoadObject(current.skinOverride1,class'Texture'));}
    if (current.skinOverride2!=""){overrides[2]=Texture(DynamicLoadObject(current.skinOverride2,class'Texture'));}
    if (current.skinOverride3!=""){overrides[3]=Texture(DynamicLoadObject(current.skinOverride3,class'Texture'));}
    if (current.skinOverride4!=""){overrides[4]=Texture(DynamicLoadObject(current.skinOverride4,class'Texture'));}
    if (current.skinOverride5!=""){overrides[5]=Texture(DynamicLoadObject(current.skinOverride5,class'Texture'));}
    if (current.skinOverride6!=""){overrides[6]=Texture(DynamicLoadObject(current.skinOverride6,class'Texture'));}
    if (current.skinOverride7!=""){overrides[7]=Texture(DynamicLoadObject(current.skinOverride7,class'Texture'));}
}

simulated function PushSkinOverride(out CurrentOutfit current, Texture overrides[8])
{
    if (overrides[0]!=None){current.skinOverride0=String(overrides[0]);} else {current.skinOverride0="";}
    if (overrides[1]!=None){current.skinOverride1=String(overrides[1]);} else {current.skinOverride1="";}
    if (overrides[2]!=None){current.skinOverride2=String(overrides[2]);} else {current.skinOverride2="";}
    if (overrides[3]!=None){current.skinOverride3=String(overrides[3]);} else {current.skinOverride3="";}
    if (overrides[4]!=None){current.skinOverride4=String(overrides[4]);} else {current.skinOverride4="";}
    if (overrides[5]!=None){current.skinOverride5=String(overrides[5]);} else {current.skinOverride5="";}
    if (overrides[6]!=None){current.skinOverride6=String(overrides[6]);} else {current.skinOverride6="";}
    if (overrides[7]!=None){current.skinOverride7=String(overrides[7]);} else {current.skinOverride7="";}
}

simulated function RandomizeClothes(#var(PlayerPawn) player)
{
    local EOutfitType outfit;
    local int i;
    local Texture overrides[8],paulOverrides[8];

    outfit=PickOutfitType(isFemale);
    curOutfit[cPLAYER].curOutfit=outfit;
    GenerateOverrides(isFemale,outfit,overrides);
    HandleGlasses(true,isFemale,outfit,overrides);
    HandleSkirtLegs(player.MultiSkins[0],outfit,overrides);
    pushSkinOverride(curOutfit[cPLAYER],overrides);

    if (isFemale){
        //Unique Paul outfit if JC is female
        curOutfit[cPAUL].curOutfit=PickOutfitType(false);
        GenerateOverrides(False,curOutfit[cPAUL].curOutfit,paulOverrides);
    } else {
        curOutfit[cPAUL].curOutfit=outfit;
        //Paul gets matching clothes if JC is male
        for (i=0;i<ArrayCount(overrides);i++){
            paulOverrides[i]=overrides[i];
        }
    }
    HandleGlasses(false,false,curOutfit[cPAUL].curOutfit,paulOverrides);
    pushSkinOverride(curOutfit[cPAUL],paulOverrides);

    lastUpdate = class'DXRando'.Default.dxr.dxInfo.MissionNumber;

}

simulated function ApplyCarcassMeshes(Actor a)
{
    local #var(DeusExPrefix)Carcass c;

    c = #var(DeusExPrefix)Carcass(a);
    if (c==None) return;

    switch(c.Mesh){
        case LodMesh'DeusExCharacters.GFM_Trench':
            c.Mesh =LodMesh'DeusExCharacters.GFM_Trench_Carcass';
            c.Mesh2=LodMesh'DeusExCharacters.GFM_Trench_CarcassB';
            c.Mesh3=LodMesh'DeusExCharacters.GFM_Trench_CarcassC';
            break;
        case LodMesh'DeusExCharacters.GM_Trench':
            c.Mesh = LodMesh'DeusExCharacters.GM_Trench_Carcass';
            c.Mesh2= LodMesh'DeusExCharacters.GM_Trench_CarcassB';
            c.Mesh3= LodMesh'DeusExCharacters.GM_Trench_CarcassC';
            break;
        case LodMesh'DeusExCharacters.GFM_TShirtPants':
            c.Mesh =LodMesh'DeusExCharacters.GFM_TShirtPants_Carcass';
            c.Mesh2=LodMesh'DeusExCharacters.GFM_TShirtPants_CarcassB';
            c.Mesh3=LodMesh'DeusExCharacters.GFM_TShirtPants_CarcassC';
            break;
        case LodMesh'MPCharacters.mp_jumpsuit':
            c.Mesh = LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass';
            c.Mesh2= LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB';
            c.Mesh3= LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC';
            break;
        case LodMesh'DeusExCharacters.GFM_SuitSkirt':
            c.Mesh = LodMesh'DeusExCharacters.GFM_SuitSkirt_Carcass';
            c.Mesh2= LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassB';
            c.Mesh3= LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassC';
            break;
    }
}

simulated function ApplyJCClothing(Actor a)
{
    local int i;
    local Texture overrides[8];

    a.Mesh=getCurModel();
    ApplyCarcassMeshes(a);
    for (i=1;i<ArrayCount(a.MultiSkins);i++){
        a.MultiSkins[i]=a.Default.MultiSkins[i];
    }

    PullSkinOverride(curOutfit[cPLAYER],overrides);
    for (i=0;i<ArrayCount(overrides);i++){
        if (overrides[i]!=None){
            a.MultiSkins[i]=overrides[i];
        }
    }
    a.Texture = Texture'DeusExItems.Skins.PinkMaskTex';
}

simulated function ApplyPaulClothing(Actor a)
{
    local int i;
    local Texture overrides[8];

    a.Mesh=getCurPaulModel();
    ApplyCarcassMeshes(a);
    for (i=1;i<ArrayCount(a.MultiSkins);i++){
        a.MultiSkins[i]=a.Default.MultiSkins[i];
    }

    PullSkinOverride(curOutfit[cPAUL],overrides);
    for (i=0;i<ArrayCount(overrides);i++){
        if (overrides[i]!=None){
            a.MultiSkins[i]=overrides[i];
        }
    }
    a.Texture = Texture'DeusExItems.Skins.PinkMaskTex';
}

simulated function GetDressed()
{
    local PaulDenton paul;
    local PaulDentonCarcass paulCarcass;
    local JCDentonMaleCarcass jcCarcass;
    local JCDouble jc;
    local #var(PlayerPawn) player;

    // JC Denton Carcass
    foreach AllActors(class'JCDentonMaleCarcass', jcCarcass)
        ApplyJCClothing(jcCarcass);

    // JC's stunt double
    foreach AllActors(class'JCDouble', jc)
        ApplyJCClothing(jc);

    foreach AllActors(class'#var(PlayerPawn)', player)
        ApplyJCClothing(player);

    // Paul Denton
    foreach AllActors(class'PaulDenton', paul)
        ApplyPaulClothing(paul);

    // Paul Denton Carcass
    foreach AllActors(class'PaulDentonCarcass', paulCarcass)
        ApplyPaulClothing(paulCarcass);
}

simulated function AddClothing(EGender gender, EClothesType type, Texture tex1, Texture tex2)
{
    local int i;
    local string tex1s,tex2s;

    //log("Adding Clothing "$numClothes$":  Type="$type$"  Gender="$gender$"  Tex1="$tex1$"  Tex2="$Tex2);

    if (tex1==None) return; //Something went wrong - don't save these clothes

    tex1s=String(tex1);
    if(tex2!=None){
        tex2s=String(tex2);
    }

    //Check for a dupe
    for (i=0;i<numClothes;i++){
        if (Clothing[i].Gender!=gender) continue;
        if (Clothing[i].Type!=type) continue;
        if (Clothing[i].tex1!=tex1s) continue;
        if (Clothing[i].tex2!=tex2s) continue;
        return; //Clothing already obtained
    }

    Clothing[numClothes].type=type;
    Clothing[numClothes].gender=gender;
    Clothing[numClothes].tex1=tex1s;
    Clothing[numClothes].tex2=tex2s;
    numClothes++;
}

//For handling special cases where a texture maybe only applies to one gender that would normally be considered for both
simulated function EGender GetCarcassShirtGender(class<#var(DeusExPrefix)Carcass> c)
{
    if (c == class'GordonQuickCarcass' || c == class'SmugglerCarcass' || c == class'TerroristCommanderCarcass' || c == class'JuanLebedevCarcass'){
        return G_Male;
    }
    return G_Both;
}

simulated function IngestCarcass(class<#var(DeusExPrefix)Carcass> carcassClass)
{
    switch(carcassClass.Default.mesh){
        case LodMesh'DeusExCharacters.GM_Trench_F_Carcass':
        case LodMesh'DeusExCharacters.GM_Trench_Carcass':
            AddClothing(GetCarcassShirtGender(carcassClass),CT_TrenchShirt,carcassClass.Default.MultiSkins[4],None);
            AddClothing(G_Male,CT_Pants,carcassClass.Default.MultiSkins[2],None);
            AddClothing(G_Both,CT_Jacket,carcassClass.Default.MultiSkins[1],carcassClass.Default.MultiSkins[5]);
            break;
        case LodMesh'DeusExCharacters.GFM_Trench_Carcass':
            AddClothing(G_Female,CT_TrenchShirt,carcassClass.Default.MultiSkins[4],None);
            AddClothing(G_Female,CT_Pants,carcassClass.Default.MultiSkins[2],None);
            AddClothing(G_Both,CT_Jacket,carcassClass.Default.MultiSkins[1],carcassClass.Default.MultiSkins[5]);
            break;

        //Non-Trenchcoat shirts don't map onto the trenchcoat body properly
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_Carcass':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_F_Carcass':
            AddClothing(G_Female,CT_Skirt,carcassClass.Default.MultiSkins[4],carcassClass.Default.MultiSkins[5]);
            break;
        case LodMesh'DeusExCharacters.GFM_TShirtPants_Carcass':
            AddClothing(G_Female,CT_Shirt,carcassClass.Default.MultiSkins[7],None);
            AddClothing(G_Female,CT_Pants,carcassClass.Default.MultiSkins[6],None);
            break;
        case LodMesh'DeusExCharacters.GM_DressShirt_B_Carcass':
            AddClothing(G_Male,CT_Shirt,carcassClass.Default.MultiSkins[0],None);
            AddClothing(G_Male,CT_Pants,carcassClass.Default.MultiSkins[1],None);
            break;
        case LodMesh'DeusExCharacters.GM_DressShirt_Carcass':
        case LodMesh'DeusExCharacters.GM_DressShirt_F_Carcass':
        case LodMesh'DeusExCharacters.GM_DressShirt_S_Carcass':
            AddClothing(G_Male,CT_Shirt,carcassClass.Default.MultiSkins[5],None);
            AddClothing(G_Male,CT_Pants,carcassClass.Default.MultiSkins[3],None);
            break;
        case LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass':
            AddClothing(G_Male,CT_Shirt,carcassClass.Default.MultiSkins[2],None);
            AddClothing(G_Male,CT_Pants,carcassClass.Default.MultiSkins[1],None);
            AddClothing(G_Male,CT_Helmet,carcassClass.Default.MultiSkins[6],None);
            break;
        case LodMesh'DeusExCharacters.GMK_DressShirt_Carcass':
        case LodMesh'DeusExCharacters.GMK_DressShirt_F_Carcass':
            AddClothing(G_Male,CT_Shirt,carcassClass.Default.MultiSkins[1],None);
            AddClothing(G_Male,CT_Pants,carcassClass.Default.MultiSkins[2],None);
            break;
        case LodMesh'DeusExCharacters.GM_Suit_Carcass':
            AddClothing(G_Male,CT_Shirt,carcassClass.Default.MultiSkins[3],None);
            AddClothing(G_Male,CT_Pants,carcassClass.Default.MultiSkins[1],None);
            break;
    }
}

defaultproperties
{
    bDisplayableInv=false
    ItemName="DXRFashionManager"
    bHidden=true
    bHeldItem=true
    InvSlotsX=-1
    InvSlotsY=-1
    Physics=PHYS_None
}
