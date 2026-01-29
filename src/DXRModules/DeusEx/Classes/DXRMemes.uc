class DXRMemes extends DXRActorsBase transient;
// make sure none of this affects speed or score, because it can be easily disabled
var Actor rotating;

struct camera_scene {
    var CameraPoint cams[20];
    var int numCams;
};

function RandomDancing(Actor a)
{
    local ScriptedPawn sp;
    if (IsHuman(a.class)) {
        sp = ScriptedPawn(a);
        if (sp.Orders == 'Standing' ||
            sp.Orders == 'Sitting' ||
            sp.Orders == '') {
            if (a.HasAnim('Dance')){
                if (chance_single(dxr.flags.settings.dancingpercent)) {
                    sp.SetOrders('Dancing');
                    if (sp.bUseHome==False){
                        sp.SetHomeBase(sp.Location,sp.Rotation,sp.CollisionRadius);
                    }

                }
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

    a.DrawScale = a.CollisionHeight / (influencer.default.CollisionHeight / influencer.default.DrawScale);
    r.Yaw = rotYaw;
    a.SetRotation(r);
}

function RandomLiberty()
{
    local NYLiberty liberty;
    local NYLibertyTop top;
    local int i;

    foreach AllActors(class'NYLibertyTop',top){
        if(IsOctober()) {
            top.style = STY_Translucent;
            top.ScaleGlow = 0.5;
        }
    }

    foreach AllActors(class'NYLiberty',liberty){
        SetGlobalSeed("RandomLiberty");

        if(IsOctober()) {
            liberty.style = STY_Translucent;
            liberty.ScaleGlow = 0.5;
        }

        if ( rng(3)!=0 && !IsAprilFools() ) return; //33% chance of getting a random statue

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

        if ( rng(3)!=0 && !IsAprilFools() ) return; //33% chance of getting a random bob

        switch(rng(29)){
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
        case 28: PlayDressUp(bob,class'Bobby',-8000); return;
        }

    }
}

//These need a bit more manual fiddling than the others since you are so much closer to them, including underneath
function RandomMJ12Globe()
{
    local Earth earth;
    local int i;
    local float scaleMult;
    local Rotator startRot;

    foreach AllActors(class'Earth',earth){
        SetGlobalSeed("RandomGlobe");

        earth.bIsSecretGoal=True;

        startRot = earth.Rotation;
        scaleMult=1.0;

        if ( rng(3)!=0 && !IsAprilFools() ) return; //33% chance of getting a random globe

        switch(rng(16)){
        case 0:
            PlayDressUp(earth,class'Basketball',0);
            startRot = rotm(8000,0,7000,0); //Give it a bit of tilt for more drama
            scaleMult = 2;
            break;
        case 1:
            PlayDressUp(earth,class'BoneSkull',0);
            startRot = rotm(0,32765,-5000,0); //Slightly tilted down
            scaleMult = 1.0;
            break;
        case 2:
            PlayDressUp(earth,class'Liquor40oz',0);
            startRot = rotm(0,16000,12000,0);
            scaleMult = 2;
            break;
        case 3:
            PlayDressUp(earth,class'#var(prefix)DXLogo',0);
            startRot = earth.Rotation;
            scaleMult = 3;
            break;
        case 4:
            PlayDressUp(earth,class'SodaCan',0);
            startRot = rotm(6000,16000,12000,0);
            scaleMult = 1.0;
            break;
        case 5: //Does this one even look good?
            PlayDressUp(earth,class'BoneFemur',0);
            startRot = rotm(0,16000,12000,0);
            scaleMult = 0.25;
            break;
        case 6:
            PlayDressUp(earth,class'ChildMale2',24000);
            startRot = earth.Rotation;
            scaleMult = 1.5;
            break;
        case 7:
            PlayDressUp(earth,class'Trophy',0);
            startRot = earth.Rotation;
            scaleMult = 1.0;
            break;
        case 8:
            PlayDressUp(earth,class'GrayCarcass',0);
            startRot = rotm(-16385,20000,0,0);
            scaleMult = 0.25;
            break;
        case 9:
            PlayDressUp(earth,class'Mutt',24000);
            startRot = earth.Rotation;
            scaleMult = 1.5;
            break;
        case 10:
            PlayDressUp(earth,class'IonStormLogo',-20000);
            startRot = earth.Rotation;
            scaleMult = 8;
            break;
        case 11:
            PlayDressUp(earth,class'EidosLogo',-20000);
            startRot = earth.Rotation;
            scaleMult = 0.4;
            break;
        case 12:
            PlayDressUp(earth,class'HKTukTuk',-20000);
            startRot = earth.Rotation;
            scaleMult = 0.6;
            break;
        case 13:
            PlayDressUp(earth,class'CarWrecked',-20000);
            startRot = earth.Rotation;
            scaleMult = 1.0;
            break;
        case 14:
            PlayDressUp(earth,class'MiniSub',-20000);
            startRot = earth.Rotation;
            scaleMult = 1.0;
            break;
        case 15:
            PlayDressUp(earth,class'JCDouble',24000);
            startRot = earth.Rotation;
            scaleMult = 1.5;
            break;
        }

        earth.RotationRate = rot(0,-750,0);
        earth.DrawScale = earth.DrawScale * scaleMult;
        earth.SetRotation(startRot);

        return;
    }
}

function RandomAnnaMannequin()
{
    local Cactus2 man;

    //Anna only has this mannequin in Revision maps
    if (!class'DXRMapVariants'.static.IsRevisionMaps(player())) return;

    SetGlobalSeed("RandomAnnaMannequin");

    foreach AllActors(class'Cactus2',man){break;}
    if (man==None) return; //If for some reason it can't be found...

    if ( rng(3)!=0 && !IsAprilFools() ) return; //33% chance of getting a random mannequin

    switch(rng(11)){
        case 0:  PlayDressUp(man,class'JuanLebedev',9752); return;
        case 1:  PlayDressUp(man,class'TerroristCommander',9752); return;
        case 2:  PlayDressUp(man,class'JoJoFine',9752); return;
        case 3:  PlayDressUp(man,class'JunkieMale',9752); return;
        case 4:  PlayDressUp(man,class'BumMale',9752); return;
        case 5:  PlayDressUp(man,class'BumMale2',9752); return;
        case 6:  PlayDressUp(man,class'BumMale3',9752); return;
        case 7:  PlayDressUp(man,class'StantonDowd',9752); return;
        case 8:  PlayDressUp(man,class'ThugMale',9752); return;
        case 9:  PlayDressUp(man,class'ThugMale2',9752); return;
        case 10: PlayDressUp(man,class'ThugMale3',9752); return;
    }

}



function RandomHotelDoorSounds()
{
    local SoundLooper sl;
    local bool randoSound;

    SetGlobalSeed("RandomHotelSounds "$dxr.localURL);

    ReplaceHotelAmbientSounds();  //Swap the AmbientSound's out for the cooler and more attractive SoundLoopers

    foreach AllActors(class'SoundLooper',sl){
        randoSound = false;
        if (sl.AmbientSound!=None){
            //Higher chance of the doors that already have sounds getting a random sound
            if ( rng(3)==0 || IsAprilFools() ) randoSound=true; //33% chance of getting a random door sound
        } else {
            //If the door *didn't* already have a sound, give a chance for the door to get a sound
            if (IsAprilFools()){
                //33% chance of getting a sound on April Fools
                if ( rng(3)==0 ) randoSound=true;
            } else {
                //10% chance of getting a sound on any other day of the year
                if ( rng(10)==0 ) randoSound=true;
            }
        }

        if (randoSound) RandomizeDoorSound(sl);
    }
}

function ReplaceHotelAmbientSounds()
{
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if (RevisionMaps){
        //Starting from the elevator, working around the hall
        //class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(-240,-2365,90),100); //Open in M02, M04, M08
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(-240,-2685,90),100);
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(  20,-2800,90),100);
        //Paul's door
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm( 915,-2800,90),100);
        if (dxr.dxinfo.missionNumber==8){
            class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(1180,-2475,90),100); //Open in M02, M04
        }
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(1180,-2150,90),100);
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm( 790,-1550,90),100);
        if (dxr.dxinfo.missionNumber!=2){
            class'SoundLooper'.static.ReplaceAmbientSound(self,vectm( 790,-1150,90),100); //Open in M02
        }
    } else {
        //Starting from the door next to Paul, and working around the hall
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(285,-2065,90),100);
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(675,-2065,90),100); //Corner
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(790,-1945,90),100); //Corner
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(790,-1550,90),100);
        class'SoundLooper'.static.ReplaceAmbientSound(self,vectm(670,-810,90),100);
    }

}

function RandomizeDoorSound(SoundLooper sl)
{
    local string soundName;
    local float playTime,delayTime;
    local bool needsLoop;
    local int max,choice,i;

    max = 20;
    if (#defined(revision)){
        max+=5;
    }
    if (dxr.IsChristmasSeason()) max++;

    choice = rng(max);
    if (choice == i++){
        soundName="Ambient.Ambient.TVSports";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.TVWestern";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.BabyCrying";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.Sex";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.Helicopter2";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.Klaxon";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.Klaxon4";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.DogsBarking";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.Electricity3";
    }
    else if (choice == i++) //10
    {
        soundName="Ambient.Ambient.FireLarge";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.HumTurbine2";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.TonalLoop2";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.TVNewsNeutral";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.TVNewsMale";
    }
    else if (choice == i++)
    {
        soundName="Ambient.Ambient.TVNewsFemale";
    }
    else if (choice == i++)
    {
        soundName="DeusExSounds.Pickup.RebreatherLoop";
    }
    else if (choice == i++)
    {
        soundName="#var(package).MemePiano.T7GPianoBad";
        playTime = 5.578;
        delayTime=2;
        needsLoop=true;
    }
    else if (choice == i++)
    {
        soundName="#var(package).MemePiano.NeverGonnaGive";
        playTime = 5.053;
        delayTime=3;
        needsLoop=true;
    }
    else if (choice == i++)
    {
        soundName="DeusExSounds.Special.FlushToilet";
        delayTime=20;
        needsLoop=true;
    }
    else if (choice == i++) //20
    {
        soundName="DeusExSounds.Special.PhoneBusy";
    }
#ifdef revision
    else if (choice == i++)
    {
        soundName="RSounds.Environment.Dodgy";
    }
    else if (choice == i++)
    {
        soundName="RSounds.Environment.VentVoicesLongLoop";
    }
    else if (choice == i++)
    {
        soundName="RSounds.Environment.WaterDock";
    }
    else if (choice == i++)
    {
        soundName="RSounds.Ambient.warble_PresidentMead";
        playTime=4.834;
        delayTime=0;
        needsLoop=true;
    }
    else if (choice == i++)
    {
        soundName="RSounds.Environment.ClockTick";
        playTime=4.856;
        delayTime=0;
        needsLoop=true;
    }
#endif
    else if (choice == i++)
    {
        soundName="#var(package).MemePiano.AllIWantForChristmas";
        playTime=34.501;
        delayTime=5;
        needsLoop=true;
    }

    if(needsLoop) {
        sl.AmbientSound = None;
        sl.mySound = Sound(DynamicLoadObject(soundName, class'Sound'));
        sl.playTime = playTime;
        sl.delayTime = delayTime;
        sl.randomizeDelay = true;
        sl.SoundVolume = 90; //The default sound volume is too loud
        sl.StartLoopedSound();
        l("RandomizeDoorSound " $ sl $" sound to "$soundName$" ("$sl.mySound$") with repeat delay " $ sl.delayTime);
        return;
    } else if (soundName!=""){
        sl.mySound = None;
        sl.AmbientSound = Sound(DynamicLoadObject(soundName, class'Sound'));
        sl.SoundPitch = 64;
        sl.SoundRadius = 8;
        sl.SoundVolume = 190;
        l("RandomizeDoorSound "$sl$" sound to "$soundName$" ("$sl.AmbientSound$")");
    }

}

function MakeNonHostileMrH(vector loc, rotator rotate)
{
    local MrH mrh;
    local rotator rotted;
    local vector locr;

    locr = vectm(loc.X,loc.Y,loc.Z);
    rotted = rotm(rotate.Pitch,rotate.Yaw,rotate.Roll,GetRotationOffset(class'MrH'));

    mrh = Spawn(class'MrH',,,locr,rotted);
    mrh.InitialAlliances[0].AllianceLevel=1; //This runs before the pawn is initialized, so this works to make him non-hostile
    mrh.Orders='Standing';
    mrh.SetOrders('Standing');
}

function CreateTrainingMrH()
{
    local vector loc;
    local rotator rotate;

    switch(dxr.localURL){
        case "00_TrainingCombat":
            loc = vect(1485,-310,-35);
            rotate = rot(0,11440,0);
            break;
        case "00_TrainingFinal":
            loc = vect(1680,-172,45);
            rotate = rot(0,32768,0);
            break;
    }

    if (loc!=vect(0,0,0)){
        MakeNonHostileMrH(loc,rotate);
    }
}

function PreFirstEntry()
{
    Super.PreFirstEntry();
    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) return;

    switch(dxr.localURL)
    {
        case "INTRO":
            //Make sure the intro has an actual location to show up in toots
            dxr.dxInfo.MissionLocation="the intro cinematic";
            break;
        case "00_TrainingCombat":
        case "00_TrainingFinal":
            CreateTrainingMrH();
            break;
        case "15_AREA51_PAGE":
            RandomBobPage();
            break;
        case "01_NYC_UNATCOIsland":
        case "03_NYC_UNATCOIsland":
        case "04_NYC_UNATCOIsland":
        case "05_NYC_UNATCOIsland":
            RandomLiberty();
            break;
        case "01_NYC_UNATCOHQ":
        case "03_NYC_UNATCOHQ":
            RandomAnnaMannequin();
            break;
        case "04_NYC_HOTEL":
            RandomHotelDoorSounds();
            if(IsAprilFools())
                PaulToilet();
            break;
        case "02_NYC_HOTEL":
        case "08_NYC_HOTEL":
            RandomHotelDoorSounds();
            break;
        case "06_HONGKONG_MJ12LAB":
            RandomMJ12Globe();
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
    TitleScreenRandoLogo();// do this even when memes disabled
    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) return;

    switch(dxr.localURL)
    {
        case "DXONLY":
        case "DX":
            l("Memeing up "$ dxr.localURL);

            foreach AllActors(class'Actor', a) {
                a.SetCollision(false,false,false);
            }

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
        case "ENDGAME4REV":
        //case "00_TRAINING":
            // extra randomization in the intro for the lolz
            l("Memeing up "$ dxr.localURL);
            RandomizeCutscene();
            FixEndgameEndCamera();
            break;
    }
}

function TitleScreenRandoLogo()
{
    local #var(prefix)DXText text;
    local vector v;

    if(dxr.localURL == "DXONLY" || dxr.localURL == "DX") {
        foreach AllActors(class'#var(prefix)DXText',text)
        {
            text.bHidden=True; //Hide all the original text
        }
    }
    if (dxr.localURL=="DX"){
        text = Spawn(class'DXRText',,,vectm(-60.979568,57.046417,-137.022430),rotm(0,32768,0,0));
        text.Skin = None;
        text = Spawn(class'DXRText',,,vectm(138.886353,57.125278,-137.022430),rotm(0,32768,0,0));
        text.Skin = Texture'DeusExDeco.Skins.DXTextTex2';

        // Randomizer logo
        v = vect(10, 57.15, -177.66);// midpoint
        text = Spawn(class'DXRText',,,vectm(v.X - 100, v.Y, v.Z),rotm(0,32768,0,0));
        text.Skin = Texture'RandomizerTextTex1';  //Left half of "Randomizer" text texture
        text = Spawn(class'DXRText',,,vectm(v.X + 100, v.Y, v.Z),rotm(0,32768,0,0));
        text.Skin = Texture'RandomizerTextTex2';  //Right half of "Randomizer" text texture
    } else if (dxr.localURL=="DXONLY"){
        text = Spawn(class'DXRText',,,vectm(-62.015648,-55.260841,-139.022430),rotm(0,49136,0,0));
        text.Skin = None;
        text = Spawn(class'DXRText',,,vectm(-61.787956,144.605042,-139.022430),rotm(0,49136,0,0));
        text.Skin = Texture'DeusExDeco.Skins.DXTextTex2';

        // Randomizer logo
        v = vect(-62, 10, -178.990417);// midpoint
        text = Spawn(class'DXRText',,,vectm(v.X, v.Y - 100, v.Z),rotm(0,49136,0,0));
        text.Skin = Texture'RandomizerTextTex1';  //Left half of "Randomizer" text texture
        text = Spawn(class'DXRText',,,vectm(v.X, v.Y + 100, v.Z),rotm(0,49136,0,0));
        text.Skin = Texture'RandomizerTextTex2';  //Right half of "Randomizer" text texture
    }
}

function FixEndgameEndCamera()
{
    local CameraPoint cp;
    local int endCameraSeq;
    local bool RevisionMaps;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL)
    {
        case "ENDGAME1":
            endCameraSeq=29; //Same in Vanilla and Revision
            break;
        case "ENDGAME2":
            if(RevisionMaps)
                endCameraSeq=32;
            else
                endCameraSeq=31;
            break;
        case "ENDGAME3":
            if(RevisionMaps)
                endCameraSeq=28;
            else
                endCameraSeq=27;
            break;
        default:
            return;
    }

    foreach AllActors(class'CameraPoint',cp){
        if (cp.sequenceNum==endCameraSeq){
            cp.timeWaitPost+=60;
        }
    }
}

function PostFirstEntry()
{
    local ScriptedPawn sp;
    local InterpolationPoint p;
    local LuciusDeBeers lucius;
    local #var(prefix)SignFloor sf;
    local vector v;
    local rotator r;

    Super.PostFirstEntry();

    SetSeed("Memes Dancing");

    foreach AllActors(class'ScriptedPawn',sp)
    {
        //Make people dance across the world, reduced rando sets this to 0%
        // we want to keep this in memes disabled because it could affect speed/difficulty/score/races
        RandomDancing(sp);
    }

    if(IsAprilFools()) {
        foreach AllActors(class'#var(prefix)SignFloor', sf) {
            class'FrictionTrigger'.static.CreateIce(sf, sf.Location, 160, 32);
        }
    }

    if(!class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) return;

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

    //Add Leo Gold if he made it! and other intro/outro stuff
    switch(dxr.localURL)
    {
        case "INTRO":
            MakeAllGhosts();
            break;
        case "ENDGAME1":
        case "ENDGAME2":
        case "ENDGAME3":
        case "ENDGAME4":
        case "ENDGAME4REV":
            AddLeo();
            MakeAllGhosts();
            break;
    }

    foreach AllActors(class'LuciusDeBeers', lucius) {
        lucius.bInvincible = false;
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

    if (p!=None && POVCorpse(p.inHand)!=None){
        c = POVCorpse(p.inHand);

        if (c.carcClassString == "DeusEx.TerroristCommanderCarcass"){
            broughtLeo = true;
            alive = c.bNotDead;
        }
    }
    if (!broughtLeo){
        return;
    }

    if (alive){
        rot.Yaw = 16472;
    } else {
        rot.Yaw = 0;
    }

    switch(dxr.localURL)
    {
        case "ENDGAME1":
        case "ENDGAME2": //They actually lined these two up!
            l("Endgame 1 or 2");
            loc.X = 189;
            loc.Y = -7816;
            loc.Z = -48;
            break;
        case "ENDGAME3":
            l("Endgame 3");
            loc.X = 192;
            loc.Y = -7813;
            loc.Z = -48;
            break;
        case "ENDGAME4":
        case "ENDGAME4REV":
            l("Endgame 4");
            loc.X = -736;
            loc.Y = -22;
            loc.Z = -32;

            rot.Yaw = -8064; //Different angle in Dance Party
            break;
    }

    if (alive){
        leo = Spawn(class'TerroristCommander',,,loc,rot);
        leo.bImportant=False; //Don't worry buddy, you're still important - I just don't want you gone
        leo.SetOrders('Standing','',True);
        leo.bInvincible=True; //In case of explosions or lightning...
    } else {
        Spawn(class'TerroristCommanderCarcass',,,loc,rot);
    }

}

function PaulToilet()
{
    local #var(prefix)PaulDenton paul;
    local #var(prefix)Chair1 chair;
    local #var(prefix)Toilet toilet;
    local #var(prefix)FlagTrigger ft;

    foreach AllActors(class'#var(prefix)PaulDenton', paul) {
        chair = #var(prefix)Chair1(findNearestToActor(class'#var(prefix)Chair1', paul));
        toilet = #var(prefix)Toilet(findNearestToActor(class'#var(prefix)Toilet', paul));
        ft = #var(prefix)FlagTrigger(findNearestToActor(class'#var(prefix)FlagTrigger', paul));
        break;
    }

    chair.Event = '';
    chair.Destroy();

    paul.SetLocation(toilet.Location);
    ft.SetLocation(paul.Location);
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

state() JumpInTheLine {
    event Tick(float delta)
    {
        local float t;
        local #var(prefix)ScriptedPawn p;
        local vector v;

        // why does this only affect some of the ScriptedPawns?
        foreach AllActors(class'#var(prefix)ScriptedPawn', p) {
            if(DXRStalker(p) != None) continue;
            t = Level.TimeSeconds - p.Location.X - p.Location.Y;
            t = sin(t / 2.0) * 160.0;
            v = p.Location;
            v.Z = t - 16;
            p.SetLocation(v);
        }
    }
}

//Find the next camera point, relative to the given sequence number
function CameraPoint GetNextCameraPoint(int seqNum)
{
    local CameraPoint c,lowest;

    foreach AllActors(class'CameraPoint',c){
        if (c.sequenceNum>seqNum){
            if (lowest==None){
                lowest = c;
            } else {
                if (c.sequenceNum<lowest.sequenceNum){
                    lowest=c;
                }
            }
        }
    }
    return lowest;
}

function RandomizeCutsceneOrder()
{
    local CameraPoint c,firstCam,prevCam;
    local camera_scene scenes[30];
    local int numScenes,i,j,slot,temp,scenesToSkip;
    local int sceneList[30];

    switch(dxr.localURL)
    {
        case "INTRO":
            if (#defined(revision)) {
                scenesToSkip=2; //Revision has two final scenes to leave in place (an extra "REVISION" screen after the black)
            } else {
                scenesToSkip=1; //Only skip the final black room scene
            }
            break;
        case "ENDGAME1":
            scenesToSkip=2; //Skip the MJ12 Hand and the black room scenes
            break;
        case "ENDGAME2":
        case "ENDGAME3":
            if (#defined(revision)) {
                scenesToSkip=1; //Revision doesn't have a black room scene at the end
            } else {
                scenesToSkip=2; //Skip the MJ12 Hand and the black room scenes
            }
            break;
        case "ENDGAME4":
        case "ENDGAME4REV":
        default:
            return; //Don't try to randomize the dance party (or anything else), it's already crazy

    }

    SetSeed("RandomizeCutsceneOrder");

    //Gather the camera points in order and group them into scenes
    c = GetNextCameraPoint(-1); //first sequence point;
    while(c!=None)
    {
        if (c==None)continue;
        if (c.cmd==CAMCMD_MOVE && c.timeSmooth<=0){
            if (scenes[numScenes].numCams>0){
                numScenes++;
            }
        }
        scenes[numScenes].cams[scenes[numScenes].numCams++]=c;
        if (c.IsInState('Running')){
            c.GoToSleep(); //Take the active camera point out of action
        }
        c = GetNextCameraPoint(c.sequenceNum);
    }

    //This is purely for debug purposes
    //Dump all the CameraPoint's in sequence num order, grouped by scene
    /*
    for (i=0;i<ArrayCount(scenes);i++)
    {
        if (scenes[i].numCams==0) continue;
        l("Scene "$i);
        for(j=0;j<ArrayCount(scenes[i].cams);j++){
            if (scenes[i].cams[j]==None) continue;
            c=scenes[i].cams[j];
            l("    CameraPoint "$c$"  SequenceNum "$c.sequenceNum$"  Cmd: "$string(GetEnum(enum'ECameraCommand',c.cmd))$"  timeSmooth: "$c.timeSmooth$"  timeWaitPost: "$c.timeWaitPost);
        }
        l("    ");
    }
    */
    //End of debug

    //Put the scene numbers in a list
    for (i=0;i<ArrayCount(scenes);i++){
        if (scenes[i].numCams>0){
            sceneList[i]=i;
        } else {
            sceneList[i]=-1;
        }
    }

    //Shuffle the scene order (Skip the final scenes, as appropriate)
    for (i=numScenes-scenesToSkip;i>=0;i--){
        if(IsAprilFools() || chance_single(20)) {
            slot = rng(i+1);
            temp = sceneList[i];
            sceneList[i] = sceneList[slot];
            sceneList[slot] = temp;
        }
    }

    //Debug info
    //Dump the newly randomized order of the scenes
    /*
    l("Scene order:");
    for (i=0;i<ArrayCount(sceneList);i++){
        if (sceneList[i]>=0){
            l("Scene "$i$":  "$sceneList[i]);
        }
    }
    */
    //End of debug

    //Actually connect the camera points in the new order
    //Sadly, SequenceNum is a const, so we have to manually construct the links
    //ourselves so that it's linked the right way.
    for (i=0;i<ArrayCount(sceneList);i++){
        if (sceneList[i]<0) continue;
        if (scenes[sceneList[i]].numCams<=0) continue;
        for (j=0;j<ArrayCount(scenes[sceneList[i]].cams);j++){
            c = scenes[sceneList[i]].cams[j];
            if (c==None) continue;
            if (firstCam==None) firstCam = c;

            //Rig the camera list together (Typically this would be done by sequenceNum, but that's a const)
            if (prevCam!=None){
                prevCam.nextPoint=c;
            }
            prevCam = c;
            //l("CameraPoint "$c$"  SequenceNum "$c.sequenceNum$"  Cmd: "$string(GetEnum(enum'ECameraCommand',c.cmd))$"  timeSmooth: "$c.timeSmooth$"  timeWaitPost: "$c.timeWaitPost);
        }
    }
    if (c!=None){
        c.nextPoint=None; //Remove the link to the next camera on the final camera point
    }

    //Send the first cam straight to running, under the assumption that the player has already been initialized
    firstCam.GoToState('Running');
}

function bool IsCutsceneCharacter(#var(prefix)ScriptedPawn sp)
{
    switch(sp.BindName){
        case "BobPage": //Intro, Endgame1, Endgame2
        case "WaltonSimons": //Intro
        case "FemaleComputer"://Endgame1
        case "TracerTong"://Endgame1
        case "Helios"://Endgame1, Endgame2
        case "JCDouble"://Endgame2, Endgame3
        case "MorganEverett"://Endgame3
            return true;

        default: //Everyone else
            return false;
    }
}

function RandomizeCutscene()
{
    local Actor a;
    local #var(prefix)Tree t;
    local class<Actor> old_skips[6];
    local int i;
    local #var(prefix)ScriptedPawn sp;
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
    _skipactor_types[i++] = class'Earth';
#ifdef revision
    _skipactor_types[i++] = class<Actor>(DynamicLoadObject("RevisionDeco.Rev_SphereLight", class'class'));
#endif
    SwapAll("Engine.Actor", 20);

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
        if( Earth(a) != None ) continue;
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

        //Make people vincible
        if (#var(prefix)ScriptedPawn(a)!=None) {
            sp=#var(prefix)ScriptedPawn(a);
            //Talking people in cutscenes are invincible, everyone else isn't
            sp.bInvincible=IsCutsceneCharacter(sp);
        }
    }

    RandomizeZones();
    MakeTubeContentsFloat();

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
    RandomMJ12Globe();

    RandomizeDialog();

    RandomizeCutsceneOrder();
    ForceIntroFight();
}

function RandomizeZones()
{
    local ZoneInfo z;
    local bool water, ice, lowgrav, floataway;
    local int i;

    if(!IsAprilFools() && !chance_single(10)) return;

    switch(rng(3)) {
        case 0: water=true; break;
        case 1: ice=true; break;
        case 2: lowgrav=true; break;
    }

    foreach AllActors(class'ZoneInfo', z) {
        if(water) {
            z.bWaterZone = true;
            z.ViewFog=vect(0,0.05,0.1);
            z.AmbientSound=Sound'Ambient.Ambient.Underwater';
        }
        if(ice) {
            z.ZoneGroundFriction = 0.1;
        }
        if(lowgrav) {
            z.ZoneGravity = vect(0,0,-300);
        }
        if(floataway) { // not great? causes outdoor areas to be kinda empty looking
            z.ZoneGravity = vect(0,0,0.05);
        }
    }

    if(water) {
        for(i=0; i<20; i++) {
            Spawn(class'#var(prefix)FishGenerator',,, GetRandomPositionFine(,,,true));
            Spawn(class'#var(prefix)Fish2Generator',,, GetRandomPositionFine(,,,true));
        }
    }
}

function MakeTubeContentsFloat()
{
    local bool RevisionMaps;
    local vector TubeLoc;
    local rotator TubeRot;
    local float widthScale,heightScale;
    local int RotOffset;
    local Actor a;

    switch(dxr.localURL)
    {
        case "INTRO":
            break;
        default:
            return;
    }

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    if (RevisionMaps){
        TubeLoc = vectm(-9889,-8523,-5136);
        TubeRot = rot(0,8992,0);
    } else {
        TubeLoc = vectm(-11088,-8577,-5048);
        TubeRot = rot(0,16304,0);
    }

    foreach RadiusActors(class'Actor',a,50,TubeLoc){
        if (a.bHidden) continue;
        a.SetPhysics(PHYS_None);
        widthScale = class'#var(prefix)DentonClone'.default.CollisionRadius / a.Default.CollisionRadius;
        heightScale = class'#var(prefix)DentonClone'.default.CollisionHeight / a.Default.CollisionHeight;
        a.DrawScale = FMin(widthScale,heightScale); //Don't use SetActorScale, because that works from the existing scale
        a.SetLocation(TubeLoc);

        //Rotation should get updated to account for RotationOffset
        RotOffset = GetRotationOffset(a.Class);
        TubeRot = rotm(TubeRot.Pitch,TubeRot.Yaw-RotOffset,TubeRot.Roll,RotOffset);
        a.SetRotation(TubeRot);
    }

}

function ForceIntroFight()
{
    local #var(prefix)ScriptedPawn sp;
    local bool RevisionMaps;
    local int i, loc1, loc2;

    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(player());

    switch(dxr.localURL)
    {
        case "INTRO":
            break;
        default:
            return;
    }

    //Make everyone friends first
    foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
        sp.SetAlliance('Fwends');
    }

    SetSeed("ForceIntroFight");

    loc1 = rng(4); //Run this first to keep most scenarios the same as before
    i = rng(100);

    if (i==0 || dxr.IsAprilFools()) {
        //1% chance, or April Fools
        //Combat everywhere
        for (i=0;i<4;i++){
            CreateIntroFightArena(i,RevisionMaps);
        }
    } else if (i<10){
        //9% chance
        //Combat in 2 areas
        loc2 = (loc1 + 1 + rng(3)) %4;

        CreateIntroFightArena(loc1, RevisionMaps);
        CreateIntroFightArena(loc2, RevisionMaps);
    } else {
        //90% chance
        //Combat in 1 area
        CreateIntroFightArena(loc1, RevisionMaps);
    }


}

function CreateIntroFightArena(int loc, bool RevisionMaps)
{
    local vector FightLoc;
    local float  FightRad;
    local #var(prefix)ScriptedPawn sp;
    local bool whichAlliance;
    local DXREnemies enemies;

    //Stage Select
    switch (loc){
        case 0:
            //Paris (The vanilla arena)
            //Same location in Revision
            l("CreateIntroFightArena: Starting fight in Paris");
            FightLoc = vectm(11111,-16050,-200);
            FightRad = 1500;
            break;
        case 1:
            //Statue of Liberty Meeting
            //Same location in Revision
            l("CreateIntroFightArena: Starting fight at Statue of Liberty");
            FightLoc = vectm(-11150,12675,600);
            FightRad = 1500;
            break;
        case 2:
            //Free Clinic
            //Same location in Revision
            l("CreateIntroFightArena: Starting fight at Free Clinic");
            FightLoc = vectm(500,-6600,-50);
            FightRad = 1500;
            break;
        case 3:
            //MJ12 Lab
            l("CreateIntroFightArena: Starting fight at MJ12 Lab");
            if (RevisionMaps){
                FightLoc = vectm(7900,-7500,-100);
            } else {
                FightLoc = vectm(5500,-6000,0);
            }
            FightRad = 1500;
            break;
    }

    enemies = DXREnemies(class'DXREnemies'.static.Find());

    //Force them to fight for our amusement
    foreach RadiusActors(class'#var(prefix)ScriptedPawn',sp,FightRad,FightLoc) {
        //Don't touch people who talk during the intro
        if (!IsCutsceneCharacter(sp)){
            if (whichAlliance){
                sp.SetAlliance('FightGroup1');
                sp.ChangeAlly('FightGroup2',-1,true);
            } else {
                sp.SetAlliance('FightGroup2');
                sp.ChangeAlly('FightGroup1',-1,true);
            }
            sp.ChangeAlly('Fwends',1,true);
            whichAlliance = !whichAlliance;

            //Give weapon
            if (enemies!=None){
                enemies.GiveRandomWeapon(sp,false,999);
            }

            sp.SetPhysics(PHYS_Falling);
        }

    }
}

function MakeAllGhosts()
{
    local #var(prefix)ScriptedPawn p;
    local bool isEndgame4;

    if(!IsOctober()) return;

    if(dxr.localURL~="ENDGAME4" || dxr.localURL~="ENDGAME4REV") {
        isEndgame4 = true;
        GotoState('JumpInTheLine');
    }

    foreach AllActors(class'#var(prefix)ScriptedPawn', p) {
        if(#var(prefix)Robot(p) != None) continue;
        if(DXRStalker(p) != None) continue;
        class'DXRHalloween'.static.MakeGhost(p);
        if(isEndgame4) {
            p.SetPhysics(PHYS_None);
            p.SetCollision(false,false,false);
            p.SetLocation(p.Location+vect(0,0,8));// raise them by half a foot?
            Level.Game.SetGameSpeed(0.5);
        }
    }
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
    local ConSpeech speech[100];
    local ConEventSpeech ces;
    local int i, j, num, soundID;
    local string subtitle, strConName;
    local bool checkGender;
    local bool isFemale,femConv;
    //local Conversation conv;

    switch(dxr.localURL){
        case "INTRO":
            //Player never speaks in the intro, so there isn't a FemJC variant to look for
            checkGender=false;
            break;
        case "ENDGAME1":
        case "ENDGAME2":
        case "ENDGAME3":
        case "ENDGAME4":
        case "ENDGAME4REV":
            //Endgame variants have JC speaking, so only randomize within the set of conversations for the player gender
            checkGender=true;
            isFemale=player().FlagBase.GetBool('LDDPJCIsFemale');
            break;
        default:
            return; //What else is there?
    }

    SetSeed("RandomizeDialog");
    foreach AllObjects(class'ConEventSpeech', ces) {
        if (checkGender){
            strConName=String(ces.conversation.conName);
            femConv = (InStr(strConName,"FemJC")!=-1);

            if (isFemale!=femConv) continue;
        }
        speech[num++] = ces.conSpeech;
    }

    for(i=0;i<num;i++) {
        if(chance_single(10)) {
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

static function float GetVoicePitch(DXRando dxr){
    if (dxr.IsAprilFools()){
        if ((dxr.seed)%10>=5){
            return 1.5;
        } else {
            return 0.75;
        }
    }
    return 1.0;
}

function AddDXRCredits(CreditsWindow cw)
{
    if(IsAprilFools()) {
        cw.PrintLn();
        cw.PrintHeader("APRIL FOOLS!");
        cw.PrintLn();
        cw.PrintLn();
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

    l( "if ( r == i++ ) return class'" $ s $ "';" );
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
        if(newActorClass == "") {
            err("GetRandomActorClass() got empty string");
            continue;
        }
        l(old$" replaced with "$newActorClass);
        a = ReplaceActor(old, newActorClass );
        if (a!=None && a.LifeSpan > 0){
            a.LifeSpan=MaxInt;  //Please don't leave the menu open for over 60 years
        }
        if(#var(injectsprefix)MedicalBot(a) != None && chance_single(50)) {
            #var(injectsprefix)MedicalBot(a).MakeAugsOnly();
        }
        if(DXRJackOLantern(a) != None) {
            a.SetRotation(rot(0, 16384, 0));
            a.DrawScale *= 4;
        }
        if( a != None ) return a;
    }
    warning("ReplaceWithRandomClass("$old$") failed");
    return None;
}

const num_random_actor_classes = 555;

function string GetRandomActorClass()
{
    local string s;

    s = _GetRandomActorClass(rng(num_random_actor_classes));

    if(s=="") return "";
    if(InStr(s, ".") != -1) return s;
#ifdef hx
    return "HX.HX" $ s;
#else
    return "DeusEx." $ s;
#endif
}


function ExtendedTests()
{
    local int r;
    local string s;

    Super.ExtendedTests();

    r = num_random_actor_classes;
    s = _GetRandomActorClass(r);
    teststring(s, "", "_GetRandomActorClass(" $ r $ ") is empty string, " $ s);

    r--;
    s = _GetRandomActorClass(r);
    test(s!="", "_GetRandomActorClass(" $ r $ ") is not empty string, " $ s);

    s = _GetRandomActorClass(0);
    test(s!="", "_GetRandomActorClass(0) is not empty string, " $ s);
}

function string _GetRandomActorClass(int r)
{
    local int i;

    // DXRando classes
    if(r==i++) return "#var(package).MrH";
    if(r==i++) return "#var(package).WeepingAnna";
    if(r==i++) return "#var(package).Bobby";
    //if(r=i++) return "#var(package).Spiderweb"; // doesn't look good
    if(r==i++) return "#var(package).DXRJackOLantern";
    if(r==i++) return "#var(package).DeathMarker";
    if(r==i++) return "#var(package).BarDancer";
    if(r==i++) return "#var(package).FrenchGray";
    if(r==i++) return "#var(package).FrenchGrayCarcass";
    if(r==i++) return "#var(package).LeMerchantCarcass";
    if(r==i++) return "#var(package).MJ12Clone1";
    if(r==i++) return "#var(package).MJ12Clone1Carcass";
    if(r==i++) return "#var(package).MJ12Clone2";
    if(r==i++) return "#var(package).MJ12Clone2Carcass";
    if(r==i++) return "#var(package).MJ12Clone3";
    if(r==i++) return "#var(package).MJ12Clone3Carcass";
    if(r==i++) return "#var(package).MJ12Clone4";
    if(r==i++) return "#var(package).MJ12Clone4Carcass";
    if(r==i++) return "#var(package).MJ12CloneAugShield1";
    if(r==i++) return "#var(package).MJ12CloneAugShield1Carcass";
    if(r==i++) return "#var(package).MJ12CloneAugShield1NametagCarcass";
    if(r==i++) return "#var(package).MJ12CloneAugStealth1";
    if(r==i++) return "#var(package).MJ12CloneAugStealth1Carcass";
    if(r==i++) return "#var(package).MJ12CloneAugStealth1NametagCarcass";
    if(r==i++) return "#var(package).MJ12CloneAugTough1";
    if(r==i++) return "#var(package).MJ12CloneAugTough1Carcass";
    if(r==i++) return "#var(package).MJ12CloneAugTough1NametagCarcass";
    if(r==i++) return "#var(package).NSFClone1";
    if(r==i++) return "#var(package).NSFClone1Carcass";
    if(r==i++) return "#var(package).NSFClone2";
    if(r==i++) return "#var(package).NSFClone2Carcass";
    if(r==i++) return "#var(package).NSFClone3";
    if(r==i++) return "#var(package).NSFClone3Carcass";
    if(r==i++) return "#var(package).NSFClone4";
    if(r==i++) return "#var(package).NSFClone4Carcass";
    if(r==i++) return "#var(package).NSFCloneAugShield1";
    if(r==i++) return "#var(package).NSFCloneAugShield1Carcass";
    if(r==i++) return "#var(package).NSFCloneAugShield1NametagCarcass";
    if(r==i++) return "#var(package).NSFCloneAugStealth1";
    if(r==i++) return "#var(package).NSFCloneAugStealth1Carcass";
    if(r==i++) return "#var(package).NSFCloneAugStealth1NametagCarcass";
    if(r==i++) return "#var(package).NSFCloneAugTough1";
    if(r==i++) return "#var(package).NSFCloneAugTough1Carcass";
    if(r==i++) return "#var(package).NSFCloneAugTough1NametagCarcass";
    if(r==i++) return "#var(package).UNATCOClone1";
    if(r==i++) return "#var(package).UNATCOClone1Carcass";
    if(r==i++) return "#var(package).UNATCOClone2";
    if(r==i++) return "#var(package).UNATCOClone2Carcass";
    if(r==i++) return "#var(package).UNATCOClone3";
    if(r==i++) return "#var(package).UNATCOClone3Carcass";
    if(r==i++) return "#var(package).UNATCOClone4";
    if(r==i++) return "#var(package).UNATCOClone4Carcass";
    if(r==i++) return "#var(package).UNATCOCloneAugShield1";
    if(r==i++) return "#var(package).UNATCOCloneAugShield1Carcass";
    if(r==i++) return "#var(package).UNATCOCloneAugShield1NametagCarcass";
    if(r==i++) return "#var(package).UNATCOCloneAugStealth1";
    if(r==i++) return "#var(package).UNATCOCloneAugStealth1Carcass";
    if(r==i++) return "#var(package).UNATCOCloneAugStealth1NametagCarcass";
    if(r==i++) return "#var(package).UNATCOCloneAugTough1";
    if(r==i++) return "#var(package).UNATCOCloneAugTough1Carcass";
    if(r==i++) return "#var(package).UNATCOCloneAugTough1NametagCarcass";
    // medbot class twice, with 50% chance to be an augbot
    if(r==i++) return "#var(package).#var(injectsprefix)MedicalBot";
    if(r==i++) return "#var(package).#var(injectsprefix)MedicalBot";
    if(r==i++) return "#var(package).NervousWorker";
    if(r==i++) return "#var(package).NervousWorkerCarcass";
    if(r==i++) return "#var(package).LeMerchant";
    if(r==i++) return "#var(package).EnergyDrinkCan";
    if(r==i++) return "#var(package).VendingMachineEnergy";

    // vanilla classes
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
    //if ( r == i++ ) return "EMPGrenade";
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
    //if ( r == i++ ) return "GasGrenade";
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
    //if ( r == i++ ) return "NanoVirusGrenade";
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
    //if ( r == i++ ) return "PlasmaBolt";
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
    //if ( r == i++ ) return "Rockchip";
    //if ( r == i++ ) return "Rocket";
    //if ( r == i++ ) return "RocketLAW";
    //if ( r == i++ ) return "RocketMini";
    //if ( r == i++ ) return "RocketRobot";
    //if ( r == i++ ) return "RocketWP";
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

    return "";
}
