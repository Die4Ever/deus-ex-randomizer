try:
    from pathlib import Path
    import tempfile
    from zipfile import ZipFile
    from Install import MD5, DownloadFile, Mkdir, WriteBytes, debug, info
    from collections.abc import Callable
except Exception as e:
    info('ERROR: importing', e)
    raise

maps_versions = {
    'd41d8cd98f00b204e9800998ecf8427e': 'none', # empty folder
    '265d1d8bef836074c28303c9326f5d35': 'v0.7',
    '8d06331fdc7fcc6904c316bbb94a4598': 'v0.8',
    '5551a03906a0f5470e2f9bd8724d59a6': 'v0.9',
    '4a2b4cb284de0799ce0f111cfd8170fc': 'v0.9.1',
    '3aee6ad2d9f88286b9ab105fb18109e2': 'v0.9.2', # after changing Md5Maps function
    'c6bd4612828f025bdcd4cfd25655b4a3': 'v0.9.3',
    '3b678c5b4f4b7fcd26f2c30ffec14770': 'v0.9.4',
}
latest_maps = 'v0.9.4'
assert latest_maps in maps_versions.values()

def InstallMirrors(mapsdir: Path, callback: Callable, flavor:str):
    global maps_versions, latest_maps
    info('\nInstallMirrors(', mapsdir, flavor, ')')
    callback(0, 1, 1, 'Checking Maps')
    totalmd5 = Md5Maps(mapsdir)
    callback(1, 1, 1, 'Checking Maps')

    version = maps_versions.get(totalmd5)
    if version == latest_maps:
        info('already have mirrored maps', version, totalmd5)
        return
    elif version:
        info('overwriting mirrored maps', version, totalmd5)
    else:
        info('unknown existing maps MD5:', totalmd5)

    tempdir = Path(tempfile.gettempdir()) / 'dxrando'
    Mkdir(tempdir, exist_ok=True)
    name = 'dx.mirrored.maps.zip'
    if flavor == 'VMD':
        name = 'dx.vmd.mirrored.maps.zip'
    temp = tempdir / name
    if temp.exists():
        temp.unlink()

    # TODO: specify version
    url = 'https://github.com/Die4Ever/unreal-map-flipper/releases/download/'+latest_maps+'/' + name
    downloadcallback = lambda a,b,c : callback(a,b,c, status="Downloading Maps")
    DownloadFile(url, temp, downloadcallback)

    with ZipFile(temp, 'r') as zip:
        maps = list(zip.infolist())
        i=0
        for f in maps:
            callback(i, 1, len(maps), 'Extracting')
            i+=1
            if f.is_dir():
                continue
            name = Path(f.filename).name
            data = zip.read(f.filename)
            out = mapsdir / name
            WriteBytes(out, data)
            debug(Path(f.filename).name, f.file_size)

    info('done extracting to', mapsdir)
    temp.unlink()

def Md5Maps(mapsdir: Path) -> str:
    Md5sArr = []
    for f in mapsdir.glob('*.dx'):
        data = f.read_bytes()
        t = MD5(data)
        debug('MD5 of map', f.name, t)
        Md5sArr.append(t)
    Md5sArr.sort()
    Md5sStr = ','.join(Md5sArr)
    debug('Md5Maps all hashes', Md5sStr)
    return MD5(Md5sStr.encode('utf-8'))
