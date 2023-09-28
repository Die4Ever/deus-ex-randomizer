eventfile = "..\DXRModules\DeusEx\Classes\DXREvents.uc"

mission=[]
for i in range(0,16):
    mission.append(0)

def parseBingoLine(line):
    if "missions" in line:
        missionVal = int(line.split("missions=")[1].replace(")",""))
        #print(missionVal)

        for i in range(0,16):
            if(missionVal & 1):
                mission[i]+=1
                if (i==7 or i==13):
                    print(line)
            missionVal = missionVal >> 1
        
    else:
        mission[0]+=1
    

f = open(eventfile)
defprops=False

for line in f:
    if "defaultproperties" in line:
        defprops = True

    if defprops:
        if "bingo_options" in line:
            parseBingoLine(line)

print("Any mission: "+str(mission[0]))
for i in range(1,16):
    print("Mission "+str(i)+": "+str(mission[i]))


f.close()


