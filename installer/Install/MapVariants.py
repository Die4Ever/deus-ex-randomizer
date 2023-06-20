from pathlib import Path
import tempfile
from zipfile import ZipFile
from Install import MD5, DownloadFile

def InstallMirrors(mapsdir: Path, callback: callable, flavor:str):
    print('\nInstallMirrors(', mapsdir, flavor, ')')
    totalmd5 = Md5Maps(mapsdir)
    if totalmd5 == 'd41d8cd98f00b204e9800998ecf8427e': # no map files found
        print('no mirrored maps found')
    elif totalmd5 == '265d1d8bef836074c28303c9326f5d35': # mirrored maps v0.7
        print('overwriting mirrored maps v0.7')
    elif totalmd5 == '8d06331fdc7fcc6904c316bbb94a4598': # v0.8
        print('overwriting mirrored maps v0.8')
    elif totalmd5 == '5551a03906a0f5470e2f9bd8724d59a6':
        print('overwriting mirrored maps v0.9')
    elif totalmd5 == '4a2b4cb284de0799ce0f111cfd8170fc': # v0.9.1
        print('already have mirrored maps v0.9.1')
        return
    else:
        print('unknown existing maps MD5:', totalmd5)

    tempdir = Path(tempfile.gettempdir()) / 'dxrando'
    tempdir.mkdir(exist_ok=True)
    name = 'dx.mirrored.maps.zip'
    if flavor == 'VMD':
        name = 'dx.vmd.mirrored.maps.zip'
    temp = tempdir / name
    if temp.exists():
        temp.unlink()

    # TODO: specify version
    url = "https://github.com/Die4Ever/unreal-map-flipper/releases/latest/download/" + name
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
            with open(mapsdir / name, 'wb') as out:
                out.write(data)
            print(Path(f.filename).name, f.file_size)

    print('done extracting to', mapsdir)
    temp.unlink()

def Md5Maps(mapsdir: Path) -> str:
    md5s = ''
    for f in mapsdir.glob('*_-1_1_1.dx'):
        data = f.read_bytes()
        md5s += MD5(data)
    return MD5(md5s.encode('utf-8'))
