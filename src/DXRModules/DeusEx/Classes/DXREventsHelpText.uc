class DXREventsHelpText extends DXREventsBase;

static simulated function FindEventPrefixSuffix(string event, out string prefix, out string suffix)
{
    local string remain;
    local int idx, count;

    idx = -1;
    remain = event;
    prefix = "";
    suffix = "";
    count = 0;
    do{
        idx = InStr(remain,"_");
        if (idx!=-1){
            suffix = Left(remain,idx);
            if (prefix==""){
                prefix = suffix;
            }
            remain = Mid(remain,idx+1);
        } else {
            if (prefix!=""){
                suffix = remain;
            }
        }
        count++;
    }until(idx==-1 || count>10)
}

static simulated function bool IsPawnDeathSuffix(string suffix)
{
    //There are a lot of combinations of checks here, let's just check for keywords
    //rather than explicitly checking them all
    if (InStr(suffix,"Dead")!=-1) return true;
    if (InStr(suffix,"Unconscious")!=-1) return true;
    if (InStr(suffix,"Takedown")!=-1) return true;
    return false;
}

//This function branches out to the more case-specific help text functions
static simulated function string GetBingoGoalHelpText(string event,int mission, bool FemJC)
{
    local string prefix,suffix,msg;
    local int idx;

    //Get the prefix and suffix
    FindEventPrefixSuffix(event,prefix,suffix);

    //#region Which Function?
    //Look for help text in a function based on suffix...
    if (msg=="" && suffix!=""){
        if (IsPawnDeathSuffix(suffix)){
            msg = GetBingoHelpTextPawnDeaths(event,mission,FemJC);
        } else {
            switch (suffix){
                case "Played":
                case "Convo":
                case "ConvoFlag":
                case "VariousPlayed":
                    msg = GetBingoHelpTextConversations(event,mission,FemJC);
                    break;
                case "Activated":
                    msg = GetBingoHelpTextItemsUsed(event,mission,FemJC);
                    break;
                case "peepedtex":
                case "peeptime":
                case "peeped":
                    msg = GetBingoHelpTextPeeping(event,mission,FemJC);
                    break;
                case "DestroyDeco":
                    msg = GetBingoHelpTextDestroyDeco(event,mission,FemJC);
                    break;
            }
        }
    }

    //Look for help text in a function based on prefix...
    if (msg=="" && prefix!=""){
        switch(prefix){
            case "ImageOpened":
                msg = GetBingoHelpTextImages(event,mission,FemJC);
                break;
            case "WatchKeys":
                msg = GetBingoHelpNanoKeys(event,mission,FemJC);
                break;
            case "ReadText":
                msg = GetBingoHelpReadText(event,mission,FemJC);
                break;
            case "PawnState":
            case "PawnAnim":
                msg = GetBingoHelpTextPeeping(event,mission,FemJC);
                break;
        }
    }

    //If we haven't found anything, just go into the generic case
    if (msg==""){
        msg = GetBingoHelpTextGeneric(event,mission,FemJC);
    }
    //#endregion

    if (msg==""){
        msg = "Unable to find help text for event '"$event$"'|nReport this to the developers!";
    }

    return msg;


}

//#region Pawn Deaths
static simulated function string GetBingoHelpTextPawnDeaths(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "TerroristCommander_Dead":
        case "TerroristCommander_PlayerDead":
            return "Send him back to the people -- In a body bag!|n|nKill Leo Gold, the terrorist commander on Liberty Island.  You must kill him yourself.";
        case "TiffanySavage_Dead":
        case "TiffanySavage_PlayerDead":
            return "Kill Tiffany Savage.  She is being held hostage at the gas station.  You must kill her yourself.";
        case "PaulDenton_Dead":
            return "Let Paul Denton die (or kill him yourself) during the ambush on the hotel.";
        case "JordanShea_Dead":
        case "JordanShea_PlayerDead":
            return "Kill Jordan Shea, the bartender at the Underworld Tavern in New York.  You must kill her yourself.";
        case "SandraRenton_Dead":
        case "SandraRenton_PlayerDead":
        case "SandraRenton_PlayerTakedown":
            msg = "Take down Sandra Renton.  ";
            if (mission<=2){
                msg=msg$"She can be found in an alley next to the Underworld Tavern in New York";
            } else if (mission<=4){
                msg=msg$"She can be found inside the hotel";
            } else if (mission<=8){
                msg=msg$"She can be found in the Underworld Tavern";
            } else if (mission<=12){
                msg=msg$"She can be found outside the gas station";
            }
            msg = msg $ ".  You must kill or knock her out yourself.";
            return msg;
        case "GilbertRenton_Dead":
        case "GilbertRenton_PlayerDead": //old goal
            return "Kill Gilbert Renton.  He can be found behind the front desk in the 'Ton hotel.  You must kill him yourself.";
        case "GilbertRenton_PlayerTakedown":
            return "Take down Gilbert Renton.  He can be found behind the front desk in the 'Ton hotel.  You must kill or knock him out yourself.";
        case "WarehouseEntered":
            return "Enter the underground warehouse in Paris.  This warehouse is located in the building across the street from the entrance to the Catacombs.";
        case "GuntherHermann_Dead":
            return "Kill Gunther.  He can be found guarding a computer somewhere in the cathedral in Paris.";
        case "JoJoFine_Dead":
        case "JoJoFine_PlayerDead": //old goal
            return "Kill Jojo Fine.  He can be found in the 'Ton hotel before the ambush.  You must kill him yourself.";
        case "JoJoFine_PlayerTakedown":
            return "Take down Jojo Fine.  He can be found in the 'Ton hotel before the ambush.  You must kill or knock him out yourself.";
        case "TobyAtanwe_Dead":
        case "TobyAtanwe_PlayerDead": //old goal
            return "Kill Toby Atanwe, who is Morgan Everett's assistant.  He can be killed once you arrive at Everett's house.  You must kill him yourself.";
        case "TobyAtanwe_PlayerTakedown":
            return "Take down Toby Atanwe, who is Morgan Everett's assistant.  He can be killed or knocked out once you arrive at Everett's house.  You must kill or knock him out yourself.";
        case "Antoine_Dead":
        case "Antoine_PlayerDead": //old goal
            return "Kill Antoine in the Paris club.  He can be found at a table in a back corner of the club selling bioelectric cells.  You must kill him yourself.";
        case "Antoine_PlayerTakedown":
            return "Take down Antoine in the Paris club.  He can be found at a table in a back corner of the club selling bioelectric cells.  You must kill or knock him out yourself.";
        case "Chad_Dead":
        case "Chad_PlayerDead":
            return "Kill Chad Dumier.  He can be found in the Silhouette hideout in the Paris catacombs.  You must kill him yourself.";
        case "paris_hostage_Dead":
            return "Let both of the hostages in the Paris catacombs die (whether you do it yourself or not).  They can be found locked in the centre of the catacombs bunker occupied by MJ12.";
        case "Hela_Dead":
        case "Hela_PlayerDead": //old goal
            return "Kill Hela, the woman in black leading the MJ12 force in the Paris catacombs.  You must kill her yourself.";
        case "Hela_PlayerTakedown":
            return "Take down Hela, the woman in black leading the MJ12 force in the Paris catacombs.  You must kill or knock her out yourself.";
        case "Renault_Dead":
        case "Renault_PlayerDead": //old goal
            return "Kill Renault in the Paris hostel.  He is the man who asks you to steal zyme and will buy it from you.  You must kill him yourself.";
        case "Renault_PlayerTakedown":
            return "Take down Renault in the Paris hostel.  He is the man who asks you to steal zyme and will buy it from you.  You must kill or knock him out yourself.";
        case "Labrat_Bum_Dead":
        case "Labrat_Bum_PlayerDead": //old goal
            return "Kill the bum locked up in the Hong Kong MJ12 lab.  You must kill him yourself.";
        case "Labrat_Bum_PlayerTakedown":
            return "Take down the bum locked up in the Hong Kong MJ12 lab.  You must kill or knock him out yourself.";
        case "DXRNPCs1_Dead":
        case "DXRNPCs1_PlayerDead": //old goal
            return "Kill The Merchant.  He will randomly spawn in levels according to your chosen game settings.  You must kill him yourself.  Keep in mind that once you kill him, he will no longer appear for the rest of your run!";
        case "DXRNPCs1_PlayerTakedown":
            return "Take down The Merchant.  He will randomly spawn in levels according to your chosen game settings.  You must kill or knock him out yourself.  Keep in mind that once he has been taken down, he will no longer appear for the rest of your run!";
        case "lemerchant_Dead":
        case "lemerchant_PlayerDead": //old goal
            return "Kill Le Merchant.  He spawns near where you first land in Paris.  He's a different guy!  You must kill him yourself.";
        case "lemerchant_PlayerTakedown":
            return "Take down Le Merchant.  He spawns near where you first land in Paris.  He's a different guy!  You must kill or knock him out yourself.";
        case "Harold_Dead":
        case "Harold_PlayerDead": //old goal
            return "Kill Harold the mechanic.  He can be found working underneath the 747 in the LaGuardia hangar.  You must kill him yourself.";
        case "Harold_PlayerTakedown":
            return "Take down Harold the mechanic.  He can be found working underneath the 747 in the LaGuardia hangar.  You must kill or knock him out yourself.";
        case "aimee_Dead":
        case "aimee_PlayerDead": //old goal
            return "Kill Aimee, the woman worrying about her cats in Paris.  She can be found near where you first land in Paris.  You must kill her yourself.";
        case "aimee_PlayerTakedown":
            return "Take down Aimee, the woman worrying about her cats in Paris.  She can be found near where you first land in Paris.  You must kill or knock her out yourself.";
        case "WaltonSimons_Dead":
            msg="Kill Walton Simons.  ";
            if (mission<=14){
                msg=msg$"He can be found hunting you down somewhere in or around the Ocean Lab";
            } else if (mission==15){
                msg=msg$"He can be found hunting you down somewhere in Area 51";
            }
            msg=msg$".  You must kill him yourself.";
            return msg;
        case "JoeGreene_Dead":
        case "JoeGreene_PlayerDead":
            msg= "Kill Joe Greene, the reporter poking around in New York.  ";
            if (mission<=4){
                msg=msg$"He can be found in the Underworld Tavern";
            }else if (mission<=8){
                msg=msg$"He can be found somewhere in New York after you return from Hong Kong";
            }
            msg=msg$".  You must kill him yourself.";
            return msg;
        case "NiceTerrorist_Dead":
            return "Kill a friendly NSF trooper in the LaGuardia hangar.";
        case "JosephManderley_Dead":
        case "JosephManderley_PlayerDead":
            return "Kill Manderley while escaping from UNATCO.  You must kill him yourself.";
        case "SickMan_Dead":
        case "SickMan_PlayerDead":
            return "Kill the junkie in Battery Park who asks for someone to kill him.  He is typically found near the East Coast Memorial (the eagle statue and large plaques).  You must kill him yourself.";
        case "Greasel_ClassDead":
            return "Kill enough greasels.  You must kill them yourself.";
        case "UNATCOTroop_ClassDead":
            return "Kill enough UNATCO Troopers.  You must kill them yourself.";
        case "Terrorist_ClassDead":
            return "Kill enough NSF Troops.  You must kill them yourself.";
        case "MJ12Troop_ClassDead":
            return "Kill enough MJ12 Troopers.  You must kill them yourself.";
        case "MJ12Commando_ClassDead":
            return "Kill enough MJ12 Commandos.  You must kill them yourself.";
        case "Karkian_ClassDead":
            return "Kill enough karkians.  You must kill them yourself.";
        case "MilitaryBot_ClassDead":
            return "Destroy enough military bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "SecurityBot2_ClassDead":
            return "Destroy enough of the two legged walking security bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "SecurityBotSmall_ClassDead":
            return "Destroy enough of the smaller, treaded security bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "SpiderBot_ClassDead":
            return "Destroy enough spider bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "HumanStompDeath":
            return "Jump on enough humans heads until they die.  Note that people will not take stomp damage unless they are hostile to you, so you may need to hit them first to make them angry.";
        case "Rat_ClassDead":
            return "Kill enough rats.  You must kill them yourself.";
        case "UNATCOTroop_ClassUnconscious":
            return "Knock out enough UNATCO Troopers.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "Terrorist_ClassUnconscious":
            return "Knock out enough NSF Troops.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "MJ12Troop_ClassUnconscious":
            return "Knock out enough MJ12 Troopers.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "MJ12Commando_ClassUnconscious":
            return "Knock out enough MJ12 Commandos.  You can knock them out with things like the baton, prod, or tranq darts.  You must knock them out yourself.";
        case "Gray_ClassDead":
            return "Kill enough Grays.  You must kill them yourself.";
        case "JuanLebedev_Unconscious":
        case "JuanLebedev_PlayerUnconscious":
            return "Knock Lebedev out instead of killing him.  You must knock him out yourself.";
        case "AnnaNavarre_DeadM3":
            return "Kill Anna Navarre on the 747.  You must kill her yourself.";
        case "AnnaNavarre_DeadM4":
            return "Kill Anna Navarre after sending the signal for the NSF but before being captured by UNATCO.  You must kill her yourself.";
        case "AnnaNavarre_DeadM5":
            return "Kill Anna Navarre in UNATCO HQ.  You must kill her yourself.";
        case "MaySung_Dead":
        case "MaySung_PlayerDead": //old goal
            return "Kill May Sung, Maggie Chow's maid.  You must kill her yourself.";
        case "MaySung_PlayerTakedown":
            return "Take down May Sung, Maggie Chow's maid.  You must kill or knock her out yourself.";
        case "CleanerBot_ClassDead":
            return "Destroy enough cleaner bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "MedicalBot_ClassDead":
            return "Destroy enough medical bots or aug bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "RepairBot_ClassDead":
            return "Destroy enough repair bots.  You must destroy them yourself and disabling them with EMP does not count.";
        case "UtilityBot_ClassDead":
            return "Destroy enough utility bots (medical bots, aug bots, or repair bots).  You must destroy them yourself and disabling them with EMP does not count.";
        case "DrugDealer_Dead":
        case "DrugDealer_PlayerDead":
            return "Kill Rock, the drug dealer who lives in Brooklyn Bridge Station.  You must kill him yourself.";
        case "JerryTheVentGreasel_Dead":
        case "JerryTheVentGreasel_PlayerDead": //old goal
            return "Kill the greasel in the vents over the main hall of the MJ12 Lab in Hong Kong.  His name is Jerry and he is a good boy.  You must kill him yourself.";
        case "JerryTheVentGreasel_PlayerTakedown":
            return "Take down the greasel in the vents over the main hall of the MJ12 Lab in Hong Kong.  His name is Jerry and he is a good boy.  You must kill or knock him out yourself.";
        case "FordSchick_Dead":
        case "FordSchick_PlayerDead":
            return "Kill Ford Schick.  Note that you can do this after rescuing him if you're fast.  You must kill him yourself.";
        case "Sailor_ClassDeadM6":
            return "Kill enough of the sailors on the top floor of the Lucky Money club.  You must kill them yourself.";
        case "Shannon_Dead":
        case "Shannon_PlayerDead": //Old goals
            return "Kill Shannon in UNATCO HQ as retribution for her thieving ways.  You must kill her yourself.";
        case "Shannon_PlayerTakedown":
            return "Take down Shannon in UNATCO HQ as retribution for her thieving ways.  You must kill or knock her out yourself.";
        case "Canal_Cop_Dead":
        case "Canal_Cop_PlayerDead": //Old goal
            return "Kill one of the Chinese Military in the Hong Kong canals standing near the entrance to Tonnochi Road.  You must kill him yourself.";
        case "Canal_Cop_PlayerTakedown":
            return "Take down one of the Chinese Military in the Hong Kong canals standing near the entrance to Tonnochi Road.  You must kill or knock him out yourself.";
        case "Chef_ClassDead":
            return "Do what needs to be done and kill a chef.  You must kill him yourself.";
        case "ScubaDiver_ClassDead":
            return "Kill enough SCUBA divers in and around the Ocean Lab.  You must kill them yourself.";
        case "WIB_ClassDeadM11":
            return "Kill Adept 34501, the Woman in Black living in the cathedral.  You must kill her yourself.";
        case "jughead_Dead":
        case "jughead_PlayerDead": //old goal
            return "Kill El Rey, the leader of the Rooks in the Brooklyn Bridge Station.  You must kill him yourself.";
        case "jughead_PlayerTakedown":
            return "Take down El Rey, the leader of the Rooks in the Brooklyn Bridge Station.  You must kill or knock him out yourself.";
        case "ThugGang_AllianceDead":
            return "Slaughter most of the Rooks in the Brooklyn Bridge Station.  You must kill them yourself.";
        case "MarketKid_Unconscious":
        case "MarketKid_PlayerUnconscious":
            return "Knock out Louis Pan, the kid running a protection racket for the Luminous Path in the Wan Chai Market.  You must knock him out yourself.  Crime (sometimes) doesn't pay.";
        case "HowardStrong_PlayerDead":
        case "HowardStrong_PlayerTakedown":
            return "Take down Howard Strong, the MJ12 engineer in charge of the operations at the missile silo.  You must kill or knock him out yourself.";
        case "PerformBurder_ClassDead":
            return "Kill enough birds.  These can be either pigeons or seagulls.";
        case "GoneFishing_ClassDead":
            return "Kill enough fish.";
        case "DestroyCapitalism_VariousDead":
            msg = "Kill enough people willing to sell you goods in exchange for money.  You must kill them yourself.|nThe Merchant may be elusive, but he must be eliminated when spotted.|n|n";
            if (mission<=1){
                msg=msg$"Tech Sergeant Kaplan and the woman in the hut on the North Dock both absolutely deserve it.  Shannon is also acting suspicious.";
            } else if (mission<=2){
                msg=msg$"Jordan Shea and Sally in the bar, the doctors in the Free Clinic, and the pimp in the alleys deserve it.";
            } else if (mission<=3){
                msg=msg$"There is a veteran in Battery Park, El Rey and Rock in Brooklyn Bridge Station, and Harold in the hangar.  They all deserve it.  Shannon seems like she might be up to something too.";
            } else if (mission<=4){
                msg=msg$"Jordan Shea and Shannon deserve it.";
            } else if (mission<=5){
                msg=msg$"Sven the mechanic and Shannon both deserve it.";
            } else if (mission<=6){
                msg=msg$"Hong Kong is overflowing with capitalist pigs:|n";
                msg=msg$" - The tea house waiter in the market needs to go.|n";
                msg=msg$" - In the VersaLife offices, you can eliminate Mr. Hundley.|n";
                msg=msg$" - In the canals, you must end the life of the Old China Hand bartender, the man selling maps there, and the smuggler on the boat.|n";
                msg=msg$" - In the Lucky Money, you must eliminate the bartender, the bouncer, the mamasan selling escorts, and the doorgirl.";
            } else if (mission<=8){
                msg=msg$"Jordan Shea needs to go.";
            } else if (mission<=10){
                msg=msg$"Paris is filled with filthy capitalists:|n";
                msg=msg$" - Before the catacombs, you must eliminate Le Merchant and Defoe the arms dealer.|n";
                msg=msg$" - In the catacombs, the man in Vault 2 needs to go.|n";
                msg=msg$" - In the Champs D'Elysees streets, you must end the hostel bartender, Renault the drug dealer, and Kristi in the cafe.|n";
                msg=msg$" - In the club, you can annihilate Camille the dancer, Jean the male bartender, Michelle the female bartender, Antoine the biocell seller, Louis the doorman, Cassandra the woman offering to sell information, and Jocques the worker in the back room.  ";
            } else if (mission<=11){
                msg=msg$"The technician in the metro station needs to be stopped.";
            } else if (mission<=12){
                msg=msg$"The bum living at the Vandenberg gas station deserves it.";
            }
            msg = msg$"|n|n(It's a Simpsons reference)";
            return msg;
        case "ScienceIsForNerds_VariousDead":
            return "Scientists think they're so much smarter than you.  Show them how smart your weapons are and kill enough of those nerds in lab coats.";
        case "Ex51_VariousDead":
            return "Kill enough of the named X51 scientists in Vandenberg.|n|n - Carla Brown on the roof|n - Stacy Webber in front of the hazard lab|n - Tim Baker in the closet near the hazard lab|n"$" - Stephanie Maxwell near the command room doors|n - Tony Mares in the comms building|n - Ben Roper in the command room|n"$" - Latasha Taylor in the command room|n - Stacey Marshall in the command room (with LDDP installed)";

    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region Conversations
static simulated function string GetBingoHelpTextConversations(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "BathroomBarks_Played":
            return "Enter the wrong bathroom in UNATCO HQ on your first visit.";
        case "MeetAI4_Played":
            return "Talk to Morpheus, the prototype AI locked away in Everett's house.";
        case "DL_Flooded_Played":
            return "Swim outside of the Ocean Lab on the ocean floor and enter the flooded section through the hole blasted in the underside of the structure.  There is a flickering light above the hole you need to enter.";
        case "M07ChenSecondGive_Played":
            return "After the triad meeting in the temple, meet the leaders in the Lucky Money and receive all the gifted bottles of wine from each Dragon Head.";
        case "MeetTimBaker_Played":
            return "Enter the storage room in Vandenberg near the Hazard Lab and talk to Tim Baker.";
        case "MeetDrBernard_Played":
            return "Find Dr. Bernard, the scientist locked in the bathroom at the silo.";
        case "IcarusCalls_Played":
            return "Answer the phone in the building across from the entrance to the catacombs in Paris.";
        case "PageTaunt_Played":
            return "After recovering the schematics for the Universal Constructor below the Ocean Lab, talk to Bob Page on the communicator before leaving.";
        case "M07MeetJaime_Played":
            return "Meet Jaime in Tracer Tong's hideout in Hong Kong.  Note that he will only meet you in Hong Kong if you ask him to meet you there while you escape from the MJ12 base under UNATCO.";
        case "DL_gold_found_Played":
            return "Find the templar gold in the basement of the Paris cathedral.";
        case "FamilySquabbleWrapUpGilbertDead_Played":
            return "Talk to Sandra Renton after Gilbert and JoJo both die in Mission 4.  He was a good man... What a rotten way to die.";
        case "DL_SecondDoors_Played":
            return "You need to open them.|n|nTry to leave the Ocean Lab while the sub-bay doors are closed.";
        case "MeetScaredSoldier_Played":
            return "Talk to Xander, the sole surviving soldier hiding out in the building inside the hangar in Area 51.";
        case "MeetRenault_Played":
            return "Talk to Renault, in the Paris hostel.  He is the man who asks you to steal zyme and will buy it from you.";
        case "M04PlayerLikesUNATCO_Played":
            return "Tell Paul you won't send the distress signal after going to the NSF base.";
        case "M05MeetJaime_Played":
            return "Talk to Jaime while escaping UNATCO and tell him to stay or to join you in Hong Kong.";
        case "JoshuaInterrupted_Played":
            return "Learn the login for the computer in the MJ12 guard shack from a trooper's father in a Paris cafe.";
        case "OverhearLebedev_Played":
            return "Listen to a phone conversation in the airfield helibase between Juan Lebedev and Tracer Tong.  It can be heard in one of the offices.";
        case "MeetInjuredTrooper2_Played":
            return "Talk to the injured trooper in the UNATCO HQ Medical Lab.";
        case "MeetSandraRenton_Played":
            return "Rescue Sandra Renton from Johnny, the pimp who has her cornered in the alley beside the Underworld Tavern.";
        case "TriadCeremony_Played":
            return "Become a witness to the truce ceremony between the Luminous Path and the Red Arrow triads.";
        case "ClubEntryPaid_Convo":
           if (FemJC) {
#ifdef revision
               return "Let Noah, the man waiting outside the Lucky Money, pay to get you into the club.";
#else
               return "Let Russ, the man waiting outside the Lucky Money, pay to get you into the club.";
#endif
           } else {
               return "Give Mercedes and Tessa (the two women waiting outside the Lucky Money) money to get into the club.";
           }
        case "ParisClubInfo_Convo":
            if (FemJC) {
                return "Talk to Achille, the Paris clubgoer who wants to tell you about everyone else in the club.  Get as much information as you can.";
            } else {
                return "Talk to Camille the Paris cage dancer and get all the information you can.";
            }
        case "WaltonConvos_VariousPlayed":
            msg="Have enough conversations with Walton Simons.  ";
            if (mission<=3){
                msg=msg$"He can be found in Manderley's office after destroying the generator.";
            } else if (mission<=4){
                msg=msg$"He can be found in the UNATCO break room talking with Jaime Reyes.";
            } else if (mission<=5){
                msg=msg$"He can be found talking with Manderley via hologram.";
            } else if (mission<=11){
                msg=msg$"He can be found as a hologram in the basement of the cathedral after killing Gunther.";
            } else if (mission<=14){
                msg=msg$"He can be found somewhere around the Ocean Lab after retrieving the Universal Constructor schematics.";
            } else if (mission<=15){
                msg=msg$"He can be found somewhere around Area 51.";
            }
            return msg;
        case "SnitchDowd_ConvoFlag":
            return "Ask Joe Greene or Jordan Shea about Stanton Dowd.";
        case "GiveZyme_ConvoFlag":
            return "Give zyme to the two junkies in the Brooklyn Bridge Station.";
        case "InterviewLocals_VariousPlayed":
            return "Interview some of the locals around Hell's Kitchen to find out more information about the NSF generator.";
        case "MeetSmuggler_VariousPlayed":
            return "Talk to Smuggler in his Hell's Kitchen hideout.";
        case "PaulsDatavault_VariousPlayed":
            return "Find Paul somewhere in the MJ12 Lab and retrieve his datavault so that Tong can defeat the killswitch.";
        case "MeetDowd_VariousPlayed":
            if (mission<=8){
                return "Talk with Stanton Dowd in the burned out remains of the Osgoode & Sons building in Hells Kitchen.";
            } else {
                return "Talk with Stanton Dowd in the family mausoleum in the graveyard.";
            }
        case "NicoletteHouseTour_VariousPlayed":
            return "Escort Nicolette around the Chateau and let her tell you about it.  Potential points of interest include the study, the living room, the upper hallway, Beth's room, the basement, near the back door, and by the maze.";
        case "M04GreenAdvice_Played":
            return "Try to get help from Joe Greene after the raid.";
    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region Items Used
static simulated function string GetBingoHelpTextItemsUsed(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "Sodacan_Activated":
            return "Chug enough cans of soda.";
        case "BallisticArmor_Activated":
            return "Equip enough ballistic armour.";
        case "Flare_Activated":
            return "Light enough flares.";
        case "VialAmbrosia_Activated":
            return "After finding the vial of ambrosia somewhere on the upper decks of the superfreighter, drink it instead of saving it for Stanton Dowd.|n|nThere is also a vial of ambrosia in a small box in the Ocean Lab.";
        case "Binoculars_Activated":
            return "Find and use a pair of binoculars.";
        case "HazMatSuit_Activated":
            return "Use enough hazmat suits.";
        case "AdaptiveArmor_Activated":
            return "Wear enough thermoptic camo.";
        case "TechGoggles_Activated":
            return "Wear enough pairs of tech goggles.";
        case "Rebreather_Activated":
            return "Equip enough rebreathers.";
        case "FireExtinguisher_Activated":
            return "Use enough fire extinguishers.";
        case "DrinkAlcohol_Activated":
            return "Get absolutely tanked and drink enough alcohol.  This can be liquor, a forty, or wine.";

    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region Destroy Deco's
static simulated function string GetBingoHelpTextDestroyDeco(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "LightVandalism_DestroyDeco":
            return "Destroy enough lamps throughout the game.  This might be chandeliers, desk lamps, hanging lights, pool table lights, standing lamps, or table lamps.";
        case "TrophyHunter_DestroyDeco":
            msg = "Destroy enough trophies.  ";
            if (mission<=1){
                msg=msg$"Multiple trophies can be found in UNATCO HQ (in the offices and above ground).";
            } else if (RevisionMaps && mission<=2){
                msg=msg$"There is a trophy in the basement of the Underworld Tavern.";
            } else if (mission<=3){
                msg=msg$"Multiple trophies can be found in UNATCO HQ (in the offices and above ground).  Several can also be found in the LaGuardia Helibase.";
            } else if (RevisionMaps && mission<=4){
                msg=msg$"There is a trophy in the basement of the Underworld Tavern.";
            } else if (mission<=5){ //Mission 4 and 5 both only have trophies at HQ
                msg=msg$"Multiple trophies can be found in UNATCO HQ (in the offices and above ground).";
            } else if (mission<=6){
                msg=msg$"There are many trophies in Hong Kong.  One can be found in the Helibase, another one around the canals, and one on Tonnochi Road.";
            } else if (RevisionMaps && mission<=8){
                msg=msg$"There is a trophy in the basement of the Underworld Tavern.";
            } else if (mission<=10){
                msg=msg$"There is a trophy in Chateau DuClare.";
            } else if (RevisionMaps && mission<=12){
                msg=msg$"There are four trophies in the cabinet of the commanders office outside the Vandenberg Command building.";
            }
            return msg;
        case "SlippingHazard_DestroyDeco":
            msg = "Destroy enough 'Wet Floor' signs, leaving the area unmarked and dangerous.";
            if (mission<=1){
                msg = msg$"  There are signs in UNATCO HQ.";
            } else if (mission<=2){
                msg = msg$"  There is a sign in the hotel.";
            } else if (mission<=3){
                msg = msg$"  There are signs in UNATCO HQ.";
            } else if (mission<=4){
                msg = msg$"  There are signs in UNATCO HQ, and another one in the hotel.";
            } else if (mission<=5){
                msg = msg$"  There are signs in UNATCO HQ.";
            } else if (mission<=6){
                msg = msg$"  There is a sign in the MJ12 Helibase and on Tonnochi road.";
            } else if (mission<=8){
                msg = msg$"  There is a sign in the hotel.";
            } else if (mission<=9){
                msg = msg$"  There are signs on the lower decks of the superfreighter.";
            } else if (RevisionMaps && mission<=10){
                msg = msg$"  There is a sign in the store room of the Paris Club (La Porte De L'Enfer).";
            }
            return msg;
        case "BeatTheMeat_DestroyDeco":
            return "Destroy enough hanging slaughtered chickens or pigs.";
        case "WhyContainIt_DestroyDeco":
            return "Destroy a barrel of the gray death virus.  Barrels can be found around the Vandenberg command building, in the Sub Base, and around the Universal Constructor under the Ocean Lab.";
        case "MailModels_DestroyDeco":
            return "Destroy enough mailboxes.  They can be found in the streets of New York.";
        case "SmokingKills_DestroyDeco":
            return "Destroy enough cigarette vending machines.  Smoking kills!";
        case "BuoyOhBuoy_DestroyDeco":
            return "Destroy enough buoys through the game.";
        case "ASingleFlask_DestroyDeco":
            return "Destroy enough flasks through the game.";
        case "PCLOADLETTER_DestroyDeco":  //Revision only (They added a printer)
            return "PC LOAD LETTER?  What the hell does that mean?  Show a network printer who's the boss and absolutely obliterate it.";
        case "FightSkeletons_DestroyDeco":
            msg = "Destroy enough femurs or skulls.  Don't let the skeletons rise up!  ";
            if (RevisionMaps && mission<=2){
                msg=msg$"Some bones can be found in an apartment overlooking the basketball court, in the Free Clinic, and in the basement of the Underworld Tavern.";
            } else if (mission<=4){
                if (RevisionMaps){
                    msg=msg$"Some bones can be found in an apartment overlooking the basketball court, in the Free Clinic, and in the basement of the Underworld Tavern.  There is also a skull in NSF HQ";
                } else {
                    msg=msg$"A skull can be found in the NSF HQ.";
                }
            } else if (mission<=6){
                msg=msg$"A skull can be found in the Hong Kong VersaLife level 1 labs, as well as in Tracer Tong's hideout and in the Wan Chai Market.";
            } else if (RevisionMaps && mission<=8){
                msg=msg$"Some bones can be found in an apartment overlooking the basketball court, in the Free Clinic, and in the basement of the Underworld Tavern.";
            } else if (mission<=10){
                msg=msg$"The Paris catacombs are just completely loaded with skulls and femurs.";
            } else if (!RevisionMaps && mission<=11){
                msg=msg$"A skull can be found underwater at the Cathedral.";
            } else if (mission<=14){
                msg=msg$"Several skulls and femurs can be found in the OceanLab on the ocean floor.";
            }
            return msg;
        case "Dehydrated_DestroyDeco":
            return "Destroy enough water coolers or water fountains.";
    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region Images
static simulated function string GetBingoHelpTextImages(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "ImageOpened_ViewPortraits":
            return "Find and view enough portraits.  These include the picture of Leo Gold (the terrorist commander), the magazine cover showing Bob Page, the image of Joe Greene, and the image of Tiffany Savage.";
        case "ImageOpened_ViewSchematics":
            return "Find and view enough schematics.  These include the schematic of the Universal Contructor and the schematic of the blue fusion reactors.";
        case "ImageOpened_ViewMaps":
            msg = "Find and view enough maps of different areas.";

            if (mission<=1){
                msg = msg $ "|n|nPaul has a map of Liberty Island available for you before you find the terrorist commander.";
            }

            return msg;
        case "ImageOpened_ViewDissection":
            return "Find and view enough images of dissections.  This includes the images of a greasel and a gray being dissected.";
        case "ImageOpened_ViewTouristPics":
            return "Find and view enough tourist photos of places.  This includes images of the entrance to the cathedral, images of the catacombs, and the image of the NSF headquarters.";
        case "ImageOpened_WaltonSimons":
            return "Find and look at the image displaying Walton Simons' augmentations.";
    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region NanoKeys
static simulated function string GetBingoHelpNanoKeys(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "WatchKeys_DuClareKeys":
            return "Find enough different keys around Chateau DuClare.  Keys include the key to Beths Room, Nicolettes Room, and to the Basement.";
        case "WatchKeys_ShipLockerKeys":
            return "Find keys to the lockers on the lower decks of the superfreighter.  The lockers are inside the building underneath the helipad.";
        case "WatchKeys_cabinet":
            return "Find the key that opens the filing cabinets in the back of the greasel lab in the MJ12 base underneath UNATCO.  This is typically held by whoever is sitting at the desk in the back part of that lab.";
        case "WatchKeys_maintenancekey":
            return "Find the maintenance key in the tunnels underneath Vandenberg.";
    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region Reading
static simulated function string GetBingoHelpReadText(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "ReadText_KnowYourEnemy":
            return "Read enough \"Know Your Enemy\" bulletins on the public computer in the UNATCO break room.";
        case "ReadText_JacobsShadow":
            msg="Read enough chapters of Jacob's Shadow.  ";
            if (class'MenuChoice_GoalTextures'.static.BookColoursShouldChange()){
                msg = msg$"The books will have a purple cover.  ";
            }
            if (mission<=2){
                msg=msg$"There is a chapter in the MJ12 sewer base in Hell's Kitchen.  This copy of the book will be closed.";
            } else if (mission<=3){
                msg=msg$"There is a chapter in the LaGuardia Helibase.  This copy of the book will be closed.";
            } else if (mission<=4){
                msg=msg$"There is a chapter in the 'Ton hotel.  This copy of the book will be closed.";
            } else if (mission<=6){
                msg=msg$"There is a chapter in the Wan Chai Market.  This copy of the book will be closed.";
            } else if (mission<=9 && dxr.localURL!="09_NYC_GRAVEYARD"){
                msg=msg$"There is a chapter in the lower decks of the Superfreighter.  This copy of the book will be open.";
            } else if (mission<=10){
                msg=msg$"There is a chapter in the DuClare Chateau.  This copy of the book will be closed.";
            } else if (mission<=12){
                msg=msg$"There is a chapter in Vandenberg Command and the Computer area.  This copy of the book will be open.";
            } else if (mission<=15){
                msg=msg$"There is a chapter in Area 51 on the surface, and in Sector 2.  These copies of the book will be open.";
            }
            return msg;
        case "ReadText_ManWhoWasThursday":
            msg="Read enough chapters of The Man Who Was Thursday.  ";
            if (class'MenuChoice_GoalTextures'.static.BookColoursShouldChange()){
                msg = msg$"The books will have a red cover.  ";
            }
            if (mission<=2){
                msg=msg$"There is a chapter inside the 'Ton hotel and in the sewers.  These copies of the book will be closed.";
            } else if (mission<=3){
                msg=msg$"There is a chapter in the LaGuardia helibase.  This copy of the book will be closed.";
            } else if (mission<=4){
                msg=msg$"There is a chapter inside the 'Ton hotel.  This copy of the book will be closed.";
            } else if (mission<=10){
                msg=msg$"There is a chapter in Denfert-Rochereau square, the streets and buildings before entering the Paris catacombs.  This copy of the book will be closed.";
            } else if (mission<=12){
                msg=msg$"There is a chapter in Vandenberg Command.  This copy of the book will be open.";
            } else if (mission<=14){
                msg=msg$"There is a chapter in the Ocean Lab.  This copy of the book will be closed.";
            } else if (mission<=15){
                msg=msg$"There is a chapter in Sector 3 of Area 51.  This copy of the book will be open.";
            }
            return msg;
        case "ReadText_GreeneArticles":
            msg="Read enough news articles written by Joe Greene of the Midnight Sun.  ";
            if (mission<=1){
                msg=msg$"There's one on Liberty Island, and one in UNATCO HQ.";
            } else if (mission<=2){
                msg=msg$"There is an article somewhere around the NSF warehouse.";
            } else if (mission<=3){
                msg=msg$"There are 3 copies of the same article: in Brooklyn Bridge Station, in the helibase, and in the 747.";
            } else if (mission<=8){
                msg=msg$"There is an article in the streets of Hell's Kitchen and in the bar.";
            }
            return msg;
        case "ReadText_MoonBaseNews":
            msg="Read an article talking about the mining complex located on the moon.  ";
            if (mission<=2){
                msg=msg$"There is an article in the streets of Hell's Kitchen.";
            } else if (mission<=3){
                msg=msg$"There is an article in the LaGuardia Helibase.";
            } else if (mission<=6){
                msg=msg$"There is an article in the Wan Chai Market as well as the Lucky Money.";
            }
            return msg;
        case "ReadText_06_Datacube05":
            return "Find the datacube on Tonnochi Road from Louis Pan reminding Maggie that he will never forget her birthday again.";
        case "ReadText_CloneCubes":
            return "Read enough datacubes regarding the cloning projects at Area 51.  There are 8 datacubes scattered through Sector 4 of Area 51.";
        case "ReadText_UNATCOHandbook":
            return "Find and read enough UNATCO Handbooks scattered around HQ.";
        case "ReadText_02_Book06":
            return "Read a guide to basic firearm safety.  Smuggler likes to keep a copy of this lying around somewhere.";
        case "ReadText_11_Book08":
            return "Read the diary of Adept 34501, the Woman in Black living in the Paris cathedral.";
        case "ReadText_JoyOfCooking":
            return "Read a recipe from a book and experience the joy of cooking!|n|nThere is a recipe for Chinese Silver Loaves in the Wan Chai Market, and a recipe for Coq au Vin in the streets of Paris.";
        case "ReadText_12_Email04":
            return "Read the email from Gary Savage with the subject line 'We Must Stand'.  This can be found on the computer in the reception area of the main Vandenberg building, as well as inside the computer area of Vandenberg.";
        case "ReadText_ReadJCEmail":
            return "Check your email enough times.  This can be done either in UNATCO HQ or in Tracer Tong's hideout.";
        case "ReadText_02_Email05":
            return "Read Paul's emails and find out what classic movies he has ordered.";
        case "ReadText_15_Email02":
            return "Read an email discussing the true origin of the Grays.  This can be found on a computer in Sector 3 of Area 51.";
        case "ReadText_09_Email08":
            return "Read an email from Captain Zhao's daughter on his computer on the superfreighter.";
        case "ReadText_05_EmailMenu_psherman":
            return "Log into and read the email of Agent Sherman, the MIB in the secret MJ12 Lab.";
        case "ReadText_08_Bulletin02":
            return "Read your wanted poster on a public news terminal when returning to New York.";
        case "ReadText_11_Bulletin01":
            return "Read about the cathedral on a public computer.  These can be found on the streets near the metro, as well as inside the metro.";
    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region Peeping
static simulated function string GetBingoHelpTextPeeping(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "un_PrezMeadPic_peepedtex":
            if (RevisionMaps){
                return "Look closely at a picture of President Mead using a pair of binoculars or a scope.  This can be found in UNATCO HQ (both above and below ground) or in the basement of the Underworld Tavern.";
            } else {
                return "Look closely at a picture of President Mead using a pair of binoculars or a scope.  This can be found in UNATCO HQ (both above and below ground).";
            }
        case "un_bboard_peepedtex":
            return "Look at the bulletin board in the UNATCO HQ break room through a pair of binoculars or a scope.";
        case "DrtyPriceSign_A_peepedtex":
            return "Check the gas prices through a pair of binoculars or a scope at the abandoned Vandenberg Gas Station.";
        case "GS_MedKit_01_peepedtex":
            return "Use a pair of binoculars or a scope to find a representation of the Red Cross (A red cross on a white background) in the Vandenberg Gas Station.  Improper use of the emblem is a violation of the Geneva Conventions.";
        case "DangUnstabCond_peepedtex":
            return "Carefully inspect the wording on the Area Condemned signs near the top of the Statue of Liberty using binoculars or a scope.";
        case "pa_TrainSign_D_peepedtex":
            return "Take a close look at the map of the Paris metro lines using binoculars or a scope.";
        case "FC_EyeTest_peepedtex":
            return "Look at a Snellen Chart (One of those eye exams with the differently sized letters) in the Free Clinic through binoculars or a scope.  Make sure to stand further back so it isn't cheating!";
        case "Terrorist_peeptime":
            return "Watch NSF Troops through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "UNATCOTroop_peeptime":
            return "Watch UNATCO Troopers through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "MJ12Troop_peeptime":
            return "Watch MJ12 Troopers through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "MJ12Commando_peeptime":
            return "Watch MJ12 Commandos through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "Cat_peeptime":
            return "Watch cats through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "Binoculars_peeptime":
            return "Watch binoculars through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "NYEagleStatue_peeped":
            return "Look at the bronze eagle statue in Battery Park through a pair of binoculars or a scope.";
        case "BirdWatching_peeptime":
            return "Watch birds through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "ShipNamePlate_peeped":
            return "Use binoculars or a scope to check the name marked on the side of the superfreighter.";
        case "WatchDogs_peeptime":
            return "Watch dogs through binoculars or a scope for enough time.  Note that this will only count in full second increments, so you need to keep the crosshairs centered!";
        case "PawnAnim_Dance":
            return "Watch someone dance through a pair of binoculars or a scope.  There should be someone vibing in a bar or club.";
        case "Player_peeped":
            return "Observe yourself in a mirror through binoculars or a scope.";
        case "EmergencyExit_peeped":
            msg = "Know your exit in case of an emergency!  Locate enough emergency exit signs through the game by looking at them through binoculars or a scope.";
            if (mission==10 || mission==11){
                msg = msg $"|n|nThe French word for 'Exit' is 'Sortie'.";
            }
            return msg;
    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion

//#region Generic
static simulated function string GetBingoHelpTextGeneric(string event,int mission, bool FemJC)
{
    local string msg;
    local DXRando dxr;
    local bool RevisionMaps;

    dxr = class'DXRando'.default.dxr;
    RevisionMaps = class'DXRMapVariants'.static.IsRevisionMaps(dxr.player);

    switch(event){
        case "Free Space":
            return "Don't worry about it!  This one's free!";
        case "WarehouseEntered":
            return "Enter the underground warehouse in Paris.  This warehouse is located in the building across the street from the entrance to the Catacombs.";
        case "GuntherFreed":
            return "Free Gunther from the makeshift jail on Liberty Island.  The jail is just inside the base of the statue.";
        case "GotHelicopterInfo":
            return "Help Jock locate the bomb planted in his helicopter by killing the fake mechanic.";
        case "JoshFed":
            return "Give Josh some soy food or a candy bar.  Josh is a kid located on the docks of Battery Park.";
        case "M02BillyDone":
            return "Give Billy some soy food or a candy bar.  Billy is a kid located in the kiosk of Castle Clinton.";
        case "FordSchickRescued":
            return "Rescue Ford Schick from the MJ12 lab in the sewers under New York on your first visit to Hell's Kitchen.  The key to the sewers can be gotten from Smuggler.";
        case "M10EnteredBakery":
            return "Enter the bakery in the streets of Paris.  The bakery can be found across the street from the Metro.";
        case "FreshWaterOpened":
            return "Fix the fresh water supply in Brooklyn Bridge Station.  The water valves are behind some collapsed rubble.";
        case "assassinapartment":
            return "Visit the apartment in Paris that has Starr the dog inside.  This apartment is over top of the media store, but is accessed from the opposite side of the building near where Jock picks you up.";
        case "PetAnimal_BindName_Starr":
            return "Visit the apartment in Paris and pet Starr, the dog inside.  This apartment is over top of the media store, but is accessed from the opposite side of the building near where Jock picks you up.";
        case "GaveRentonGun":
            return "Give Gilbert Renton a gun when he is trying to protect his daughter from JoJo Fine, before the ambush.";
        case "DXREvents_LeftOnBoat":
            return "After destroying the NSF generator, return to Battery Park and take the boat back to UNATCO.";
        case "AlleyBumRescued":
            return "On your first visit to Battery Park, rescue the bum being mugged on the basketball court.  The court can be found behind the subway station.";
        case "FoundScientistBody":
            return "Enter the collapsed tunnel under the canals and find the scientist body.  The tunnel can be accessed through the vents in the freezer of the Old China Hand.";
        case "M08WarnedSmuggler":
            return "After talking to Stanton Dowd, talk to Smuggler and warn him of the impending UNATCO raid.";
        case "ShipPowerCut":
            return "Help the electrician on the superfreighter by disabling the electrical panels under the electrical room.";
        case "JockSecondStory":
            return "Buy two beers from Jordan Shea and give them to Jock in the Underworld Tavern.";
        case "DeBeersDead":
            return "Kill Lucius DeBeers in Everett's House.  You can do so either by destroying him or shutting off his bio support with the computer next to him.";
        case "StantonAmbushDefeated":
            return "Defend Stanton Dowd from the MJ12 ambush after talking to him.";
        case "SmugglerDied":
            return "Let Smuggler die by not warning him of the UNATCO raid.  This can be done either by not talking to him at all, or not warning him of the raid if you talk to him after talking to Dowd.";
        case "GaveDowdAmbrosia":
            return "Find a vial of ambrosia on the upper decks of the superfreighter and bring it to Stanton Dowd in the graveyard.";
        case "JockBlewUp":
            return "Don't kill the fake mechanic at Everett's house so that Jock dies when you arrive in Area 51.";
        case "SavedPaul":
            return "Save Paul during the ambush on the 'Ton hotel.";
        case "nsfwander":
            return "Escort Miguel, the captured NSF troop, out of the MJ12 base underneath UNATCO HQ.";
        case "MadeBasket":
            return "Throw the basketball into the net in Hell's Kitchen.";
        case "BoughtClinicPlan":
            return "On your first visit to Hell's Kitchen, go to the free clinic and buy the full treatment plan from the doctors.";
        case "ExtinguishFire":
            return "Put yourself out by using a shower, sink, toilet, or urinal while on fire.  You can light yourself on fire with WP Rockets or by jumping onto a burning barrel.";
        case "SubwayHostagesSaved":
            return "Ensure both hostages in the Battery Park subway station escape on the train.";
        case "HotelHostagesSaved":
            return "Rescue the hostages on the top floor of the 'Ton as well as Gilbert Renton.";
        case "SilhouetteHostagesAllRescued":
            return "Save both hostages in the Paris catacombs and escort them to safety in the Silhouette hideout.";
        case "MadeItToBP":
            return "After the raid on the 'Ton hotel, escape to Gunther's roadblock in Battery Park.";
        case "M06PaidJunkie":
            return "Visit the junkie living on the floor under construction below Maggie Chow's apartment.  Give her money.";
        case "M06BoughtVersaLife":
            return "Buy the maps of Versalife from the guy in the Old China Hand bar, by the canal.";
        case "FlushToilet":
            return "Find and flush enough different toilets.  Note that toilets in places that you revisit (like UNATCO HQ) will count again on each visit.";
        case "FlushUrinal":
            return "Find and flush enough different urinals.  Note that urinals in places that you revisit (like UNATCO HQ) will count again on each visit.";
        case "KnowsGuntherKillphrase":
            return "Learn Gunther's killphrase from Jaime in Paris.  Note that he will only meet you in Paris if you ask him to stay with UNATCO while you escape from the MJ12 base.";
        case "KnowsAnnasKillphrase":
            return "Learn both parts of Anna's killphrase in UNATCO HQ after escaping from the MJ12 lab.  The killphrase is split across two computers in HQ.  There will be a datacube on Manderley's desk with hints to the location of the parts of the killphrase.";
        case "Area51FanShaft":
            return "In Area 51, jump down the ventilation shaft inside the hangar.";
        case "PoliceVaultBingo":
            return "Enter the police vault in the Wan Chai Market.";
        case "SunkenShip":
            return "Enter the ship that has sunk off the North Dock of Liberty Island (Near Harley Filben).";
        case "SpinShipsWheel":
            msg="Spin enough ships wheels.  ";
            if (mission<=1){
                msg=msg$"There is a ships wheel on the wall of the hut Harley Filben is in.";
            }else if (RevisionMaps && mission<=4){ //Both M02 and M04
                msg=msg$"There is a ships wheel on the wall of the Underworld Tavern.";
            }else if (mission<=6){
                msg=msg$"There is a ships wheel on the smuggler's ship in the Wan Chai canals, as well as on the wall of the Boat Persons house (off the side of the canal).";
            }else if (mission<=9){
                msg=msg$"There is a ships wheel on the bridge of the Superfreighter.";
            }else if (RevisionMaps && mission<=12){
                msg=msg$"There is a ships wheel on the wall of a house near the gas station.";
            }
            return msg;
        case "ActivateVandenbergBots":
            return "Activate both military bots in Vandenberg.  The two generator keypads must be activated before you can enter the building that the milbots are inside.";
        case "TongsHotTub":
            return "Jump into the tub of water in Tracer Tong's hideout.";
        case "JocksToilet":
            return "Use the toilet in Jock's Tonnochi Road apartment.  The bathroom is behind a sliding door next to the kitchen.";
        case "support1":
            return "Blow up the gas station.";
        case "VandenbergToilet":
            return "Use the one toilet in Vandenberg.  It is located inside the Comm building outside.";
        case "BoatEngineRoom":
            return "Enter the small room at the back of the smuggler's boat in the Hong Kong canals and check the power levels on the equipment inside.  The room can be accessed by using one of the hanging lanterns near the back of the boat.";
        case "HumanStompDeath":
            return "Jump on enough humans heads until they die.  Note that people will not take stomp damage unless they are hostile to you, so you may need to hit them first to make them angry.";
        case "purge":
            return "Use the keypad in the vents of the Hong Kong MJ12 Helibase to release poison gas into the barracks.";
        case "ChugWater":
            return "Drink the entire contents of a water fountain or water cooler as quickly as possible.";
        case "ChangeClothes":
            return "Use hanging clothes to change your appearance!";
        case "arctrigger":
            return "Disable the arcing electricity in the corner of the LaGuardia airfield.";
        case "LeoToTheBar":
            return "Bring the body of Leo Gold (The terrorist commander from Liberty Island) to any bar in the game (New York, Hong Kong, Paris) and set him down.  You can also bring him to the bottom of the Ocean Lab, since it is under many BARs of pressure.";
        case "09_NYC_DOCKYARD--796967769":
            return "Find Jenny's number (867-5309) somewhere in the outer area of the Brooklyn Naval Yards on a datacube.";
        case "blast_door_open":
            return "Open the main blast doors of the Area 51 bunker by finding the security computer somewhere on the surface or by opening them from inside.";
        case "SpinningRoom":
            return "Pass through the center of the spinning room in the ventilation system of the Brooklyn Naval Yards.";
        case "MolePeopleSlaughtered":
            return "Kill most of the friendly mole people in the tunnels leading to Lebedev's private terminal at LaGuardia.";
        case "surrender":
            return "Find the leader of the NSF in the hidden room of the mole people tunnels and let him surrender.";
        case "nanocage":
            return "Open the greasel cages in the MJ12 lab underneath UNATCO HQ.";
        case "unbirth":
            return "Find the cloning tank in Sector 4 of Area 51 that does not have a lid and go swimming in it.";
        case "StolenAmbrosia":
            msg="Find enough stolen barrels of ambrosia.  ";
            if (mission<=2){
                msg=msg$"There is a barrel of ambrosia somewhere in Battery Park.";
            } else if (mission<=3){
                msg=msg$"There are three barrels of ambrosia.  One is in the LaGuardia helibase.  One is in the airfield.  One is either in the hangar or on the 747.";
            }
            return msg;
        case "AnnaKilledLebedev":
            return "Let Anna kill Lebedev by walking away without killing him yourself.";
        case "PlayerKilledLebedev":
            return "Murder Juan Lebedev on the 747 of your own volition.";
        case "BrowserHistoryCleared":
            return "While escaping UNATCO, log into the computer in your office and clear your browser history.";
        case "AnnaKillswitch":
            return "After finding the pieces of Anna's killphrase, actually use it against her.";
        case "SimonsAssassination":
            return "Watch Walton Simons' full interrogation of the captured NSF soldiers.";
        case "AlliesKilled":
            return "Kill enough people who do not actively hate you.  (This should be most people who show as green on the crosshairs)";
        case "botordertrigger":
            return "Set off the laser tripwires in Smuggler's hideout.";
        case "IgnitedPawn":
            return "Set enough people on fire.";
        case "GibbedPawn":
            return "Blow up enough people.  If they turn into chunks of meat, it counts.  They must be human and you must blow them up yourself.";
        case "AlexCloset":
            return "Enter Alex Jacobson's storage closet in UNATCO HQ.  The code to the door can be found in his email during the first mission.";
        case "BackOfStatue":
            return "Climb out along the balcony ledges of the Statue of Liberty and go around to the side facing UNATCO HQ.";
        case "CommsPit":
            return "Inspect the wiring in the pit outside of UNATCO HQ enough times.";
        case "StatueHead":
            return "Walk up to where the head of the Statue of Liberty is being displayed.";
        case "CraneControls":
            return "Move the crane next to the Superfreighter (inside the dock) by going up the elevator on the dockside and hitting the button at the top.";
        case "CraneTop":
            return "Walk to the ends of the two cranes that are on the deck of the Superfreighter itself.";
        case "CaptainBed":
            return "Enter the captain's quarters on the Superfreighter and jump on his bed.";
        case "FanTop":
            return "Enter the ventilation shaft in the lower decks of the Superfreighter and let yourself get blown to the top of the shaft.";
        case "LouisBerates":
            return "Sneak behind the doorman of the Porte De L'Enfer, the club in Paris.";
        case "EverettAquarium":
            return "Enter the aquarium in Morgan Everett's house.";
        case "TrainTracks":
            return "Jump onto the train tracks in Paris.";
        case "OceanLabCrewChamber":
            return "Visit enough of the crew chambers in the Ocean Lab.";
        case "HeliosControlArms":
            return "Jump down onto the arms sticking out of the wall below where you talk to Helios in Area 51.";
        case "TongTargets":
            return "Shoot at the targets in the shooting range in Tracer Tong's hideout.";
        case "WanChaiStores":
            return "Visit all of the stores in the Wan Chai market by walking up to them.";
        case "HongKongBBall":
            return "Throw the basketball into the net on the rooftop of the MJ12 helibase in Hong Kong.";
        case "CanalDrugDeal":
            return "Find the two people making a drug deal in the Hong Kong canals and listen in.";
        case "HongKongGrays":
            return "Enter the enclosure in the Hong Kong MJ12 Lab containing the grays.";
        case "EnterQuickStop":
            return "Enter the Quick Stop convenience store outside of the Lucky Money in Hong Kong.";
        case "LuckyMoneyFreezer":
            return "Enter the freezer in the back of the Lucky Money club in Hong Kong.";
        case "TonnochiBillboard":
            return "Jump onto the 'Big Top Cigarettes' billboard hanging above the entrance in Tonnochi Road.  This sign has a big picture of a clown on it, and says 'NO JOKE' at the top.";
        case "AirfieldGuardTowers":
            return "Enter the top floor of enough of the guard towers in the corners of the LaGuardia airfield.";
        case "mirrordoor":
            return "Open (or destroy) the mirror acting as the door to the secret stash in Smuggler's hideout.";
        case "MolePeopleWater":
            return "Find the pool of water in the Mole People tunnels and jump into it.  You need to crouch to get yourself fully immersed.";
        case "botorders2":
            return "Use the security computer in the upper floor of the MJ12 Robot Maintenance facility to alter the AI of the security bots.";
        case "BathroomFlags":
            return "Place a flag in Manderley's bathroom enough times.  This can only be done once per visit.  I'm sure this is how you get to the secret ending!";
        case "SiloSlide":
            return "When entering the missile silo, open the vent in the floor and go down the slide that drops you into the water underneath the missile.";
        case "SiloWaterTower":
            return "Go to the top of the water tower at the missile silo.";
        case "TonThirdFloor":
            if (RevisionMaps && mission > 4){
                return "Climb up the elevator shaft or up the stairs in the 'Ton hotel to the third floor.";
            } else {
                return "Climb up the elevator shaft in the 'Ton hotel to the third floor.";
            }
        case "Set_flag_helios":
            return "Enter the Aquinas Control Room in sector 4 of Area 51 and engage the primary router by pressing the buttons on each side of the room and using the computer.";
        case "coolant_switch":
            msg = "Flush the reactor coolant";
            if (dxr.flags.settings.goals>0){
                msg = "Flush the reactor coolant somewhere in Sector 4 of Area 51.  To flush the coolant, you need to find a large orange button that is in a random location.";
            } else {
                msg = "Flush the reactor coolant in the coolant area on the bottom floor of Sector 4 of Area 51.";
            }
            return msg;
        case "BlueFusionReactors":
            msg = "Deactivate blue fusion reactors in Sector 4 of Area 51.  Alex will give you three of the four digits of the code and you have to guess the last one.";
            if (dxr.flags.settings.goals>0){
                msg = msg $ "  The locations of the keypads for the blue fusion reactors have been randomized.";
            }
            return msg;
        case "A51UCBlocked":
            return "Close the doors to enough of the UCs in Sector 4 of Area 51.";
        case "VandenbergReactorRoom":
            return "Enter the flooded reactor room in the tunnels underneath Vandenberg.";
        case "VandenbergServerRoom":
            return "Enter the locked server room in the computer section of Vandenberg.";
        case "VandenbergWaterTower":
            return "Climb to the top of the water tower at the back of Vandenberg.";
        case "Cremation":
            return "Kill (or knock out) a chef in Paris, then throw his body either into a fireplace or onto a stovetop.";
        case "OceanLabGreenBeacon":
            return "Swim to the green beacon on top of the Ocean Lab crew module.  The green beacon can be seen out the window of the sub bay on the ocean floor.";
        case "BiggestFan":
            return "Destroy the large fan in the ventilation ducts of the Brooklyn Naval Yards.";
        case "ToxicShip":
            return "Find and enter the low, flat boat in the Hong Kong canals.  Note that the interior of the boat is filled with toxic gas.";
        case "ComputerHacked":
            return "Use your computer skills to hack enough computers.";
        case "ChateauInComputerRoom":
            return "Make your way down to Beth DuClare's computer station in the basement of the DuClare chateau.";
        case "DuClareBedrooms":
            return "Enter both Beth and Nicolette's bedrooms in the DuClare chateau.";
        case "PlayPool":
            return "Sink all 16 balls on enough different pool tables.";
        case "PianoSongPlayed":
            return "Play enough different songs on a piano.";
        case "PianoSong0Played":
            return "Play the Deus Ex theme song on a piano.  The song needs to be played correctly and all the way through.";
        case "PianoSong7Played":
            return "Play 'The Game' from The 7th Guest on a piano.   The song needs to be played correctly and all the way through.";
        case "PinballWizard":
            msg="Play enough different pinball machines.  ";
            if (mission<=1){
                msg=msg$"There is a machine in Alex's office as well as the break room.";
            } else if (mission<=2){
                msg=msg$"There is a machine in the Underworld Tavern in Hell's Kitchen.";
            } else if (mission<=3){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ, two machines in the LaGuardia helibase break room, and one in the Airfield barracks.";
            } else if (mission<=4){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ, as well as one in the Underworld Tavern in Hell's Kitchen.";
            } else if (mission<=5){
                msg=msg$"There is a machine in Alex's office and the break room of UNATCO HQ.";
            } else if (mission<=6){
                msg=msg$"There is a machine in the MJ12 Helibase, one in the MJ12 Lab barracks, one in the Old China Hand, and one in the Lucky Money.";
            } else if (mission<=8){
                msg=msg$"There is a machine in the Underworld Tavern in Hell's Kitchen.";
            } else if (RevisionMaps && mission<=9){
                msg=msg$"There is a machine in the break room on the Lower Decks of the Superfreighter.";
            } else if (mission<=12){
                msg=msg$"There is a machine in the Comms building in Vandenberg.";
            } else if (mission<=15){
                msg=msg$"There is a machine in the Comm building on the surface, and another one in the break room of Area 51.";
            }
            return msg;
        case "FlowersForTheLab":
            return "Bring some flowers into either level of the Hong Kong MJ12 lab and set them down.";
        case "BurnTrash":
            return "Set enough bags of trash on fire and let them burn until they are destroyed.";
        case "BrokenPianoPlayed":
            return "Damage a piano enough that it will no longer work without fully breaking it, then try to play it.  It will make a sound to let you know when it is damaged enough.";
        case "Supervisor_Paid":
            return "Pay Mr. Hundley for access to the MJ12 Lab in Hong Kong.";
        case "BethsPainting":
            return "Open (or destroy) the painting in Beth DuClare's bedroom in the DuClare chateau.";
        case "CathedralUnderwater":
            return "Swim through the underwater tunnel that leads to the Paris cathedral.";
        case "GasStationCeiling":
            return "Enter the ceiling of the gas station either from the roof or through the ventilation ducts.";
        case "nico_fireplace":
            return "Access the secret stash behind the fireplace in Nicolette's bedroom in the Chateau.";
        case "dumbwaiter":
            return "Use the DuClare dumbwaiter between the kitchen and Beth's room.";
        case "secretdoor01":
            return "Twist the pulsating light in the Cathedral and open the secret door.";
        case "CathedralLibrary":
            return "Enter the library in the Cathedral.";
        case "VendingMachineEmpty":
            return "Empty enough vending machines of any type.";
        case "VendingMachineEmpty_Drink":
            return "Empty enough soda vending machines.";
        case "VendingMachineDispense_Candy":
            return "Dispense enough candy bars from vending machines.";
        case "M06JCHasDate":
            return "Rent a companion for the night from the Mamasan in the Lucky Money club.";
        case "PresentForManderley":
            return "Bring Juan Lebedev back to Manderley's office.";
        case "OceanLabShed":
            return "Enter the small square storage building on shore, near the main pedestal leading up to the Ocean Lab sub base.";
        case "DockBlastDoors":
            return "Open enough of the blast doors inside the ammunition storage warehouse in the dockyard.";
        case "ShipsBridge":
            return "Enter the bridge on the top deck of the superfreighter.";
        case "CrackSafe":
            msg="Open enough safes throughout the game.  ";
            if (mission<=2){
                msg=msg$"There is a safe in the control room under Castle Clinton, and another one in the basement office of the NSF Warehouse.";
            } else if (mission<=9){
                msg=msg$"There is a safe in the office in the dockyard, one on the upper decks of the superfreighter, and one in Dowd's mausoleum.";
            }
            return msg;
        case "CliffSacrifice":
            return "Throw a corpse off of the cliffs in Vandenberg.";
        case "MaggieCanFly":
            return "Throw Maggie Chow out of her apartment window.";
        case "VandenbergShaft":
            return "Jump down the shaft leading from the third floor to the first floor, down to near the indoor generator.";
        case "MiguelLeaving":
            return "Tell Miguel that he can slip out on his own.  He definitely can't, but he doesn't know that.";
        case "KarkianDoorsBingo":
            return "Open the doors to the karkian cage near the surgery ward in the MJ12 base underneath UNATCO.";
        case "SuspensionCrate":
            msg = "Open enough suspension crates.  These are the square containers with force fields sealing them.|n|n";
            if (mission<=3){
                msg = msg $ "There is a suspension crate on Lebedev's plane.";
            } else if (mission<=5){
                msg = msg $ "There is a suspension crate in the back of the greasel lab at the MJ12 base under UNATCO.";
            } else if (mission<=10){
                msg = msg $ "There is a suspension crate in the basement of Chateau DuClare.";
            } else if (mission<=11){
                msg = msg $ "There are two suspension crates in Everett's lab.";
            }
            return msg;
        case "ScubaDiver_ClassDead":
            return "Kill enough SCUBA divers in and around the Ocean Lab.  You must kill them yourself.";
        case "ShipRamp":
            return "Raise the ramp to get on board the superfreighter from the docks.  There is a keypad on a box next to the ramp that raises it.";
        case "SuperfreighterProp":
            return "Dive to the propeller at the back of the superfreighter.";
        case "ManderleyMail":
            return "Check Manderley's holomail messages enough times on different visits.";
        case "LetMeIn":
            return "Try to enter the door below the UNATCO Medical office without authorization.";
        case "SewerSurfin":
            return "Throw Joe Greene's body into the water in the New York sewers, like the rat he is.";
        case "PhoneCall":
            msg = "Make phone calls on enough different phones (Either desk phones or pay phones).";
            if (RevisionMaps && mission <=1) {
                msg=msg$"|n|nThere several phones scattered around UNATCO HQ.";
            } else if (mission <=2){
                msg=msg$"|n|nThere is a desk phone and a pay phone in the Free Clinic.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=3){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.  There are two desk phones in offices in the LaGuardia Helibase.";
            } else if (mission <=4){
                msg=msg$"|n|nThere is a desk phone on Janice's desk in UNATCO HQ.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=5){
                msg=msg$"|n|nThere is a desk phone on Sam's desk in UNATCO HQ.";
            } else if (mission <=6){
                msg=msg$"|n|nThere is a desk phone in the Luminous Path Compound in the Wan Chai Market.";
                msg=msg$"|nThere is a desk phone at the front desk of Queen's Tower on Tonnochi Road.";
                msg=msg$"|nThere is a desk phone on the conference table in the Lucky Money.";
                msg=msg$"|nThere is a desk phone in the conference room on the first level of the MJ12 Lab under VersaLife.";
            } else if (mission <=8){
                msg=msg$"|n|nThere is a desk phone and a pay phone in the Free Clinic.  There are two payphones in the streets.  There is a payphone in the back of the bar.";
            } else if (mission <=9){
                msg=msg$"|n|nThere is a desk phone in an office in the dockyard.";
            } else if (mission<=10){
                msg=msg$"|n|nThere is a desk phone in the office across the street from the entrance to the catacombs in Denfert-Rochereau.";
            } else if (RevisionMaps && mission<=11){
                msg=msg$"|n|nThere are phones in the Paris Metro station as well as in Everett's house.";
            } else if (RevisionMaps && mission<=12){
                msg=msg$"|n|nThere is a phone in the security room of the Vandenberg Command building.";
            } else if (RevisionMaps && mission<=14){
                msg=msg$"|n|nThere is a phone in the gatehouse at the sub base.";
            }
            return msg;
        case "Area51ElevatorPower":
            return "Enter the main blast doors of the Area 51 bunker and turn on the power to the elevator.";
        case "Area51SleepingPod":
            return "Open enough of the sleeping pods in the entrance to the Area 51 bunker.";
        case "Area51SteamValve":
            return "Close the steam valves in the maintenance tunnels under the floors of the entrance to the Area 51 bunker.";
        case "DockyardLaser":
            return "Deactivate enough of the laser grids in the sewers underneath the dockyards.";
        case "A51CommBuildingBasement":
            return "Go into the hatch in the Command 24 building in Area 51 and enter the basement.";
        case "FreighterHelipad":
            return "Walk up onto the helipad in the lower decks of the superfreighter.";
        case "A51ExplosiveLocker":
            return "Enter the explosives locker in Area 51.  This is the locked room on the staircase leading down from Helios towards Sector 4.";
        case "A51SeparationSwim":
            return "Go swimming in the tall cylindrical separation tank in Sector 3 of Area 51.";
        case "Titanic":
            return "Stand on the rail at the front of the superfreighter and hold your arms out... It feels like you're flying!";
        case "DockyardTrailer":
            return "Enter one of the trailers parked in the dockyards.  There is a key to open the trailers somewhere in the dockyards.";
        case "CathedralDisplayCase":
            return "Enter the store display case in the street leading up to the cathedral.";
        case "VandenbergAntenna":
            return "Shoot the tip of the antenna on top of the command center at the Vandenberg Air Force Base.";
        case "VandenbergHazLab":
            return "Enter the Hazard Lab in Vandenberg and disable the electricity that is making the water hazardous.";
        case "EnterUC":
            return "Step into enough Universal Constructors throughout the game.  There are five available:|n - One in the computer section of Vandenberg|n - One in the bottom of the Ocean Lab|n - Three in the very bottom of Area 51";
        case "VandenbergComputerElec":
            return "Disable both electrical panels in the computer room of Vandenberg.  There's very little risk!";
        case "VandenbergGasSwim":
            return "Go swimming in the water around the base of the two gas tanks outside of the Vandenberg command center.";
        case "SiloAttic":
            return "Enter the attic in the building outside the fence at the silo.";
        case "SubBaseSatellite":
            return "Shoot one of the satellite dishes on the tower on top of the sub base on shore in California.";
        case "UCVentilation":
            return "Destroy enough ventilation fans near the Universal Contructor under the Ocean Lab.";
        case "OceanLabFloodedStoreRoom":
            return "Swim along the ocean floor to the locked and flooded storage room from in the Ocean Lab.";
        case "OceanLabMedBay":
            return "Enter the med bay in the Ocean Lab.  This room is flooded and off the side of the Karkian Lab.";
        case "roof_elevator":
            return "Use the roof elevator in Denfert-Rochereau right at the start.  There will be a book nearby with the code for the keypad.";
        case "SoldRenaultZyme":
            return "Sell at least 5 vials of Zyme to Renault in the Paris hostel.";
        case "WarehouseSewerTunnel":
            return "Swim through the underwater tunnel in the Warehouse District.";
        case "PaulToTong":
            return "Take Paul's corpse from the MJ12 facility under UNATCO to Tracer Tong.";
        case "Canal_Bartender_Question4":
            return "Learn about Olaf Stapledon's \"Last and First Men\" from the Old China Hand bartender.";
        case "M06BartenderQuestion3":
            return "Hear the Lucky Money bartender's ideas about good government.";
        case "LebedevLived":
            return "Leave the airfield for UNATCO with Juan Lebedev still alive and Anna Navarre dead.";
        case "AimeeLeMerchantLived":
            return "Leave Denfert-Rochereau with Aimee and Le Merchant still alive and conscious.  This is a very difficult goal.";
        case "MaggieLived":
            return "Leave Hong Kong for New York with Maggie Chow still alive and conscious.";
        case "PetKarkians":
            return "Hear me out - Karkians are basically just big puppies... Give enough of them the head rubs they deserve!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetDogs":
            return "That's right, you can pet the dog!  Give enough dogs some petting time.  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetFish":
            return "Trust me, fish like getting pet.  Max Chen has some fish in his office who would really appreciate it.  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetBirds":
            return "Ok, maybe you shouldn't pet the birds, but can you help yourself?  Give enough birds a pet!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetAnimal_Cat":
            return "Ohhhh, that cat really wants to get pet!  Give enough cats a pet!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetAnimal_Greasel":
            return "They might look a bit greasy and very mean, but they sure love head pats!  Give those greasels some pets!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "PetRats":
            return "Get down there and pet enough rats!  Make sure your hands are empty, or you won't be able to pet anything!";
        case "NotABigFan":
            return "Turn off enough ceiling fans through the game.";
        case "TiffanyHeli":
            return "Rescue Tiffany Savage at the abandoned gas station.";
        case "AlarmUnitHacked":
            return "Hack enough Alarm Sounder Panels.  These are the big red wall buttons that set off alarms.";
        case "IOnceKnelt":
            return "Yeah, I can do that too, buddy.  Crouch inside the chapel at the Paris Cathedral.";
        case "GasCashRegister":
            return "Find the cash register in the gas station and check if there's anything left behind.";
        case "LibertyPoints":
            return "Walk around on the foundation of the statue and visit each of the 11 points.";
        case "CherryPickerSeat":
            return "Take a knee in the seat of a cherry picker.";
        case "ForkliftCertified":
            return "Demonstrate your certification and operate a functional forklift.";
        case "DolphinJump": // keep height number in sync with DolphinJumpTrigger CreateDolphin
            msg = TrimTrailingZeros(FloatToString(GetRealDistance(160), 1)) @ GetDistanceUnitLong();
            return "Jump " $ msg $ " out of the water.|n|nHow high in the sky can you fly?";
        case "M06HeliSafe":
            return "Open both safes in the Hong Kong Helibase.|n|nThere's one in each Flight Control Deck room.";
        case "JustAFleshWound":
            return "Reduce JC to just a torso and head by losing both arms and both legs.";
        case "LostLimbs":
            return "Every night, I can feel my leg... and my arm... even my fingers.|n|nLose enough limbs through the game.";
        case "PoolTableStripes":
            return "Sink all 7 solid-color balls (9-15) on enough different pool tables.";
        case "PoolTableSolids":
            return "Sink all 7 striped balls (1-7) on enough different pool tables.";
        case "steampipe":
            return "Shut off the gas and stop a leak near the armory in the MJ12 Lab under UNATCO.";
        case "ArmoryVentEntrance":
            return "Enter the armory in the MJ12 Lab under UNATCO by going through the vent in the ceiling.";
        case "UNATCOMJ12LabGreaselCages":
            return "Enter all four greasel cages in the MJ12 Lab under UNATCO.";
        case "BrokenMirror":
            return "They say that if you break a mirror, you'll have seven years of bad luck.  Accumulate bad luck for yourself by breaking enough mirrors.";
        case "InCaseOfEmergency":
            return "Break open enough fire extinguisher cases with glass fronts through the game.";
        case "LootNewClothing":
            return "Loot enough new, unique, pieces of clothing.  Note that a single person may be wearing multiple pieces of clothing, such as pants, shirts, jackets, glasses, or helmets.  Some people may have overlapping pieces of clothing with others.";
        case "PoolTableStripeBallSunk":
            return "Sink enough unique striped pool balls (1-7) through the game.";
        case "PoolTableSolidBallSunk":
            return "Sink enough unique solid pool balls (9-15) through the game.";
        case "PoolTableBallSunk":
            return "Sink enough unique pool balls through the game.  The cue ball does not count, and the eight ball only counts if all of the stripes or solids have already been sunk.";
        case "GeneratorBlown":
            return "Destroy the NSF Generator hidden in the warehouse district.  You can destroy the generator either by using explosives or by turning off the coolant.";
        case "NSFSignalSent":
            return "Go to the NSF HQ, align the satellites, and transmit the signal.  God damn terrorist.";
        case "Have_Evidence":
            return "Find the Dragon Tooth Sword somewhere in Hong Kong in order to earn Tracer Tong's trust.";
        case "Have_ROM":
            return "Find the ROM Encoding for the Dragon Tooth Sword in the Versalife Labs.";
        case "VL_Got_Schematic":
            return "Upload the schematics for the Grey Death virus from the Versalife Level 2 Labs.";
        case "VL_UC_Destroyed":
            return "Destroy the Universal Constructor in the Versalife Level 2 Labs.";
        case "Pistons":
            return "Activate the bilge pumps in the lower decks of the superfreighter.";
        case "WeldPointDestroyed":
            return "Destroy enough of the weld points in the lower decks of the superfreighter.";
        case "templar_upload":
            return "Find the computer in the Paris Cathedral and establish a system uplink for Everett.";
        case "HeliosBorn":
            return "Provide MilNet access for Daedalus in the Vandenberg Computer Room and witness the birth of a new AI.";
        case "schematic_downloaded":
            return "Retrieve the schematics for building a Universal Constructor from the computer at the very bottom of the OceanLab.";
        case "missile_launched":
            return "Redirect the missile that is being aimed at Vandenberg.  It's going to be a sunny day at Area 51...";
        case "MerchantPurchaseBind_DXRNPCs1":
            return "Make enough purchases from The Merchant through the game.|n|nNote that purchases from his French cousin, Le Merchant, do not count.  He is a different guy.";
        case "MerchantPurchaseBind_lemerchant":
            return "Make a purchase from Le Merchant, the French merchant hiding in the abandoned high-rise at Denfert-Rochereau.";
        case "MostWarehouseTroopsDead":
            return "Kill or knock out most of the UNATCO Troops securing the NSF HQ.  This can be done before sending the signal for the NSF or after.";
        case "M02QuestionedGreen":
            return "Question Joe Greene about the NSF or their secret power generator.";
        case "CivilForfeiture":
            return "Claim the contents of enough ATM accounts as the proceeds of crime.  The accounts must be fully emptied.";
    }

    //Return nothing so the generic function can handle it
    return "";
}
//#endregion
