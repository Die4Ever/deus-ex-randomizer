class DXRHints extends DXRBase transient;

var #var(PlayerPawn) _player;

// if this hints array is too long, then no one will ever see the best hints
var int numHints;
struct GameHint {
    var string line1, line2;
    var bool deathOnly;
};
var GameHint hintList[150];

simulated function InitHints()
{
    local DXRTelemetry telem;
    local DXRSkills skills;
    local DXRAugmentations augs;
    local int mission, num_stalkers;
    local string map;

    numHints = 0;
    mission = dxr.dxInfo.missionNumber;
    map = dxr.localURL;

    telem = DXRTelemetry(dxr.FindModule(class'DXRTelemetry'));
    if(telem == None || telem.enabled == false || mission < 1)
        AddHint("Check out https://mastodon.social/@DXRandoActivity!","Make sure \"Online Features\" are enabled to show up yourself!");
    else
        AddHint("Check out https://mastodon.social/@DXRandoActivity!", "We just shared your death publicly, go retweet it!",true);

    if(dxr.flags.crowdcontrol > 0) {
        if (dxr.flags.crowdcontrol!=3){
            AddHint("Viewers, you could've prevented this with Crowd Control.", "Or maybe you caused it.", true);
            AddHint("Don't forget you (the viewer!) can", "use Crowd Control to influence the game!", true);
        } else {
            AddHint("RNG did not work in your favour today.", "You have been defeated by a computer.", true);
            AddHint("Sometimes a computer can be more cruel than a human.", "(but not always!)", true);
        }
    }

    if (dxr.flags.settings.goals > 0) {
        AddHint("Check the Deus Ex Randomizer wiki", "for information about randomized objective locations and more!");
        AddHint("Try the Goal Locations button on the Goals screen", "for a list of the randomized objective locations!");
        if (class'MenuChoice_GoalTextures'.static.IsEnabled()){
            AddHint("Security Computers associated with randomized goals", "will have a green lid to make them stand out!");
            AddHint("Personal Computers associated with randomized goals", "will have a yellow screen to make them stand out!");
        }
    }

    if (dxr.flags.IsBingoCampaignMode()){
        if (dxr.flags.settings.bingo_win>1) {
            AddHint("You need to complete "$dxr.flags.settings.bingo_win$" lines on your bingo board", "in order to progress in the game!");
        } else if (dxr.flags.settings.bingo_win==1) {
            AddHint("You need to complete one line on your bingo board", "in order to progress in the game!");
        }
    } else {
        if (dxr.flags.settings.bingo_win>0) {
            if (dxr.flags.settings.bingo_win>1) {
                AddHint("You'll finish this loop once you complete "$dxr.flags.settings.bingo_win$" lines", "on your bingo board!");
            } else {
                AddHint("You'll finish this loop once you complete one line", "on your bingo board!");
            }
            if (dxr.flags.bingo_duration==1){
                AddHint("All of your bingo goals can be", "completed within this mission!");
            } else if (dxr.flags.bingo_duration>1){
                AddHint("All of your bingo goals can be", "completed within "$dxr.flags.bingo_duration$" missions!");
            }
            AddHint("Your health will be refilled when you finish this loop!", "Use it to its fullest!"); //Make sure this is in line with the decision made about NG+ energy refilling in issue #1065

            //Technically not "WaltonWare" hints, but only really a concern if you've got bingo win enabled (for faster games):
            if (dxr.flags.newgameplus_num_removed_weapons==1) {
                AddHint("One weapon will be taken away when you finish this loop!", "Don't get too attached!");
            } else if (dxr.flags.newgameplus_num_removed_weapons>1) {
                AddHint(dxr.flags.newgameplus_num_removed_weapons$" weapons will be taken away when you finish this loop!", "Don't get too attached!");
            }

            skills = DXRSkills(dxr.FindModule(class'DXRSkills'));
            if( skills != None ) {
                if (dxr.flags.newgameplus_num_skill_downgrades==1) {
                    AddHint("One skill will be downgraded when you finish this loop", "and you'll lose 25% of your unused skill points!");
                } else if (dxr.flags.newgameplus_num_skill_downgrades>1) {
                    AddHint(dxr.flags.newgameplus_num_skill_downgrades$" skills will be downgraded when you finish this loop", "and you'll lose 25% of your unused skill points!");
                }
            }

            augs = DXRAugmentations(dxr.FindModule(class'DXRAugmentations'));
            if( augs != None ) {
                if (dxr.flags.newgameplus_num_removed_augs==1) {
                    AddHint("One aug will be removed when you finish this loop", "but you might get new ones to replace it!");
                } else if (dxr.flags.newgameplus_num_removed_augs>1) {
                    AddHint(dxr.flags.newgameplus_num_removed_augs$" augs will be removed when you finish this loop", "but you might get new ones to replace them!");
                }
            }

            if (dxr.flags.newgameplus_max_item_carryover==1) {
                AddHint("You can only carry one copy of non-stackable items between loops!", "Don't hoard too much!");
            } else if (dxr.flags.newgameplus_max_item_carryover>1) {
                AddHint("You can only carry "$dxr.flags.newgameplus_max_item_carryover$" copies of non-stackable items between loops!", "Don't hoard too much!");
            }
        }
    }

    if (dxr.flags.moresettings.aug_loc_rando>0){
        AddHint("The body locations that augs can be installed in might be changed!", "Make sure to read the descriptions to find out!");
    }

    if (dxr.flags.clothes_looting>0) {
        AddHint("Your selection of clothes is limited to those you've collected!", "Make sure to check bodies and clothes racks to get more!");
    }

    if (dxr.flags.moresettings.camera_mode==1) {//Third person
    } else if (dxr.flags.moresettings.camera_mode==2) { //Fixed cameras
        AddHint("The camera location will change once you're out of line of sight!", "Use this to your advantage to get better angles!");
        AddHint("Using a scope will make the camera look where you're aiming!", "Maybe you can actually see something far away like this!");
        AddHint("Have you tried shooting the camera?", "Maybe you can get a better view!");
    }

    if (dxr.flags.settings.spoilers>0) {
        AddHint("Spoiler buttons are available on the Goals screen!", "Give them a shot if you get really stuck!");
    }

    if (dxr.flags.settings.menus_pause==0) {
        AddHint("The game won't pause when you enter menus!", "Watch out!");
    }

    if (class'MenuChoice_RandomMusic'.static.IsEnabled(dxr.flags)){
        AddHint("You can skip or disable songs in the Rando Audio menu!", "Customize your vibe!");
        if (#defined(revision)){
            AddHint("You can switch between the original and Revision", "soundtracks in the Revision Sound menu!");
        }
    }

    if (!class'MenuChoice_Epilepsy'.default.enabled){
        AddHint("Are the flickering lights too much for you?  Disable Flickering", "Lights in the Rando Visuals menu to make them more gentle!");
    }

    if (class'MenuChoice_ShowHints'.static.IsEnabled(dxr.flags)){
        AddHint("Are the hints annoying when you enter a level?", "You can disable Level Start Hints in the Randomizer settings!");
    }

    if (#defined(vanilla)){
        AddHint("Check out the various options in the Rando Gameplay menu to decide", "how some types of items are looted from dead bodies!");
        AddHint("Use the Trash button in the Inventory menu to stop", "looting that type of item from dead bodies!");
        AddHint("The Aggressive Defense System aug can stop not only missiles", "and grenades, but also darts, throwing knives, plasma, and flames!");
    }

    if(dxr.flags.settings.minskill != dxr.flags.settings.maxskill) {
        if( dxr.flags.settings.skills_reroll_missions == 1 ) {
            AddHint("Skill costs reroll every mission.", "Check them often, especially the BANNED skills.");
        } else if( dxr.flags.settings.skills_reroll_missions > 0 ) {
            AddHint("Skill costs reroll every "$ dxr.flags.settings.skills_reroll_missions $" missions.", "You're currently in mission "$mission$".");
        }
    }

    AddHint("Attaching a LAM or Gas Grenade to a wall can be very strong!", "Also try to lure enemies into them.");
    AddHint("You don't trigger your own grenades.", "Setup traps without fear.");
    AddHint("Use sabot shotgun rounds to kill the little spider bots.");
    AddHint("Sabot rounds can damage tough objects no matter the damage threshold.","Check the highlight text!");
    AddHint("Grab a plasma rifle, blast everything in sight,", "then go get your items back.");
    AddHint("Thermoptic Camo allows you to pass", "through lasers without being detected!");
    AddHint("Thermoptic Camo makes you invisible to people and bots", "but not to cameras or turrets!");
    AddHint("Thermoptic Camo and Cloak do not work against cameras or turrets,", "but Radar Transparency does.");
    if(dxr.flags.settings.energy != 100) {
        AddHint("Your max energy is "$dxr.flags.settings.energy$" points.", "Your energy meter shows percent relative to this value.");
    }
    if(#defined(injections)) {
        if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) AddHint("Grays have strong resistance to fire and plasma,", "but it will eventually kill them!");
        else AddHint("Grays are immune to fire and plasma!");
        if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) AddHint("Weapon animation speeds now improve with skills,", "especially grenades with Demolition skill.");
        if(class'MenuChoice_BalanceItems'.static.IsEnabled()) AddHint("Grenades can now be attached to the floor", "or even on a door!");
        if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) AddHint("Attaching a grenade to a wall increases its", "blast radius and damage, especially with high skill.");
        if(class'MenuChoice_SaveDuringInfolinks'.static.IsEnabled(dxr.flags)){
            AddHint("You can safely save during infolinks!", "Give it a shot, Tong won't mind!");
        } else {
            AddHint("Wish you could save during infolinks?", "Look for the 'Saving During Infolinks' option in the settings!");
        }
        if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) AddHint("Red lasers will always set off an alarm.", "Blue lasers won't, but will trigger something else!");
        if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) AddHint("Everything except an NPC will set off a laser!", "Better be careful around them!");
        AddHint("Enemies with gold visors are resistant to gas", "so you might need to deal with them differently!");
        if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) AddHint("Enemies with helmets take less damage from headshots", "so you might need to be more careful!");
        if (class'MenuChoice_AutoWeaponMods'.default.enabled){
            AddHint("Picking up a weapon mod while holding a weapon", "will automatically apply it to that weapon!");
        }
        AddHint("Try using the Quick Skill Menu to upgrade skills while moving!", "Look for the 'Activate Multiplayer Skill Menu' key binding!");
        AddHint("Try using the Quick Aug Menu to upgrade augs while moving!", "Look for the 'Activate Quick Aug Menu' key binding!");
        AddHint("You can upgrade augs without picking up the upgrade canister!", "Just highlight it before trying to upgrade!");
        if (!class'MenuChoice_AutoLaser'.default.enabled){
            AddHint("Look for the 'Auto Laser Sight' option in the Rando Gameplay menu", "to automatically activate laser mods when you draw your weapon!");
        }
        if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) AddHint("The Speed Enhancement aug now instantly burns 1 energy", "in order to prevent abuse.  Just turn it on and off like normal!");
        AddHint("You will still pick up ammo from weapons even if you", "are unable to pick them up (or have them marked as trash)!");
        if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) AddHint("The Vision Enhancement aug will now show characters, goals, items,", "datacubes, vehicles, crates, and electronic devices through walls!");
        if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) AddHint("The Regeneration aug will no longer bring you to maximum health.", "Upgrade the aug to increase the healing cap!");
        AddHint("The inventory description of augmentation canisters will show", "the full description of the augs available within!");
    }

    if(dxr.flags.moresettings.reanimation > 0) {
        AddHint("Dead bodies will come back as zombies!", "You might want to destroy the bodies.");
        AddHint("Dead bodies will come back as zombies!", "Maybe a non-lethal approach would help?");
    }
    if (dxr.flags.settings.enemyrespawn > 0) {
        AddHint("Enemies will respawn once they've been killed or knocked out!", "Remember that you can leave enemies critically injured!");
    }
    if(dxr.flags.autosave == 3 && !dxr.flags.IsHordeMode()) {
        AddHint("You're not allowed to manually save,", "you only get an autosave when first entering a map.");
    }
    else if(dxr.flags.autosave == 5) {
        AddHint("You're not allowed to save the game.", "You really need to try not dying!");
    }
    else if(dxr.flags.autosave == 6) {
        AddHint("You need a Memory Containment Unit to save the game.", "Search every map you can for them.");
        AddHint("You need a Memory Containment Unit to save the game.", "Remember you can leave them on the floor and grab them later.");
    }
    else if(dxr.flags.autosave == 7) {
        AddHint("You need a Memory Containment Unit to save the game at a computer.", "Search every map you can for them.");
        AddHint("You need a Memory Containment Unit to save the game at a computer.", "Remember you can leave them on the floor and grab them later.");
    }
    else if(dxr.flags.autosave == 8) {
        AddHint("You need to highlight a computer to save your game.", "You do know where they all are, right?");
    }

    if(mission <= 3) {
        if(dxr.flags.settings.enemiesrandomized > 0) {
            AddHint("Some NSF terrorists are visibly augmented.", "Watch out for their special capabilities!");
        }
    } else if(mission <= 4) {
        if(dxr.flags.settings.enemiesrandomized > 0) {
            AddHint("Some UNATCO troops are visibly augmented.", "They explode when they die, so watch out!");
        }
    } else {
        if(dxr.flags.settings.enemiesrandomized > 0) {
            AddHint("Some UNATCO and MJ12 troops are visibly augmented.", "They explode when they die, so watch out!");
        }
    }

    num_stalkers = dxr.flags.moresettings.stalkers >>> 16;
    if(num_stalkers > 0) {
        AddHint("Stalkers cannot be permanently killed,", "but if they take enough damage then they will go away for a while.");
        if((dxr.flags.moresettings.stalkers & 1) != 0) { // Mr. H
            AddHint("Mr. H cannot die", "but he will flee for a bit if you hurt him enough.");
        }
        if((dxr.flags.moresettings.stalkers & 2) != 0) { // Weeping Anna
            AddHint("Weeping Anna cannot move, attack,", "or take damage while you are looking at her.");
        }
        if((dxr.flags.moresettings.stalkers & 4) != 0) { // Bobby
            AddHint("Bobby will wait until you turn your back to ambush you.");
        }
    }
    if(mission <= 5) {
        AddHint("Melee attacks from behind do bonus damage!");
        AddHint("Don't hoard items.", "You'll find more!");
        AddHint("Have you looked at your Bingo Board?", "Find it in the middle bar of your Goals/Notes screen.");

        if(!dxr.flags.IsZeroRando()) AddHint("Use everything at your disposal, like TNT crates.", "Randomizer makes this even more of a strategy/puzzle game.");
        AddHint("A vending machine can provide you with 20 health worth of food.", "Eat up!");
        AddHint("Pepper spray and fire extinguishers can incapacitate an enemy", "letting you sneak past them.");
        if(dxr.flags.settings.keysrando>0 && dxr.flags.settings.infodevices>0) AddHint("Datacubes and nanokeys give off a glow.", "Keep your eyes open for it!");
        else if(dxr.flags.settings.keysrando>0) AddHint("Nanokeys give off a glow.", "Keep your eyes open for it!");
        else if(dxr.flags.settings.infodevices>0) AddHint("Datacubes give off a glow.", "Keep your eyes open for it!");

        if(!dxr.flags.IsZeroRando()) {
            AddHint("The medium and large metal crates are now destructible.", "They have 500 HP.");
            AddHint("Make sure to read the descriptions for skills, augs, and items.", "Randomizer adds some extra info.");
        }
        if(dxr.flags.settings.min_weapon_dmg != dxr.flags.settings.max_weapon_dmg || dxr.flags.settings.min_weapon_shottime != dxr.flags.settings.max_weapon_shottime) {
            AddHint("Each type of weapon gets randomized stats!", "Make sure to check one of each type.");
            if (!dxr.flags.IsBingoCampaignMode() && dxr.flags.settings.bingo_win > 0 && dxr.flags.moresettings.newgameplus_curve_scalar != -1) {
                AddHint("Each type of weapon will have the same stats", "until the next loop.  Then they'll be randomized again!");
            } else {
                AddHint("Each type of weapon will have the same stats", "through the whole game.  They won't change later!");
            }
        }

        if(#defined(injections) || #defined(vmd) || #defined(gmdx)) {
            AddHint("You can left click on items to use them without picking them up.", "Great for eating to recover health or putting on armor!");
        }

        if(#defined(injections)) {
            if(!dxr.flags.IsHalloweenMode()) {
                AddHint("The flashlight (F12) no longer consumes energy when used.", "Go wild with it!");
                AddHint("The flashlight (F12) can be used to attract the attention of guards.", "It doesn't cost any energy!");
            } else {
                AddHint("The flashlight (F12) consumes energy in Halloween Mode!", "Don't waste your energy!");
                AddHint("The flashlight (F12) can be upgraded in Halloween Mode!", "Level 2 is brighter and doesn't cost energy!");
            }
            if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
                AddHint("Alcohol and medkits will heal your legs first", "if they are completely broken.");
                AddHint("You can carry 5 fire extinguishers in 1 inventory slot.", "They are very useful for stealthily killing multiple enemies.");
                AddHint("Items like ballistic armor and rebreathers now free up", "the inventory space immediately when you equip them.");
                AddHint("Items like hazmat suits and thermoptic camo now free up", "the inventory space immediately when you equip them.");
                AddHint("The PS20 has been upgraded to the PS40", "and does significantly more damage.");
                AddHint("Flare darts now set enemies on fire for 3 seconds.");
                if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) AddHint("Thowing knives deal more damage,", "and their speed and range increase with your low-tech skill.");
                else AddHint("Thowing knives deal more damage.");
            }
            AddHint("Ever tried to extinguish a fire with a toilet?", "How about a urinal or a shower?");
            AddHint("Try using a hazmat suit", "against plasma, fire, and gas attacks.");
            if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) AddHint("Hacking computers now uses 5 bioelectric energy per second.");
            if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
                AddHint("Spy Drone aug has improved speed", "and it's easier to control.");
                if(class'MenuChoice_BalanceItems'.static.IsEnabled()) AddHint("Vision Enhancement Aug and Tech Goggles can now see through walls", "even at level 1, and they stack.");
                else AddHint("Vision Enhancement Aug can now see through walls", "even at level 1.");
                AddHint("Vision Enhancement Aug can see goal items through walls at level 2.", "Use it to see what's inside locked boxes.");
            }
            AddHint("Read the pop-up text on doors to see how many", "hits from your equipped weapon it takes to break it.");
        } else {
            AddHint("The flashlight (F12) can be used to attract the attention of guards.");
        }

        if(dxr.flags.moresettings.entrance_rando > 0) {
            AddHint("Entrance Randomizer is enabled,", "check the wiki on our GitHub for help.");
        }

        if(dxr.flags.settings.medbots > 0) {
            AddHint("Medbots are randomized.", "Don't expect to find them in the usual locations.");
            AddHint("Medbots are randomized.", "There will be a datacube nearby saying the delivery has been made.");
        }
        else if(dxr.flags.settings.medbots == 0) {
            AddHint("Medbots are disabled.", "Good luck.");
        }

        if(dxr.flags.moresettings.empty_medbots > 0) {
            AddHint("You might find an augbot in maps where medbots didn't spawn.", "At least you can still install that aug canister!");
            AddHint("Augbots are blue.  Medbots are white.", "Know the difference!");
        }

        if(dxr.flags.settings.repairbots > 0) {
            AddHint("Repair bots are randomized.", "Don't expect to find them in the usual locations.");
            AddHint("Repair bots are randomized.", "There will be a datacube nearby saying the delivery has been made.");
        }
        else if(dxr.flags.settings.repairbots == 0) {
            AddHint("Repair bots are disabled.", "Good luck.");
        }

        if(!#defined(vmd)) {
            if (dxr.flags.settings.medbotuses==1) {
                AddHint("Each medbot can heal you one time!","Use it wisely!");
            } else if (dxr.flags.settings.medbotuses>1 && dxr.flags.settings.medbotuses <30) {
                AddHint("Each medbot can heal you "$dxr.flags.settings.medbotuses$" times!","Use them wisely!");
            }

            if (dxr.flags.settings.repairbotuses == 1) {
                AddHint("Each repair bot can recharge you one time!","Use it wisely!");
            } else if (dxr.flags.settings.repairbotuses>1 && dxr.flags.settings.repairbotuses <30){
                AddHint("Each repair bot can recharge you "$dxr.flags.settings.repairbotuses$" times!","Use them wisely!");
            }
        }

        if (dxr.flags.settings.medbotcooldowns == 1) { //Individual
            AddHint("Medbots have a randomized cooldown.", "Each one is different, so pay attention!");
        } else if (dxr.flags.settings.medbotcooldowns == 2) { //Global
            AddHint("Medbots have a randomized cooldown.", "The cooldown is the same for all of them!");
        }

        if (dxr.flags.settings.repairbotcooldowns == 1) { //Individual
            AddHint("Repair bots have a randomized cooldown.", "Each one is different, so pay attention!");
        } else if (dxr.flags.settings.repairbotcooldowns == 2) { //Global
            AddHint("Repair bots have a randomized cooldown", "The cooldown is the same for all of them!");
        }

        if (dxr.flags.settings.medbotamount == 1) { //Individual
            AddHint("Medbots have a randomized heal amount.", "Each one is different, so pay attention!");
        } else if (dxr.flags.settings.medbotamount == 2) { //Global
            AddHint("Medbots have a randomized heal amount.", "The amount is the same for all of them!");
        }

        if (dxr.flags.settings.repairbotamount == 1) { //Individual
            AddHint("Repair bots have a randomized recharge amount.", "Each one is different, so pay attention!");
        } else if (dxr.flags.settings.repairbotamount == 2) { //Global
            AddHint("Repair bots have a randomized recharge amount.", "The amount is the same for all of them!");
        }
    }
    else if(mission <= 11) {
        AddHint("Don't hoard items.", "You'll find more!");
        if(!dxr.flags.IsZeroRando())
            AddHint("Make sure to read the descriptions for skills, augs, and items.", "Randomizer adds some extra info.");
        if(#defined(injections)) {
            if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
                if(class'MenuChoice_BalanceItems'.static.IsEnabled()) AddHint("Vision Enhancement Aug and Tech Goggles can now see through walls", "even at level 1, and they stack.");
                else AddHint("Vision Enhancement Aug can now see through walls", "even at level 1.");
                AddHint("Vision Enhancement Aug can see goal items through walls at level 2.", "Use it to see what's inside locked boxes.");
            }
            if(class'MenuChoice_BalanceItems'.static.IsEnabled()) AddHint("You can left click on items to use them without picking them up.", "Great for eating to recover health or putting on armor!");
            else AddHint("You can left click on items to use them without picking them up.", "Great for eating to recover health!");
        }
    }
    else if(mission <= 14) {
        // maybe you should be hoarding items here until Area 51 lol
        AddHint("Now might actually be a good time to hoard items.", "You might need them for the end.");
    }
    else {
        AddHint("Try not dying.");
        AddHint("Don't hoard items.", "What are you saving them for?");
        AddHint("Spend your skill points!");
    }

    // ~= is case insensitive equality
    switch(dxr.dxInfo.missionNumber) {
    case 1:
        if(map ~= "01_NYC_UNATCOIsland") {
            if(dxr.flags.settings.passwordsrandomized > 0)
                AddHint("Passwords have been randomized.", "Don't even try smashthestate!");
            if(dxr.flags.settings.goals > 0){
                AddHint("The locations of the terrorist commander and boat are randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("Your start location, the terrorist commander, and the boat won't", "be close.  You might be able to skip some locations!");
                if(#defined(injections)) {
                    AddHint("The map of the island can show possible goal locations.", "Give it a try!");
                }
            }
            AddHint("Harley Filben has the key that opens doors in the statue.", "Be nice to him!");
            AddHint("The key that opens the front doors of the statue also opens", "the cell Gunther is being held in.  Walk right in!");
        }
        break;

    case 2:
        if(map ~= "02_NYC_BatteryPark") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of the Ambrosia barrel is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        else if(map ~= "02_NYC_Warehouse") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("The locations of the generator, computer, and Jock are randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The Email Computer contains a hint about the generator location.", "Make sure to read your emails!");
            }
            if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) {
                AddHint("There are lots of enemies here!", "Look for thermoptic camo to help.");
                AddHint("There are lots of enemies here!", "Look for ballistic armor to help.");
                AddHint("There are lots of enemies here!", "Look for fire extinguishers to stun enemies.");
            }
        }
        break;

    case 3:
        switch(map) {
        case "03_NYC_BatteryPark":
            if(dxr.flags.settings.goals > 0)
                AddHint("The locations of Harley and Curly are randomized.", "Check the Goal Randomization page on our Wiki.");
            break;
        case "03_NYC_BrooklynBridgeStation":
            if(dxr.flags.settings.goals > 0)
                AddHint("The locations of some NPCs on this map are randomized.", "Check the Goal Randomization page on our Wiki.");
            break;
        case "03_NYC_Airfield":
            if(dxr.flags.settings.goals > 0){
                AddHint("The location of the NSF soldier with the East Gate key is randomized.", "Check the Goal Randomization page on our Wiki.");
                if(#defined(injections)) {
                    AddHint("The map of the airfield can show possible goal locations.", "Give it a try!");
                }
            }
            break;
        case "03_NYC_747":
            if(class'MenuChoice_BalanceMaps'.static.MajorEnabled()) AddHint("Anna will no longer trigger a LAM", "while she's allied to you!");
            break;
        }
        break;

    case 4:
        if (map ~= "04_NYC_NSFHQ") {
            if(dxr.flags.settings.goals > 0){
                AddHint("The location of the computer to align the satellites is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The location of the computer to send the signal is randomized.", "Check the Goal Randomization page on our Wiki.");
            }
        } else if(dxr.flags.settings.goals > 0) {
            AddHint("Anna Navarre's location is randomized.", "Check the Goal Randomization page on our Wiki.");
        }

        if (dxr.flags.settings.prison_pocket > 1) { //Augmented
            AddHint("You'll be able to keep all your items when going to prison.", "JC has hidden pockets!");
        } else if (dxr.flags.settings.prison_pocket == 1) { //Unaugmented
            AddHint("You'll be able to keep the first single square item in", "your belt when going to prison.  JC has a hidden pocket!");
        }
        break;

    case 5:
        if (map ~= "05_NYC_UnatcoMJ12Lab") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("Paul's location in the lab is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The security computer in the command center has a", "camera that shows where Paul is located!");
                AddHint("Your equipment could be in either", "the armory, or the surgery ward.");
                AddHint("Your equipment will never be in the", "same wing of the lab as Paul!");
                if(#defined(injections)) {
                    AddHint("The map of the lab can show possible goal locations.", "Give it a try!");
                }
            }
        } else if (map ~= "05_NYC_UnatcoHQ") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("Alex Jacobson's location in UNATCO HQ is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The locations for Anna's killphrase are randomized in UNATCO HQ.", "Check the Goal Randomization page on our Wiki.");
                AddHint("Jaime Reyes's location in UNATCO HQ is randomized.", "Check the Goal Randomization page on our Wiki.");
            }
        } else if (map ~= "05_NYC_UNATCOISLAND") {
            if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled() && class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) {
                AddHint("Private Lloyd has been promoted to Master Sergeant!", "Be careful!");
            }
        }
        break;

    case 6:
        if (map ~= "06_hongkong_mj12lab") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of the computer with the ROM Encoding is randomized.", "Check the Goal Randomization page on our Wiki.");
        } else if (map ~= "06_HongKong_WanChai_Street") {
            if(class'MenuChoice_ToggleMemes'.static.IsEnabled(dxr.flags)) AddHint("All that time JC spent practicing the piano...", "All wasted because of your choices.",true);
            if(dxr.flags.settings.goals > 0)
                AddHint("The Dragon Tooth Sword is randomized in Hong Kong.","Open the case in Maggie Chow's apartment for a hint.");
        } else if (map ~= "06_HongKong_VersaLife") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The locations of some VersaLife employees are randomized.", "Check the Goal Randomization page on our Wiki.");
        } else if (map ~= "06_HONGKONG_WANCHAI_UNDERWORLD") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of Max Chen in the Lucky Money Club is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        break;

    case 8:
        AddHint("Osgoode & Sons is the burned out", "building next to the hotel.");
        if(dxr.flags.settings.goals > 0){
            AddHint("The locations of Filben, Greene, and Vinny are randomized.", "Check the Goal Randomization page on our Wiki.");
            AddHint("The start location of the raid has been randomized.", "Look for the black vans!");
            AddHint("The location of Jock when leaving is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        break;

    case 9:
        if (map ~= "09_nyc_graveyard") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of the signal jammer is randomized.", "Check the Goal Randomization page on our Wiki.");
        } else if (map ~= "09_nyc_shipbelow") {
            if(dxr.flags.settings.goals > 0){
                AddHint("The locations of the tri-hull weld points are randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The location of the bilge pump computer is randomized.", "Check the Goal Randomization page on our Wiki.");
                if(#defined(injections)) {
                    AddHint("The map of the ship can show possible goal locations.", " Give it a try!");
                }
            }
        } else if (map ~= "09_nyc_dockyard") {
            if(dxr.flags.settings.goals > 0) {
                if(dxr.flagbase.GetBool('MS_ShipBreeched'))
                    AddHint("The location of Jock is randomized.", "Check the Goal Randomization page on our Wiki.");
                else
                    AddHint("The location of Jock will be randomized.", "Check the Goal Randomization page on our Wiki.");
            }
        }
        break;

    case 10:
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to come back here later.");
        }
#endif
        if(class'MenuChoice_BalanceItems'.static.IsEnabled()) AddHint("There's wine everywhere in Paris,", "it can be a decent source of health and energy.");
        else AddHint("There's wine everywhere in Paris,", "it can be a decent source of health.");
        if(map ~= "10_Paris_Catacombs" || map~="10_Paris_Entrance") { //Le Merchant is in ENTRANCE in Revision
            if(dxr.flags.settings.swapitems > 0) {
                AddHint("If you need a Hazmat suit,", "Le Merchant has one for sale.", true);
                AddHint("You can kill Le Merchant and loot him", "if you don't have enough money.");
            }
        }
        if(dxr.flags.settings.goals > 0 && (map ~= "10_paris_metro" || map ~= "10_paris_club")) {
            AddHint("The location of Nicolette DuClare is randomized.", "Check the Goal Randomization page on our Wiki.");
            if(#defined(injections)) {
                AddHint("The street map can show possible goal locations.", "Give it a try!");
            }
        }
        if(dxr.flags.settings.goals > 0 && (map ~= "10_Paris_Catacombs_Tunnels")) {
            if(#defined(injections)) {
                AddHint("The map of the catacombs can show possible goal locations.", "Give it a try!");
            }
            AddHint("Agent Hela will always have two copies of the sewer key.", "She will be carrying one and keep another nearby.");
            AddHint("The location of Agent Hela is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
        break;

    case 11:
        if (map ~= "11_paris_cathedral") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of Gunther and the computer is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to go back to previous Paris levels.");
        }
#endif
        if(class'MenuChoice_BalanceItems'.static.IsEnabled()) AddHint("There's wine everywhere in Paris,", "it can be a decent source of health and energy.");
        else AddHint("There's wine everywhere in Paris,", "it can be a decent source of health.");
        break;

    case 12:
        if (map ~= "12_vandenberg_cmd") {
            AddHint("The comms building will open once the friendly bots are released", "if you aren't equipped to deal with the bots yourself.");
            if(dxr.flags.settings.goals > 0) {
                AddHint("The locations of the power generator keypads and Jock are randomized.", "Check the Goal Randomization page on our Wiki.");
            }
        } else if (map ~= "12_vandenberg_tunnels") {
            AddHint("Looking for the Control Room key?", "Have you checked the flooded reactor room?");
            AddHint("It's possible to use the overhead pipes to bypass", "the radioactive area while travelling in either direction!");
        }
#ifdef injections
        if( class'DXRBacktracking'.static.bSillyChoppers() && dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to come back here later.");
        }
#endif
        break;

    case 14:
        if (map ~= "14_oceanlab_silo") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("Howard Strong is now in a random location at the missile silo.", "Check the Goal Randomization page on our Wiki.");
                AddHint("Howard Strong will only show up if you've done your objectives!", "Been to the Ocean Lab UC and merged Helios?");
                AddHint("Jock will pick you up at a random location.", "Check the Goal Randomization page on our Wiki.");
            }
        }
        else if (map ~= "14_OceanLab_UC") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("The location of the UC schematics computer is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The Email Computer contains a hint about the UC Computer location.", "Make sure to read your emails!");
            }
        }
        if (map ~= "14_OCEANLAB_LAB" || map ~= "14_VANDENBERG_SUB" || map ~= "14_OCEANLAB_UC") {
            if(dxr.flags.settings.goals > 0)
                AddHint("The location of Walton Simons is randomized.", "Check the Goal Randomization page on our Wiki.");
        }
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to go back to Vandenberg.");
        }
#endif
        break;

    case 15:
        AddHint("Area 51 has great signage,", "read the signs to know where to go.");
        if (map ~= "15_AREA51_BUNKER") {
            if(dxr.flags.settings.goals > 0) {
                AddHint("The location of Walton Simons is randomized.", "Check the Goal Randomization page on our Wiki.");
                AddHint("The location of blast doors computer is randomized.", "Check the Goal Randomization page on our Wiki.");
            }

            if(class'MenuChoice_BalanceMaps'.static.ModerateEnabled()) AddHint("The path jumping down past the fan has been made more difficult", "than in vanilla.  Be warned.");
        }
        else if (map ~= "15_Area51_Entrance") {
            AddHint("You are in Sector 2.", "Find the key so that you can make your way to Sector 3.");
        }
        else if (map ~= "15_Area51_Final") {
            AddHint("You are in Sector 3.", "This is where the Aquinas Hub and Reactor Lab are.");
            AddHint("There's a datacube with the code for the Reactor Lab.", "The mechanic there will give you the code for the Aquinas Hub.");
        }
        else if (map ~= "15_Area51_Page") {
            AddHint("You are in Sector 4 with Bob Page.  This is where the", "Aquinas Router, Coolant Controls, and Blue Fusion Reactors are.");
            AddHint("You are in Sector 4.  The UCs will constantly spawn new enemies,", "but they can be closed off.");

            if(dxr.flagbase.GetBool('DL_Blue4_Played')) {
                AddHint("All four Blue Fusion Reactors are disabled!", "Go to the Infusion Controls and destroy Bob Page!");
            } else {
                AddHint("Look for four keypads to disable the blue fusion reactors", "in order to destroy Bob Page and let the Illuminati take over!");
            }

            if(dxr.flagbase.GetBool('coolantcut')) {
                AddHint("The coolant has been cut!", "Go to the Antimatter Reactor room in Sector 3 and blow up Area 51!");
            } else {
                AddHint("Look for a switch to deactivate the coolant", "in order to destroy Area 51 and start a new Dark Age!");
            }

            if(dxr.flagbase.GetBool('HeliosFree')) {
                AddHint("The uplink locks have been disabled!", "Go see Helios in Sector 3 so you can merge with him!");
            } else {
                AddHint("Look for a security computer to open the Aquinas Router Control Room", "in order to merge with Helios!");
            }

            if (dxr.flagbase.GetBool('DL_Blue4_Played') && dxr.flagbase.GetBool('coolantcut') && dxr.flagbase.GetBool('HeliosFree')) {
                AddHint("You're doing all three endings?", "It's time to make up your mind!");
            }
        }
#ifdef injections
        if( dxr.FindModule(class'DXRBacktracking') != None ) {
            AddHint("Randomizer has enabled extra backtracking.", "You will be able to move more freely through Area 51.");
        }
#endif
        break;
    }
}

simulated function AddHint(string hint, optional string detail, optional bool deathOnly)
{
    hintList[numHints].line1=hint;
    hintList[numHints].line2=detail;
    hintList[numHints].deathOnly=deathOnly;

    numHints++;

    if (numHints > ArrayCount(hintList)){
        err("Death hint list length exceeded!  Now "$numHints);
    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) player)
{
    local int i;
    local string msg, hint, detail;

    Super.PlayerAnyEntry(player);
    _player = player;
    InitHints();

    if(dxr.localURL ~= "00_Training") {
        for(i=0;i<numHints;i++) {
            msg = hintList[i].line1;
            if(Len(hintList[i].line2) > 0) {
                msg = msg $ "|n" $ hintList[i].line2;
            }
            player.AddNote(msg, false, i==numHints-1);
        }
        player.ClientMessage("Press G or F2 to check your Goals/Notes screen!",, true);
    }

    if (class'MenuChoice_ShowHints'.static.IsEnabled(dxr.flags)) {
        GetHint(false,hint,detail);
        player.ClientMessage("Hint: "$hint@detail);
    }
}

simulated function int GetHint(bool isDeath, out string hint, out string detail, optional bool addSpace)
{
    local GameHint actList[ArrayCount(hintList)];
    local int numActHints, i, hintNum;
    local string lastChar;

    numActHints=0;
    for (i=0;i<numHints;i++){
        if ((!isDeath && hintList[i].deathOnly==false) || isDeath) {
            actList[numActHints++]=hintList[i];
        }
    }

    // don't use the stable rng that we use for other things, needs to be different every time
    hintNum = Rand(numActHints);

    hint = actList[hintNum].line1;
    detail = actList[hintNum].line2;

    if (addSpace) {
        lastChar = Right(hint, 1);
        if (lastChar == "." || lastChar == "!" || lastChar == "?") {
            hint = hint $ " ";
        }
    }

    return hintNum;
}

simulated function ShowHint(optional int recursion)
{
    local int hint;
    local string hintStr,hintDetail;
    local DXRBigMessage m;

    //Only show death hints if the player wants them
    if (!class'MenuChoice_ShowDeathHints'.static.IsEnabled(dxr.flags)) return;

#ifdef hx
    // for hx, the DXRBigMessage is bugged, so just disable the timer and PlayerRespawn will enable it again
    SetTimer(0, false);
    return;
#endif
    SetTimer(15, true);
    if( recursion > 10 ) {
        info("ShowHint reached max recursion " $ recursion);
        return;
    }
    hint = GetHint(true,hintStr,hintDetail);

    m = class'DXRBigMessage'.static.CreateBigMessage(_player, self, hintStr, hintDetail);
    if(m == None) {
        ShowHint(++recursion);
        return;
    }
    m.line3 = "Deaths: "$class'DXRStats'.static.GetDataStorageStat(dxr, "DXRStats_deaths")$", Loads: "$class'DXRStats'.static.GetDataStorageStat(dxr, "DXRStats_loads");
    m.bottomText = "(Hint "$hint$" / "$numHints$", many hints are context sensitive)";
}

simulated function Timer()
{
    if(_player == None) {
        SetTimer(0, false);
        return;
    }
    if(class'DXRBigMessage'.static.GetCurrentBigMessage(_player) != None) {
        ShowHint();
    }
    else {
        SetTimer(0, false);
    }
}

static function AddDeath(DXRando dxr, #var(PlayerPawn) player)
{
    local DXRHints hints;
    hints = DXRHints(dxr.FindModule(class'DXRHints'));
    if(hints != None) {
        hints._player = player;
        hints.ShowHint();
    }
}

function RunTests()
{
    local int i, ln;
    Super.RunTests();

    test(numHints <= arrayCount(hintList), "numHints within bounds");

    for(i=0; i<numHints; i++) {
        ln = Len(hintList[i].line1);
        test(ln < 70, "length " $ ln $ " of hint: "$hintList[i].line1);

        ln = Len(hintList[i].line2);
        test(ln < 70, "length " $ ln $ " of hint detail: "$hintList[i].line2);
    }
}
