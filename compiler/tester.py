from compiler.base import *

def runAutomatedTests(out):
    rc = False
    if exists(out + '/System/DXRando.ini'):
        os.remove(out + '/System/DXRando.ini')
    if exists(out + '/System/DXRDataStorage.ini'):
        os.remove(out + '/System/DXRDataStorage.ini')
    if exists(out + '/System/DeusEx.ini'):
        # copy DeusEx.ini to test.ini, change [Engine.Engine] DefaultServerGame to =DeusEx.DXRandoTests
        f = open (out + '/System/DeusEx.ini','r')
        lines = f.readlines()
        f.close()

        for i in range(0,len(lines)):
            if "DefaultServerGame" in lines[i]:
                lines[i] = "DefaultServerGame=DeusEx.DXRandoTests\n"

        f = open(out + '/System/test.ini','w')
        f.writelines(lines)
        f.close()

        
        print("")
        print("=====================================================")
        print("             Starting Automated Tests")
        print("=====================================================")
        print("")
        

        # then we run this command
        # ucc server ini=test.ini
        calla([ out + '/System/ucc', 'server', 'ini=test.ini' ])
        if exists(out + '/System/DXRando.ini'):
            os.remove(out + '/System/DXRando.ini')
        if exists(out + '/System/DXRDataStorage.ini'):
            os.remove(out + '/System/DXRDataStorage.ini')
        print("")
        print("=====================================================")
        print("             Automated Tests Finished")
        print("=====================================================")
        print("")

        # then we can check UCC.log for the test results or parse them from the stdout

        print("")
        print("=====================================================")
        print("                      Results")
        print("=====================================================")
        print("")
        
        if exists(out + '/System/ucc.log'):
            f = open (out + '/System/ucc.log','r')
            lines = f.readlines()
            f.close()

            modulesTested = []
            failures = []
            allTestsPassed = []
            allExtendedTestsPassed = []
            startingTests = []
            warnings = []
            #Run through to find modules that ran tests and what failures there were
            for line in lines:
                if "passed tests!" in line:
                    modulesTested.append(line.strip())
                elif "tests failed!" in line:
                    modulesTested.append(line.strip())
                elif "fail: " in line:
                    failures.append(line.strip())
                elif "all tests passed!" in line:
                    allTestsPassed.append(line.strip())
                elif "all extended tests passed!" in line:
                    allExtendedTestsPassed.append(line.strip())
                elif "starting RunTests()" in line:
                    startingTests.append(line.strip())
                elif "WARNING:" in line:
                    warnings.append(line.strip())
                elif "ERROR" in line:
                    warnings.append(line.strip())
                elif "Accessed None" in line:
                    warnings.append(line.strip())
                elif "Accessed array out of bounds" in line:
                    warnings.append(line.strip())

            for module in modulesTested:
                print(module)

            print("")

            if len(warnings) > 0:
                print("Test Warnings ("+str(len(warnings))+"):")
                print("-----------------")
                for warn in warnings:
                    print(warn)
                print("")

            if len(failures) > 0:
                print("Test Failures ("+str(len(failures))+"):")
                print("-----------------")
                for fail in failures:
                    print(fail)
                print("")
                rc = False

            elif len(allTestsPassed) == len(startingTests) and len(allTestsPassed) > 0 and len(startingTests) > 0 and len(allExtendedTestsPassed) > 0:
                print("All tests passed! len(startingTests) == "+str(len(startingTests))+", len(allTestsPassed) == "+str(len(allTestsPassed))+", len(allExtendedTestsPassed) == "+str(len(allExtendedTestsPassed)))
                rc = True
            else:
                print("len(startingTests) == "+str(len(startingTests))+", len(allTestsPassed) == "+str(len(allTestsPassed))+", len(allExtendedTestsPassed) == "+str(len(allExtendedTestsPassed)))
                print("Failed to run tests!")
                rc = False

            print("")
            print("")

        else:
            print("Couldn't find ucc.log - did the compilation actually happen?")
            rc = False

        
    else:
        print("DeusEx.ini does not exist in the system folder of the output dir!")
        rc = False

    return rc
