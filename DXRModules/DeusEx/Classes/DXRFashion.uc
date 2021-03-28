class DXRFashion extends DXRBase;

var class<ScriptedPawn> influencers[100];
var int numInfluencers;
var class<ScriptedPawn> coatInfluencers[100];
var int numCoatInfluencers;

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

function AddCoatInfluencer(class<ScriptedPawn> p)
{
    //AddInfluencer(p);
    coatInfluencers[numCoatInfluencers++] = p;
}

function class<ScriptedPawn> RandomShirtPantInfluencer()
{
    return influencers[Rand(numInfluencers)];
}

function class<ScriptedPawn> RandomCoatInfluencer()
{
    return coatInfluencers[Rand(numCoatInfluencers)];

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
        coat1=GetCoat1(styleInfluencer);
        coat2=GetCoat2(styleInfluencer);
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
		paul.MultiSkins[1] = coat1;
		paul.MultiSkins[5] = coat2;
	    paul.MultiSkins[4] = shirt;
		paul.MultiSkins[2] = pants;
    }

	// Paul Denton Carcass
	foreach AllActors(class'PaulDentonCarcass', paulCarcass) 
        break;
        
    if (paulCarcass!=None) {
		paulCarcass.MultiSkins[1] = coat1;
		paulCarcass.MultiSkins[5] = coat2;
	    paulCarcass.MultiSkins[4] = shirt;
		paulCarcass.MultiSkins[2] = pants;
    }


	// JC Denton Carcass
	foreach AllActors(class'JCDentonMaleCarcass', jcCarcass)
		break;

	if (jcCarcass != None) {
        jcCarcass.MultiSkins[1] = coat1;
		jcCarcass.MultiSkins[5] = coat2;
		jcCarcass.MultiSkins[4] = shirt;
		jcCarcass.MultiSkins[2] = pants;
    }

	// JC's stunt double
	foreach AllActors(class'JCDouble', jc)
        break;

	if (jc != None) {
		jc.MultiSkins[1] = coat1;
		jc.MultiSkins[5] = coat2;
		jc.MultiSkins[4] = shirt;
		jc.MultiSkins[2] = pants;
    }
    
    if (dxr.Player != None) {
		dxr.Player.MultiSkins[1] = coat1;
		dxr.Player.MultiSkins[5] = coat2;
		dxr.Player.MultiSkins[4] = shirt;
		dxr.Player.MultiSkins[2] = pants;    
    }

}

function RandomizeClothes()
{
    local class<ScriptedPawn> styleInfluencer;
  
    //Randomize Coat (Multiskin 1 and 5)
    styleInfluencer = RandomCoatInfluencer();
    dxr.Player.FlagBase.SetName('DXRFashion_CoatInfluencer',styleInfluencer.name);
    info("Coat influencer is "$styleInfluencer);

    
    //Randomize Pants (Multiskin 2)
    styleInfluencer = RandomShirtPantInfluencer();
    dxr.Player.FlagBase.SetName('DXRFashion_PantsInfluencer',styleInfluencer.name);
    info("Pants influencer is "$styleInfluencer);
    
    //Randomize Shirt (Multiskin 4
    styleInfluencer = RandomCoatInfluencer();
    dxr.Player.FlagBase.SetName('DXRFashion_ShirtInfluencer',styleInfluencer.name);
    info("Shirt influencer is "$styleInfluencer);
    
    dxr.flags.f.SetInt('DXRFashion_LastUpdate',dxr.dxInfo.MissionNumber,,999);

}