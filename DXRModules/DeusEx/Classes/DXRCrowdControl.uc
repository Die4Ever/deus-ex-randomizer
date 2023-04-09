class DXRCrowdControl extends DXRActorsBase transient;

//var config bool enabled;
var config string crowd_control_addr;

var DXRandoCrowdControlLink link;

struct stupidQuestion {
    var String question;
    var int numAnswers;
    var String answers[3];
};

//The config file didn't want to load an array inside a struct
struct stupidQuestionSave {
    var String question;
    var int numAnswers;
    var String answerOne;
    var String answerTwo;
    var String answerThree;
};

var config int numStupidQuestions;
var config stupidQuestionSave StupidQuestions[50];
var        stupidQuestion    _StupidQuestions[50];
var int curStupidQuestion;

function Init(DXRando tdxr)
{
    local bool anon, offline;
    Super.Init(tdxr);

    curStupidQuestion = Rand(numStupidQuestions);

    if (tdxr.flags.crowdcontrol != 0) {
        link = Spawn(class'DXRandoCrowdControlLink');
        info("spawned "$link);
        if (tdxr.flags.crowdcontrol == 1) {
            anon = False;
        } else if (tdxr.flags.crowdcontrol == 2) {
            anon = True;
        }
        else if(tdxr.flags.crowdcontrol == 3) {
            offline = true;
        }
        link.Init(tdxr, Self, crowd_control_addr, anon, offline);
    } else info("crowd control disabled");
}

function AnyEntry() {
    Super.AnyEntry();
    if( link != None && link.ccEffects != None ) {
        link.ccEffects.InitOnEnter();
    }
}

function PreTravel() {
    if( link != None && link.ccEffects != None ) {
        link.ccEffects.CleanupOnExit();
    }
    Super.PreTravel();
}

function CheckConfig()
{
    if ( crowd_control_addr=="" ) {
        crowd_control_addr = "localhost";
    }
    if (numStupidQuestions == 0 || ConfigOlderThan(1,5,5,0) ) {
        InitStupidQuestions();
        StupidQuestionsToSave();
        SaveConfig();
    }

    Super.CheckConfig();

    SaveToStupidQuestions();
}


function StupidQuestionsToSave() {
    local int i;

    for (i=0;i<numStupidQuestions;i++) {
        StupidQuestions[i].question = _StupidQuestions[i].question;
        StupidQuestions[i].numAnswers = _StupidQuestions[i].numAnswers;
        StupidQuestions[i].answerOne = _StupidQuestions[i].answers[0];
        StupidQuestions[i].answerTwo = _StupidQuestions[i].answers[1];
        StupidQuestions[i].answerThree = _StupidQuestions[i].answers[2];
    }
}

function SaveToStupidQuestions() {
    local int i;

    for (i=0;i<numStupidQuestions;i++) {
        _StupidQuestions[i].question = StupidQuestions[i].question;
        _StupidQuestions[i].numAnswers = StupidQuestions[i].numAnswers;
        _StupidQuestions[i].answers[0] = StupidQuestions[i].answerOne;
        _StupidQuestions[i].answers[1] = StupidQuestions[i].answerTwo;
        _StupidQuestions[i].answers[2] = StupidQuestions[i].answerThree;
    }
}


function InitStupidQuestions() {
    numStupidQuestions=0;

    _StupidQuestions[numStupidQuestions].Question = "Do you like me?  Check one.";
    _StupidQuestions[numStupidQuestions].numAnswers = 3;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    _StupidQuestions[numStupidQuestions].answers[2] = "<3";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Are you in danger right now?";
    _StupidQuestions[numStupidQuestions].numAnswers = 3;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "*Chuckles*";
    _StupidQuestions[numStupidQuestions].answers[2] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Is a greasel actually greasy?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Has Anyone Really Been Far Even as Decided to Use Even Go Want to do Look More Like?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Would you rather own a horse the size of a cat or a cat the size of a mouse?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "Small Horse";
    _StupidQuestions[numStupidQuestions].answers[1] = "Tiny Cat";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Would you watch a smurf die?";
    _StupidQuestions[numStupidQuestions].numAnswers = 3;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    _StupidQuestions[numStupidQuestions].answers[2] = "Excuse me?";

    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Is your vision augmented?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Do fish get thirsty?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "If you have a cold hot pocket, is it just a pocket?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Is it really chili if it's hot?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "If you pamper a cow, do you get spoiled milk?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Are you not entertained?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Are hot dogs a sandwich?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Huh?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "What?";
    _StupidQuestions[numStupidQuestions].answers[1] = "???";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "If you enjoy wasting time, is that time really wasted?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "If anything is possible, is it possible for anything to be impossible?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Is there such a thing as a stupid question?";
    _StupidQuestions[numStupidQuestions].numAnswers = 3;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "This is one";
    _StupidQuestions[numStupidQuestions].answers[2] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "How is babby formed?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "instain mother";
    _StupidQuestions[numStupidQuestions].answers[1] = "too lady to rest";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Do stairs go up or down?";
    _StupidQuestions[numStupidQuestions].numAnswers = 3;
    _StupidQuestions[numStupidQuestions].answers[0] = "Up";
    _StupidQuestions[numStupidQuestions].answers[1] = "Down";
    _StupidQuestions[numStupidQuestions].answers[2] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Did you ever ask for this?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "Never";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Can you name the Backstreet Boys?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "If a fork was made of gold, would it still be considered silverware?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Are Pop Tarts a ravioli?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "If you were on fire IRL, could you extinguish yourself with a urinal?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "If you were on fire IRL, could you extinguish yourself with a can of soda?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "No";
    _StupidQuestions[numStupidQuestions].answers[1] = "Yes";
    numStupidQuestions++;

    _StupidQuestions[numStupidQuestions].Question = "Aurora borealis at this time of year, at this time of day, in this part of the country, localized entirely within your kitchen?";
    _StupidQuestions[numStupidQuestions].numAnswers = 2;
    _StupidQuestions[numStupidQuestions].answers[0] = "Yes";
    _StupidQuestions[numStupidQuestions].answers[1] = "YES!";
    numStupidQuestions++;
}


function getRandomQuestion(out string question, out int numAnswers,
                           out string ansOne, out string ansTwo, out string ansThree) {

    curStupidQuestion++;
    curStupidQuestion = curStupidQuestion % numStupidQuestions;

    question = _StupidQuestions[curStupidQuestion].question;
    numAnswers = _StupidQuestions[curStupidQuestion].numAnswers;
    ansOne   = _StupidQuestions[curStupidQuestion].answers[0];
    ansTwo   = _StupidQuestions[curStupidQuestion].answers[1];
    ansThree = _StupidQuestions[curStupidQuestion].answers[2];
}

function IncHandledEffects()
{
    local int numEffects;

    numEffects = dxr.flagbase.GetInt('cc_numCCEffects');
    dxr.flagbase.SetInt('cc_numCCEffects',numEffects+1,,999);
}

function AddDXRCredits(CreditsWindow cw)
{
    local int numEffects;

    numEffects = dxr.flagbase.GetInt('cc_numCCEffects');

    if (numEffects>0) {
        cw.PrintText("Number of Crowd Control Effects:"@numEffects);
        cw.PrintLn();
    }
}


function ExtendedTests()
{
    local DXRandoCrowdControlLink t;

    t = Spawn(class'DXRandoCrowdControlLink');
    test( t!=None, "spawned "$t);
    if( t != None ) {
        t.RunTests(Self);
        t.Destroy();
    }
}
