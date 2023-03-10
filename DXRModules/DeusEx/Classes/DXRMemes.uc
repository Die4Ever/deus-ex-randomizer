class DXRMemes extends DXRActorsBase;

var Actor rotating;

function RandomDancing(Actor a)
{
    if (IsHuman(a.class)) {
        if (ScriptedPawn(a).Orders == 'Standing' ||
            ScriptedPawn(a).Orders == 'Sitting' ||
            ScriptedPawn(a).Orders == '') {
            if (a.HasAnim('Dance')){
                if (chance_single(dxr.flags.settings.dancingpercent))  ScriptedPawn(a).SetOrders('Dancing');
            }
        }
    }
}

function PlayDressUp(Actor a,class<Actor> influencer, float rotYaw)
{
    local int i;
    local Rotator r;

    a.Texture = influencer.default.Texture;
    a.Mesh = influencer.default.Mesh;
    for (i=0;i<=7;i++){
        a.MultiSkins[i] = influencer.default.MultiSkins[i];
    }

    if (influencer.default.Physics == PHYS_Rotating){
        a.RotationRate = influencer.default.RotationRate;
        a.SetPhysics(influencer.default.Physics);
        a.bFixedRotationDir = influencer.default.bFixedRotationDir;
    }

    a.DrawScale = a.CollisionHeight / influencer.default.CollisionHeight;
    r.Yaw = rotYaw;
    a.SetRotation(r);
}

function RandomLiberty()
{
    local NYLiberty liberty;
    local int i;

    foreach AllActors(class'NYLiberty',liberty){
        SetGlobalSeed("RandomLiberty");

        if ( rng(3)!=0 ) return; //33% chance of getting a random statue

        //Rotation doesn't work here because the statue is static
        switch(rng(22)){
        case 0: PlayDressUp(liberty,class'Cactus1',0); return;
        case 1: PlayDressUp(liberty,class'HKBuddha',0); return;
        case 2: PlayDressUp(liberty,class'Basketball',0); return;
        case 3: PlayDressUp(liberty,class'#var(prefix)DXLogo',0); return;
        case 4: PlayDressUp(liberty,class'Flowers',0); return;
        case 5: PlayDressUp(liberty,class'Trophy',0); return;
        case 6: PlayDressUp(liberty,class'LiquorBottle',0); return;
        case 7: PlayDressUp(liberty,class'ChildMale2',0); return;
        case 8: PlayDressUp(liberty,class'WaterCooler',0); return;
        case 9: PlayDressUp(liberty,class'VendingMachine',0); return;
        case 10: PlayDressUp(liberty,class'SodaCan',0); return;
        case 11: PlayDressUp(liberty,class'BoneSkull',0); return;
        case 12: PlayDressUp(liberty,class'Liquor40oz',0); return;
        case 13: PlayDressUp(liberty,class'Barrel1',0);liberty.Skin=Texture'Barrel1Tex8'; return; //Poison barrel
        case 14: PlayDressUp(liberty,class'Barrel1',0);liberty.Skin=Texture'Barrel1Tex11'; return; //Yellow barrel
        case 15: PlayDressUp(liberty,class'BobPageAugmented',0); return;
        case 16: PlayDressUp(liberty,class'JCDouble',0); return;
        case 17: PlayDressUp(liberty,class'Tree1',0); return;
        case 18: PlayDressUp(liberty,class'Tree2',0); return; //Tree3 looks bad, that's why it isn't here
        case 19: PlayDressUp(liberty,class'Tree4',0); return;
        case 20: PlayDressUp(liberty,class'Vase1',0); return;
        case 21: PlayDressUp(liberty,class'Lamp1',0); return;

        }
    }
}

function RandomBobPage()
{
    local BobPageAugmented bob;
    local int i;

    foreach AllActors(class'BobPageAugmented',bob){
        SetGlobalSeed("RandomBobPage");

        if ( rng(3)!=0 ) return; //33% chance of getting a random bob

        switch(rng(28)){
        case 0: PlayDressUp(bob,class'Cactus1',8000); return;
        case 1: PlayDressUp(bob,class'Mailbox',8000); return;
        case 2: PlayDressUp(bob,class'CarWrecked',8000); return;
        case 3: PlayDressUp(bob,class'#var(prefix)DXLogo',8000); return;
        case 4: PlayDressUp(bob,class'HKBuddha',8000); return;
        case 5: PlayDressUp(bob,class'Lamp1',0); return;
        case 6: PlayDressUp(bob,class'LiquorBottle',8000); return;
        case 7: PlayDressUp(bob,class'Microscope',0); return;
        case 8: PlayDressUp(bob,class'Seagull',-8000); return;
        case 9: PlayDressUp(bob,class'SignFloor',8000); return;
        case 10: PlayDressUp(bob,class'StatueLion',8000); return;
        case 11: PlayDressUp(bob,class'Trashbag',8000); return;
        case 12: PlayDressUp(bob,class'Trashbag2',8000); return;
        case 13: PlayDressUp(bob,class'TrashCan3',0); return;
        case 14: PlayDressUp(bob,class'Basketball',8000); return;
        case 15: PlayDressUp(bob,class'Flowers',8000); return;
        case 16: PlayDressUp(bob,class'ChairLeather',8000); return;
        case 17: PlayDressUp(bob,class'NYLiberty',8000); return;
        case 18: PlayDressUp(bob,class'NYLibertyTorch',8000); return;
        case 19: PlayDressUp(bob,class'Trophy',8000); return;
        case 20: PlayDressUp(bob,class'MiniSub',8000); return;
        case 21: PlayDressUp(bob,class'WaterCooler',8000); return;
        case 22: PlayDressUp(bob,class'Mutt',-8000); return;
        case 23: PlayDressUp(bob,class'Fish2',-8000); return;
        case 24: PlayDressUp(bob,class'MilitaryBot',-8000); return;
        case 25: PlayDressUp(bob,class'VendingMachine',-8000); return;
        case 26: PlayDressUp(bob,class'Hooker1',-8000); return;
        case 27: PlayDressUp(bob,class'ChildMale2',-8000); return;
        }

    }
}

function PreFirstEntry()
{
    Super.PreFirstEntry();
    switch(dxr.localURL)
    {
        case "15_AREA51_PAGE":
            RandomBobPage();
            break;
        case "01_NYC_UNATCOIsland":
        case "03_NYC_UNATCOIsland":
        case "04_NYC_UNATCOIsland":
        case "05_NYC_UNATCOIsland":
            RandomLiberty();
            break;
    }
}

function AnyEntry()
{
    local #var(prefix)DXLogo logo;
    local #var(prefix)IonStormLogo islogo;
    local #var(prefix)EidosLogo elogo;
    local #var(prefix)ElectricityEmitter elec;
    local Actor a;
    local Rotator r;
    local Vector v;
    Super.AnyEntry();

    switch(dxr.localURL)
    {
        case "DXONLY":
        case "DX":
            l("Memeing up "$ dxr.localURL);
            foreach AllActors(class'#var(prefix)DXLogo', logo)
            {
                a = ReplaceWithRandomClass(logo);
                if (IsHuman(a.class)){
                    ScriptedPawn(a).SetOrders('Standing');
                }

                //Maybe make them dance?
                RandomDancing(a);

                //Get it spinning just right
                rotating = a;
                a.SetPhysics(PHYS_None);
                a.bFixedRotationDir = True;
                a.bRotateToDesired = False;
                r.Pitch = 2500;
                r.Yaw = 5000;
                r.Roll = 0;
                a.RotationRate = r;

                //Get rid of any ambient sounds it may make
                a.AmbientSound = None;

                GotoState('RotatingState');
            }

            foreach AllActors(class'#var(prefix)IonStormLogo', islogo)
            {
                a = ReplaceWithRandomClass(islogo);
                if (IsHuman(a.class)){
                    ScriptedPawn(a).SetOrders('Standing');
                }
                //Maybe make them dance?
                RandomDancing(a);

                a.SetPhysics(PHYS_None);
                a.DrawScale *= 2.0;
                //Get rid of any ambient sounds it may make
                a.AmbientSound = None;
            }

            foreach AllActors(class'#var(prefix)EidosLogo', elogo)
            {
                a = ReplaceWithRandomClass(elogo);
                if (IsHuman(a.class)){
                    ScriptedPawn(a).SetOrders('Standing');
                }
                //Maybe make them dance?
                RandomDancing(a);

                a.SetPhysics(PHYS_None);
                a.DrawScale *= 2.0;
                //Get rid of any ambient sounds it may make
                a.AmbientSound = None;
            }

            foreach AllActors(class'#var(prefix)ElectricityEmitter', elec)
            {
                v.Z = 70;
                elec.move(v);
            }
            break;

        case "INTRO":
        case "ENDGAME1":
        case "ENDGAME2":
        case "ENDGAME3":
        case "ENDGAME4":
        //case "00_TRAINING":
            // extra randomization in the intro for the lolz, ENDGAME4 doesn't have a DeusExLevelInfo object though, so it doesn't get randomized :(
            l("Memeing up "$ dxr.localURL);
            RandomizeCutscene();
            break;
    }
}

function PostFirstEntry()
{
    local ScriptedPawn sp;
    local InterpolationPoint p;
    local vector v;
    local rotator r;
    Super.PostFirstEntry();

    SetSeed("Memes Dancing");

    foreach AllActors(class'ScriptedPawn',sp)
    {
        //Make people dance across the world
        RandomDancing(sp);
    }

    SetSeed("Memes InterpolationPoints");

    /* might want to first search for the InterpolateTrigger to make sure you find the right tag for the chopper's path and not the camera's path, and maybe go through them in order by the Position variable
    foreach AllActors(class'InterpolationPoint', p) {
        if( p.Position == 0 || p.Position == 1 ) continue;
        v = p.Location;
        v.X += rngfn() * 160.0 * p.Position;
        v.Y += rngfn() * 160.0 * p.Position;
        v.Z += rngfn() * 160.0 * p.Position;
        p.SetLocation( v );
        r.Pitch = rng(65536);
        r.Yaw = rng(65536);
        r.Roll = rng(65536);
        p.SetRotation( r );
    }*/

    //Add Leo Gold if he made it!
    switch(dxr.localURL)
    {
        case "ENDGAME1":
        case "ENDGAME2":
        case "ENDGAME3":
            AddLeo();
            break;
    }
}

function AddLeo()
{
    local bool broughtLeo;
    local bool alive;
    local POVCorpse c;
    local vector loc;
    local Rotator rot;
    local TerroristCommander leo;
    local DeusExPlayer p;

    foreach AllActors(class'DeusExPlayer',p){break;}

    if (p!=None && p.inHand.IsA('POVCorpse')){
        c = POVCorpse(p.inHand);

        if (c.carcClassString == "DeusEx.TerroristCommanderCarcass"){
            broughtLeo = true;
            alive = c.bNotDead;
        }
    }
    if (!broughtLeo){
        return;
    }
    switch(dxr.localURL)
    {
        case "ENDGAME1":
        case "ENDGAME2": //They actually lined these two up!
            log("Endgame 1 or 2");
            loc.X = 189;
            loc.Y = -7816;
            loc.Z = -48;
            break;
        case "ENDGAME3":
            log("Endgame 3");
            loc.X = 192;
            loc.Y = -7813;
            loc.Z = -48;
            break;
    }

    if (alive){
        rot.Yaw = 16472;
        leo = Spawn(class'TerroristCommander',,,loc,rot);
        leo.bImportant=False; //Don't worry buddy, you're still important - I just don't want you gone
        leo.SetOrders('Standing','',True);
        leo.bInvincible=True; //In case of explosions or lightning...
    } else {
        rot.Yaw=0;
        Spawn(class'TerroristCommanderCarcass',,,loc,rot);
    }

}

state() RotatingState {
    event Tick(float deltaTime)
    {
        local Rotator r;
        if( rotating == None ) return;
        r = rotating.Rotation;
        r.Pitch += float(rotating.RotationRate.Pitch) * deltaTime;
        r.Yaw += float(rotating.RotationRate.Yaw) * deltaTime;
        r.Roll += float(rotating.RotationRate.Roll) * deltaTime;
        rotating.SetRotation(r);

        //This is a bit kludgy, HangingDecoration
        //override the rotation behaviour.
        //Worth it for the meme though
        if (rotating.IsA('HangingDecoration')) {
            HangingDecoration(rotating).origRot = r;
        }
        if (rotating.IsA('DeusExProjectile')) {
            DeusExProjectile(rotating).bStuck = true;
        }
    }
}

function RandomizeCutscene()
{
    local Actor a;
    local #var(prefix)Tree t;
    local class<Actor> old_skips[6];
    local int i;
    //local CameraPoint c;

    SetSeed("RandomizeCutscene");

    foreach AllActors(class'#var(prefix)Tree', t)
    { // exclude 90% of trees from the SwapAll by temporarily hiding them
        if( rng(100) < 90 ) t.bHidden = true;
    }

    for(i=0; i<ArrayCount(_skipactor_types); i++) {
        old_skips[i] = _skipactor_types[i];
        _skipactor_types[i] = None;
    }

    i=0;
    _skipactor_types[i++] = class'DeusExPlayer';
    _skipactor_types[i++] = class'Mover';
#ifdef revision
    _skipactor_types[i++] = class<Actor>(DynamicLoadObject("RevisionDeco.Rev_SphereLight", class'class'));
#endif
    SwapAll("Engine.Actor", 10);

    for(i=0; i<ArrayCount(_skipactor_types); i++) {
        _skipactor_types[i] = old_skips[i];
    }

    foreach AllActors(class'#var(prefix)Tree', t)
    {
        t.bHidden = false;
    }

    foreach AllActors(class'Actor', a)
    {
        if( Mover(a) != None ) continue;
        if( #var(prefix)BreakableGlass(a) != None ) continue;
        if( a.IsA('Rev_SphereLight') ) continue;
        if( a.bHidden || DeusExPlayer(a) != None ) continue;

        if(chance_single(50))
            SetActorScale(a, rngrange(1, 0.3, 1.7));
        else
            SetActorScale(a, rngrange(1, 0.8, 1.2));

        if(chance_single(50))
            a.Fatness = rng(50) + 105;
        else
            a.Fatness = rng(20) + 120;
    }

    /*foreach AllActors(class'CameraPoint', c)
    {
        c.bHidden = false;
    }
    SwapAll('CameraPoint', 100);
    foreach AllActors(class'CameraPoint', c)
    {
        c.bHidden = true;
    }*/

    RandomBobPage();
    RandomLiberty();

    RandomizeDialog();
}

function SwapSpeech(ConSpeech a, ConSpeech b)
{
    local int soundID;
    local string subtitle;

    subtitle = a.speech;
    soundID = a.soundID;
    a.speech = b.speech;
    a.soundID = b.soundID;
    b.speech = subtitle;
    b.soundID = soundID;
}

function RandomizeDialog()
{
    local ConSpeech s, speech[100];
    local int i, j, num, soundID;
    local string subtitle;
    //local Conversation conv;

    SetSeed("RandomizeDialog");
    foreach AllObjects(class'ConSpeech', s) {
        speech[num++] = s;
    }
    for(i=0;i<num;i++) {
        if(chance_single(5)) {
            j = rng(num);
            SwapSpeech(speech[i], speech[j]);
        }
    }

    /*foreach AllObjects(class'Conversation', conv) {
        RandomizeDialogConversation(conv);
    }*/
}

function RandomizeDialogConversation(Conversation conv)
{
    local ConEvent co;
    local ConEventSpeech es;
    local ConSpeech s, speech[100];
    local int i, j, num, soundID;
    local string subtitle;

    SetSeed("RandomizeDialogConversation "$conv.conName);
    for(co=conv.eventList; co!=None; co=co.nextEvent) {
        es = ConEventSpeech(co);
        if(es==None) continue;
        speech[num++] = es.conSpeech;
    }

    // last thing before release: do this per conversation...
    for(i=0;i<num;i++) {
        j = rng(num);
        SwapSpeech(speech[i], speech[j]);
    }
}

function bool is_valid(string s, class<Object> o)
{// determines if a class is worthy of replacing the logo in the menu
    local class<Actor> a;
    a = class<Actor>(o);
    if ( a == None ) return false;
    if ( a.default.bHidden ) return false;
    if ( a.default.Mesh == None ) return false;
    if ( a.default.DrawType != DT_Mesh ) return false;
    if ( a.default.Style != STY_Normal ) return false;

    log( "if ( r == i++ ) return class'" $ s $ "';" );
    //i++;//was a global variable in my code that outputted code...
    return true;
}

function Actor ReplaceWithRandomClass(Actor old)
{
    local Actor a;
    local string newActorClass;
    local int i;
    for(i=0; i<10; i++) {
        newActorClass = GetRandomActorClass();
        l(old$" replaced with "$newActorClass);
        a = ReplaceActor(old, newActorClass );
        if( a != None ) return a;
    }
    warning("ReplaceWithRandomClass("$old$") failed");
    return None;
}

function string GetRandomActorClass()
{
#ifdef hx
    return "HX.HX" $ _GetRandomActorClass();
#else
    return "DeusEx." $ _GetRandomActorClass();
#endif
}

function string _GetRandomActorClass()
{
    local int r, i;

    r = rng(499);

    if ( r == i++ ) return "AcousticSensor";
    if ( r == i++ ) return "AdaptiveArmor";
    if ( r == i++ ) return "AIPrototype";
    if ( r == i++ ) return "AlarmLight";
    if ( r == i++ ) return "AlarmUnit";
    if ( r == i++ ) return "AlexJacobson";
    if ( r == i++ ) return "AlexJacobsonCarcass";
    if ( r == i++ ) return "Ammo10mm";
    if ( r == i++ ) return "Ammo20mm";
    if ( r == i++ ) return "Ammo3006";
    if ( r == i++ ) return "Ammo762mm";
    if ( r == i++ ) return "AmmoBattery";
    if ( r == i++ ) return "ammocrate";
    if ( r == i++ ) return "AmmoDart";
    if ( r == i++ ) return "AmmoDartFlare";
    if ( r == i++ ) return "AmmoDartPoison";
    if ( r == i++ ) return "AmmoEMPGrenade";
    //if ( r == i++ ) return "AmmoGasGrenade";
    //if ( r == i++ ) return "AmmoGraySpit";
    //if ( r == i++ ) return "AmmoGreaselSpit";
    //if ( r == i++ ) return "AmmoLAM";
    //if ( r == i++ ) return "AmmoNanoVirusGrenade";
    if ( r == i++ ) return "AmmoNapalm";
    //if ( r == i++ ) return "AmmoNone";
    if ( r == i++ ) return "AmmoPepper";
    if ( r == i++ ) return "AmmoPlasma";
    if ( r == i++ ) return "AmmoRocket";
    if ( r == i++ ) return "AmmoRocketMini";
    //if ( r == i++ ) return "AmmoRocketRobot";
    if ( r == i++ ) return "AmmoRocketWP";
    if ( r == i++ ) return "AmmoSabot";
    if ( r == i++ ) return "AmmoShell";
    if ( r == i++ ) return "AmmoShuriken";
    if ( r == i++ ) return "AnnaNavarre";
    if ( r == i++ ) return "AnnaNavarreCarcass";
    if ( r == i++ ) return "ATM";
    if ( r == i++ ) return "AttackHelicopter";
    if ( r == i++ ) return "AugmentationCannister";
    if ( r == i++ ) return "AugmentationUpgradeCannister";
    if ( r == i++ ) return "AutoTurret";
    if ( r == i++ ) return "AutoTurretGun";
    if ( r == i++ ) return "AutoTurretGunSmall";
    if ( r == i++ ) return "AutoTurretSmall";
    if ( r == i++ ) return "BallisticArmor";
    if ( r == i++ ) return "Barrel1";
    if ( r == i++ ) return "BarrelAmbrosia";
    if ( r == i++ ) return "BarrelFire";
    if ( r == i++ ) return "BarrelVirus";
    if ( r == i++ ) return "Bartender";
    if ( r == i++ ) return "BartenderCarcass";
    if ( r == i++ ) return "Basket";
    if ( r == i++ ) return "Basketball";
    if ( r == i++ ) return "BeamTrigger";
    if ( r == i++ ) return "Binoculars";
    if ( r == i++ ) return "BioelectricCell";
    if ( r == i++ ) return "BlackHelicopter";
    if ( r == i++ ) return "BoatPerson";
    if ( r == i++ ) return "BoatPersonCarcass";
    if ( r == i++ ) return "BobPage";
    if ( r == i++ ) return "BobPageAugmented";
    if ( r == i++ ) return "BobPageCarcass";
    if ( r == i++ ) return "BoneFemur";
    if ( r == i++ ) return "BoneSkull";
    if ( r == i++ ) return "BookClosed";
    if ( r == i++ ) return "BookOpen";
    if ( r == i++ ) return "BoxLarge";
    if ( r == i++ ) return "BoxMedium";
    if ( r == i++ ) return "BoxSmall";
    if ( r == i++ ) return "BumFemale";
    if ( r == i++ ) return "BumFemaleCarcass";
    if ( r == i++ ) return "BumMale";
    if ( r == i++ ) return "BumMale2";
    if ( r == i++ ) return "BumMale2Carcass";
    if ( r == i++ ) return "BumMale3";
    if ( r == i++ ) return "BumMale3Carcass";
    if ( r == i++ ) return "BumMaleCarcass";
    if ( r == i++ ) return "Buoy";
    if ( r == i++ ) return "Bushes1";
    if ( r == i++ ) return "Bushes2";
    if ( r == i++ ) return "Bushes3";
    if ( r == i++ ) return "Businessman1";
    if ( r == i++ ) return "Businessman1Carcass";
    if ( r == i++ ) return "Businessman2";
    if ( r == i++ ) return "Businessman2Carcass";
    if ( r == i++ ) return "Businessman3";
    if ( r == i++ ) return "Businessman3Carcass";
    if ( r == i++ ) return "Businesswoman1";
    if ( r == i++ ) return "Businesswoman1Carcass";
    if ( r == i++ ) return "Butler";
    if ( r == i++ ) return "ButlerCarcass";
    if ( r == i++ ) return "Button1";
    if ( r == i++ ) return "Cactus1";
    if ( r == i++ ) return "Cactus2";
    if ( r == i++ ) return "CageLight";
    if ( r == i++ ) return "Candybar";
    if ( r == i++ ) return "CarBurned";
    if ( r == i++ ) return "CarStripped";
    if ( r == i++ ) return "Cart";
    if ( r == i++ ) return "CarWrecked";
    if ( r == i++ ) return "Cat";
    if ( r == i++ ) return "CatCarcass";
    if ( r == i++ ) return "CeilingFan";
    if ( r == i++ ) return "CeilingFanMotor";
    if ( r == i++ ) return "Chad";
    if ( r == i++ ) return "ChadCarcass";
    if ( r == i++ ) return "Chair1";
    if ( r == i++ ) return "ChairLeather";
    if ( r == i++ ) return "Chandelier";
    if ( r == i++ ) return "Chef";
    if ( r == i++ ) return "ChefCarcass";
    if ( r == i++ ) return "ChildMale";
    if ( r == i++ ) return "ChildMale2";
    if ( r == i++ ) return "ChildMale2Carcass";
    if ( r == i++ ) return "ChildMaleCarcass";
    if ( r == i++ ) return "CigaretteMachine";
    if ( r == i++ ) return "Cigarettes";
    if ( r == i++ ) return "CleanerBot";
    if ( r == i++ ) return "ClothesRack";
    if ( r == i++ ) return "CoffeeTable";
    if ( r == i++ ) return "ComputerPersonal";
    if ( r == i++ ) return "ComputerPublic";
    if ( r == i++ ) return "ComputerSecurity";
    if ( r == i++ ) return "ControlPanel";
    if ( r == i++ ) return "Cop";
    if ( r == i++ ) return "CopCarcass";
    if ( r == i++ ) return "CouchLeather";
    if ( r == i++ ) return "CrateBreakableMedCombat";
    if ( r == i++ ) return "CrateBreakableMedGeneral";
    if ( r == i++ ) return "CrateBreakableMedMedical";
    if ( r == i++ ) return "CrateExplosiveSmall";
    if ( r == i++ ) return "CrateUnbreakableLarge";
    if ( r == i++ ) return "CrateUnbreakableMed";
    if ( r == i++ ) return "CrateUnbreakableSmall";
    if ( r == i++ ) return "Credits";
    if ( r == i++ ) return "Cushion";
    if ( r == i++ ) return "Dart";
    if ( r == i++ ) return "DartFlare";
    if ( r == i++ ) return "DartPoison";
    if ( r == i++ ) return "DataCube";
    //if ( r == i++ ) return "DataVaultImage";
    if ( r == i++ ) return "DentonClone";
    if ( r == i++ ) return "Doberman";
    if ( r == i++ ) return "DobermanCarcass";
    if ( r == i++ ) return "Doctor";
    if ( r == i++ ) return "DoctorCarcass";
    if ( r == i++ ) return "DXLogo";
    if ( r == i++ ) return "DXText";
    if ( r == i++ ) return "Earth";
    //if ( r == i++ ) return "EidosLogo";//Warning: SpawnActor failed because class EidosLogo has bStatic or bNoDelete
    if ( r == i++ ) return "EMPGrenade";
    if ( r == i++ ) return "Fan1";
    if ( r == i++ ) return "Fan1Vertical";
    if ( r == i++ ) return "Fan2";
    if ( r == i++ ) return "Faucet";
    if ( r == i++ ) return "Female1";
    if ( r == i++ ) return "Female1Carcass";
    if ( r == i++ ) return "Female2";
    if ( r == i++ ) return "Female2Carcass";
    if ( r == i++ ) return "Female3";
    if ( r == i++ ) return "Female3Carcass";
    if ( r == i++ ) return "Female4";
    if ( r == i++ ) return "Female4Carcass";
    if ( r == i++ ) return "FireExtinguisher";
    //if ( r == i++ ) return "FirePlug";
    if ( r == i++ ) return "Fish";
    if ( r == i++ ) return "Fish2";
    //if ( r == i++ ) return "Fishes";//Warning: SpawnActor failed because class Fishes is abstract
    if ( r == i++ ) return "FlagPole";
    if ( r == i++ ) return "Flare";
    if ( r == i++ ) return "Flask";
    //if ( r == i++ ) return "FleshFragment";
    if ( r == i++ ) return "Flowers";
    if ( r == i++ ) return "Fly";
    if ( r == i++ ) return "FordSchick";
    if ( r == i++ ) return "FordSchickCarcass";
    if ( r == i++ ) return "GarySavage";
    if ( r == i++ ) return "GarySavageCarcass";
    if ( r == i++ ) return "GasGrenade";
    if ( r == i++ ) return "GilbertRenton";
    if ( r == i++ ) return "GilbertRentonCarcass";
    //if ( r == i++ ) return "GlassFragment";
    if ( r == i++ ) return "GordonQuick";
    if ( r == i++ ) return "GordonQuickCarcass";
    if ( r == i++ ) return "Gray";
    if ( r == i++ ) return "GrayCarcass";
    if ( r == i++ ) return "Greasel";
    if ( r == i++ ) return "GreaselCarcass";
    if ( r == i++ ) return "GuntherHermann";
    if ( r == i++ ) return "GuntherHermannCarcass";
    if ( r == i++ ) return "HangingChicken";
    if ( r == i++ ) return "HangingShopLight";
    if ( r == i++ ) return "HarleyFilben";
    if ( r == i++ ) return "HarleyFilbenCarcass";
    if ( r == i++ ) return "HazMatSuit";
    //if ( r == i++ ) return "HECannister20mm";
    if ( r == i++ ) return "HKBirdcage";
    if ( r == i++ ) return "HKBuddha";
    if ( r == i++ ) return "HKChair";
    if ( r == i++ ) return "HKCouch";
    if ( r == i++ ) return "HKHangingLantern";
    if ( r == i++ ) return "HKHangingLantern2";
    if ( r == i++ ) return "HKHangingPig";
    if ( r == i++ ) return "HKIncenseBurner";
    if ( r == i++ ) return "HKMarketLight";
    if ( r == i++ ) return "HKMarketTable";
    if ( r == i++ ) return "HKMarketTarp";
    if ( r == i++ ) return "HKMilitary";
    if ( r == i++ ) return "HKMilitaryCarcass";
    if ( r == i++ ) return "HKTable";
    if ( r == i++ ) return "HKTukTuk";
    if ( r == i++ ) return "Hooker1";
    if ( r == i++ ) return "Hooker1Carcass";
    if ( r == i++ ) return "Hooker2";
    if ( r == i++ ) return "Hooker2Carcass";
    if ( r == i++ ) return "HowardStrong";
    if ( r == i++ ) return "HowardStrongCarcass";
    //if ( r == i++ ) return "Image01_GunFireSensor";
    //if ( r == i++ ) return "Image01_LibertyIsland";
    //if ( r == i++ ) return "Image01_TerroristCommander";
    //if ( r == i++ ) return "Image02_Ambrosia_Flyer";
    //if ( r == i++ ) return "Image02_BobPage_ManOfYear";
    //if ( r == i++ ) return "Image02_NYC_Warehouse";
    //if ( r == i++ ) return "Image03_747Diagram";
    //if ( r == i++ ) return "Image03_NYC_Airfield";
    //if ( r == i++ ) return "Image03_WaltonSimons";
    //if ( r == i++ ) return "Image04_NSFHeadquarters";
    //if ( r == i++ ) return "Image04_UNATCONotice";
    //if ( r == i++ ) return "Image05_GreaselDisection";
    //if ( r == i++ ) return "Image05_NYC_MJ12Lab";
    //if ( r == i++ ) return "Image06_HK_Market";
    //if ( r == i++ ) return "Image06_HK_MJ12Helipad";
    //if ( r == i++ ) return "Image06_HK_MJ12Lab";
    //if ( r == i++ ) return "Image06_HK_Versalife";
    //if ( r == i++ ) return "Image06_HK_WanChai";
    //if ( r == i++ ) return "Image08_JoeGreenMIBMJ12";
    //if ( r == i++ ) return "Image09_NYC_Ship_Bottom";
    //if ( r == i++ ) return "Image09_NYC_Ship_Top";
    //if ( r == i++ ) return "Image10_Paris_Catacombs";
    //if ( r == i++ ) return "Image10_Paris_CatacombsTunnels";
    //if ( r == i++ ) return "Image10_Paris_Metro";
    //if ( r == i++ ) return "Image11_Paris_Cathedral";
    //if ( r == i++ ) return "Image11_Paris_CathedralEntrance";
    //if ( r == i++ ) return "Image12_Tiffany_HostagePic";
    //if ( r == i++ ) return "Image12_Vandenberg_Command";
    //if ( r == i++ ) return "Image12_Vandenberg_Sub";
    //if ( r == i++ ) return "Image14_OceanLab";
    //if ( r == i++ ) return "Image14_Schematic";
    //if ( r == i++ ) return "Image15_Area51Bunker";
    //if ( r == i++ ) return "Image15_Area51_Sector3";
    //if ( r == i++ ) return "Image15_Area51_Sector4";
    //if ( r == i++ ) return "Image15_BlueFusionDevice";
    //if ( r == i++ ) return "Image15_GrayDisection";
    if ( r == i++ ) return "IonStormLogo";
    if ( r == i++ ) return "JaimeReyes";
    if ( r == i++ ) return "JaimeReyesCarcass";
    if ( r == i++ ) return "Janitor";
    if ( r == i++ ) return "JanitorCarcass";
    if ( r == i++ ) return "JCDentonMale";
    if ( r == i++ ) return "JCDentonMaleCarcass";
    if ( r == i++ ) return "JCDouble";
    if ( r == i++ ) return "Jock";
    if ( r == i++ ) return "JockCarcass";
    if ( r == i++ ) return "JoeGreene";
    if ( r == i++ ) return "JoeGreeneCarcass";
    if ( r == i++ ) return "JoJoFine";
    if ( r == i++ ) return "JoJoFineCarcass";
    if ( r == i++ ) return "JordanShea";
    if ( r == i++ ) return "JordanSheaCarcass";
    if ( r == i++ ) return "JosephManderley";
    if ( r == i++ ) return "JosephManderleyCarcass";
    if ( r == i++ ) return "JuanLebedev";
    if ( r == i++ ) return "JuanLebedevCarcass";
    if ( r == i++ ) return "JunkieFemale";
    if ( r == i++ ) return "JunkieFemaleCarcass";
    if ( r == i++ ) return "JunkieMale";
    if ( r == i++ ) return "JunkieMaleCarcass";
    if ( r == i++ ) return "Karkian";
    if ( r == i++ ) return "KarkianBaby";
    if ( r == i++ ) return "KarkianBabyCarcass";
    if ( r == i++ ) return "KarkianCarcass";
    if ( r == i++ ) return "Keypad1";
    if ( r == i++ ) return "Keypad2";
    if ( r == i++ ) return "Keypad3";
    //if ( r == i++ ) return "LAM";
    if ( r == i++ ) return "Lamp1";
    if ( r == i++ ) return "Lamp2";
    if ( r == i++ ) return "Lamp3";
    if ( r == i++ ) return "LaserTrigger";
    if ( r == i++ ) return "LifeSupportBase";
    if ( r == i++ ) return "Lightbulb";
    if ( r == i++ ) return "LightSwitch";
    if ( r == i++ ) return "Liquor40oz";
    if ( r == i++ ) return "LiquorBottle";
    if ( r == i++ ) return "Lockpick";
    if ( r == i++ ) return "LowerClassFemale";
    if ( r == i++ ) return "LowerClassFemaleCarcass";
    if ( r == i++ ) return "LowerClassMale";
    if ( r == i++ ) return "LowerClassMale2";
    if ( r == i++ ) return "LowerClassMale2Carcass";
    if ( r == i++ ) return "LowerClassMaleCarcass";
    if ( r == i++ ) return "LuciusDeBeers";
    if ( r == i++ ) return "MaggieChow";
    if ( r == i++ ) return "MaggieChowCarcass";
    if ( r == i++ ) return "Maid";
    if ( r == i++ ) return "MaidCarcass";
    if ( r == i++ ) return "Mailbox";
    if ( r == i++ ) return "Male1";
    if ( r == i++ ) return "Male1Carcass";
    if ( r == i++ ) return "Male2";
    if ( r == i++ ) return "Male2Carcass";
    if ( r == i++ ) return "Male3";
    if ( r == i++ ) return "Male3Carcass";
    if ( r == i++ ) return "Male4";
    if ( r == i++ ) return "Male4Carcass";
    if ( r == i++ ) return "MargaretWilliams";
    if ( r == i++ ) return "MargaretWilliamsCarcass";
    if ( r == i++ ) return "MaxChen";
    if ( r == i++ ) return "MaxChenCarcass";
    if ( r == i++ ) return "Mechanic";
    if ( r == i++ ) return "MechanicCarcass";
    if ( r == i++ ) return "MedicalBot";
    if ( r == i++ ) return "MedKit";
    //if ( r == i++ ) return "MetalFragment";
    if ( r == i++ ) return "MIB";
    if ( r == i++ ) return "MIBCarcass";
    if ( r == i++ ) return "MichaelHamner";
    if ( r == i++ ) return "MichaelHamnerCarcass";
    if ( r == i++ ) return "Microscope";
    if ( r == i++ ) return "MilitaryBot";
    if ( r == i++ ) return "MiniSub";
    if ( r == i++ ) return "MJ12Commando";
    if ( r == i++ ) return "MJ12CommandoCarcass";
    if ( r == i++ ) return "MJ12Troop";
    if ( r == i++ ) return "MJ12TroopCarcass";
    if ( r == i++ ) return "Moon";
    if ( r == i++ ) return "MorganEverett";
    if ( r == i++ ) return "MorganEverettCarcass";
    //if ( r == i++ ) return "mpmj12";
    //if ( r == i++ ) return "mpnsf";
    //if ( r == i++ ) return "Mpunatco";
    if ( r == i++ ) return "Multitool";
    if ( r == i++ ) return "Mutt";
    if ( r == i++ ) return "MuttCarcass";
    if ( r == i++ ) return "NanoKey";
    if ( r == i++ ) return "NanoVirusGrenade";
    if ( r == i++ ) return "NathanMadison";
    if ( r == i++ ) return "NathanMadisonCarcass";
    if ( r == i++ ) return "Newspaper";
    if ( r == i++ ) return "NewspaperOpen";
    if ( r == i++ ) return "NicoletteDuClare";
    if ( r == i++ ) return "NicoletteDuClareCarcass";
    if ( r == i++ ) return "Nurse";
    if ( r == i++ ) return "NurseCarcass";
    if ( r == i++ ) return "NYEagleStatue";
    if ( r == i++ ) return "NYLiberty";
    if ( r == i++ ) return "NYLibertyTop";
    if ( r == i++ ) return "NYLibertyTorch";
    if ( r == i++ ) return "NYPoliceBoat";
    if ( r == i++ ) return "OfficeChair";
    if ( r == i++ ) return "Pan1";
    if ( r == i++ ) return "Pan2";
    if ( r == i++ ) return "Pan3";
    if ( r == i++ ) return "Pan4";
    //if ( r == i++ ) return "PaperFragment";
    if ( r == i++ ) return "PaulDenton";
    if ( r == i++ ) return "PaulDentonCarcass";
    if ( r == i++ ) return "PhilipMead";
    if ( r == i++ ) return "PhilipMeadCarcass";
    if ( r == i++ ) return "Phone";
    if ( r == i++ ) return "Pigeon";
    if ( r == i++ ) return "PigeonCarcass";
    if ( r == i++ ) return "Pillow";
    if ( r == i++ ) return "Pinball";
    if ( r == i++ ) return "Plant1";
    if ( r == i++ ) return "Plant2";
    if ( r == i++ ) return "Plant3";
    if ( r == i++ ) return "PlasmaBolt";
    //if ( r == i++ ) return "PlasticFragment";
    if ( r == i++ ) return "Poolball";
    if ( r == i++ ) return "PoolTableLight";
    if ( r == i++ ) return "Pot1";
    if ( r == i++ ) return "Pot2";
    //if ( r == i++ ) return "POVCorpse";
    if ( r == i++ ) return "RachelMead";
    if ( r == i++ ) return "RachelMeadCarcass";
    if ( r == i++ ) return "Rat";
    if ( r == i++ ) return "RatCarcass";
    if ( r == i++ ) return "Rebreather";
    if ( r == i++ ) return "RepairBot";
    if ( r == i++ ) return "RetinalScanner";
    if ( r == i++ ) return "RiotCop";
    if ( r == i++ ) return "RiotCopCarcass";
    if ( r == i++ ) return "RoadBlock";
    if ( r == i++ ) return "Rockchip";
    if ( r == i++ ) return "Rocket";
    if ( r == i++ ) return "RocketLAW";
    if ( r == i++ ) return "RocketMini";
    if ( r == i++ ) return "RocketRobot";
    if ( r == i++ ) return "RocketWP";
    if ( r == i++ ) return "Sailor";
    if ( r == i++ ) return "SailorCarcass";
    if ( r == i++ ) return "SamCarter";
    if ( r == i++ ) return "SamCarterCarcass";
    if ( r == i++ ) return "SandraRenton";
    if ( r == i++ ) return "SandraRentonCarcass";
    if ( r == i++ ) return "SarahMead";
    if ( r == i++ ) return "SarahMeadCarcass";
    if ( r == i++ ) return "SatelliteDish";
    if ( r == i++ ) return "ScientistFemale";
    if ( r == i++ ) return "ScientistFemaleCarcass";
    if ( r == i++ ) return "ScientistMale";
    if ( r == i++ ) return "ScientistMaleCarcass";
    if ( r == i++ ) return "ScubaDiver";
    if ( r == i++ ) return "ScubaDiverCarcass";
    if ( r == i++ ) return "Seagull";
    if ( r == i++ ) return "SeagullCarcass";
    if ( r == i++ ) return "Secretary";
    if ( r == i++ ) return "SecretaryCarcass";
    if ( r == i++ ) return "SecretService";
    if ( r == i++ ) return "SecretServiceCarcass";
    if ( r == i++ ) return "SecurityBot2";
    if ( r == i++ ) return "SecurityBot3";
    if ( r == i++ ) return "SecurityBot4";
    if ( r == i++ ) return "SecurityCamera";
    if ( r == i++ ) return "ShellCasing";
    if ( r == i++ ) return "ShellCasing2";
    if ( r == i++ ) return "ShellCasingSilent";
    if ( r == i++ ) return "ShipsWheel";
    if ( r == i++ ) return "ShopLight";
    if ( r == i++ ) return "ShowerFaucet";
    if ( r == i++ ) return "ShowerHead";
    if ( r == i++ ) return "Shuriken";
    if ( r == i++ ) return "SignFloor";
    if ( r == i++ ) return "Smuggler";
    if ( r == i++ ) return "SmugglerCarcass";
    //if ( r == i++ ) return "snipertracer";
    if ( r == i++ ) return "Sodacan";
    if ( r == i++ ) return "Soldier";
    if ( r == i++ ) return "SoldierCarcass";
    if ( r == i++ ) return "SoyFood";
    if ( r == i++ ) return "SpiderBot";
    if ( r == i++ ) return "SpiderBot2";
    if ( r == i++ ) return "SpyDrone";
    if ( r == i++ ) return "StantonDowd";
    if ( r == i++ ) return "StantonDowdCarcass";
    if ( r == i++ ) return "StatueLion";
    if ( r == i++ ) return "SubwayControlPanel";
    if ( r == i++ ) return "Switch1";
    if ( r == i++ ) return "Switch2";
    if ( r == i++ ) return "TAD";
    if ( r == i++ ) return "TechGoggles";
    if ( r == i++ ) return "Terrorist";
    if ( r == i++ ) return "TerroristCarcass";
    if ( r == i++ ) return "TerroristCommander";
    if ( r == i++ ) return "TerroristCommanderCarcass";
    if ( r == i++ ) return "ThugMale";
    if ( r == i++ ) return "ThugMale2";
    if ( r == i++ ) return "ThugMale2Carcass";
    if ( r == i++ ) return "ThugMale3";
    if ( r == i++ ) return "ThugMale3Carcass";
    if ( r == i++ ) return "ThugMaleCarcass";
    if ( r == i++ ) return "TiffanySavage";
    if ( r == i++ ) return "TiffanySavageCarcass";
    if ( r == i++ ) return "TobyAtanwe";
    if ( r == i++ ) return "TobyAtanweCarcass";
    if ( r == i++ ) return "Toilet";
    if ( r == i++ ) return "Toilet2";
    //if ( r == i++ ) return "Tracer";
    if ( r == i++ ) return "TracerTong";
    if ( r == i++ ) return "TracerTongCarcass";
    if ( r == i++ ) return "TrafficLight";
    if ( r == i++ ) return "Trashbag";
    if ( r == i++ ) return "Trashbag2";
    if ( r == i++ ) return "TrashCan1";
    if ( r == i++ ) return "Trashcan2";
    if ( r == i++ ) return "TrashCan3";
    if ( r == i++ ) return "TrashCan4";
    if ( r == i++ ) return "TrashPaper";
    if ( r == i++ ) return "Tree1";
    if ( r == i++ ) return "Tree2";
    if ( r == i++ ) return "Tree3";
    if ( r == i++ ) return "Tree4";
    if ( r == i++ ) return "TriadLumPath";
    if ( r == i++ ) return "TriadLumPath2";
    if ( r == i++ ) return "TriadLumPath2Carcass";
    if ( r == i++ ) return "TriadLumPathCarcass";
    if ( r == i++ ) return "TriadRedArrow";
    if ( r == i++ ) return "TriadRedArrowCarcass";
    if ( r == i++ ) return "Trophy";
    if ( r == i++ ) return "Tumbleweed";
    if ( r == i++ ) return "UNATCOTroop";
    if ( r == i++ ) return "UNATCOTroopCarcass";
    if ( r == i++ ) return "Valve";
    if ( r == i++ ) return "Van";
    if ( r == i++ ) return "Vase1";
    if ( r == i++ ) return "Vase2";
    if ( r == i++ ) return "VendingMachine";
    if ( r == i++ ) return "VialAmbrosia";
    if ( r == i++ ) return "VialCrack";
    if ( r == i++ ) return "WaltonSimons";
    if ( r == i++ ) return "WaltonSimonsCarcass";
    if ( r == i++ ) return "WaterCooler";
    if ( r == i++ ) return "WaterFountain";
    if ( r == i++ ) return "WeaponAssaultGun";
    if ( r == i++ ) return "WeaponAssaultShotgun";
    if ( r == i++ ) return "WeaponBaton";
    //if ( r == i++ ) return "WeaponCatScratch";
    if ( r == i++ ) return "WeaponCombatKnife";
    if ( r == i++ ) return "WeaponCrowbar";
    //if ( r == i++ ) return "WeaponDogBite";
    if ( r == i++ ) return "WeaponEMPGrenade";
    if ( r == i++ ) return "WeaponFlamethrower";
    if ( r == i++ ) return "WeaponGasGrenade";
    if ( r == i++ ) return "WeaponGEPGun";
    //if ( r == i++ ) return "WeaponGraySpit";
    //if ( r == i++ ) return "WeaponGraySwipe";
    //if ( r == i++ ) return "WeaponGreaselSpit";
    if ( r == i++ ) return "WeaponHideAGun";
    //if ( r == i++ ) return "WeaponKarkianBite";
    //if ( r == i++ ) return "WeaponKarkianBump";
    if ( r == i++ ) return "WeaponLAM";
    if ( r == i++ ) return "WeaponLAW";
    if ( r == i++ ) return "WeaponMiniCrossbow";
    //if ( r == i++ ) return "WeaponMJ12Commando";
    //if ( r == i++ ) return "WeaponMJ12Rocket";
    //if ( r == i++ ) return "WeaponMod";
    if ( r == i++ ) return "WeaponModAccuracy";
    if ( r == i++ ) return "WeaponModClip";
    if ( r == i++ ) return "WeaponModLaser";
    if ( r == i++ ) return "WeaponModRange";
    if ( r == i++ ) return "WeaponModRecoil";
    if ( r == i++ ) return "WeaponModReload";
    if ( r == i++ ) return "WeaponModScope";
    if ( r == i++ ) return "WeaponModSilencer";
    if ( r == i++ ) return "WeaponNanoSword";
    if ( r == i++ ) return "WeaponNanoVirusGrenade";
    //if ( r == i++ ) return "WeaponNPCMelee";
    //if ( r == i++ ) return "WeaponNPCRanged";
    if ( r == i++ ) return "WeaponPepperGun";
    if ( r == i++ ) return "WeaponPistol";
    if ( r == i++ ) return "WeaponPlasmaRifle";
    if ( r == i++ ) return "WeaponProd";
    //if ( r == i++ ) return "WeaponRatBite";
    if ( r == i++ ) return "WeaponRifle";
    //if ( r == i++ ) return "WeaponRobotMachinegun";
    //if ( r == i++ ) return "WeaponRobotRocket";
    if ( r == i++ ) return "WeaponSawedOffShotgun";
    if ( r == i++ ) return "WeaponShuriken";
    //if ( r == i++ ) return "WeaponSpiderBot";
    //if ( r == i++ ) return "WeaponSpiderBot2";
    if ( r == i++ ) return "WeaponStealthPistol";
    if ( r == i++ ) return "WeaponSword";
    if ( r == i++ ) return "WHBenchEast";
    if ( r == i++ ) return "WHBenchLibrary";
    if ( r == i++ ) return "WHBookstandLibrary";
    if ( r == i++ ) return "WHCabinet";
    if ( r == i++ ) return "WHChairDining";
    if ( r == i++ ) return "WHChairOvalOffice";
    if ( r == i++ ) return "WHChairPink";
    if ( r == i++ ) return "WHDeskLibrarySmall";
    if ( r == i++ ) return "WHDeskOvalOffice";
    if ( r == i++ ) return "WHEndtableLibrary";
    if ( r == i++ ) return "WHFireplaceGrill";
    if ( r == i++ ) return "WHFireplaceLog";
    if ( r == i++ ) return "WHPhone";
    if ( r == i++ ) return "WHPiano";
    if ( r == i++ ) return "WHRedCandleabra";
    if ( r == i++ ) return "WHRedCouch";
    if ( r == i++ ) return "WHRedEagleTable";
    if ( r == i++ ) return "WHRedLampTable";
    if ( r == i++ ) return "WHRedOvalTable";
    if ( r == i++ ) return "WHRedVase";
    if ( r == i++ ) return "WHTableBlue";
    if ( r == i++ ) return "WIB";
    if ( r == i++ ) return "WIBCarcass";
    if ( r == i++ ) return "WineBottle";
    //if ( r == i++ ) return "WoodFragment";
}

defaultproperties
{
}
