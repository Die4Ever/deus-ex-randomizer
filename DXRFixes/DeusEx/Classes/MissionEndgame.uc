class MissionEndgame injects MissionEndgame;

struct EndQuote
{
    var string quote;
    var string attribution;
};

var EndQuote quotes[80];
var int numQuotes;


//For now, this is limited to the default UnrealScript limit of 256 characters in a string
function AddQuote(string quote, string attribution)
{
    quotes[numQuotes].quote = quote;
    quotes[numQuotes].attribution = "    -- "$attribution;
    numQuotes++;
}

function LoadQuotes()
{
    //Original Endgame Quotes
    AddQuote("YESTERDAY WE OBEYED KINGS AND BENT OUR NECKS BEFORE EMPERORS.  BUT TODAY WE KNEEL ONLY TO TRUTH...","KAHLIL GIBRAN");
    AddQuote("IF THERE WERE NO GOD, IT WOULD BE NECESSARY TO INVENT HIM.","VOLTAIRE");
    AddQuote("BETTER TO REIGN IN HELL, THAN SERVE IN HEAVEN.","PARADISE LOST, JOHN MILTON");

    //DX Quotes
    AddQuote("A BOMB!","JC DENTON");
    AddQuote("OH MY GOD! JC! A BOMB!","JOCK");
    AddQuote("I SPILL MY DRINK!","IVAN");
    AddQuote("THANKS FOR GETTING ME IN!","TESSA");
    AddQuote("WHAT A SHAME...","JC DENTON");
    AddQuote("YOU CAN'T FIGHT IDEAS WITH BULLETS.","LEO GOLD");
    AddQuote("WHAT AN EXPENSIVE MISTAKE YOU TURNED OUT TO BE.","WALTON SIMONS");
    AddQuote("JUMP! YOU CAN MAKE IT!","BOB PAGE");
    AddQuote("THE MORE POWER YOU THINK YOU HAVE, THE MORE QUICKLY IT SLIPS FROM YOUR GRASP.","TRACER TONG");
    AddQuote("I NEVER HAD TIME TO TAKE THE OATH OF SERVICE TO THE COALITION. HOW ABOUT THIS ONE? I SWEAR NOT TO REST UNTIL UNATCO IS FREE OF YOU AND THE OTHER CROOKED BUREAUCRATS WHO HAVE PERVERTED ITS MISSION.","JC DENTON");
    AddQuote("WE ARE THE INVISIBLE HAND. WE ARE THE ILLUMINATI. WE COME BEFORE AND AFTER. WE ARE FOREVER. AND EVENTUALLY... EVENTUALLY WE WILL LEAD THEM INTO THE DAY.","MORGAN EVERETT");
    AddQuote("THE NEED TO BE OBSERVED AND UNDERSTOOD WAS ONCE SATISFIED BY GOD. NOW WE CAN IMPLEMENT THE SAME FUNCTIONALITY WITH DATA-MINING ALGORITHMS.","MORPHEUS");
    AddQuote("I ORDER YOU TO STAND IN THE SPOTLIGHT AND GROWL AT THE WOMEN LIKE A DOG WHO NEEDS A MASTER.","DOOR GIRL");
    AddQuote("I WANTED ORANGE. IT GAVE ME LEMON-LIME.","GUNTHER HERMANN");

    //Why not some Zero Wing?
    AddQuote("SOMEBODY SET UP US THE BOMB.","MECHANIC");
    AddQuote("ALL YOUR BASE ARE BELONG TO US.","CATS");
    AddQuote("YOU HAVE NO CHANCE TO SURVIVE MAKE YOUR TIME.","CATS");

    //A bit of Zelda perhaps?
    AddQuote("AND THE MASTER SWORD SLEEPS AGAIN... FOREVER!","A LINK TO THE PAST");
    AddQuote("IT'S A SECRET TO EVERYBODY","MOBLIN");
    AddQuote("AH, THE SCROLL OF SHURMAK, BEARER OF SAD NEWS THESE MANY YEARS AGO.","GASPRA");
    AddQuote("SHADOW AND LIGHT ARE TWO SIDES OF THE SAME COIN, ONE CANNOT EXIST WITHOUT THE OTHER.","PRINCESS ZELDA");
    AddQuote("A SWORD WIELDS NO STRENGTH UNLESS THE HAND THAT HOLDS IT HAS COURAGE","THE HERO'S SHADE");
    AddQuote("THE WIND... IT IS BLOWING...","GANONDORF");
    AddQuote("DO NOT THINK IT ENDS HERE... THE HISTORY OF LIGHT AND SHADOW WILL BE WRITTEN IN BLOOD!","GANONDORF");
    AddQuote("YOUR COURAGE AND STRENGTH WILL NOT BE FORGOTTEN. FOR NOW, YOUR WORK IS DONE. OFF YOU GO TO CELEBRATE LINK'S RETURN. BUT FIRST, REMEMBER, LESSONS OF THE HEART, MERCY, AND HUMAN KINDNESS PREVAIL ABOVE ALL ELSE.","GASPRA");
    AddQuote("LAMP OIL? ROPE? BOMBS? YOU WANT IT? IT'S YOURS MY FRIEND, AS LONG AS YOU HAVE ENOUGH RUBIES!","MORSHU");

    //Some Plumber Talk
    AddQuote("THANK YOU MARIO! BUT OUR PRINCESS IS IN ANOTHER CASTLE!","TOAD");
    AddQuote("THANK YOU SO MUCH FOR PLAYING MY GAME!","MARIO");
    AddQuote("DEAR PESKY PLUMBERS, THE KOOPALINGS AND I HAVE TAKEN OVER THE MUSHROOM KINGDOM! THE PRINCESS IS NOW A PERMANENT GUEST AT ONE OF MY SEVEN KOOPA HOTELS. I DARE YOU TO FIND HER IF YOU CAN!","BOWSER");

    //A bit of this and that
    AddQuote("UNFORTUNATELY, KLLING IS ONE OF THOSE THINGS THAT GETS EASIER THE MORE YOU DO IT.","SOLID SNAKE");
    AddQuote("WHAT IS A MAN? A MISERABLE LITTLE PILE OF SECRETS!","DRACULA");
    AddQuote("THE RIGHT MAN IN THE WRONG PLACE CAN MAKE ALL THE DIFFERENCE IN THE WORLD","G-MAN");
    AddQuote("HACK THE PLANET!","HACKERS");
    AddQuote("I NEVER ASKED FOR THIS","ADAM JENSEN");
    AddQuote("BRING ME A BUCKET, AND I'LL SHOW YOU A BUCKET!","PSYCHO");
    AddQuote("DO A BARREL ROLL!","PEPPY HARE");
    AddQuote("WAR.  WAR NEVER CHANGES.","RON PERLMAN");
    AddQuote("PRAISE THE SUN!","SOLAIRE OF ASTORA");
    AddQuote("STUPID BANJO AND DUMB KAZOOIE. I'LL BE BACK IN BANJO-TOOIE!","GRUNTILDA");
    AddQuote("IF HISTORY IS TO CHANGE, LET IT CHANGE.  IF THE WORLD IS TO BE DESTROYED, SO BE IT.  IF MY FATE IS TO DIE, I MUST SIMPLY LAUGH","MAGUS");
    AddQuote("LIFE... DREAMS... HOPE... WHERE DO THEY COME FROM? AND WHERE DO THEY GO...? SUCH MEANINGLESS THINGS... I'LL DESTROY THEM ALL!","KEFKA");
    AddQuote("DO NOT HATE HUMANS. IF YOU CANNOT LIVE WITH THEM, THEN AT LEAST DO THEM NO HARM, FOR THEIRS IS ALREADY A HARD LOT","LISA");
    AddQuote("UH, BOYS? HOW ABOUT THAT EVAC? COMMANDER? JIM? WHAT THE HELL IS GOING ON UP THERE??","SARAH KERRIGAN");
    AddQuote("LOOK AT YOU, HACKER: A PATHETIC CREATURE OF MEAT AND BONE, PANTING AND SWEATING AS YOU RUN THROUGH MY CORRIDORS.  HOW CAN YOU CHALLENGE A PERFECT, IMMORTAL MACHINE?","SHODAN");
    AddQuote("NANOMACHINES, SON.","SENATOR ARMSTRONG");
    AddQuote("THIS WAS A TRIUMPH. I'M MAKING A NOTE HERE: HUGE SUCCESS","GLADOS");
    AddQuote("NEVER GONNA GIVE YOU UP, NEVER GONNA LET YOU DOWN. NEVER GONNA RUN AROUND AND DESERT YOU. NEVER GONNA MAKE YOU CRY. NEVER GONNA SAY GOODBYE. NEVER GONNA TELL A LIE AND HURT YOU","RICK ASTLEY");
    AddQuote("IF THE ZOO BANS ME FOR HOLLERING AT THE ANIMALS I WILL FACE GOD AND WALK BACKWARDS INTO HELL","DRIL");
    AddQuote("NANITES! COURTESY OF RAY PALMER!", "OLIVER QUEEN");

    //T7G / T11H Quotes... trying to avoid spoilers...
    AddQuote("OLD MAN STAUF BUILT A HOUSE AND FILLED IT WITH HIS TOYS", "HENRY STAUF");
    AddQuote("MY, ISN'T THIS A CHEERY PLACE?", "MARTINE BURDEN");
    AddQuote("AT LEAST HE LEFT HIS *REGRETS*", "HAMILTON TEMPLE");
    AddQuote("YOU ARE A GLUTTON FOR PUNISHMENT", "HENRY STAUF");
    AddQuote("WANT A BALLOON, SONNY?", "CLOWN");
    AddQuote("FEELING LONELY?", "HENRY STAUF");
    AddQuote("ARRRRRR! DON'T THINK YOU'LL BE SO LUCKY NEXT TIME.", "HENRY STAUF");
    AddQuote("OH, I'M DYING TO SEE WHAT YOU DO NEXT...", "HENRY STAUF");
    AddQuote("SO... YOU LIVE TO PLAY ANOTHER DAY... <SIGHS>.", "HENRY STAUF");
    AddQuote("HENRY STAUF GREW WEALTHY, BUT THEN THIS STRANGE VIRUS CAME...", "THE 7TH GUEST NARRATOR");
    AddQuote("I THINK THAT WE WERE MEANT TO EAT THE SOUP.", "EDWARD KNOX");
    AddQuote("CHUCK HIM INTO THE SOUP", "SOUP");
    AddQuote("YEAH, IT'S BLOOD.", "CHIEF JIM MARTIN");
}


function EndQuote PickRandomQuote()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando',dxr)
        return quotes[dxr.rng(numQuotes)];

    return quotes[Rand(numQuotes)];
}

function PostPostBeginPlay()
{
    savedSoundVolume = SoundVolume;
    Super.PostPostBeginPlay();
}

// ----------------------------------------------------------------------
// InitStateMachine()
// ----------------------------------------------------------------------

function InitStateMachine()
{
    Super(MissionScript).InitStateMachine();

    // Destroy all flags!
    //if (flags != None)
    //    flags.DeleteAllFlags();

    // Set the PlayerTraveling flag (always want it set for
    // the intro and endgames)
    flags.SetBool('PlayerTraveling', True, True, 0);
}

// ----------------------------------------------------------------------
// FirstFrame()
//
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
    Super(MissionScript).FirstFrame();

    endgameTimer = 0.0;

    if (Player != None)
    {
        TarEndgameConvo = 'Barf';
        DelayTimer = 0.05;

        //LDDP, 11/3/21: Barf.
        //Player.StartConversationByName(UseConvo, Player, False, True);

        // Make sure all the flags are deleted.
        //DeusExRootWindow(Player.rootWindow).ResetFlags();

        // turn down the sound so we can hear the speech
        savedSoundVolume = SoundVolume;
        SoundVolume = 32;
        Player.SetInstantSoundVolume(SoundVolume);
    }
}

function Tick(float DT)
{
    local bool bFemale;
    local name UseConvo;

    Super.Tick(DT);

    //LDDP, 11/3/21: Barf, part 2.
    if (TarEndgameConvo == 'Barf')
    {
        if (DelayTimer > 0)
        {
            DelayTimer -= DT;
        }
        else
        {
            //LDDP, 10/26/21: Parse this on the fly, and reset flags AFTER playing the right conversation, NOT before.
            //if ((Player.FlagBase != None) && (Player.FlagBase.GetBool('LDDPJCIsFemale')))
            if ((Human(Player) != None) && (Human(Player).bMadeFemale))
            {
                bFemale = true;
            }

            // Start the conversation
            switch(LocalURL)
            {
                case "ENDGAME1":
                    UseConvo = 'Endgame1';
                    if (bFemale) UseConvo = 'FemJCEndgame1';
                break;
                case "ENDGAME2":
                    UseConvo = 'Endgame2';
                    if (bFemale) UseConvo = 'FemJCEndgame2';
                break;
                case "ENDGAME3":
                    UseConvo = 'Endgame3';
                    if (bFemale) UseConvo = 'FemJCEndgame3';
                break;
            }
            TarEndgameConvo = UseConvo;

            Player.StartConversationByName(TarEndgameConvo, Player, False, True);

            //LDDP, 11/3/21: Make sure all the flags are deleted, now that flags manager is here.
            //DeusExRootWindow(Player.rootWindow).ResetFlags();
        }
    }
}


function PrintEndgameQuote(int num)
{
    local int i;
    local DeusExRootWindow root;
    local EndQuote quote;

    bQuotePrinted = True;
    flags.SetBool('EndgameExplosions', False);

    LoadQuotes();

    root = DeusExRootWindow(Player.rootWindow);
    if (root != None)
    {
        quoteDisplay = HUDMissionStartTextDisplay(root.NewChild(Class'HUDMissionStartTextDisplay', True));
        if (quoteDisplay != None)
        {
            quoteDisplay.displayTime = endgameDelays[num];
            quoteDisplay.SetWindowAlignments(HALIGN_Center, VALIGN_Center);

            quote = PickRandomQuote();

            quoteDisplay.AddMessage(quote.quote);
            quoteDisplay.AddMessage(quote.attribution);

            quoteDisplay.StartMessage();
        }
    }
}
