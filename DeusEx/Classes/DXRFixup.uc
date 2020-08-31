class DXRFixup expands DXRBase;

function FirstEntry()
{
    Super.FirstEntry();
    l( "mission " $ dxr.dxInfo.missionNumber $ " FirstEntry()");

    Level.AmbientBrightness += dxr.flags.brightness;
    
    if( dxr.dxInfo.missionNumber == 6 )
        HongKong_FirstEntry();
    else if( dxr.dxInfo.missionNumber == 12 )
        Vandenberg_FirstEntry();
}

function AnyEntry()
{
    Super.AnyEntry();
    l( "mission " $ dxr.dxInfo.missionNumber $ " AnyEntry()");

    FixUnbreakableCrates();

    if (dxr.dxInfo.missionNumber == -1 || dxr.dxInfo.missionNumber==-2)
        Intro_AnyEntry();
    else if( dxr.dxInfo.missionNumber == 6 )
        HongKong_AnyEntry();
}

function FixUnbreakableCrates()
{
    local CrateUnbreakableLarge c;
    foreach AllActors(class'CrateUnbreakableLarge', c) {
        if( c.bInvincible ) {
            c.bInvincible = False;
            c.HitPoints = 2000;
        }
    }
}

function Vandenberg_FirstEntry()
{
    local ElevatorMover e;
    local Button1 b;
    local Dispatcher d;
    local LogicTrigger lt;

    switch(dxr.localURL)
    {
        case "12_VANDENBERG_CMD":
            foreach AllActors(class'Dispatcher', d)
            {
                switch(d.Tag)
                {
                    case 'overload2':
                        d.tag = 'overload2disp';
                        lt = Spawn(class'LogicTrigger',,,d.Location);
                        lt.Tag = 'overload2';
                        lt.Event = 'overload2disp';
                        lt.inGroup1 = 'sec_switch2';
                        lt.inGroup2 = 'sec_switch2';
                        lt.OneShot = True;
                        break;
                    case 'overload1':
                        d.tag = 'overload1disp';
                        lt = Spawn(class'LogicTrigger',,,d.Location);
                        lt.Tag = 'overload1';
                        lt.Event = 'overload1disp';
                        lt.inGroup1 = 'sec_switch1';
                        lt.inGroup2 = 'sec_switch1';
                        lt.OneShot = True;
                        break;
                }
            }
            break;
        case "12_VANDENBERG_TUNNELS":
            foreach AllActors(class'ElevatorMover', e, 'Security_door3') {
                e.BumpType = BT_PlayerBump;
                e.BumpEvent = 'SC_Door3_opened';
            }
            foreach AllActors(class'Button1', b) {
                if( b.Event == 'Top' || b.Event == 'middle' || b.Event == 'Bottom' ) {
                    AddDelay(b, 5);
                }
            }
            break;
    }
}

function HongKong_FirstEntry()
{
    local Actor a;
    local ScriptedPawn p;

    switch(dxr.localURL)
    {
        case "06_HONGKONG_TONGBASE":
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "AlexGone":
                    case "TracerGone":
                    case "JaimeGone":
                        a.Destroy();
                        break;
                    case "Breakintocompound":
                    case "LumpathPissed":
                        Trigger(a).bTriggerOnceOnly = False;
                        break;
                    default:
                        break;
                }
            }    
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "DummyKeypad01":
                        a.Destroy();
                        break;
                    case "BasementKeypad":
                    case "GateKeypad":
                        a.bHidden=False;
                        break;    
                    case "Breakintocompound":
                    case "LumpathPissed":
                        Trigger(a).bTriggerOnceOnly = False;
                        break;
                    default:
                        break;
                }
            }
            
            break;
        default:
            break;
    }
}


//Not every Actor seems to actually rotate, so I've handpicked
//a selection of fun items to replace the logo
function class<Actor> RandomLogoItem()
{
    local int r;
    local class<Actor> newclass;
    
    r = initchance();

    if( chance(5,r) ) newclass = class'Van';
    if( chance(5,r) ) newclass = class'DentonClone';
    if( chance(5,r) ) newclass = class'LuciusDeBeers';
    if( chance(5,r) ) newclass = class'RoadBlock';
    if( chance(5,r) ) newclass = class'Trophy';
    if( chance(5,r) ) newclass = class'Toilet';
    if( chance(5,r) ) newclass = class'AttackHelicopter';
    if( chance(5,r) ) newclass = class'MiniSub';
    if( chance(5,r) ) newclass = class'Trashbag';
    if( chance(5,r) ) newclass = class'HKBuddha';
    if( chance(5,r) ) newclass = class'ChairLeather';
    if( chance(5,r) ) newclass = class'Mailbox';
    if( chance(5,r) ) newclass = class'TrashCan1';
    if( chance(5,r) ) newclass = class'JCDentonMaleCarcass';
    if( chance(5,r) ) newclass = class'Flask';
    if( chance(5,r) ) newclass = class'Tree1';
    if( chance(5,r) ) newclass = class'BarrelAmbrosia';
    if( chance(5,r) ) newclass = class'KarkianCarcass';
    if( chance(5,r) ) newclass = class'VendingMachine';
    if( chance(5,r) ) newclass = class'BobPageAugmented';
    
    
    return newclass;
}

function Intro_AnyEntry()
{
    local DXLogo logo;
    local ElectricityEmitter elec;
    local Actor a;
    local Rotator r;
    local Vector v;
    local float scalefactor;
    local float largestDim;
    
    l("Intro AnyEntry()");
    

    switch(dxr.localURL)
    {
        case "DXONLY":
        case "DX":
            l("Map is "$ dxr.localURL);
            foreach AllActors(class'DXLogo', logo)
            {
                a = Spawn(RandomLogoItem(),,,logo.Location);
                
                //Get it spinning just right
                a.SetPhysics(PHYS_Rotating);
                a.bFixedRotationDir = True;
                a.bRotateToDesired = False;
                r.Pitch = 2500;
                r.Yaw = 5000;
                r.Roll = 0;
                a.RotationRate = r;
                
                //Get the scaling to match
                if (a.CollisionRadius > a.CollisionHeight) {
                    largestDim = a.CollisionRadius;
                } else {
                    largestDim = a.CollisionHeight;
                }
                scalefactor = logo.CollisionHeight/largestDim;
                a.DrawScale = scalefactor;
                
                
                //Get it at the right height
                v.Z = -(a.CollisionHeight/2);
                a.move(v);
                
                //Get rid of any ambient sounds it may make
                a.AmbientSound = None;
                
                logo.Destroy();
            }
            
            foreach AllActors(class'ElectricityEmitter', elec)
            {
                v.Z = 60;
                elec.move(v);
            }
        break;
    }
}

function HongKong_AnyEntry()
{
    local Actor a;
    local ScriptedPawn p;
    local bool boolFlag;
    local bool recruitedFlag;

    switch(dxr.localURL)
    {
        case "06_HONGKONG_TONGBASE":
            boolFlag = dxr.Player.flagBase.GetBool('QuickLetPlayerIn');
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "TriadLumPath":
                        ScriptedPawn(a).ChangeAlly(dxr.Player.Alliance,1,False);
                        break;
                        
                    case "TracerTong":                      
                        if ( boolFlag == True )
                        {
                            ScriptedPawn(a).EnterWorld();                    
                        } else {
                            ScriptedPawn(a).LeaveWorld();
                        }
                        break;
                    case "AlexJacobson":
                        recruitedFlag = dxr.Player.flagBase.GetBool('JacobsonRecruited');
                        if ( boolFlag == True && recruitedFlag == True)
                        {
                            ScriptedPawn(a).EnterWorld();                    
                        } else {
                            ScriptedPawn(a).LeaveWorld();
                        }
                        break;
                    case "JaimeReyes":
                        recruitedFlag = dxr.Player.flagBase.GetBool('JaimeRecruited');
                        if ( boolFlag == True && recruitedFlag == True)
                        {
                            ScriptedPawn(a).EnterWorld();                    
                        } else {
                            ScriptedPawn(a).LeaveWorld();
                        }
                        break;
                    case "Operation1":
                        DataLinkTrigger(a).checkFlag = 'QuickLetPlayerIn';
                        break;
                    case "TurnOnTheKillSwitch":
                        if (boolFlag == True)
                        {
                            Trigger(a).TriggerType = TT_PlayerProximity;                        
                        } else {
                            Trigger(a).TriggerType = TT_ClassProximity;
                            Trigger(a).ClassProximityType = class'Teleporter';//Impossible, thus disabling it
                        }
                        break;
                    default:
                        break;
                }
            }    
            break;
        case "06_HONGKONG_WANCHAI_MARKET":
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "TriadLumPath":
                    case "TriadLumPath1":
                    case "TriadLumPath2":
                    case "TriadLumPath3":
                    case "TriadLumPath4":
                    case "TriadLumPath5":
                    case "GordonQuick":
                    
                        ScriptedPawn(a).ChangeAlly(dxr.Player.Alliance,1,False);
                        break;
                }
            }

            break;
        default:
            break;
    }
}

function AddDelay(Actor trigger, float time)
{
    local Dispatcher d;
    local name tagname;
    tagname = dxr.Player.rootWindow.StringToName( "dxr_delay_" $ trigger.Event );
    d = Spawn(class'Dispatcher', trigger, tagname);
    d.OutEvents[0] = trigger.Event;
    d.OutDelays[0] = time;
    trigger.Event = d.Tag;
}

defaultproperties
{
}
