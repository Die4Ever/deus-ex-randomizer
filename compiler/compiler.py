# calls the other modules and runs the UCC make compiler
from compiler.base import *

dryrun = False

def compile(args):
    orig_files = {}
    mods_files = []
    injects = {}
    written = {}

    source = args.source_path
    mods = args.mods_paths
    out = args.out_dir
    definitions = args.preproc_definitions
    reader = args.reader
    preprocessor = args.preprocessor
    writer = args.writer

    print("processing source files from "+source)
    for file in insensitive_glob(source+'/*'):
        reader.proc_file(file, orig_files, 'source', None, preprocessor, definitions)
    
    for mod in mods:
        print("processing files from mod "+mod)
        mods_files.append({})
        for file in insensitive_glob(mod+'*'):
            reader.proc_file(file, mods_files[-1], mod, injects, preprocessor, definitions)

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
    if exists(out + '/System/DeusEx.u'):
        print("Removing old DeusEx.u")
        os.remove(out + '/System/DeusEx.u')

    # can set a custom ini file ucc make INI=ProBob.ini https://www.oldunreal.com/wiki/index.php?title=Working_with_*.uc%27s
    # I can run automated tests like ucc Core.HelloWorld
    if not exists_dir(out + '/DeusEx/Inc'):
        os.makedirs(out + '/DeusEx/Inc', exist_ok=True)
    # also we can check UCC.log for success or just the existence of DeusEx.u
    ret = 1
    ret = calla([ out + '/System/ucc', 'make', '-h', '-NoBind', '-Silent' ])
    # if ret != 0 we should show the end of UCC.log, we could also keep track of compiler warnings to show at the end after the test results
    return ret

