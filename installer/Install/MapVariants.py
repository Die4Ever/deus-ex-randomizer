from pathlib import Path
import urllib.request
import tempfile
from zipfile import ZipFile

def InstallMirrors(mapsdir: Path, downloadcallback: callable):
    tempdir = Path(tempfile.gettempdir()) / 'dxrando'
    tempdir.mkdir(exist_ok=True)
    temp = tempdir / "dxmirrors.zip"
    # TODO: check version and flavor
    if not temp.exists():
        print('\n\ndownloading to', temp)
        urllib.request.urlretrieve(
            "https://github.com/Die4Ever/unreal-map-flipper/releases/latest/download/dx.mirrored.maps.zip",
            temp, downloadcallback
        )
        print('done downloading to', temp)

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
