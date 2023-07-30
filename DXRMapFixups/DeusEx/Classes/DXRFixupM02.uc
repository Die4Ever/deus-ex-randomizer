class DXRFixupM02 extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local BarrelAmbrosia ambrosia;
    local Trigger t;
    local NYPoliceBoat b;
    local DeusExMover d;
    local #var(prefix)NanoKey k;
    local CrateExplosiveSmall c;
    local Terrorist nsf;
#ifdef injections
    local #var(prefix)Newspaper np;
    local class<#var(prefix)Newspaper> npClass;
    npClass = class'#var(prefix)Newspaper';
#else
    local DXRInformationDevices np;
    local class<DXRInformationDevices> npClass;
    npClass = class'DXRInformationDevices';
#endif

    switch (dxr.localURL)
    {
#ifdef vanillamaps
    case "02_NYC_BATTERYPARK":
        foreach AllActors(class'BarrelAmbrosia', ambrosia) {
            foreach RadiusActors(class'Trigger', t, 16, ambrosia.Location) {
                if(t.CollisionRadius < 100)
                    t.SetCollisionSize(t.CollisionRadius*2, t.CollisionHeight*2);
            }
        }
        foreach AllActors(class'NYPoliceBoat',b) {
            b.BindName = "NYPoliceBoat";
            b.ConBindEvents();
        }
        foreach AllActors(class'DeusExMover', d) {
            if( d.Name == 'DeusExMover19' ) {
                d.KeyIDNeeded = 'ControlRoomDoor';
            }
        }
        foreach AllActors(class'Terrorist',nsf,'ShantyTerrorist'){
            nsf.Tag = 'ShantyTerrorists';  //Restores voice lines when NSF still alive (still hard to have happen though)
        }
        k = Spawn(class'#var(prefix)NanoKey',,, vectm(1574.209839, -238.380142, 339.215179));
        k.KeyID = 'ControlRoomDoor';
        k.Description = "Control Room Door Key";
        if(dxr.flags.settings.keysrando > 0)
            GlowUp(k);
        break;
    case "02_NYC_WAREHOUSE":
        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(1700.929810,-519.988037,57.729870),rotm(0,0,0),'02_Newspaper06'); //Table in room next to break room (near bathrooms)
        npClass.static.SpawnInfoDevice(self,class'#var(prefix)NewspaperOpen',vectm(-1727.644775,2479.614990,1745.724976),rotm(0,0,0),'02_Newspaper06'); //Next to apartment(?) door on rooftops, near elevator

        class'PlaceholderEnemy'.static.Create(self,vectm(782,-1452,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(1508,-1373,256));
        class'PlaceholderEnemy'.static.Create(self,vectm(1814,-1842,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(-31,-1485,48));
        class'PlaceholderEnemy'.static.Create(self,vectm(1121,-1095,-144));
        class'PlaceholderEnemy'.static.Create(self,vectm(467,-214,-144));
        break;
    case "02_NYC_HOTEL":
        Spawn(class'#var(prefix)Binoculars',,, vectm(-610.374573,-3221.998779,94.160065)); //Paul's bedside table
        break;
#endif

    case "02_NYC_STREET":
#ifdef revision
        foreach AllActors(class'CrateExplosiveSmall', c) {
            l("hiding " $ c @ c.Tag @ c.Event);
            c.bHidden = true;// hide it so DXRSwapItems doesn't move it, this is supposed to be inside the plane that flies overhead
        }
#endif
        foreach AllActors(class'DeusExMover', d, 'AugStore') {
            d.bFrobbable = true;
        }
        break;
    }
}

function PostFirstEntryMapFixes()
{
    switch(dxr.localURL) {
    case "02_NYC_WAREHOUSE":
        if(!#defined(revision)) {
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(183.993530, 926.125000, 1162.103271));// apartment
            AddBox(class'#var(prefix)CrateUnbreakableMed', vectm(-389.361969, 744.039978, 1088.083618));// ladder
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vectm(-328.287048, 767.875000, 1072.113770));
        }

        // this map is too hard
        Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)AdaptiveArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());

        break;
    }
}
