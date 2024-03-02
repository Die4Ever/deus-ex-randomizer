class DXRFixupM08 extends DXRFixup;

function AnyEntryMapFixes()
{
    local StantonDowd s;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    Super.AnyEntryMapFixes();

    switch(dxr.localURL) {
    case "08_NYC_STREET":
        SetTimer(1.0, True);
        foreach AllActors(class'StantonDowd', s) {
            RemoveReactions(s);
        }
        Player().StartDataLinkTransmission("DL_Entry");
        break;

    case "08_NYC_SMUG":
        if (VanillaMaps){
            FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        }
        break;
    }
}

function TimerMapFixes()
{
    local BlackHelicopter chopper;
    local bool VanillaMaps;

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
    case "08_NYC_STREET":
        if (VanillaMaps && dxr.flagbase.GetBool('StantonDowd_Played') )
        {
            foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                chopper.EnterWorld();
            dxr.flagbase.SetBool('MS_Helicopter_Unhidden', True,, 9);
        }
        break;
    }
}

function PreFirstEntryMapFixes()
{
    local DataLinkTrigger dlt;
    local #var(prefix)NanoKey k;
    local #var(prefix)PigeonGenerator pg;
    local #var(prefix)MapExit exit;
    local #var(prefix)BlackHelicopter jock;
    local DXRHoverHint hoverHint;
    local bool VanillaMaps;

#ifdef injections
    local #var(prefix)Newspaper np;
    local class<#var(prefix)Newspaper> npClass;
    npClass = class'#var(prefix)Newspaper';
#else
    local DXRInformationDevices np;
    local class<DXRInformationDevices> npClass;
    npClass = class'DXRInformationDevices';
#endif

    VanillaMaps = class'DXRMapVariants'.static.IsVanillaMaps(player());

    switch(dxr.localURL)
    {
        case "08_NYC_STREET":
            //Since we always spawn the helicopter on the roof immediately after the conversation,
            //the ambush should also always happen immediately after the conversation (instead of
            //after getting explosives)
            foreach AllActors(class'DataLinkTrigger',dlt)
            {
                if (dlt.CheckFlag=='PlayerHasExplosives'){
                    dlt.CheckFlag='StantonDowd_Played';
                }
            }

            pg=Spawn(class'#var(prefix)PigeonGenerator',,, vectm(-2102,1942,-503));//In park
            pg.MaxCount=3;

            //Add teleporter hint text to Jock
            foreach AllActors(class'#var(prefix)MapExit',exit){break;}
            foreach AllActors(class'#var(prefix)BlackHelicopter',jock){break;}
            hoverHint = class'DXRTeleporterHoverHint'.static.Create(self, "", jock.Location, jock.CollisionRadius+5, jock.CollisionHeight+5, exit.Name);
            hoverHint.SetBaseActor(jock);

            break;
        case "08_NYC_HOTEL":
            if (VanillaMaps){
                Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table
                SpawnDatacubeTextTag(vectm(-840,-2920,85), rotm(0,0,0), '02_Datacube07',False); //Paul's stash code, in closet

                k = Spawn(class'#var(prefix)NanoKey',,, vectm(-967,-1240,-74));
                k.KeyID = 'CrackRoom';
                k.Description = "'Ton Hotel, North Room Key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(k);

                k = Spawn(class'#var(prefix)NanoKey',,, vectm(-845,-2920,180));
                k.KeyID = 'Apartment';
                k.Description = "Apartment key";
                if(dxr.flags.settings.keysrando > 0)
                    GlowUp(k);


                Spawn(class'PlaceholderItem',,, vectm(-732,-2628,75)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(-732,-2712,75)); //Actual closet
                Spawn(class'PlaceholderItem',,, vectm(-129,-3038,127)); //Bathroom counter
                Spawn(class'PlaceholderItem',,, vectm(15,-2972,123)); //Kitchen counter
                Spawn(class'PlaceholderItem',,, vectm(-853,-3148,75)); //Crack next to Paul's bed
            }
            break;
        case "08_NYC_BAR":
            npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1171.976440,250.575806,53.729687),rotm(0,0,0),'08_Newspaper01'); //Joe Greene article, table near where Harley is in Vanilla
            Spawn(class'BarDancer',,,vectm(-2150,-500,48),rotm(0,0,0));

            break;
    }
}
