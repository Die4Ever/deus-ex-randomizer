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
        appendException(e, '\n\nERROR: You need to copy compiler_settings.example.json to compiler_settings.json and adjust the paths.')
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
        if profile['verbose']:
            increase_loglevel(DebugLevels.DEBUG)
        else:
            increase_loglevel(DebugLevels.INFO)
        printHeader("using profile: "+profile_name+", settings:")
        notice(repr(profile)+"\n")
        if not run_profile(args, profile):
            return


def run_profile(args, settings):
    out = settings['out_dir']
    packages = settings['packages']
    run_tests = settings['run_tests']

    copy_local = settings.get('copy_local')
    changed = False
    if settings.get('copy_if_changed'):
        copy_local = True
        gitstatus = call(['git', 'status'])[1]
        if re.search(r'%s' % settings.get('copy_if_changed'), gitstatus):
            changed = True

    (compileResult, compileWarnings) = compile(args, settings)
    if compileResult != 0:
        raise RuntimeError("Compilation failed, returned: "+str(compileResult))

    testSuccess = True
    if run_tests:
        testSuccess = args.tester.runAutomatedTests(out, packages[0])
        for warning in compileWarnings:
            print_colored(warning)

    if not testSuccess:
        return False

    if settings.get('copy_if_changed') and not changed:
        notice("not copying locally because "+settings.get('copy_if_changed')+" has not changed: "+repr(packages))
    elif copy_local:
        copy_package_files(out, packages)
    else:
        notice("not copying locally due to compiler_settings config file: "+repr(packages))

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
        notice("processing source files from "+source)
        for file in insensitive_glob(source+'/*'):
            try:
                reader.proc_file(file, orig_files, 'source', None, preprocessor, definitions)
            except Exception as e:
                appendException(e, "error processing vanilla file: "+file)
                raise

    for mod in mods:
        notice("processing files from mod "+mod)
        mods_files.append({})
        for file in insensitive_glob(mod+'*'):
            try:
                if file_is_blacklisted(file, settings):
                    continue
                f = reader.proc_file(file, mods_files[-1], mod, injects, preprocessor, definitions)
                if f and f.namespace in rewrite_packages:
                    f.namespace = rewrite_packages[f.namespace]
            except Exception as e:
                appendException(e, "error processing mod file: "+file)
                raise

    notice("\nwriting source files...")
    writer.before_write(orig_files, injects)
    for file in orig_files.values():
        try:
            debug("Writing file "+str(file.file))
            writer.write_file(out, file, written, injects)
        except Exception as e:
            appendException(e, "error writing vanilla file "+str(file.file))
            raise

    for mod in mods_files:
        notice("writing mod "+repr(mod.keys())[:200])
        try:
            writer.before_write(mod, injects)
        except Exception as e:
            appendException(e, "error before_write mod "+repr(mod.keys()))
            raise
        for file in mod.values():
            debug("Writing mod file "+str(file.file))
            try:
                writer.write_file(out, file, written, injects)
            except Exception as e:
                appendException(e, "error writing mod file "+str(file.file))
                raise

    if dryrun:
        return 1

    writer.cleanup(out, written)

    # now we need to delete DeusEx.u otherwise it won't get recompiled, might want to consider support for other packages too
    for package in packages:
        file = package+'.u'
        if exists(out + '/System/'+file):
            notice("Removing old "+file)
            os.remove(out + '/System/'+file)

    # can set a custom ini file ucc make INI=ProBob.ini https://www.oldunreal.com/wiki/index.php?title=Working_with_*.uc%27s
    # I can run automated tests like ucc Core.HelloWorld
    if not exists_dir(out + '/DeusEx/Inc'):
        os.makedirs(out + '/DeusEx/Inc', exist_ok=True)
    # also we can check UCC.log for success or just the existence of DeusEx.u
    ret = 1
    (ret, out, errs) = call([ out + '/System/ucc', 'make', '-h', '-NoBind', '-Silent' ])
    warnings = []
    re_terrorist = re.compile(r'((Parsing)|(Compiling)) (([\w\d_]*Terrorist\w*)|(AmmoNone))')
    for line in errs.splitlines():
        if not re_terrorist.match(line):
            warnings.append(line)
    # if ret != 0 we should show the end of UCC.log, we could also keep track of compiler warnings to show at the end after the test results
    return (ret, warnings)


def copy_package_files(out_dir, packages):
    for package in packages:
        copyPackageFile(out_dir, package)


def copyPackageFile(out, package):
    file = package+'.u'
    if exists(out + '/System/'+file):
        notice(file+" exists")
        shutil.copy2(out + '/System/'+file,'./'+file)
        notice(file+" copied locally")
    else:
        raise RuntimeError("could not find "+file)


def file_is_blacklisted(file, settings):
    for b in settings['blacklist']:
        if b in file:
            return True
    return False

