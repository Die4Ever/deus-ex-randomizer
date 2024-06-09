#dontcompileif vmd
class DXRFashion extends DXRBase transient;

var class<ScriptedPawn> influencers[100];
var int numInfluencers;

var class<ScriptedPawn> femaleInfluencers[100];
var int numFemaleInfluencers;

var bool isFemale;

function CheckConfig()
{
    Super.CheckConfig();
    InitInfluencers();
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local int lastUpdate, i;
    local class<Pawn> jcd;
    Super.PlayerAnyEntry(p);
    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) return;

    isFemale = false;
    //if( Level.Game.Class.Name == 'JCDentonFemaleGameInfo' ) {
    if( dxr.flagbase.GetBool('LDDPJCIsFemale') ) {
        isFemale = true;
        //dxr.flagbase.SetBool('LDDPJCIsFemale', true,, 999);
        info("DXRFashion isFemale, Level.Game.Class.Name == " $ Level.Game.Class.Name);
    }

    lastUpdate = dxr.flagbase.GetInt('DXRFashion_LastUpdate');
    info("got DXRFashion_LastUpdate: "$lastUpdate);
    if (lastUpdate < dxr.dxInfo.MissionNumber || lastUpdate > dxr.dxInfo.MissionNumber + 2) {
        RandomizeClothes(player());
    }

    GetDressed();
}

simulated function InitInfluencers()
{
    numInfluencers = 0;
    numFemaleInfluencers = 0;

    AddInfluencer(class'Male1', class'Female2');
    AddInfluencer(class'Male2', class'Female4');
    AddInfluencer(class'Male3', class'Female1');
    AddInfluencer(class'Male4', class'Female3');
    AddInfluencer(class'Doctor', class'Nurse');
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
    AddInfluencerName(class'JCDouble', 'JCFDouble');


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
    AddInfluencer(class'JosephManderley', class'JosephManderley');
    AddInfluencer(class'MJ12Troop', None);
    AddInfluencer(class'RiotCop', None);
    AddInfluencer(class'SamCarter', None);
    AddInfluencer(class'Soldier', None);
    AddInfluencer(class'Terrorist', None);
    AddInfluencer(class'UNATCOTroop', None);
    AddInfluencer(class'Chad', None);
    AddInfluencer(class'ThugMale', class'ThugMale');
    AddInfluencer(class'TriadLumPath', None);
    AddInfluencer(class'TriadLumPath2', None);
    AddInfluencer(class'BumMale2', class'BumMale2');
    AddInfluencer(class'BumMale3', class'BumMale3');
    AddInfluencer(class'JaimeReyes', class'MaxChen'); //Max Chen isn't related to Jaime, but get Max in the mix for FemJC outfit choices
    AddInfluencer(class'HarleyFilben', class'HarleyFilben');
    AddInfluencer(class'GilbertRenton', class'GilbertRenton');
    AddInfluencer(class'FordSchick', class'FordSchick');
    AddInfluencer(class'GordonQuick', class'GordonQuick'); //Obviously we don't want his "shirt" for FemJC... His jacket is fine though
    AddInfluencer(class'JuanLebedev', class'JuanLebedev');
    AddInfluencer(class'WaltonSimons', class'WaltonSimons');
    AddInfluencer(class'Smuggler', class'Smuggler'); //His shirt is a bit tight and looks weird on FemJC
    AddInfluencer(class'TobyAtanwe', class'TobyAtanwe');
    AddInfluencer(class'TerroristCommander', class'TerroristCommander'); //His shirt isn't great for FemJC
    AddInfluencer(class'TriadRedArrow', class'TriadRedArrow');
    AddInfluencer(class'GarySavage', None);
    AddInfluencer(class'StantonDowd', class'StantonDowd');
    AddInfluencer(class'Jock', class'Jock');
    AddInfluencer(class'PaulDenton', class'PaulDenton');
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
    AddBaseInfluencer(male, false);

    if( female == None )
        return;

    //info("AddInfluencer("$male$", "$female$") male model: "$male.Default.Mesh$", female model: "$female.Default.Mesh);
    AddBaseInfluencer(female, true);
}

simulated function AddInfluencerName(class<ScriptedPawn> male, name female)
{
    local class<ScriptedPawn> femaleClass;

    // don't want to require LDDP for compilation, so this handles it at runtime
    if( dxr.flagbase.GetBool('LDDPJCIsFemale') ) { //isFemale won't be initialized when this is called
        femaleClass = GetInfluencerClass(female);
    }

    AddInfluencer(male, femaleClass);
}

simulated function AddBaseInfluencer(class<ScriptedPawn> p, bool female)
{
    if( female )
        femaleInfluencers[numFemaleInfluencers++] = p;
    else
        influencers[numInfluencers++] = p;
}

simulated function class<ScriptedPawn> RandomInfluencerForMeshes(bool female, LodMesh meshes[16])
{
    local class<ScriptedPawn> infs[100];
    local int num, i, m;
    num = 0;
    if(female) {
        for(i=0; i<numFemaleInfluencers; i++) {
            //warning(""$femaleInfluencers[i].Default.Mesh);
            for(m=0; m<ArrayCount(meshes); m++) {
                if( meshes[m] == None )
                    break;
                if( femaleInfluencers[i].Default.Mesh == meshes[m] ) {
                    infs[num++] = femaleInfluencers[i];
                    break;
                }
            }
        }
    } else {
        for(i=0; i<numInfluencers; i++) {
            for(m=0; m<ArrayCount(meshes); m++) {
                if( meshes[m] == None )
                    break;
                if( influencers[i].Default.Mesh == meshes[m] ) {
                    infs[num++] = influencers[i];
                    break;
                }
            }
        }
    }

    if(num == 0) {
        err("RandomInfluencerForMeshes, female: "$female$", failed with meshes...");
        for(m=0; m<ArrayCount(meshes); m++) {
            if(meshes[m] == None) break;
            warning("..." $ meshes[m]);
        }
        return None;
    }

    return infs[Rand(num)];
}

simulated function class<ScriptedPawn> RandomInfluencer(bool female)
{
    if( female )
        return femaleInfluencers[Rand(numFemaleInfluencers)];
    else
        return influencers[Rand(numInfluencers)];
}

simulated function class<ScriptedPawn> RandomCoatInfluencer(bool female, bool shirtSearch)
{
    local LodMesh meshes[16];
    local class<ScriptedPawn> c;
    local int i;
    local bool compatible;

    if(female) {
        meshes[0] = LodMesh'DeusExCharacters.GFM_Trench';
        meshes[1] = LodMesh'DeusExCharacters.GM_Trench'; //These mens coats work on the female model also
        meshes[2] = LodMesh'DeusExCharacters.GM_Trench_F';

    } else {
        meshes[0] = LodMesh'DeusExCharacters.GM_Trench';
        meshes[1] = LodMesh'DeusExCharacters.GM_Trench_F';
    }

    for(i=0; i < 10 && !compatible; i++) {
        c = RandomInfluencerForMeshes(female, meshes);

        compatible=true;
        if (female && shirtSearch){
            compatible = isValidFemaleShirtInfluencer(c);
        }
    }

    return c;
}

simulated function class<ScriptedPawn> RandomCoatOtherSkinInfluencer(bool female, bool shirtSearch)
{
    local int i;
    local class<ScriptedPawn> c;
    local bool compatible;
    for(i=0; i < 10 && !compatible; i++) {
        c = RandomCoatInfluencer(female,shirtSearch);
        compatible = isOtherSkinCompatible(c);
    }
    return c;
}

simulated function class<ScriptedPawn> RandomFemaleShirtInfluencer()
{
    local LodMesh meshes[16];
    meshes[0] = LodMesh'DeusExCharacters.GFM_TShirtPants';
    return RandomInfluencerForMeshes(true, meshes);
}

simulated function class<ScriptedPawn> RandomSkirtInfluencer()
{
    local LodMesh meshes[16];
    meshes[0] = LodMesh'DeusExCharacters.GFM_SuitSkirt';
    meshes[1] = LodMesh'DeusExCharacters.GFM_SuitSkirt_F';
    return RandomInfluencerForMeshes(true, meshes);
}

simulated function class<ScriptedPawn> RandomNonCoatInfluencer(bool female)
{
    local LodMesh meshes[16];
    local int i;
    i=0;

    if(female) {
        meshes[i++] = LodMesh'DeusExCharacters.GFM_SuitSkirt';
        meshes[i++] = LodMesh'DeusExCharacters.GFM_SuitSkirt_F';
        meshes[i++] = LodMesh'DeusExCharacters.GFM_TShirtPants';
    } else {
        meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_B';
        meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt';
        meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_F';
        meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_S';
        meshes[i++] = LodMesh'DeusExCharacters.GM_Jumpsuit';
        meshes[i++] = LodMesh'DeusExCharacters.GMK_DressShirt';
        meshes[i++] = LodMesh'DeusExCharacters.GMK_DressShirt_F';
        meshes[i++] = LodMesh'DeusExCharacters.GM_Suit';
    }

    return RandomInfluencerForMeshes(female, meshes);
}

simulated function class<ScriptedPawn> RandomUniSexNonSkirtInfluencer(bool female)
{
    local LodMesh meshes[16];
    local int i;
    i=0;
    meshes[i++] = LodMesh'DeusExCharacters.GFM_TShirtPants';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_B';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_F';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_S';
    meshes[i++] = LodMesh'DeusExCharacters.GM_Jumpsuit';
    meshes[i++] = LodMesh'DeusExCharacters.GMK_DressShirt';
    meshes[i++] = LodMesh'DeusExCharacters.GMK_DressShirt_F';
    meshes[i++] = LodMesh'DeusExCharacters.GM_Suit';

    // currently ignore the incoming female flag, maybe later we might want to use it for weighting or something?
    female = Rand(2) == 1;
    return RandomInfluencerForMeshes(female, meshes);
}

simulated function class<ScriptedPawn> RandomUniSexNonCoatInfluencer(bool female, bool isOtherSkinColor)
{
    local LodMesh meshes[16];
    local int i;
    local class<ScriptedPawn> c;
    local bool compatible;
    i=0;

    meshes[i++] = LodMesh'DeusExCharacters.GFM_SuitSkirt';
    meshes[i++] = LodMesh'DeusExCharacters.GFM_SuitSkirt_F';
    //meshes[i++] = LodMesh'DeusExCharacters.GFM_TShirtPants';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_B';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_F';
    meshes[i++] = LodMesh'DeusExCharacters.GM_DressShirt_S';
    meshes[i++] = LodMesh'DeusExCharacters.GM_Jumpsuit';
    meshes[i++] = LodMesh'DeusExCharacters.GMK_DressShirt';
    meshes[i++] = LodMesh'DeusExCharacters.GMK_DressShirt_F';
    meshes[i++] = LodMesh'DeusExCharacters.GM_Suit';

    // currently ignore the incoming female flag, maybe later we might want to use it for weighting or something?
    //female = Rand(2) == 1;
    if(!isOtherSkinColor)
        return RandomInfluencerForMeshes(female, meshes);

    for(i=0; i < 10 && !compatible; i++) {
        c = RandomInfluencerForMeshes(female, meshes);
        compatible = isOtherSkinCompatible(c);
    }
    return c;
}

simulated function bool isOtherSkinCompatible(class<ScriptedPawn> c)
{
    return ! (c == class'Female4' || c == class'Male4' || c == class'HKMilitary' || c == class'SamCarter'
            || c == class'BoatPerson' || c == class'LowerClassMale' || c == class'GordonQuick' || c == class'ThugMale3');
}

//Influencers who are valid for other bits, but not shirts
simulated function bool isValidFemaleShirtInfluencer(class<ScriptedPawn> c)
{
    return ! (c == class'GordonQuick' || c == class'Smuggler' || c == class'TerroristCommander' || c == class'JuanLebedev');
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

simulated function bool IsFemaleShirtInfluencer(class<ScriptedPawn> influencer)
{
    return influencer.Default.Mesh == LodMesh'DeusExCharacters.GFM_TShirtPants';
}

simulated function ApplyOutfit(Actor p, class<ScriptedPawn> model, texture coat1, texture coat2, texture shirt, texture pants, texture helmet, bool isJC) {
    local bool female;
    local #var(DeusExPrefix)Carcass carcass;
    local class<#var(DeusExPrefix)Carcass> modelCarcass;
    local int i;

    female = isFemale && isJC;
    carcass = #var(DeusExPrefix)Carcass(p);

    if(DeusExPlayer(p) != None) {
        // LDDP: take control away from FemJC package
        DeusExPlayer(p).CarcassType = class'JCDentonMaleCarcass';
    }

    // need to exlude _F meshes, JC is fit
    if( carcass != None ) {
        modelCarcass = class<#var(DeusExPrefix)Carcass>(model.default.CarcassType);
        carcass.Mesh = modelCarcass.default.Mesh;
        carcass.Mesh2 = modelCarcass.default.Mesh2;
        carcass.Mesh3 = modelCarcass.default.Mesh3;
    }
    else {
        p.Mesh = model.default.Mesh;
    }

    switch(model.default.Mesh) {
        case LodMesh'DeusExCharacters.GFM_SuitSkirt':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
            if( carcass != None ) {
                carcass.Mesh = LodMesh'DeusExCharacters.GFM_SuitSkirt_Carcass';
                carcass.Mesh2 = LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassB';
                carcass.Mesh3 = LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassC';
            } else {
                p.Mesh = LodMesh'DeusExCharacters.GFM_SuitSkirt';
            }
            break;

        case LodMesh'DeusExCharacters.GM_Trench_F':
        case LodMesh'DeusExCharacters.GM_Trench':
            if( carcass != None ) {
                carcass.Mesh = LodMesh'DeusExCharacters.GM_Trench_Carcass';
                carcass.Mesh2 = LodMesh'DeusExCharacters.GM_Trench_CarcassB';
                carcass.Mesh3 = LodMesh'DeusExCharacters.GM_Trench_CarcassC';
            } else {
                p.Mesh = LodMesh'DeusExCharacters.GM_Trench';
            }
            break;

        //case LodMesh'DeusExCharacters.GFM_Trench':
            //break;
        //case LodMesh'DeusExCharacters.GFM_SuitSkirt':
        //case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
        //case LodMesh'DeusExCharacters.GFM_TShirtPants':
            //break;

        case LodMesh'DeusExCharacters.GM_DressShirt_B':
        case LodMesh'DeusExCharacters.GM_DressShirt':
        case LodMesh'DeusExCharacters.GM_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_DressShirt_S':
        case LodMesh'DeusExCharacters.GM_Jumpsuit':
        case LodMesh'DeusExCharacters.GMK_DressShirt':
        case LodMesh'DeusExCharacters.GMK_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_Suit':
            if( #var(DeusExPrefix)Carcass(p) != None ) {
                p.Mesh = LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass';
                #var(DeusExPrefix)Carcass(p).Mesh2 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB';
                #var(DeusExPrefix)Carcass(p).Mesh3 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC';
            }
            else {
                p.Mesh = LodMesh'MPCharacters.mp_jumpsuit';
            }
            break;
    }

    // first set to defaults
    for(i=1; i<8; i++) {
        p.MultiSkins[i] = model.Default.MultiSkins[i];
    }

    switch(model.default.Mesh) {
        case LodMesh'DeusExCharacters.GFM_Trench':
            p.MultiSkins[1] = coat1;
            p.MultiSkins[2] = pants;
            p.MultiSkins[4] = shirt;
            p.MultiSkins[5] = coat2;

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
            if( String(p.MultiSkins[0]) == "FemJC.Characters.JCDentonFemaleTex4" || String(p.MultiSkins[0]) == "FemJC.Characters.JCDentonFemaleTex5" )
                p.MultiSkins[3] = Texture'DeusExCharacters.Skins.Hooker1Tex1';// darker legs
            else
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

    l( p $ " " $ p.Mesh );
    for(i=0; i<8; i++) {
        l( p $ " " $ i $ ": " $ p.MultiSkins[i]);
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

    //FemJC can use male trenchcoat textures, but obviously shouldn't use the male model
    if (isFemale && isJC){
        switch(model.default.Mesh){
            case LodMesh'DeusExCharacters.GM_Trench_F':
            case LodMesh'DeusExCharacters.GM_Trench':
                model = class'ScientistFemale'; //Placeholder for a generic trenchcoat female
        }
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

simulated function _ReadInfluencers(bool female, out name coatinfluencer, out name pantsinfluencer, out name shirtinfluencer)
{
    if(female) {
        coatinfluencer = dxr.flagbase.GetName('DXRFashion_CoatInfluencerF');
        pantsinfluencer = dxr.flagbase.GetName('DXRFashion_PantsInfluencerF');
        shirtinfluencer = dxr.flagbase.GetName('DXRFashion_ShirtInfluencerF');
    } else {
        coatinfluencer = dxr.flagbase.GetName('DXRFashion_CoatInfluencer');
        pantsinfluencer = dxr.flagbase.GetName('DXRFashion_PantsInfluencer');
        shirtinfluencer = dxr.flagbase.GetName('DXRFashion_ShirtInfluencer');
    }
}

simulated function ReadInfluencers(bool female, out name coatinfluencer, out name pantsinfluencer, out name shirtinfluencer)
{
    _ReadInfluencers(female, coatinfluencer, pantsinfluencer, shirtinfluencer);

    if (coatinfluencer == '' ||
        pantsinfluencer == '' ||
        shirtinfluencer == '') {
        //This was probably a game saved before fashion existed
        warning("No stored outfit!");
        //InitInfluencers();
        _RandomizeClothes(player(), female);

        _ReadInfluencers(female, coatinfluencer, pantsinfluencer, shirtinfluencer);
    }
}

//Brothers gotta match, mom got their clothes out in advance... maybe one day we can make FemJC and Paul match...
simulated function GetDressed()
{
    local PaulDenton paul;
    local PaulDentonCarcass paulCarcass;
    local JCDentonMaleCarcass jcCarcass;
    local JCDouble jc;
    local DeusExPlayer player;
    local name coatinfluencer,pantsinfluencer,shirtinfluencer;

    ReadInfluencers(isFemale, coatinfluencer, pantsinfluencer, shirtinfluencer);

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
        /*coatinfluencer = GetMaleInfluencer(coatinfluencer);
        pantsinfluencer = GetMaleInfluencer(pantsinfluencer);
        shirtinfluencer = GetMaleInfluencer(shirtinfluencer);*/

        // disable matching Paul for now, unfortunately the compatibility checks are too complicated to convert influencers to male
        // example: trying to convert a trenchcoat influencer to a jumpsuit male, or a skirt to a trenchcoat...
        ReadInfluencers(false, coatinfluencer, pantsinfluencer, shirtinfluencer);
    }

    // Paul Denton
    foreach AllActors(class'PaulDenton', paul)
        ApplyInfluencers(paul, coatinfluencer, pantsinfluencer, shirtinfluencer, false);

    // Paul Denton Carcass
    foreach AllActors(class'PaulDentonCarcass', paulCarcass)
        ApplyInfluencers(paulCarcass, coatinfluencer, pantsinfluencer, shirtinfluencer, false);
}

simulated function _RandomizeClothes(#var(PlayerPawn) player, bool female)
{
    local class<ScriptedPawn> styleInfluencer;
    local bool isTrench, isSkirt, isFemaleShirt, isOtherSkinColor;
    local name flagname;

    // notes about mixing and matching clothes
    // male pants are distorted on female butts, but look fine from the front
    // shirts don't blend well with skirts
    // shirts are distorted on the GFM_TShirtPants model (unless of course they're made for that model), I think it also spills into the hair
    // maybe the only unisex clothing should be shirts on GFM_Trench, gotta check how coats work out
    // female shirts and skirts don't seem to have any darker skin options

    //Randomize Coat (Multiskin 1 and 5)
    isOtherSkinColor = player.PlayerSkin == 1 || player.PlayerSkin == 2 || player.PlayerSkin == 4;
    if(female && isOtherSkinColor)
        styleInfluencer = RandomCoatInfluencer(female,false);
    else
        styleInfluencer = RandomInfluencer(female);
    isTrench = IsTrenchInfluencer(styleInfluencer);
    isSkirt = IsSkirtInfluencer(styleInfluencer);
    isFemaleShirt = IsFemaleShirtInfluencer(styleInfluencer);// these shirts aren't compatible with other texture coordinates
    if(female)
        flagname = 'DXRFashion_CoatInfluencerF';
    else
        flagname = 'DXRFashion_CoatInfluencer';
    dxr.flagbase.SetName(flagname,styleInfluencer.name,, 999);
    info("Coat influencer is "$styleInfluencer$", isSkirt: "$isSkirt$", isTrench: "$isTrench$", isFemaleShirt: "$isFemaleShirt);
    //player().ClientMessage("Coat influencer is "$styleInfluencer);

    //Randomize Pants (Multiskin 2)
    if (isSkirt) {
        styleInfluencer = RandomSkirtInfluencer();
    } else {
        // for pants we might be able to pull from male pants too, but no skirts
        styleInfluencer = RandomUniSexNonSkirtInfluencer(female);
    }
    if(female)
        flagname = 'DXRFashion_PantsInfluencerF';
    else
        flagname = 'DXRFashion_PantsInfluencer';
    dxr.flagbase.SetName(flagname,styleInfluencer.name,, 999);
    info("Pants influencer is "$styleInfluencer);
    //player().ClientMessage("Pants influencer is "$styleInfluencer);

    //Randomize Shirt (Multiskin 4)
    if (isTrench) {
        if(isOtherSkinColor)
            styleInfluencer = RandomCoatOtherSkinInfluencer(female,true);
        else
            styleInfluencer = RandomCoatInfluencer(female,true);
    } else if (isFemaleShirt) {
        styleInfluencer = RandomFemaleShirtInfluencer();
    } else {
        // for shirts we might be able to pull from male shirts too
        styleInfluencer = RandomUniSexNonCoatInfluencer(female, isOtherSkinColor);
    }
    if(female)
        flagname = 'DXRFashion_ShirtInfluencerF';
    else
        flagname = 'DXRFashion_ShirtInfluencer';
    dxr.flagbase.SetName(flagname,styleInfluencer.name,, 999);
    info("Shirt influencer is "$styleInfluencer);
    //player().ClientMessage("Shirt influencer is "$styleInfluencer);

    info("writing DXRFashion_LastUpdate: "$dxr.dxInfo.MissionNumber);
    dxr.flags.f.SetInt('DXRFashion_LastUpdate',dxr.dxInfo.MissionNumber,,999);
}

simulated function RandomizeClothes(#var(PlayerPawn) player)
{
    _RandomizeClothes(player, isFemale);
    // when FemJC uses a clothesrack, we only change her clothes? or Paul's too?
    if(isFemale)
        _RandomizeClothes(player, false);
}

function RunTests()
{
    Super.RunTests();
    teststring( GetMaleInfluencer('Female2'), 'Male1', "GetMaleInfluencer");
    teststring( GetMaleInfluencer('Nurse'), 'Doctor', "GetMaleInfluencer");
    teststring( GetMaleInfluencer('ScientistFemale'), 'ScientistMale', "GetMaleInfluencer");
    teststring( GetMaleInfluencer('AnnaNavarre'), 'GuntherHermann', "GetMaleInfluencer");
}
