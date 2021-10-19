class DXRFashion extends DXRBase;

var class<ScriptedPawn> influencers[100];
var int numInfluencers;
var class<ScriptedPawn> coatInfluencers[100];
var int numCoatInfluencers;
var class<ScriptedPawn> nonCoatInfluencers[100];
var int numNonCoatInfluencers;

simulated function PlayerAnyEntry(#var PlayerPawn  p)
{
    local int lastUpdate;
    Super.PlayerAnyEntry(p);

    InitInfluencers();

    lastUpdate = dxr.flagbase.GetInt('DXRFashion_LastUpdate');
    if (lastUpdate < dxr.dxInfo.MissionNumber) {
        RandomizeClothes();
        p.ClientMessage("Time for a change of clothes...");
    }

    GetDressed();
}

simulated function InitInfluencers()
{
    numInfluencers = 0;
    numCoatInfluencers = 0;
    numNonCoatInfluencers = 0;
    
    AddInfluencer(class'AlexJacobson');
    AddInfluencer(class'BoatPerson');
    AddInfluencer(class'Bartender');
    AddInfluencer(class'HowardStrong');
    AddInfluencer(class'JoeGreene');
    AddInfluencer(class'Male1');
    AddInfluencer(class'Male2');
    AddInfluencer(class'Male3');
    AddInfluencer(class'MorganEverett');
    AddInfluencer(class'Cop');
    AddInfluencer(class'JoJoFine');
    AddInfluencer(class'ThugMale2');
    AddInfluencer(class'ThugMale3');
    AddInfluencer(class'GuntherHermann');
    AddInfluencer(class'BusinessMan1');
    AddInfluencer(class'BusinessMan2');
    AddInfluencer(class'BusinessMan3');
    AddInfluencer(class'Butler');
    AddInfluencer(class'Chef');
    AddInfluencer(class'ChildMale');
    AddInfluencer(class'ChildMale2');
    AddInfluencer(class'Janitor');
    AddInfluencer(class'JunkieMale');
    AddInfluencer(class'LowerClassMale');
    AddInfluencer(class'LowerClassMale2');
    AddInfluencer(class'Male4');
    AddInfluencer(class'Mechanic');
    AddInfluencer(class'MichaelHamner');
    AddInfluencer(class'NathanMadison');
    AddInfluencer(class'PhilipMead');
    AddInfluencer(class'Sailor');
    AddInfluencer(class'SecretService');
    AddInfluencer(class'TracerTong');
    AddInfluencer(class'BobPage');
    AddInfluencer(class'HKMilitary');
    AddInfluencer(class'JosephManderley');
    AddInfluencer(class'MIB');
    AddInfluencer(class'MJ12Troop');
    AddInfluencer(class'RiotCop');
    AddInfluencer(class'SamCarter');
    AddInfluencer(class'Soldier');
    AddInfluencer(class'Terrorist');
    AddInfluencer(class'UNATCOTroop');
    AddInfluencer(class'Chad');
    AddInfluencer(class'ThugMale');
    AddInfluencer(class'TriadLumPath');
    AddInfluencer(class'TriadLumPath2');
    AddInfluencer(class'BumMale');
    AddInfluencer(class'BumMale2');
    AddInfluencer(class'BumMale3');
    AddInfluencer(class'JCDouble');
    AddInfluencer(class'JaimeReyes');
    AddInfluencer(class'HarleyFilben');
    AddInfluencer(class'GilbertRenton');
    AddInfluencer(class'FordSchick');
    AddInfluencer(class'GordonQuick');
    AddInfluencer(class'JuanLebedev');
    AddInfluencer(class'MaxChen');
    AddInfluencer(class'WaltonSimons');
    AddInfluencer(class'Smuggler');
    AddInfluencer(class'TobyAtanwe');
    AddInfluencer(class'TerroristCommander');
    AddInfluencer(class'TriadRedArrow');
    AddInfluencer(class'GarySavage');
    AddInfluencer(class'Doctor');
    AddInfluencer(class'ScientistMale');
    AddInfluencer(class'StantonDowd');
    AddInfluencer(class'Jock');
    AddInfluencer(class'ThugMale');
    AddInfluencer(class'PaulDenton'); 
}

simulated function texture GetCoat1(class<ScriptedPawn> p) 
{
    if (p==None){
        return None;
    }
    if (!IsTrenchInfluencer(p)) {
        return None;
    }
    return p.Default.MultiSkins[1];
}

simulated function texture GetCoat2(class<ScriptedPawn> p) 
{
    if (p==None){
        return None;
    }
    if (!IsTrenchInfluencer(p)) {
        return None;
    }
    return p.Default.MultiSkins[5];
}

simulated function texture GetShirt(class<ScriptedPawn> p)
{
    if (p==None){
        return None;
    }
    switch(p.Default.Mesh){
        case LodMesh'DeusExCharacters.GM_Trench_F':
        case LodMesh'DeusExCharacters.GM_Trench':
            return p.Default.MultiSkins[4]; 

        //Non-Trenchcoat shirts don't map onto the trenchcoat body properly            
        case LodMesh'DeusExCharacters.GM_DressShirt_B':
            return p.Default.MultiSkins[0]; 
        case LodMesh'DeusExCharacters.GM_DressShirt':
        case LodMesh'DeusExCharacters.GM_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_DressShirt_S':
             return p.Default.MultiSkins[5];
        case LodMesh'DeusExCharacters.GM_Jumpsuit':
             return p.Default.MultiSkins[2];
        case LodMesh'DeusExCharacters.GMK_DressShirt':
        case LodMesh'DeusExCharacters.GMK_DressShirt_F':
             return p.Default.MultiSkins[1];
        case LodMesh'DeusExCharacters.GM_Suit':
             return p.Default.MultiSkins[3];
        default:
            err("Influencer "$p.Name$" has mesh "$p.Default.Mesh);
            return None;
    }
}

simulated function texture GetPants(class<ScriptedPawn> p)
{
    if (p==None){
        return None;
    }
    switch(p.Default.Mesh){
        case LodMesh'DeusExCharacters.GM_Trench_F':
        case LodMesh'DeusExCharacters.GM_Trench':
            return p.Default.MultiSkins[2];    
        case LodMesh'DeusExCharacters.GM_DressShirt_B':
            return p.Default.MultiSkins[1];    
        case LodMesh'DeusExCharacters.GM_DressShirt':
        case LodMesh'DeusExCharacters.GM_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_DressShirt_S':
             return p.Default.MultiSkins[3];
        case LodMesh'DeusExCharacters.GM_Jumpsuit':
        case LodMesh'DeusExCharacters.GM_Suit':
             return p.Default.MultiSkins[1];
        case LodMesh'DeusExCharacters.GMK_DressShirt':
        case LodMesh'DeusExCharacters.GMK_DressShirt_F':
             return p.Default.MultiSkins[2];
        default:
            err("Influencer "$p.Name$" has mesh "$p.Default.Mesh);
            return None;
    }
}


simulated function texture GetHelmet(class<ScriptedPawn> p)
{
    if (p==None){
        return None;
    }
    switch(p.Default.Mesh){
        case LodMesh'DeusExCharacters.GM_Trench_F':
        case LodMesh'DeusExCharacters.GM_Trench': 
        case LodMesh'DeusExCharacters.GM_DressShirt_B':   
        case LodMesh'DeusExCharacters.GM_DressShirt':
        case LodMesh'DeusExCharacters.GM_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_DressShirt_S':
        case LodMesh'DeusExCharacters.GM_Suit':
        case LodMesh'DeusExCharacters.GMK_DressShirt':
        case LodMesh'DeusExCharacters.GMK_DressShirt_F':
             return Texture'DeusExItems.Skins.PinkMaskTex';
        case LodMesh'DeusExCharacters.GM_Jumpsuit':
             return p.Default.MultiSkins[6];
        default:
            err("Influencer "$p.Name$" has mesh "$p.Default.Mesh);
            return None;
    }

}

simulated function AddInfluencer(class<ScriptedPawn> p)
{
    if (isTrenchInfluencer(p)) {
        AddCoatInfluencer(p);
    } else {
        AddNonCoatInfluencer(p);
    }
}

simulated function AddBaseInfluencer(class<ScriptedPawn> p)
{
    influencers[numInfluencers++] = p;
}

simulated function AddNonCoatInfluencer(class<ScriptedPawn> p)
{
    AddBaseInfluencer(p);
    nonCoatInfluencers[numNonCoatInfluencers++] = p;
}

simulated function AddCoatInfluencer(class<ScriptedPawn> p)
{
    AddBaseInfluencer(p);
    coatInfluencers[numCoatInfluencers++] = p;
}

simulated function class<ScriptedPawn> RandomInfluencer()
{
    return influencers[Rand(numInfluencers)];
}

simulated function class<ScriptedPawn> RandomCoatInfluencer()
{
    return coatInfluencers[Rand(numCoatInfluencers)];
}

simulated function class<ScriptedPawn> RandomNonCoatInfluencer()
{
    return nonCoatInfluencers[Rand(numNonCoatInfluencers)];
}

simulated function bool IsTrenchInfluencer(class<ScriptedPawn> influencer)
{
    return (influencer.Default.Mesh == LodMesh'DeusExCharacters.GM_Trench' ||
            influencer.Default.Mesh == LodMesh'DeusExCharacters.GM_Trench_F');
}

simulated function ApplyOutfit(Actor p, texture coat1, texture coat2, texture shirt, texture pants, texture helmet, bool isJC) {
    local bool isTrench;
    
    isTrench = (coat1 != None && coat2 != None);
    
    if (isTrench) {
        if( DeusExCarcass(p) != None ) {
            p.Mesh = LodMesh'DeusExCharacters.GM_Trench_Carcass';
            DeusExCarcass(p).Mesh2 = LodMesh'DeusExCharacters.GM_Trench_CarcassB';
            DeusExCarcass(p).Mesh3 = LodMesh'DeusExCharacters.GM_Trench_CarcassC';
        }
        else {
            p.Mesh = LodMesh'DeusExCharacters.GM_Trench';
        }
        p.MultiSkins[1] = coat1;
        p.MultiSkins[2] = pants;
        p.MultiSkins[4] = shirt;
        p.MultiSkins[5] = coat2;
        
        if (isJC) {
            p.MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
            p.MultiSkins[7] = Texture'DeusExCharacters.Skins.LensesTex5';
        } else {
            p.MultiSkins[6] = Texture'DeusExItems.Skins.GrayMaskTex';
            p.MultiSkins[7] = Texture'DeusExItems.Skins.BlackMaskTex';
        }
        
    } else {
        if( DeusExCarcass(p) != None ) {
            p.Mesh = LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass';
            DeusExCarcass(p).Mesh2 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB';
            DeusExCarcass(p).Mesh3 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC';
        }
        else {
            p.Mesh = LodMesh'MPCharacters.mp_jumpsuit';
        }
        p.MultiSkins[1] = pants;
        p.MultiSkins[2] = shirt;
        p.MultiSkins[3] = p.MultiSkins[0];
        p.MultiSkins[4] = Texture'DeusExItems.Skins.PinkMaskTex'; //Face mask, like for NSF guys
        p.MultiSkins[5] = Texture'DeusExItems.Skins.PinkMaskTex'; //Visor lens
        p.MultiSkins[6] = helmet; //Helmet
        p.MultiSkins[7] = Texture'DeusExItems.Skins.PinkMaskTex';
        
        p.Texture = Texture'DeusExItems.Skins.PinkMaskTex';
        
        //Jumpsuit doesn't support glasses
    }
}

//Brothers gotta match, mom got their clothes out in advance
simulated function GetDressed()
{
    local PaulDenton paul;
    local PaulDentonCarcass paulCarcass;
    local JCDentonMaleCarcass jcCarcass;
    local JCDouble jc;
    local DeusExPlayer player;
    local texture coat1,coat2,pants,shirt,helmet;
    local name coatinfluencer,pantsinfluencer,shirtinfluencer;
    local class<ScriptedPawn> styleInfluencer;
    local bool isTrench;

    if( Level.Game.Class.Name == 'JCDentonFemaleGameInfo' ) {
        dxr.flagbase.SetBool('LDDPJCIsFemale', true,, 999);
        info("disabled DXRFashion because Level.Game.Class.Name == " $ Level.Game.Class.Name);
        return;
    }

    coatinfluencer = dxr.flagbase.GetName('DXRFashion_CoatInfluencer');
    pantsinfluencer = dxr.flagbase.GetName('DXRFashion_PantsInfluencer');
    shirtinfluencer = dxr.flagbase.GetName('DXRFashion_ShirtInfluencer');

    if (coatinfluencer == '' ||
        pantsinfluencer == '' ||
        shirtinfluencer == '') {
        //This was probably a game saved before fashion existed
        info("No stored outfit!");
        InitInfluencers();
        RandomizeClothes();
        coatinfluencer = dxr.flagbase.GetName('DXRFashion_CoatInfluencer');
        pantsinfluencer = dxr.flagbase.GetName('DXRFashion_PantsInfluencer');
        shirtinfluencer = dxr.flagbase.GetName('DXRFashion_ShirtInfluencer');        
    }
    

    if (coatinfluencer!='') {
        styleInfluencer = class<ScriptedPawn>(GetClassFromString(string(coatinfluencer),class'ScriptedPawn'));
        isTrench = IsTrenchInfluencer(styleInfluencer);
        if (isTrench) {
            coat1=GetCoat1(styleInfluencer);
            coat2=GetCoat2(styleInfluencer);
            helmet = None;
        } else {
            coat1 = None;
            coat2 = None;
            helmet = GetHelmet(styleInfluencer);
        }
    }
    
    
    if (pantsinfluencer!='') {
        styleInfluencer = class<ScriptedPawn>(GetClassFromString(string(pantsinfluencer),class'ScriptedPawn'));   
        pants = GetPants(styleInfluencer);   
    }

    if (shirtinfluencer!='') {
        styleInfluencer = class<ScriptedPawn>(GetClassFromString(string(shirtinfluencer),class'ScriptedPawn'));    
        shirt = GetShirt(styleInfluencer);
    }


    
    
    // Paul Denton
    foreach AllActors(class'PaulDenton', paul)
        break;

    if (paul != None) {
        ApplyOutfit(paul,coat1,coat2,shirt,pants,helmet,False);
    }

    // Paul Denton Carcass
    foreach AllActors(class'PaulDentonCarcass', paulCarcass) 
        break;
        
    if (paulCarcass!=None) {
        ApplyOutfit(paulCarcass,coat1,coat2,shirt,pants,helmet,False);
    }


    // JC Denton Carcass
    foreach AllActors(class'JCDentonMaleCarcass', jcCarcass)
        break;

    if (jcCarcass != None) {
        ApplyOutfit(jcCarcass,coat1,coat2,shirt,pants,helmet,True);
    }

    // JC's stunt double
    foreach AllActors(class'JCDouble', jc)
        ApplyOutfit(jc,coat1,coat2,shirt,pants,helmet,True);

    foreach AllActors(class'DeusExPlayer', player)
        ApplyOutfit(player,coat1,coat2,shirt,pants,helmet,True);

}

simulated function RandomizeClothes()
{
    local class<ScriptedPawn> styleInfluencer;
    local bool isTrench;
  
    //Randomize Coat (Multiskin 1 and 5)
    styleInfluencer = RandomInfluencer();
    isTrench = IsTrenchInfluencer(styleInfluencer);
    dxr.flagbase.SetName('DXRFashion_CoatInfluencer',styleInfluencer.name);
    info("Coat influencer is "$styleInfluencer);
    //player().ClientMessage("Coat influencer is "$styleInfluencer);
    
    //Randomize Pants (Multiskin 2)
    styleInfluencer = RandomInfluencer();
    dxr.flagbase.SetName('DXRFashion_PantsInfluencer',styleInfluencer.name);
    info("Pants influencer is "$styleInfluencer);
    //player().ClientMessage("Pants influencer is "$styleInfluencer);
    
    //Randomize Shirt (Multiskin 4
    if (isTrench) {
        styleInfluencer = RandomCoatInfluencer();
    } else {
        styleInfluencer = RandomNonCoatInfluencer();
    }
    dxr.flagbase.SetName('DXRFashion_ShirtInfluencer',styleInfluencer.name);
    info("Shirt influencer is "$styleInfluencer);
    //player().ClientMessage("Shirt influencer is "$styleInfluencer);
    
    dxr.flags.f.SetInt('DXRFashion_LastUpdate',dxr.dxInfo.MissionNumber,,999);

}
