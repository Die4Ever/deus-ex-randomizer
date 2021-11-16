class DXRFashion extends DXRBase transient;

var class<ScriptedPawn> influencers[100];
var int numInfluencers;
var class<ScriptedPawn> coatInfluencers[100];
var int numCoatInfluencers;
var class<ScriptedPawn> nonCoatInfluencers[100];
var int numNonCoatInfluencers;

var class<ScriptedPawn> femaleInfluencers[100];
var int numFemaleInfluencers;
var class<ScriptedPawn> femaleCoatInfluencers[100];
var int numFemaleCoatInfluencers;
var class<ScriptedPawn> femaleSkirtInfluencers[100];
var int numFemaleSkirtInfluencers;
var class<ScriptedPawn> femaleNonCoatInfluencers[100];
var int numFemaleNonCoatInfluencers;

var bool isFemale;

simulated function PlayerAnyEntry(#var PlayerPawn  p)
{
    local int lastUpdate, i;
    local class<Pawn> jcd;
    Super.PlayerAnyEntry(p);

    isFemale = false;
    if( Level.Game.Class.Name == 'JCDentonFemaleGameInfo' ) {
        isFemale = true;
        dxr.flagbase.SetBool('LDDPJCIsFemale', true,, 999);
        info("DXRFashion isFemale because Level.Game.Class.Name == " $ Level.Game.Class.Name);

        info( "" $ p.Mesh );
        for(i=0; i<8; i++) {
            info( "" $ p.MultiSkins[i]);
        }
        info( "" $ p.CarcassType );
        jcd = class<Pawn>(GetClassFromString("FemJC.JCFDouble", class'Pawn'));
        info( "" $ jcd.default.Mesh );
        for(i=0; i<8; i++) {
            info( "" $ jcd.default.MultiSkins[i]);
        }

        /*info( "" $ p.CarcassType.default.Mesh );
        info( "" $ p.CarcassType.default.Mesh2 );
        info( "" $ p.CarcassType.default.Mesh3 );*/
    }

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
    numFemaleInfluencers = 0;
    numFemaleCoatInfluencers = 0;
    numFemaleSkirtInfluencers = 0;
    numFemaleNonCoatInfluencers = 0;
    
    AddInfluencer(class'Male1', class'Female2');
    AddInfluencer(class'Male2', class'Female4');
    AddInfluencer(class'Male3', class'Female1');
    AddInfluencer(class'Male4', class'Female3');
    AddInfluencer(class'Doctor', class'Nurse');
    AddInfluencerString(class'JCDouble', "FemJC.JCFDouble");
    AddInfluencer(class'ScientistMale', class'ScientistFemale');
    AddInfluencer(class'Bartender', class'JordanShea');
    AddInfluencer(class'MaxChen', class'MaggieChow');
    AddInfluencer(class'GuntherHermann', class'AnnaNavarre');
    AddInfluencer(class'MIB', class'WIB');
    AddInfluencer(class'BusinessMan3', class'BusinessWoman1');
    AddInfluencer(class'JunkieMale', class'JunkieFemale');
    AddInfluencer(class'LowerClassMale', class'LowerClassFemale');
    AddInfluencer(class'HowardStrong', class'RachelMead');
    AddInfluencer(class'PhilipMead', class'MargaretWilliams');
    AddInfluencer(class'JoJoFine', class'TiffanySavage');
    AddInfluencer(class'BusinessMan1', class'Secretary');
    AddInfluencer(class'BumMale', class'BumFemale');


    AddInfluencer(class'AlexJacobson', None);
    AddInfluencer(class'BoatPerson', None);
    AddInfluencer(class'JoeGreene', None);
    AddInfluencer(class'MorganEverett', None);
    AddInfluencer(class'Cop', None);
    AddInfluencer(class'ThugMale2', None);
    AddInfluencer(class'ThugMale3', None);
    AddInfluencer(class'BusinessMan2', None);
    AddInfluencer(class'Butler', None);
    AddInfluencer(class'Chef', None);
    AddInfluencer(class'ChildMale', None);
    AddInfluencer(class'ChildMale2', None);
    AddInfluencer(class'Janitor', None);
    AddInfluencer(class'LowerClassMale2', None);
    AddInfluencer(class'Mechanic', None);
    AddInfluencer(class'MichaelHamner', None);
    AddInfluencer(class'NathanMadison', None);
    AddInfluencer(class'Sailor', None);
    AddInfluencer(class'SecretService', None);
    AddInfluencer(class'TracerTong', None);
    AddInfluencer(class'BobPage', None);
    AddInfluencer(class'HKMilitary', None);
    AddInfluencer(class'JosephManderley', None);
    AddInfluencer(class'MJ12Troop', None);
    AddInfluencer(class'RiotCop', None);
    AddInfluencer(class'SamCarter', None);
    AddInfluencer(class'Soldier', None);
    AddInfluencer(class'Terrorist', None);
    AddInfluencer(class'UNATCOTroop', None);
    AddInfluencer(class'Chad', None);
    AddInfluencer(class'ThugMale', None);
    AddInfluencer(class'TriadLumPath', None);
    AddInfluencer(class'TriadLumPath2', None);
    AddInfluencer(class'BumMale2', None);
    AddInfluencer(class'BumMale3', None);
    AddInfluencer(class'JaimeReyes', None);
    AddInfluencer(class'HarleyFilben', None);
    AddInfluencer(class'GilbertRenton', None);
    AddInfluencer(class'FordSchick', None);
    AddInfluencer(class'GordonQuick', None);
    AddInfluencer(class'JuanLebedev', None);
    AddInfluencer(class'WaltonSimons', None);
    AddInfluencer(class'Smuggler', None);
    AddInfluencer(class'TobyAtanwe', None);
    AddInfluencer(class'TerroristCommander', None);
    AddInfluencer(class'TriadRedArrow', None);
    AddInfluencer(class'GarySavage', None);
    AddInfluencer(class'StantonDowd', None);
    AddInfluencer(class'Jock', None);
    AddInfluencer(class'ThugMale', None);
    AddInfluencer(class'PaulDenton', None); 
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
    // females don't use coat2
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
        case LodMesh'DeusExCharacters.GFM_Trench':
            return p.Default.MultiSkins[4];

        //Non-Trenchcoat shirts don't map onto the trenchcoat body properly
        case LodMesh'DeusExCharacters.GFM_SuitSkirt':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
            return p.Default.MultiSkins[4];
        case LodMesh'DeusExCharacters.GFM_TShirtPants':
            return p.Default.MultiSkins[7];
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
        case LodMesh'DeusExCharacters.GFM_Trench':
            return p.Default.MultiSkins[2];
        case LodMesh'DeusExCharacters.GFM_SuitSkirt':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
            return p.Default.MultiSkins[5];
        case LodMesh'DeusExCharacters.GFM_TShirtPants':
            return p.Default.MultiSkins[6];
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
        case LodMesh'DeusExCharacters.GFM_Trench':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
        case LodMesh'DeusExCharacters.GFM_TShirtPants':
            // I don't think any of the female models support helmets
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

simulated function AddInfluencer(class<ScriptedPawn> male, class<ScriptedPawn> female)
{
    if (isTrenchInfluencer(male))
        AddCoatInfluencer(male, false);
    else
        AddNonCoatInfluencer(male, false);

    if( female == None || isFemale == false )
        return;

    if (isTrenchInfluencer(female))
        AddCoatInfluencer(female, true);
    else if (IsSkirtInfluencer(female))
        AddSkirtInfluencer(female);
    else
        AddNonCoatInfluencer(female, true);
}

simulated function AddInfluencerString(class<ScriptedPawn> male, string female)
{
    local class<ScriptedPawn> femaleClass;
    // don't want to require LDD for compilation, so this handles it at runtime
    if( isFemale )
        femaleClass = class<ScriptedPawn>(GetClassFromString(female, class'ScriptedPawn'));
    AddInfluencer(male, femaleClass);
}

simulated function AddBaseInfluencer(class<ScriptedPawn> p, bool female)
{
    if( female )
        femaleInfluencers[numFemaleInfluencers++] = p;
    else
        influencers[numInfluencers++] = p;
}

simulated function AddNonCoatInfluencer(class<ScriptedPawn> p, bool female)
{
    AddBaseInfluencer(p, female);
    if( female )
        femaleNonCoatInfluencers[numFemaleNonCoatInfluencers++] = p;
    else
        nonCoatInfluencers[numNonCoatInfluencers++] = p;
}

simulated function AddCoatInfluencer(class<ScriptedPawn> p, bool female)
{
    AddBaseInfluencer(p, female);
    if( female )
        femaleCoatInfluencers[numFemaleCoatInfluencers++] = p;
    else
        coatInfluencers[numCoatInfluencers++] = p;
}

simulated function AddSkirtInfluencer(class<ScriptedPawn> p)
{
    AddBaseInfluencer(p, true);
    femaleSkirtInfluencers[numFemaleSkirtInfluencers++] = p;
}

simulated function class<ScriptedPawn> RandomInfluencer(bool female)
{
    if( female )
        return femaleInfluencers[Rand(numFemaleInfluencers)];
    else
        return influencers[Rand(numInfluencers)];
}

simulated function class<ScriptedPawn> RandomCoatInfluencer(bool female)
{
    if( female )
        return femaleCoatInfluencers[Rand(numFemaleCoatInfluencers)];
    else
        return coatInfluencers[Rand(numCoatInfluencers)];
}

simulated function class<ScriptedPawn> RandomSkirtInfluencer()
{
    return femaleSkirtInfluencers[Rand(numFemaleSkirtInfluencers)];
}

simulated function class<ScriptedPawn> RandomNonCoatInfluencer(bool female)
{
    if( female )
        return femaleNonCoatInfluencers[Rand(numFemaleNonCoatInfluencers)];
    else
        return nonCoatInfluencers[Rand(numNonCoatInfluencers)];
}

simulated function class<ScriptedPawn> RandomUniSexNonSkirtInfluencer(bool female)
{
    local int num, r;

    num = numInfluencers + numFemaleCoatInfluencers + numFemaleNonCoatInfluencers;
    r = Rand(num);
    if( r >= numInfluencers ) {
        r -= numInfluencers;
        if( r >= numFemaleCoatInfluencers ) {
            r -= numFemaleCoatInfluencers;
            return femaleNonCoatInfluencers[r];
        }
        return femaleCoatInfluencers[r];
    }

    return influencers[r];
}

simulated function class<ScriptedPawn> RandomUniSexNonCoatInfluencer(bool female)
{
    local int num, r;

    num = numNonCoatInfluencers + numFemaleSkirtInfluencers + numFemaleNonCoatInfluencers;
    r = Rand(num);
    if( r >= numNonCoatInfluencers ) {
        r -= numNonCoatInfluencers;
        if( r >= numFemaleSkirtInfluencers ) {
            r -= numFemaleSkirtInfluencers;
            return femaleNonCoatInfluencers[r];
        }
        return femaleSkirtInfluencers[r];
    }

    return nonCoatInfluencers[r];
}

simulated function bool IsTrenchInfluencer(class<ScriptedPawn> influencer)
{
    return (influencer.Default.Mesh == LodMesh'DeusExCharacters.GM_Trench' ||
            influencer.Default.Mesh == LodMesh'DeusExCharacters.GM_Trench_F' ||
            influencer.Default.Mesh == LodMesh'DeusExCharacters.GFM_Trench' );
}

simulated function bool IsSkirtInfluencer(class<ScriptedPawn> influencer)
{
    return influencer.Default.Mesh == LodMesh'DeusExCharacters.GFM_SuitSkirt' || influencer.Default.Mesh == LodMesh'DeusExCharacters.GFM_SuitSkirt_F';
}

simulated function ApplyOutfit(Actor p, class<ScriptedPawn> model, texture coat1, texture coat2, texture shirt, texture pants, texture helmet, bool isJC) {
    local bool female;
    local DeusExCarcass carcass;
    local class<DeusExCarcass> modelCarcass;
    local int i;

    female = isFemale && isJC;
    carcass = DeusExCarcass(p);

    // need to exlude _F meshes, JC is fit
    if( carcass != None ) {
        modelCarcass = class<DeusExCarcass>(model.default.CarcassType);
        carcass.Mesh = modelCarcass.default.Mesh;
        carcass.Mesh2 = modelCarcass.default.Mesh2;
        carcass.Mesh3 = modelCarcass.default.Mesh3;
    }
    else {
        p.Mesh = model.default.Mesh;
    }

    // first set to defaults
    for(i=1; i<8; i++) {
        p.MultiSkins[i] = Texture'DeusExItems.Skins.PinkMaskTex';// model.Default.MultiSkins[i];
    }
    p.MultiSkins[0] = p.Default.MultiSkins[0];
    /*coat1 = Texture'DeusExItems.Skins.PinkMaskTex';
    coat2 = Texture'DeusExItems.Skins.PinkMaskTex';
    shirt = Texture'DeusExItems.Skins.PinkMaskTex';
    //pants = Texture'DeusExItems.Skins.PinkMaskTex';
    helmet = Texture'DeusExItems.Skins.PinkMaskTex';*/

    switch(model.default.Mesh) {
        case LodMesh'DeusExCharacters.GFM_Trench':
            p.MultiSkins[1] = coat1;
            p.MultiSkins[2] = pants;
            p.MultiSkins[4] = shirt;
            // 5 is skirt?

            if (isJC) {
                p.MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
                p.MultiSkins[7] = Texture'DeusExCharacters.Skins.LensesTex5';
            } else {// just in case anyone wants to make a FemPaul mod?
                p.MultiSkins[6] = Texture'DeusExItems.Skins.GrayMaskTex';
                p.MultiSkins[7] = Texture'DeusExItems.Skins.BlackMaskTex';
            }
            break;
        case LodMesh'DeusExCharacters.GFM_SuitSkirt':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
            // 1 is hair?
            p.MultiSkins[3] = Texture'DeusExCharacters.Skins.Female2Tex1';// legs/pants
            p.MultiSkins[4] = shirt;
            p.MultiSkins[5] = pants;// skirt

            if (isJC) {
                p.MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
                p.MultiSkins[7] = Texture'DeusExCharacters.Skins.LensesTex5';
            } else {
                p.MultiSkins[6] = Texture'DeusExItems.Skins.GrayMaskTex';
                p.MultiSkins[7] = Texture'DeusExItems.Skins.BlackMaskTex';
            }
            break;
        case LodMesh'DeusExCharacters.GFM_TShirtPants':
            // 2 is hair?
            p.MultiSkins[6] = pants;
            p.MultiSkins[7] = shirt;

            if (isJC) {
                p.MultiSkins[3] = Texture'DeusExCharacters.Skins.FramesTex4';
                p.MultiSkins[4] = Texture'DeusExCharacters.Skins.LensesTex5';
            } else {
                p.MultiSkins[3] = Texture'DeusExItems.Skins.GrayMaskTex';
                p.MultiSkins[4] = Texture'DeusExItems.Skins.BlackMaskTex';
            }
            break;
        
        case LodMesh'DeusExCharacters.GM_Trench':
        case LodMesh'DeusExCharacters.GM_Trench_F':
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
            break;
        
        case LodMesh'MPCharacters.mp_jumpsuit':
        case LodMesh'DeusExCharacters.GM_DressShirt_B':
        case LodMesh'DeusExCharacters.GM_DressShirt':
        case LodMesh'DeusExCharacters.GM_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_DressShirt_S':
        case LodMesh'DeusExCharacters.GM_Suit':
        case LodMesh'DeusExCharacters.GMK_DressShirt':
        case LodMesh'DeusExCharacters.GMK_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_Jumpsuit':

            if( carcass != None ) {
                carcass.Mesh = LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass';
                carcass.Mesh2 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB';
                carcass.Mesh3 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC';
            } else {
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
            break;

        default:
            err("unhandled mesh " $ model.default.Mesh);
    }

    info( p $ " " $ p.Mesh );
    for(i=0; i<8; i++) {
        info( p $ " " $ i $ ": " $ p.MultiSkins[i]);
    }
}

simulated function class<ScriptedPawn> GetInfluencerClass(name inf)
{
    local string infname;
    infname = string(inf);
    switch(infname) {
        case "JCFDouble":
            // the name type can't have periods in it
            infname = "FemJC.JCFDouble";
            break;
    }
    return class<ScriptedPawn>(GetClassFromString(infname,class'ScriptedPawn'));
}

simulated function ApplyInfluencers(Actor p, name coatinfluencer, name pantsinfluencer, name shirtinfluencer, bool isJC)
{
    local texture coat1,coat2,pants,shirt,helmet;
    local class<ScriptedPawn> styleInfluencer, model;
    local bool isTrench;

    if (coatinfluencer!='') {
        model = GetInfluencerClass(coatinfluencer);
        isTrench = IsTrenchInfluencer(model);
        if (isTrench) {
            coat1=GetCoat1(model);
            coat2=GetCoat2(model);
            helmet = None;
        } else {
            coat1 = None;
            coat2 = None;
            helmet = GetHelmet(model);
        }
    }
    
    
    if (pantsinfluencer!='') {
        styleInfluencer = GetInfluencerClass(pantsinfluencer);
        pants = GetPants(styleInfluencer);   
    }

    if (shirtinfluencer!='') {
        styleInfluencer = GetInfluencerClass(shirtinfluencer);
        shirt = GetShirt(styleInfluencer);
    }

    ApplyOutfit(p, model, coat1, coat2, shirt, pants, helmet, isJC);
}

simulated function name GetMaleInfluencer(name influencer)
{
    local int i;
    for(i=0; i<numFemaleInfluencers; i++) {
        if( femaleInfluencers[i].Name == influencer ) {
            info("GetMaleInfluencer("$influencer$") returned "$influencers[i].Name);
            return influencers[i].Name;
        }
    }
    return influencer;
    //warning("GetMaleInfluencer("$influencer$") failed");
    //return 'PaulDenton';
}

//Siblings gotta match, mom got their clothes out in advance
simulated function GetDressed()
{
    local PaulDenton paul;
    local PaulDentonCarcass paulCarcass;
    local JCDentonMaleCarcass jcCarcass;
    local JCDouble jc;
    local DeusExPlayer player;
    local name coatinfluencer,pantsinfluencer,shirtinfluencer;

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

    // JC Denton Carcass
    foreach AllActors(class'JCDentonMaleCarcass', jcCarcass)
        ApplyInfluencers(jcCarcass, coatinfluencer, pantsinfluencer, shirtinfluencer, true);

    // JC's stunt double
    foreach AllActors(class'JCDouble', jc)
        ApplyInfluencers(jc, coatinfluencer, pantsinfluencer, shirtinfluencer, true);

    foreach AllActors(class'DeusExPlayer', player)
        ApplyInfluencers(player, coatinfluencer, pantsinfluencer, shirtinfluencer, true);

    if( isFemale ) {
        // convert influencers to male for Paul
        coatinfluencer = GetMaleInfluencer(coatinfluencer);
        pantsinfluencer = GetMaleInfluencer(pantsinfluencer);
        shirtinfluencer = GetMaleInfluencer(shirtinfluencer);
    }

    // Paul Denton
    foreach AllActors(class'PaulDenton', paul)
        ApplyInfluencers(paul, coatinfluencer, pantsinfluencer, shirtinfluencer, false);

    // Paul Denton Carcass
    foreach AllActors(class'PaulDentonCarcass', paulCarcass) 
        ApplyInfluencers(paulCarcass, coatinfluencer, pantsinfluencer, shirtinfluencer, false);
}

simulated function RandomizeClothes()
{
    local class<ScriptedPawn> styleInfluencer;
    local bool isTrench, isSkirt;

    // notes about mixing and matching clothes
    // male pants are distorted on female butts, but look fine from the front
    // shirts don't blend well with skirts
    // shirts are distorted on the GFM_TShirtPants model (unless of course they're made for that model)
    
    //Randomize Coat (Multiskin 1 and 5)
    styleInfluencer = RandomInfluencer(isFemale);
    isTrench = IsTrenchInfluencer(styleInfluencer);
    isSkirt = IsSkirtInfluencer(styleInfluencer);
    dxr.flagbase.SetName('DXRFashion_CoatInfluencer',styleInfluencer.name);
    info("Coat influencer is "$styleInfluencer$", isSkirt: "$isSkirt$", isTrench: "$isTrench);
    //player().ClientMessage("Coat influencer is "$styleInfluencer);
    
    //Randomize Pants (Multiskin 2)
    if (isSkirt) {
        styleInfluencer = RandomSkirtInfluencer();
    } else {
        // for pants we might be able to pull from male pants too, but no skirts
        styleInfluencer = RandomUniSexNonSkirtInfluencer(isFemale);
    }
    dxr.flagbase.SetName('DXRFashion_PantsInfluencer',styleInfluencer.name);
    info("Pants influencer is "$styleInfluencer);
    //player().ClientMessage("Pants influencer is "$styleInfluencer);
    
    //Randomize Shirt (Multiskin 4)
    if (isTrench) {
        styleInfluencer = RandomCoatInfluencer(isFemale);
    } else {
        // for shirts we might be able to pull from male shirts too
        styleInfluencer = RandomUniSexNonCoatInfluencer(isFemale);
    }
    dxr.flagbase.SetName('DXRFashion_ShirtInfluencer',styleInfluencer.name);
    info("Shirt influencer is "$styleInfluencer);
    //player().ClientMessage("Shirt influencer is "$styleInfluencer);
    
    dxr.flags.f.SetInt('DXRFashion_LastUpdate',dxr.dxInfo.MissionNumber,,999);

}
