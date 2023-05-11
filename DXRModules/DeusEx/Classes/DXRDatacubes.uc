class DXRDatacubes extends DXRPasswordsBase abstract;

var config safe_rule datacubes_rules[64];
var config float min_hack_adjust, max_hack_adjust;

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(2,3,4,3) ) {
        min_hack_adjust = 0.5;
        max_hack_adjust = 1.5;

        for(i=0; i<ArrayCount(datacubes_rules); i++) {
            datacubes_rules[i].map = "";
        }
#ifdef revision
        revision_datacubes_rules();
#else
        vanilla_datacubes_rules();
#endif
    }
    for(i=0; i<ArrayCount(datacubes_rules); i++) {
        datacubes_rules[i].map = Caps(datacubes_rules[i].map);
    }

    Super.CheckConfig();
}

function vanilla_datacubes_rules()
{
    local int i;

    // satcom password
    datacubes_rules[i].map = "01_NYC_UNATCOISLAND";
    datacubes_rules[i].item_name = '01_Datacube06';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // armory 0451 code
    datacubes_rules[i].map = "01_NYC_UNATCOISLAND";
    datacubes_rules[i].item_name = '01_Datacube03';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // nsf001 smashthestate
    datacubes_rules[i].map = "01_NYC_UNATCOISLAND";
    datacubes_rules[i].item_name = '01_Datacube04';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // ramp code
    datacubes_rules[i].map = "02_NYC_WAREHOUSE";
    datacubes_rules[i].item_name = '02_Datacube09';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // NSF righteous
    datacubes_rules[i].map = "02_NYC_WAREHOUSE";
    datacubes_rules[i].item_name = '02_Datacube14';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // Curly's Journal
    datacubes_rules[i].map = "03_NYC_BatteryPark";
    datacubes_rules[i].item_name = '03_Book06';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    datacubes_rules[i].map = "03_NYC_BrooklynBridgeStation";
    datacubes_rules[i].item_name = '03_Datacube14';
    datacubes_rules[i].min_pos = vect(-999999, -999999, -999999);
    datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
    datacubes_rules[i].allow = true;
    i++;

    // datacube for hanger keypad
    // disallow in security tower
    datacubes_rules[i].map = "03_NYC_Airfield";
    datacubes_rules[i].item_name = '03_Datacube10';
    datacubes_rules[i].min_pos = vect(5200, 3650, 200);
    datacubes_rules[i].max_pos = vect(999999, 999999, 9999);
    datacubes_rules[i].allow = false;
    i++;

    // allow anywhere else past the gate
    datacubes_rules[i].map = "03_NYC_Airfield";
    datacubes_rules[i].item_name = '03_Datacube10';
    datacubes_rules[i].min_pos = vect(1700, 2400, -999999);
    datacubes_rules[i].max_pos = vect(999999, 999999, 999999);
    datacubes_rules[i].allow = true;
    i++;

    // datacube with the password for sending the signal
    datacubes_rules[i].map = "04_NYC_NSFHQ";
    datacubes_rules[i].item_name = '04_Datacube01';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // datacube with the security password, don't allow it to go in the basement, you might need it to open the weird door things
    datacubes_rules[i].map = "04_NYC_NSFHQ";
    datacubes_rules[i].item_name = '04_Datacube02';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 0);
    datacubes_rules[i].allow = false;
    i++;

    datacubes_rules[i].map = "04_NYC_NSFHQ";
    datacubes_rules[i].item_name = '04_Datacube02';
    datacubes_rules[i].min_pos = vect(-99999, -99999, 0);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // jail cell codes
    datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
    datacubes_rules[i].item_name = '05_Datacube01';// don't allow this in the locked cabinet
    datacubes_rules[i].min_pos = vect(-2235.248291, 1414.674072, -159.039658)-vect(8,8,8);
    datacubes_rules[i].max_pos = vect(-2235.248291, 1414.674072, -159.039658)+vect(8,8,8);
    datacubes_rules[i].allow = false;
    i++;

    // As requested, the patient has been moved to the Surgery Ward for immediate salvage of his datavault.  If you wish to observe the progress of the operation in person, the door code for surgery is 0199; or, if you wish to view the operation remotely, you may use the temporary account we've created for you: login "psherman" and password "Raven".  Please let me know if myself or my staff can provide you with any further assistance.
    /*datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
    datacubes_rules[i].item_name = '05_Datacube03';
    datacubes_rules[i].min_pos = vect(1214.396851, -1006.870361, -99999);
    datacubes_rules[i].max_pos = vect(2404.169922, -254.634888, 99999);
    datacubes_rules[i].allow = false;
    i++;*/

    datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
    datacubes_rules[i].item_name = '05_Datacube03';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = false;// actually just don't randomize this one since we mention it in the wiki
    i++;

    // Wednesday, 4/15: IS promises that LabNet accounts will be restored by Friday; new login is "dmoreau" with password "raptor".
    datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
    datacubes_rules[i].item_name = '05_Book01';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // We are in the process of ghosting all network security resources to provide additional protection against possible intrusion or denial of service attacks.  Until this process is complete, all security computers will be utilizing a temporary system.
    // Login: MJ12  Password: INVADER
    datacubes_rules[i].map = "05_NYC_UNATCOMJ12LAB";
    datacubes_rules[i].item_name = '05_Datacube02';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    //Ramp Code
    datacubes_rules[i].map = "09_NYC_SHIP";
    datacubes_rules[i].item_name = '09_Datacube14';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    // make sure you can get to the book without needing to jump down
    datacubes_rules[i].map = "10_PARIS_CATACOMBS";
    datacubes_rules[i].item_name = '10_Book09';
    datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    datacubes_rules[i].map = "10_PARIS_CATACOMBS";
    datacubes_rules[i].item_name = '10_Book09';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999); //top floor
    datacubes_rules[i].max_pos = vect(99999, 99999, 1956.809082);
    datacubes_rules[i].allow = false;
    i++;

    // DataCube0 and 2
    datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
    datacubes_rules[i].item_name = '11_Datacube03';
    datacubes_rules[i].min_pos = vect(-99999, -99999, 1956.809082); //top floor
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
    datacubes_rules[i].item_name = '11_Datacube03';// DataCube0 and 2 have the same textTag
    datacubes_rules[i].min_pos = vect(3587, -812, -487); //before gunther room
    datacubes_rules[i].max_pos = vect(4322, -124, 74);
    datacubes_rules[i].allow = false;
    i++;

    datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
    datacubes_rules[i].item_name = '11_Datacube03';// 0 and 2
    datacubes_rules[i].min_pos = vect(3146, -1715, -85); //above before gunther room
    datacubes_rules[i].max_pos = vect(3907, -1224, 434);
    datacubes_rules[i].allow = false;
    i++;

    datacubes_rules[i].map = "11_PARIS_CATHEDRAL";
    datacubes_rules[i].item_name = '11_Datacube03';
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = true;
    i++;

    datacubes_rules[i].map = "15_AREA51_PAGE";
    datacubes_rules[i].item_name = '15_Datacube18';// LAB 12 / graytest
    datacubes_rules[i].min_pos = vect(4774.132813, -10507.679688, -5294.627441);
    datacubes_rules[i].max_pos = vect(6394.192383, -9250.182617, 99999);
    datacubes_rules[i].allow = true;
    i++;

    datacubes_rules[i].map = "15_AREA51_PAGE";
    datacubes_rules[i].item_name = '15_Datacube18';// LAB 12 / graytest
    datacubes_rules[i].min_pos = vect(-99999, -99999, -99999);
    datacubes_rules[i].max_pos = vect(99999, 99999, 99999);
    datacubes_rules[i].allow = false;
    i++;
}

function revision_datacubes_rules()
{
    local int i;

    // TODO: datacubes_rules for Revision
}

function FirstEntry()
{
    Super.FirstEntry();

    RandoInfoDevs(dxr.flags.settings.infodevices);
    RandoHacks();
    MakeAllHackable(dxr.flags.settings.deviceshackable);
}

function RandoHacks()
{
    local #var(prefix)HackableDevices h;

    SetSeed( "RandoHacks" );

    foreach AllActors(class'#var(prefix)HackableDevices', h) {
        _RandoHackable(h);
    }
}

function _RandoHackable(#var(prefix)HackableDevices h)
{
    if( h.bHackable ) {
        h.hackStrength = FClamp(rngrange(h.hackStrength, min_hack_adjust, max_hack_adjust), 0, 1);
        h.hackStrength = int(h.hackStrength*100)/100.0;
        h.initialhackStrength = h.hackStrength;
    }
}

static function RandoHackable(DXRando dxr, #var(prefix)HackableDevices h)
{
    local DXRPasswords m;
    m = DXRPasswords(dxr.FindModule(class'DXRPasswords'));
    if( m != None ) {
        m._RandoHackable(h);
    }
}

function RandoInfoDevs(int percent)
{
    local #var(prefix)InformationDevices id;

    if(percent <= 0) return;

    foreach AllActors(class'#var(prefix)InformationDevices', id)
    {
        if(!id.bHidden && id.Mesh == class'#var(prefix)DataCube'.default.Mesh)
            GlowUp(id);
        if( id.bIsSecretGoal ) continue;
        if( ! chance_single(percent) ) continue;
        _RandoInfoDev(id, dxr.flags.settings.infodevices_containers > 0);
    }
}

function _RandoInfoDev(#var(prefix)InformationDevices id, bool containers)
{
    local Inventory inv;
    local Containers c;
    local Actor temp[1024];
    local int num, slot, numHasPass, bads;
    local int hasPass[64];

    InfoDevsHasPass(id, hasPass, numHasPass);

    num=0;
    foreach AllActors(class'Inventory', inv)
    {
        if( SkipActor(inv) ) continue;
        if( InfoPositionGood(id, inv.Location, hasPass, numHasPass) == False ) {
            bads++;
            continue;
        }
#ifdef debug
        //if(id.textTag == '03_Datacube10') DebugMarkKeyPosition(inv, id.textTag);
#endif
        temp[num++] = inv;
    }

    if(containers) {
        foreach AllActors(class'Containers', c)
        {
            if( SkipActor(c) ) continue;
            if( InfoPositionGood(id, c.Location, hasPass, numHasPass) == False ) {
                bads++;
                continue;
            }
            if( HasBased(c) ) continue;
#ifdef debug
            //DebugMarkKeyPosition(inv, id.textTag);
#endif
            temp[num++] = c;
        }
    }

    l("datacube "$id$" got num "$num$" with "$bads$" unsafe positions");
    slot=rng(num+1);//+1 for the vanilla location
    if(slot==0) {
        l("not swapping infodevice "$ActorToString(id));
        return;
    }
    slot--;
    l("swapping infodevice "$ActorToString(id)$" with "$temp[slot] $" ("$temp[slot].Location$")");
    // Swap argument A is more lenient with collision than argument B
    Swap(temp[slot], id);
}

function MakeAllHackable(int deviceshackable)
{
    local #var(prefix)HackableDevices h;

    SetSeed( "MakeAllHackable" );

    foreach AllActors(class'#var(prefix)HackableDevices', h)
    {
        if( h.bHackable == false && chance_single(deviceshackable) ) {
            l("found unhackable device: " $ ActorToString(h) $ ", tag: " $ h.Tag $ " in " $ dxr.localURL);
            h.bHackable = true;
            h.hackStrength = FClamp(rngrange(1, min_hack_adjust, max_hack_adjust), 0, 1);
            h.hackStrength = int(h.hackStrength*100)/100.0;
            h.initialhackStrength = h.hackStrength;
        }

        // make Helios ending slightly harder?
        if(h.Event == 'door_helios_room') {
            h.hackStrength = 1;
            h.initialhackStrength = h.hackStrength;
        }
    }
}

simulated function bool InfoDevsHasPass(#var(prefix)InformationDevices id, optional out int hasPass[64], optional out int numHasPass)
{
    local DeusExTextParser parser;
    local int i;

    numHasPass=0;
    for(i=0; i<ArrayCount(hasPass); i++)
        hasPass[i]=0;

    if ( id.textTag != '' ) {
        parser = new(None) Class'DeusExTextParser';
        if( parser.OpenText(id.textTag, id.TextPackage) ) {
            l("infodev test password "$id$" textTag: " $ id.textTag);
            ProcessText(parser, hasPass, numHasPass);
            parser.CloseText();
        }
        CriticalDelete(parser);
    }

#ifdef injections
    if( id.plaintext != "" ) {// TODO: wait maybe this works now with DXRInfoDevs?
        ProcessStringHasPass(id.plaintext, hasPass, numHasPass);
    }
#endif

    if( numHasPass > 0 )
        id.bAddToVault = true;

    return numHasPass > 0;
}

simulated function ProcessText(DeusExTextParser parser, out int hasPass[64], out int numHasPass)
{
    local string text;
    local int i;
    local byte tag;

    while(parser.ProcessText()) {
        tag = parser.GetTag();
        if( tag != 0 ) continue;

        text = parser.GetText();
        l(text);
        text = Caps(text);
        if( Len(text) == 0 ) continue;

        ProcessStringHasPass( text, hasPass, numHasPass );
    }
}

simulated function ProcessStringHasPass(string text, out int hasPass[64], out int numHasPass)
{
    local int i;
    text = Caps(text);
    for(i=0; i<passEnd; i++) {
        if( Len(oldpasswords[i]) == 0 ) continue;
        if( PassInStr( text, oldpasswords[i] ) != -1 ) {
            /*l("found password "$oldpasswords[i]);
            l(text);
            l("---");*/
            hasPass[i] = 1;
            numHasPass++;
        }
    }
}

function bool CheckComputerPosition(#var(prefix)InformationDevices id, #var(prefix)Computers c, vector newpos, int hasPass[64])
{
    local int a, i;

    if( PositionIsSafe(id.Location, c, newpos) ) return True;// don't even need to check the passwords

    for (i=0; i<ArrayCount(c.userList); i++)
    {
        if (c.userList[i].password == "")
            continue;

        for (a=0; a<passEnd; a++) {
            if( hasPass[a]==1 && c.userList[i].password == newpasswords[a] ) {
                return False;
            }
        }
    }
    return True;
}

function bool CheckKeypadPosition(#var(prefix)InformationDevices id, #var(prefix)Keypad k, vector newpos, int hasPass[64])
{
    local int i;

    if( PositionIsSafe(id.Location, k, newpos) ) return True;// don't even need to check the passwords
    if ( k.validCode == "" ) return True;

    for (i=0; i<passEnd; i++) {
        if( hasPass[i]==1 && k.validCode == newpasswords[i] ) {
            return False;
        }
    }
    return True;
}

function bool InfoPositionGood(#var(prefix)InformationDevices id, vector newpos, int hasPass[64], int numHasPass)
{
    local #var(prefix)Computers c;
    local #var(prefix)Keypad k;
    local int i;

    i = GetSafeRule( datacubes_rules, id.textTag, newpos);
    if( i != -1 ) return datacubes_rules[i].allow;

    if( VSize( id.Location - newpos ) > 5000 ) return False;

    if ( id.textTag == '' ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, no textTag");
        return True;
    }

    if( numHasPass==0 ) {
        //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True, hasPass is empty");
        return True;
    }// else l("InfoPositionGood("$ActorToString(id)$", "$newpos$") found hasPass "$a);

    foreach AllActors(class'#var(prefix)Computers', c)
    {
        if( CheckComputerPosition(id, c, newpos, hasPass) == False ) {
            //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning False, found computer "$ActorToString(c));
            return False;
        }
    }
    foreach AllActors(class'#var(prefix)Keypad', k)
    {
        if( CheckKeypadPosition(id, k, newpos, hasPass) == False ) {
            //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning False, found keypad "$ActorToString(k));
            return False;
        }
    }
    //l("InfoPositionGood("$ActorToString(id)$", "$newpos$") returning True");
    return True;
}
