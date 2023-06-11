from pathlib import Path
import urllib.request
import tempfile
from zipfile import ZipFile

def InstallMirrors(mapsdir: Path, downloadcallback: callable, flavor:str):
    tempdir = Path(tempfile.gettempdir()) / 'dxrando'
    tempdir.mkdir(exist_ok=True)
    name = 'dx.mirrored.maps.zip'
    if flavor == 'VMD':
        name = 'dx.vmd.mirrored.maps.zip'
    temp = tempdir / name
    # TODO: check version
    if not temp.exists():
        url = "https://github.com/Die4Ever/unreal-map-flipper/releases/latest/download/" + name
        print('\n\ndownloading', url, 'to', temp)
        urllib.request.urlretrieve(url, temp, downloadcallback)
        print('done downloading ', url, 'to', temp)

    with ZipFile(temp, 'r') as zip:
        maps = list(zip.infolist())
        i=0
        for f in maps:
            downloadcallback(i, 1, len(maps), 'Extracting')
            i+=1
            if f.is_dir():
                continue
            name = Path(f.filename).name
            data = zip.read(f.filename)
            with open(mapsdir / name, 'wb') as out:
                out.write(data)
            print(Path(f.filename).name, f.file_size)

    print('done extracting to', mapsdir)
    #temp.unlink()
