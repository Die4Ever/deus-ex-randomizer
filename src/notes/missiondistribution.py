import os

eventfile = os.path.join("..", "DXRModules", "DeusEx", "Classes", "DXREvents.uc")

mission=[]
for i in range(0,16):
    mission.append([])

def parseBingoLine(line):
    #print(line)
    line=line.strip(")\n")
    if ("//" in line):
        line = line.rsplit("//")[0]
    line = line.strip()
    if line=="":
        return

    bingoLine = line.split(")=(")[1]
    bingoLine = bingoLine.split(",") #This isn't perfect, but is good enough for splitting the line apart (Since we don't really care about the descriptions, which can include commas

    bingoLineDict = dict()
    for part in bingoLine:
        if "=" not in part:
            #Parts without an equal are probably part of the description, if it included a comma
            continue
        bingoLineSplit = part.split("=")
        bingoLineDict[bingoLineSplit[0]]=bingoLineSplit[1]
    print(bingoLineDict)

    if "missions" in bingoLineDict:
        missionVal=int(bingoLineDict["missions"])
        
        for i in range(0,16):
            if(missionVal & 1):
                mission[i].append(line)
                if (i==7 or i==13):
                    print(line)
            missionVal = missionVal >> 1

    else:
        mission[0].append(line)


f = open(eventfile)
defprops=False

for line in f:
    if "defaultproperties" in line:
        defprops = True

    if defprops:
        if "bingo_options" in line:
            parseBingoLine(line)

print("")

for i in range(0,16):
    if (len(mission[i])==0):
        continue

    print("##################")
    print("")
    print("Mission "+str(i)+": "+str(len(mission[i])))
    print("")
    for g in mission[i]:
        print(g)
    print("")

print("Any mission: "+str(len(mission[0])))
for i in range(1,16):
    if (len(mission[i])>0):
        print("Mission "+str(i)+": "+str(len(mission[i])))


f.close()


