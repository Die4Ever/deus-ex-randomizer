// written by joewintergreen
class LipSyncScriptedPawn shims ScriptedPawn;

//
// lip synching support - DEUS_EX CNN
//
function LipSynch(float deltaTime)
{
    local name animseq;
    local float rnd;
    local float tweentime;

    // update the animation timers that we are using
    animTimer[0] += deltaTime;
    animTimer[1] += deltaTime;
    animTimer[2] += deltaTime;

    if (bIsSpeaking)
    {
        // if our framerate is high enough (>20fps), tween the lips smoothly

//JOE CHANGE: I doubt this is a legit way to figure out frame rate.
//This used to set tweentime to 0 (no blend) if it thoght FPS was low, else 0.1.
//Even 0.1 is too fast to look good though. Anyway, skip the check, we don't care
//
//        if (Level.TimeSeconds - animTimer[3]  < 0.05)
//            tweentime = 0.4;
//        else
            tweentime = 0.36;

//Also, ideally tweentime would be the duration until the next time we get a phoneme update?
//But I don't know where that update comes from at the moment


        // the last animTimer slot is used to check framerate
        animTimer[3] = Level.TimeSeconds;

        if (nextPhoneme == "A")
            animseq = 'MouthA';
        else if (nextPhoneme == "E")
            animseq = 'MouthE';
        else if (nextPhoneme == "F")
            animseq = 'MouthF';
        else if (nextPhoneme == "M")
            animseq = 'MouthM';
        else if (nextPhoneme == "O")
            animseq = 'MouthO';
        else if (nextPhoneme == "T")
            animseq = 'MouthT';
        else if (nextPhoneme == "U")
            animseq = 'MouthU';
        else if (nextPhoneme == "X")
            animseq = 'MouthClosed';

        if (animseq != '')
        {
                    if (lastPhoneme != nextPhoneme)
            {
                lastPhoneme = nextPhoneme;
                TweenBlendAnim(animseq, tweentime);
//                TimeLastPhoneme = Level.TimeSeconds;
            }

        }


//        if ((Level.TimeSeconds - TimeLastPhoneme) >= tweentime*0.8 && TimeLastPhoneme != 0)
//        {
//        TweenBlendAnim('MouthClosed', 0.2);
//        nextPhoneme = "X";
//        lastPhoneme = "A";
//        TimeLastPhoneme = Level.TimeSeconds;
//        }
    }
    else
    if (bWasSpeaking)
    {
        bWasSpeaking = false;

//JOE: I added this tweentime set. Without it it was 0 as initialised, so the jaw snapped shut

        tweentime = 0.3;
        TweenBlendAnim('MouthClosed', tweentime);
    }

    // blink randomly
    if (animTimer[0] > 0.5)
    {
        animTimer[0] = 0;
        if (FRand() < 0.4)
            PlayBlendAnim('Blink', 0.2, 0.1, 1);
    }

    LoopHeadConvoAnim();
    LoopBaseConvoAnim();
}
