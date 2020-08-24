class DXRFixup expands DXRBase;

function FirstEntry()
{
    local Actor a;
    local ScriptedPawn p;

    Super.FirstEntry();
    
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

function AnyEntry()
{
    Super.AnyEntry();
    
    doFixup();
    
}

function ReEntry()
{
    Super.ReEntry();
    doFixup();
}

function doFixup()
{
    local Actor a;
    local ScriptedPawn p;
    local name flagName;
    local bool boolFlag;
    
    switch(dxr.localURL)
    {
        case "06_HONGKONG_TONGBASE":
            flagName = dxr.Player.rootWindow.StringToName("QuickLetPlayerIn");
            boolFlag = dxr.Player.flagBase.GetBool(flagName);
            foreach AllActors(class'Actor', a)
            {
                switch(string(a.Tag))
                {
                    case "TriadLumPath":
                        ScriptedPawn(a).ChangeAlly(dxr.Player.Alliance,1,False);
                        break;
                        
                    case "TracerTong":
                    case "AlexJacobson":
                    case "JaimeReyes":                        
                        if ( boolFlag == True )
                        {
                            ScriptedPawn(a).bInWorld=True;
                            a.bHidden = False;
                            a.bBlockPlayers = True;
                            a.BindName = string(a.Tag);  //Re-enables conversations with them.
                            l("BindName reset to "$a.BindName);
                            ScriptedPawn(a).ConBindEvents();                        
                        } else {
                            ScriptedPawn(a).bInWorld=False;
                            a.bHidden = True;
                            a.bBlockPlayers = False;
                            l("BindName was "$a.BindName);
                            a.BindName = "";  //Disables conversations with them.
                        }
                        break;
                    case "Operation1":
                        DataLinkTrigger(a).checkFlag = flagName;
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

defaultproperties
{
}
