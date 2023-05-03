class DXRFixupM00 extends DXRFixup;

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "In the real game, the locations of nanokeys will be randomized.";
    add_datacubes[i].location = vect(362.768005, 1083.160889, -146.629639);
    i++;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "Door stats will be randomized, as well as the strength of the lockpicking skill and all the other skills too."
                            $ "|n|nRead all the skill descriptions."
                            $ "|n|nRarity of lockpicks and other items will also be randomized.";
    add_datacubes[i].location = vect(1063.068481, 376.354431, -78.630066);
    i++;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "Passwords are randomized! And in the real game, the locations of datacubes will also be randomized."
                            $ "|n|nKeypad stats and the electronics skill strength are randomized too.";
    add_datacubes[i].location = vect(1492.952026, 824.573669, -146.630493);
    i++;

    add_datacubes[i].map = "00_Training";
    if(#defined(injections))
        add_datacubes[i].text = "The flashlight is free and more useful than you might think, but it can alert enemies. Also brightness can be adjusted in Rando settings menu.";
    else
        add_datacubes[i].text = "Do not underestimate the usefulness of the flashlight, but it can alert enemies. Also brightness can be adjusted in Rando settings menu.";
    add_datacubes[i].location = vect(4281.545410, 857.203918, -190.630219);
    i++;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "Repair bots locations are randomized, as well as their stats. There will also be a hint datacube near them to help you find them.|nSame thing for Medbots.";
    add_datacubes[i].location = vect(5039.701172, 412.508270, -190.629654);
    i++;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "Ammo amounts will be randomized, as well as the maximum amounts of ammo you can carry. Item locations will also be shuffled.";
    add_datacubes[i].location = vect(6487.020020, 615.031006, -190.630127);
    i++;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "The locations of crates will be shuffled.";
    add_datacubes[i].location = vect(7258.977539, -1548.123291, -30.629023);
    i++;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "Since skill strengths are randomized, read the Environmental skill description to see how effective hazmat suits are.";
    if(#defined(injections))
        add_datacubes[i].text = add_datacubes[i].text $ "|nArmors will free up inventory space immediately when used. Left click to use items without needing to put them into your inventory.";
    add_datacubes[i].location = vect(6624.718750, -4041.603271, -30.629770);
    i++;

    add_datacubes[i].map = "00_Training";
    add_datacubes[i].text = "Medbots locations are randomized, as well as their stats. There will also be a hint datacube near them to help you find them.|nSame thing for Repair bots.";
    add_datacubes[i].location = vect(5137.563477, -4133.698730, -30.629473);
    i++;

    add_datacubes[i].map = "00_TrainingCombat";
    add_datacubes[i].text = "Each type of weapon has its stats randomized.|n|nFor example, every knife will have the same stats so you don't need to compare different knives. But you will want to compare the knife vs the baton to see which one is better to keep.";
    add_datacubes[i].location = vect(-237.082443, 5.800471, -94.629921);
    i++;

    add_datacubes[i].map = "00_TrainingCombat";
    add_datacubes[i].text = "Since skill strengths are randomized, read the skill descriptions to see how strong they are, for example the Pistol skill."
                            $ "|n|nMaximum ammo is also randomized, read the description for the pistol on the inventory screen.";
    add_datacubes[i].location = vect(70.125610, -495.520569, -158.629715);
    i++;

    if(#defined(injections)) {
        add_datacubes[i].map = "00_TrainingCombat";
        add_datacubes[i].text = "Arming time for grenades is affected by your demolitions skill, as well as the fuse time. You can also try attaching grenades to the ground!";
        add_datacubes[i].location = vect(1963.962524, 1532.572510, -158.630264);
        i++;
    }

    add_datacubes[i].map = "00_TrainingCombat";
    add_datacubes[i].text = "Door stats are randomized and some doors that are normally not breakable/pickable may become so in the Randomizer. Read the hover text on each door to see their stats.";
    add_datacubes[i].location = vect(2996.493408, 1215.471680, -94.630165);
    i++;

    add_datacubes[i].map = "00_TrainingCombat";
    add_datacubes[i].text = "Skill costs are rerolled every 5 missions by default (MJ12 Jail, Paris, Area 51).";
    add_datacubes[i].location = vect(3781.695557, 1616.889282, -94.629799);
    i++;

    add_datacubes[i].map = "00_TrainingFinal";
    add_datacubes[i].text = "In the real game, enemies will be shuffled around the map, and they can be given random weapons. Also randomized enemies can be added near normal enemy placements.";
    add_datacubes[i].location = vect(-82.128166, 300.156036, 29.369879);
    i++;

    add_datacubes[i].map = "00_TrainingFinal";
    add_datacubes[i].text = "The contents of augmentation canisters are randomized as well as the strengths of augmentations.";
    add_datacubes[i].location = vect(573.204163, 191.433258, -110.629906);
    i++;

    add_datacubes[i].map = "00_TrainingFinal";
    add_datacubes[i].text = "Many other things will be randomized when you get to the real game, including goal locations. If you get stuck you can press the Show Spoilers button on the Goals screen."
                            $ "|n|nIn order to be prepared, check out our README and Wiki on the Deus Ex Randomizer GitHub.";
    add_datacubes[i].location = vect(6577.697266, -3884.925049, 33.369633);
    i++;

    Super.CheckConfig();
}

function PostFirstEntryMapFixes()
{
    local Actor a;

    switch(dxr.localURL) {
    case "00_TrainingFinal":
        Spawn(class'#var(prefix)BallisticArmor',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)FireExtinguisher',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)Multitool',,, GetRandomPositionFine());
        a = Spawn(class'#var(prefix)Credits',,, GetRandomPositionFine());
        #var(prefix)Credits(a).numCredits = 2000;
        a = Spawn(class'#var(prefix)Credits',,, GetRandomPositionFine());
        #var(prefix)Credits(a).numCredits = 2000;
        Spawn(class'#var(prefix)Medkit',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)WineBottle',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)Liquor40oz',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)LiquorBottle',,, GetRandomPositionFine());
        Spawn(class'#var(prefix)BioelectricCell',,, GetRandomPositionFine());
        a = Spawn(class'#var(prefix)AugmentationCannister',,, GetRandomPositionFine());
        class'DXRAugmentations'.static.RandomizeAugCannister(dxr, #var(prefix)AugmentationCannister(a));
        a = Spawn(class'#var(prefix)AugmentationCannister',,, GetRandomPositionFine());
        class'DXRAugmentations'.static.RandomizeAugCannister(dxr, #var(prefix)AugmentationCannister(a));
        break;
    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local Inventory i;
    Super.PlayerAnyEntry(p);
    if(dxr.localURL != "00_INTRO") return;
    // try to fix inventory stuff on new game (issue #426)
    foreach AllActors(class'Inventory', i) {
        if(PlayerPawn(i.Owner) != None)
            i.Destroy();
    }
    p.Inventory = None;
}
