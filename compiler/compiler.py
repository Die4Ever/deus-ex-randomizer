# calls the other modules and runs the UCC make compiler
from compiler.base import *
import json

dryrun = False

def run(args):
    if args.verbose:
        args.base.loglevel = 'debug'
    
    argprofiles = args.profile
    default_settings = {}
    with open('compiler_settings.default.json') as f:
        default_settings = json.load(f)
    
    settings = {}
    try:
        with open('compiler_settings.json') as f:
            settings = json.load(f)
    except FileNotFoundError as e:
        e.strerror += '\n\nERROR: You need to copy compiler_settings.example.json to compiler_settings.json and adjust the paths.'
        raise

    merged = default_settings
    for p in settings:
        if p not in merged:
            merged[p] = {}
        merged[p] = {**merged[p], **settings[p]}
    

    profiles = []
    if argprofiles == 'all':
        profiles = merged.keys()
    else:
        profiles = argprofiles.split(',')
    
    for p in profiles:
        profile_name = p.strip()
        profile = merged[profile_name]
        print("using "+profile_name+" settings\n"+repr(profile)+"\n")
        if not run_profile(args, profile):
            return
    

def run_profile(args, settings):
    out = settings['out_dir']
    packages = settings['packages']
    copy_local = settings['copy_local']
    run_tests = settings['run_tests']

    compileResult = compile(args, settings)
    if compileResult != 0:
        raise RuntimeError("Compilation failed, returned: "+str(compileResult))

    testSuccess = True
    if run_tests:
        testSuccess = args.tester.runAutomatedTests(out, packages[0])

    if not testSuccess:
        return False

    if copy_local:
        copy_package_files(out, packages)
    
    return True


def compile(args, settings):
    orig_files = {}
    mods_files = []
    injects = {}
    written = {}

    #source = None
    source = None
    if 'source_path' in settings:
        source = settings['source_path']
    mods = settings['mods_paths']
    out = settings['out_dir']
    definitions = settings['preproc_definitions']
    packages = settings['packages']
    rewrite_packages = {}
    if 'rewrite_packages' in settings:
        rewrite_packages = settings['rewrite_packages']
    reader = args.reader
    preprocessor = args.preprocessor
    writer = args.writer

    if source:
        print("processing source files from "+source)
        for file in insensitive_glob(source+'/*'):
            reader.proc_file(file, orig_files, 'source', None, preprocessor, definitions)
    
    for mod in mods:
        print("processing files from mod "+mod)
        mods_files.append({})
        for file in insensitive_glob(mod+'*'):
            if file_is_blacklisted(file, settings):
                continue
            f = reader.proc_file(file, mods_files[-1], mod, injects, preprocessor, definitions)
            if f and f.namespace in rewrite_packages:
                f.namespace = rewrite_packages[f.namespace]

    print("\nwriting source files...")
    writer.before_write(orig_files, injects)
    for file in orig_files.values():
        debug("Writing file "+str(file.file))
        writer.write_file(out, file, written, injects)
    
    for mod in mods_files:
        print("writing mod "+repr(mod.keys()))
        writer.before_write(mod, injects)
        for file in mod.values():
            debug("Writing mod file "+str(file.file))
            writer.write_file(out, file, written, injects)
    
    if dryrun:
        return 1
    
    writer.cleanup(out, written)
    
    # now we need to delete DeusEx.u otherwise it won't get recompiled, might want to consider support for other packages too
    for package in packages:
        file = package+'.u'
        if exists(out + '/System/'+file):
            print("Removing old "+file)
            os.remove(out + '/System/'+file)

    # can set a custom ini file ucc make INI=ProBob.ini https://www.oldunreal.com/wiki/index.php?title=Working_with_*.uc%27s
    # I can run automated tests like ucc Core.HelloWorld
    if not exists_dir(out + '/DeusEx/Inc'):
        os.makedirs(out + '/DeusEx/Inc', exist_ok=True)
    # also we can check UCC.log for success or just the existence of DeusEx.u
    ret = 1
    ret = calla([ out + '/System/ucc', 'make', '-h', '-NoBind', '-Silent' ])
    # if ret != 0 we should show the end of UCC.log, we could also keep track of compiler warnings to show at the end after the test results
    return ret


def copy_package_files(out_dir, packages):
    for package in packages:
        copyPackageFile(out_dir, package)


def copyPackageFile(out, package):
    file = package+'.u'
    if exists(out + '/System/'+file):
        print(file+" exists")
        shutil.copy2(out + '/System/'+file,'./'+file)
        print(file+" copied locally")
    else:
        raise RuntimeError("could not find "+file)


def file_is_blacklisted(file, settings):
    for b in settings['blacklist']:
        if b in file:
            return True
    return False

