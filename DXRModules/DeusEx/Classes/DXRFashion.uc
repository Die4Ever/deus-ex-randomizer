class DXRFashion extends DXRBase;

var class<ScriptedPawn> influencers[100];
var int numInfluencers;
var class<ScriptedPawn> coatInfluencers[100];
var int numCoatInfluencers;
var class<ScriptedPawn> nonCoatInfluencers[100];
var int numNonCoatInfluencers;

function AnyEntry()
{
    local int lastUpdate;
    Super.AnyEntry();

    InitInfluencers();

    lastUpdate = dxr.flags.f.GetInt('DXRFashion_LastUpdate');
    if (lastUpdate < dxr.dxInfo.MissionNumber) {
        RandomizeClothes();
        dxr.Player.ClientMessage("Time for a change of clothes...");
    }

    GetDressed();
}


function InitInfluencers()
{
    numInfluencers = 0;
    numCoatInfluencers = 0;
    
    AddNonCoatInfluencer(class'AlexJacobson');
    AddNonCoatInfluencer(class'BoatPerson');
    AddNonCoatInfluencer(class'Bartender');
    AddNonCoatInfluencer(class'HowardStrong');
    AddNonCoatInfluencer(class'JoeGreene');
    AddNonCoatInfluencer(class'Male1');
    AddNonCoatInfluencer(class'Male2');
    AddNonCoatInfluencer(class'Male3');
    AddNonCoatInfluencer(class'MorganEverett');
    AddNonCoatInfluencer(class'Cop');
    AddNonCoatInfluencer(class'JoJoFine');
    AddNonCoatInfluencer(class'ThugMale2');
    AddNonCoatInfluencer(class'ThugMale3');
    AddNonCoatInfluencer(class'GuntherHermann');

    AddCoatInfluencer(class'BumMale');
    AddCoatInfluencer(class'BumMale2');
    AddCoatInfluencer(class'BumMale3');
    AddCoatInfluencer(class'JCDouble');
    AddCoatInfluencer(class'JaimeReyes');
    AddCoatInfluencer(class'HarleyFilben');
    AddCoatInfluencer(class'GilbertRenton');
    AddCoatInfluencer(class'FordSchick');
    AddCoatInfluencer(class'GordonQuick');
    AddCoatInfluencer(class'JuanLebedev');
    AddCoatInfluencer(class'MaxChen');
    AddCoatInfluencer(class'WaltonSimons');
    AddCoatInfluencer(class'Smuggler');
    AddCoatInfluencer(class'TobyAtanwe');
    AddCoatInfluencer(class'TerroristCommander');
    AddCoatInfluencer(class'TriadRedArrow');
    AddCoatInfluencer(class'GarySavage');
    AddCoatInfluencer(class'Doctor');
    AddCoatInfluencer(class'ScientistMale');
    AddCoatInfluencer(class'StantonDowd');
    AddCoatInfluencer(class'Jock');
    AddCoatInfluencer(class'ThugMale');
    AddCoatInfluencer(class'PaulDenton');
}

//This will assume the pawn is a trenchcoat wearer
function texture GetCoat1(class<ScriptedPawn> p) 
{
    if (p==None){
        return None;
    }
    return p.Default.MultiSkins[1];
}

//This will assume the pawn is a trenchcoat wearer
function texture GetCoat2(class<ScriptedPawn> p) 
{
    if (p==None){
        return None;
    }
    return p.Default.MultiSkins[5];
}

function texture GetShirt(class<ScriptedPawn> p)
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
        default:
            return p.Default.MultiSkins[5];
    }
}

function texture GetPants(class<ScriptedPawn> p)
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
        default:
            return p.Default.MultiSkins[3];
    }
}

function AddInfluencer(class<ScriptedPawn> p)
{
    influencers[numInfluencers++] = p;
}

function AddNonCoatInfluencer(class<ScriptedPawn> p)
{
    AddInfluencer(p);
    nonCoatInfluencers[numNonCoatInfluencers++] = p;
}

function AddCoatInfluencer(class<ScriptedPawn> p)
{
    AddInfluencer(p);
    coatInfluencers[numCoatInfluencers++] = p;
}

function class<ScriptedPawn> RandomInfluencer()
{
    return influencers[Rand(numInfluencers)];
}

function class<ScriptedPawn> RandomCoatInfluencer()
{
    return coatInfluencers[Rand(numCoatInfluencers)];
}

function class<ScriptedPawn> RandomNonCoatInfluencer()
{
    return nonCoatInfluencers[Rand(numNonCoatInfluencers)];
}

function bool IsTrenchInfluencer(class<ScriptedPawn> influencer)
{
    return (influencer.Default.Mesh == LodMesh'DeusExCharacters.GM_Trench' ||
        influencer.Default.Mesh == LodMesh'DeusExCharacters.GM_Trench_F');
}

function ApplyOutfit(Actor p, texture coat1, texture coat2, texture shirt, texture pants, bool isJC) {
    local bool isTrench;
    
    isTrench = (coat1 != None && coat2 != None);
    
    if (isTrench) {
        p.Mesh = LodMesh'DeusExCharacters.GM_Trench';
        p.MultiSkins[1] = coat1;
	    p.MultiSkins[5] = coat2;
    	p.MultiSkins[4] = shirt;
        p.MultiSkins[2] = pants;   
    } else {
        p.Mesh = LodMesh'DeusExCharacters.GM_DressShirt';
    	p.MultiSkins[5] = shirt;
        p.MultiSkins[3] = pants;
        p.MultiSkins[1] = Texture'DeusExItems.Skins.PinkMaskTex';
        p.MultiSkins[2] = Texture'DeusExItems.Skins.PinkMaskTex';
    }
    
    if (isJC) {
        p.MultiSkins[6] = Texture'DeusExCharacters.Skins.FramesTex4';
        p.MultiSkins[7] = Texture'DeusExCharacters.Skins.LensesTex5';
    } else {
        p.MultiSkins[6] = Texture'DeusExItems.Skins.GrayMaskTex';
        p.MultiSkins[7] = Texture'DeusExItems.Skins.BlackMaskTex';
    }


}

//Brothers gotta match, mom got their clothes out in advance
function GetDressed()
{
	local PaulDenton paul;
	local PaulDentonCarcass paulCarcass;
	local JCDentonMaleCarcass jcCarcass;
	local JCDouble jc;  
    local texture coat1,coat2,pants,shirt;
    local name coatinfluencer,pantsinfluencer,shirtinfluencer;
    local class<ScriptedPawn> styleInfluencer;
    local bool isTrench;

    coatinfluencer = dxr.Player.FlagBase.GetName('DXRFashion_CoatInfluencer');
    pantsinfluencer = dxr.Player.FlagBase.GetName('DXRFashion_PantsInfluencer');
    shirtinfluencer = dxr.Player.FlagBase.GetName('DXRFashion_ShirtInfluencer');

    if (coatinfluencer == '' ||
        pantsinfluencer == '' ||
        shirtinfluencer == '') {
        //This was probably a game saved before fashion existed
        info("No stored outfit!");
        InitInfluencers();
        RandomizeClothes();
        coatinfluencer = dxr.Player.FlagBase.GetName('DXRFashion_CoatInfluencer');
        pantsinfluencer = dxr.Player.FlagBase.GetName('DXRFashion_PantsInfluencer');
        shirtinfluencer = dxr.Player.FlagBase.GetName('DXRFashion_ShirtInfluencer');        
    }
    

    if (coatinfluencer!='') {
        styleInfluencer = class<ScriptedPawn>(GetClassFromString(string(coatinfluencer),class'ScriptedPawn'));
        isTrench = IsTrenchInfluencer(styleInfluencer);
        if (isTrench) {
            coat1=GetCoat1(styleInfluencer);
            coat2=GetCoat2(styleInfluencer);
        } else {
            coat1 = None;
            coat2 = None;
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
        ApplyOutfit(paul,coat1,coat2,shirt,pants,False);
    }

	// Paul Denton Carcass
	foreach AllActors(class'PaulDentonCarcass', paulCarcass) 
        break;
        
    if (paulCarcass!=None) {
        ApplyOutfit(paulCarcass,coat1,coat2,shirt,pants,False);
    }


	// JC Denton Carcass
	foreach AllActors(class'JCDentonMaleCarcass', jcCarcass)
		break;

	if (jcCarcass != None) {
        ApplyOutfit(jcCarcass,coat1,coat2,shirt,pants,True);
    }

	// JC's stunt double
	foreach AllActors(class'JCDouble', jc)
        break;

	if (jc != None) {
        ApplyOutfit(jc,coat1,coat2,shirt,pants,True);
    }
    
    if (dxr.Player != None) {
        ApplyOutfit(dxr.Player,coat1,coat2,shirt,pants,True);
    }

}

function RandomizeClothes()
{
    local class<ScriptedPawn> styleInfluencer;
    local bool isTrench;
  
    //Randomize Coat (Multiskin 1 and 5)
    styleInfluencer = RandomInfluencer();
    isTrench = IsTrenchInfluencer(styleInfluencer);
    dxr.Player.FlagBase.SetName('DXRFashion_CoatInfluencer',styleInfluencer.name);
    info("Coat influencer is "$styleInfluencer);

    
    //Randomize Pants (Multiskin 2)
    styleInfluencer = RandomInfluencer();
    dxr.Player.FlagBase.SetName('DXRFashion_PantsInfluencer',styleInfluencer.name);
    info("Pants influencer is "$styleInfluencer);
    
    //Randomize Shirt (Multiskin 4
    if (isTrench) {
        styleInfluencer = RandomCoatInfluencer();
    } else {
        styleInfluencer = RandomNonCoatInfluencer();
    }
    dxr.Player.FlagBase.SetName('DXRFashion_ShirtInfluencer',styleInfluencer.name);
    info("Shirt influencer is "$styleInfluencer);
    
    dxr.flags.f.SetInt('DXRFashion_LastUpdate',dxr.dxInfo.MissionNumber,,999);

}