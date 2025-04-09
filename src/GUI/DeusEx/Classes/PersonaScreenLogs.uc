class DXRPersonaScreenLogs merges PersonaScreenLogs;

const LOGMSGCHARLIMIT = 80;

// ----------------------------------------------------------------------
// PopulateLog()
//
// Loops through all the log messages and displays them
// ----------------------------------------------------------------------
function PopulateLog()
{
	local DeusExLog log;
	local int rowIndex;
	local int logCount;

    local string finalLogLines[10];
    local int numLines,i, strLen;
    local bool moreText;


	// Now loop through all the conversations and add them to the list
	log = player.FirstLog;
	logCount = 0;

	while(log != None)
	{
        strLen=Len(log.text);
        numLines=0;
        for(i=0;i<ArrayCount(finalLogLines);i++){
            finalLogLines[i]="";
        }

        while(true){
            finalLogLines[numLines]=Mid(log.text,numLines*LOGMSGCHARLIMIT,LOGMSGCHARLIMIT);
            numLines++;
            if (Len(finalLogLines[numLines-1])<LOGMSGCHARLIMIT){
                break;
            }
            if (numLines>ArrayCount(finalLogLines)){
                break;
            }
        }
        for(i=numLines-1;i>=0 /*&& finalLogLines[i]!=""*/;i--){
		    rowIndex = lstLogs.AddRow(finalLogLines[i] $ ";" $ logCount++);
        }
		log = log.next;
	}

	lstLogs.Sort();
}

