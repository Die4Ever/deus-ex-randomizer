class MenuSelectDifficulty extends DXRMenuBase;

function BindControls(bool writing, optional string action)
{
    local float difficulty;
    local DXRFlags f;
    local string sseed;
    Super.BindControls(writing);

    f = InitFlags();

    labels[id] = "";
    helptexts[id] = "Choose a game mode!";
    EnumOption(id, "Original Story", 0, writing, f.gamemode);
    EnumOption(id, "Horde Mode (Beta)", 2, writing, f.gamemode);
    EnumOption(id, "Original Story, Rearranged Levels (Alpha)", 1, writing, f.gamemode);
    //EnumOption(id, "Kill Bob Page (Alpha)", 3, writing, f.gamemode);
    //EnumOption(id, "How About Some Soy Food?", 6, writing, f.gamemode);
    EnumOption(id, "Stick With the Prod", 4, writing, f.gamemode);
    EnumOption(id, "Stick With the Prod Plus", 5, writing, f.gamemode);
    //EnumOption(id, "Max Rando", 7, writing, f.gamemode);
    id++;

    labels[id] = "Difficulty";
    helptexts[id] = "Difficulty determines the default settings for the randomizer.";
    if( EnumOption(id, "Easy", 0, writing) ) {
        difficulty=1;
        //also 20% enemies, key-only doors breakable and pickable, all hackable, normal skill rando 25%-200%, level 3 speed?
    }
    if( EnumOption(id, "Normal", 0, writing) ) {
        difficulty=1.25;
        //35% enemies, key-only doors breakable or pickable, all hackable, 80% ammo and items, normal skill rando 25%-300%, level 1 speed
    }
    if( EnumOption(id, "Hard", 0, writing) ) {
        difficulty=1.5;
        //50% enemies, some doors breakable or pickable, most hackable, 70% ammo and items, blind skill rando every 5 missions 25%-300%, level 1 speed
    }
    if( EnumOption(id, "Extreme", 0, writing) ) {
        difficulty=2;
        //70% enemies, some doors breakable or pickable, most hackable, 50% ammo and items, blind skill rando every 5 missions 25%-400%, level 1 speed?
    }
    id++;

    labels[id] = "Autosave";
    helptexts[id] = "Saves the game in case you die!";
    EnumOption(id, "Every Entry", 2, writing, f.autosave);
    EnumOption(id, "First Entry", 1, writing, f.autosave);
    EnumOption(id, "Off", 0, writing, f.autosave);
    id++;

    labels[id] = "Seed";
    helptexts[id] = "Enter a seed if you want to play the same game again.";
    sseed = EditBox(id, "", "1234567890", writing);
    if( sseed != "" ) {
        f.seed = int(sseed);
        //dxr.seed = f.seed;
    }
    id++;

    if(writing) {
        NewGameSetup(difficulty, action != "ADVANCED");
    }
}

function NewGameSetup(float difficulty, bool use_defaults)
{
    local DXRMenuSetupRando newGame;

    newGame = DXRMenuSetupRando(root.InvokeMenuScreen(Class'DXRMenuSetupRando'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.flags = flags;
        if( use_defaults ) newGame.ProcessAction("NEXT");
    }
}

defaultproperties
{
    num_rows=5
    num_cols=2
    col_width_odd=160
    col_width_even=220
    row_height=20
    padding_width=20
    padding_height=10
    actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel,Text="|&Back")
    actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Advanced",Key="ADVANCED")
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
}
