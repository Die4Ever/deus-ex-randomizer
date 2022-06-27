# runs the automated tests using
from compiler.base import *


def runAutomatedTests(out, package):
    rc = False
    cleanup(out)

    if exists(out + '/System/Default.ini'):
        # copy Default.ini (defaults for DeusEx.ini) to test.ini, change [Engine.Engine] DefaultServerGame to =DeusEx.DXRandoTests
        f = open (out + '/System/Default.ini','r')
        lines = f.readlines()
        f.close()

        for i in range(0,len(lines)):
            if "DefaultServerGame" in lines[i]:
                lines[i] = "DefaultServerGame="+package+".DXRandoTests\n"

        f = open(out + '/System/test.ini','w')
        f.writelines(lines)
        f.close()

        printHeader('Starting Automated Tests')

        # then we run this command
        # ucc server ini=test.ini
        log = call([ out + '/System/ucc', 'server', 'ini=test.ini' ])[1]
        cleanup(out)

        printHeader('Automated Tests Finished')

        # then we can check UCC.log for the test results or parse them from the stdout

        printHeader('Results')

        if exists(out + '/System/ucc.log'):
            rc = parseUCClog(log)
        else:
            print("Couldn't find ucc.log - did the compilation actually happen?")
            rc = False


    else:
        print("Default.ini does not exist in the system folder of the output dir!")
        rc = False

    return rc


def parseUCClog(log):
    lines = log.splitlines()

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
        print_colored("Test Warnings ("+str(len(warnings))+"):")
        print("-----------------")
        for warn in warnings:
            print_colored(warn)
        print("")

    if len(failures) > 0:
        printError("Test Failures ("+str(len(failures))+"):")
        printError("-----------------")
        for fail in failures:
            print_colored(fail)
        print("")
        rc = False

    elif len(allTestsPassed) == len(startingTests) and len(allTestsPassed) > 0 and len(startingTests) > 0 and len(allExtendedTestsPassed) > 0:
        print("All tests passed! len(startingTests) == "+str(len(startingTests))+", len(allTestsPassed) == "+str(len(allTestsPassed))+", len(allExtendedTestsPassed) == "+str(len(allExtendedTestsPassed)))
        rc = True
    else:
        print("len(startingTests) == "+str(len(startingTests))+", len(allTestsPassed) == "+str(len(allTestsPassed))+", len(allExtendedTestsPassed) == "+str(len(allExtendedTestsPassed)))
        printError("Failed to run tests!")
        rc = False

    print("")
    print("")
    return rc


def cleanup(out):
    if exists(out + '/System/DXRando.ini'):
        os.remove(out + '/System/DXRando.ini')
    if exists(out + '/System/DXRDataStorage.ini'):
        os.remove(out + '/System/DXRDataStorage.ini')
    if exists(out + '/System/DXRBingo.ini'):
        os.remove(out + '/System/DXRBingo.ini')

