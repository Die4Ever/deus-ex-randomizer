class DXRFixupM02 extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local BarrelAmbrosia ambrosia;
    local Trigger t;
    local NYPoliceBoat b;
    local DeusExMover d;
    local #var(prefix)NanoKey k;
    local CrateExplosiveSmall c;

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
        k = Spawn(class'#var(prefix)NanoKey',,, vect(1574.209839, -238.380142, 339.215179));
        k.KeyID = 'ControlRoomDoor';
        k.Description = "Control Room Door Key";
        break;
    case "02_NYC_WAREHOUSE":
        class'PlaceholderEnemy'.static.Create(self,vect(782,-1452,48),rot(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vect(1508,-1373,256),rot(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vect(1814,-1842,48),rot(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vect(-31,-1485,48),rot(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vect(1121,-1095,-144),rot(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vect(467,-214,-144),rot(0,0,0),'Wandering');
        break;
#endif

#ifdef revision
    case "02_NYC_STREET":
        foreach AllActors(class'CrateExplosiveSmall', c) {
            l("hiding " $ c @ c.Tag @ c.Event);
            c.bHidden = true;// hide it so DXRSwapItems doesn't move it, this is supposed to be inside the plane that flies overhead
        }
        break;
#endif
    }
}

function PostFirstEntryMapFixes()
{
    switch(dxr.localURL) {
    case "02_NYC_WAREHOUSE":
        if(!#defined(revision)) {
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vect(183.993530, 926.125000, 1162.103271));// apartment
            AddBox(class'#var(prefix)CrateUnbreakableMed', vect(-389.361969, 744.039978, 1088.083618));// ladder
            AddBox(class'#var(prefix)CrateUnbreakableSmall', vect(-328.287048, 767.875000, 1072.113770));
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
