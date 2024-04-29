from pathlib import Path
import unittest
from unittest import case
from typeguard import typechecked, install_import_hook

typechecks = True
if typechecks:
    install_import_hook('Install')
    install_import_hook('Configs')
    install_import_hook('GUI')

import Install
import Install.Install
import Install.Config as Config
import GUI
import Install.MapVariants

@typechecked
class DXRTestCase(unittest.TestCase):
    def test_documents(self):
        system = Path('/home/deck/.local/share/Steam/steamapps/common/Deus Ex/System/')
        d = Install.GetSteamPlayDocuments(system)
        self.assertEqual(d, Path('/home/deck/.local/share/Steam/steamapps/compatdata/6910/pfx/drive_c/users/steamuser/Documents/'), 'GetSteamPlayDocuments')

        d = Install.GetDocumentsDir(Path.home())
        self.assertTrue(d.exists(), str(d) + ' exists')


    def test_config(self):
        # test config 1
        origconfig = (b'[Engine.Engine]\r\n'
            + b'DefaultGame=DeusEx.DeusExGameInfo\r\n'
            + b'\r\n\r\n'
            + b'[Core.System]\r\nPaths=Maps\r\nPaths=System\r\n'
        )

        desiredconfig = (b'[Engine.Engine]\r\n'
            + b'DefaultGame=GMDXRandomizer.DXRandoGameInfo\r\n'
            + b';DefaultGame=DeusEx.DeusExGameInfo\r\n'# old values are commented out
            + b'\r\n'
            + b'[Core.System]\r\nPaths=..\GMDXRandomizer\System\*.u\r\nPaths=Maps\r\nPaths=System\r\n'
            + b'\r\n'
        )

        c = Config.Config(origconfig)
        c.ModifyConfig(
            {'Engine.Engine': {'DefaultGame': 'GMDXRandomizer.DXRandoGameInfo'}},#changes
            {'Core.System': {'Paths': '..\\GMDXRandomizer\\System\\*.u'}}#additions
        )
        result = c.GetBinary()

        print('\nresult:')
        print(result)
        print('desired:')
        print(desiredconfig)
        print('')
        self.assertEqual(result, desiredconfig, 'got desired config text 1')

        # test config 2
        origconfig    = (b'[Engine.Engine]\r\nGameRenderDevice=D3D10Drv.D3D10RenderDevice\r\nAudioDevice=Galaxy.GalaxyAudioSubsystem\r\nNetworkDevice=IpDrv.TcpNetDriver\r\nDemoRecordingDevice=Engine.DemoRecDriver\r\nConsole=Engine.Console\r\nLanguage=VMD\r\nGameEngine=DeusEx.DeusExGameEngine\r\nEditorEngine=Editor.EditorEngine\r\nWindowedRenderDevice=SoftDrv.SoftwareRenderDevice\r\nRenderDevice=GlideDrv.GlideRenderDevice\r\n'
            + b'DefaultGame=DeusEx.DeusExGameInfo\r\n'
            + b'DefaultServerGame=DeusEx.DeathMatchGame\r\nViewportManager=WinDrv.WindowsClient\r\nRender=RenderExt.RenderExt\r\nInput=Extension.InputExt\r\nCanvas=Engine.Canvas\r\n'
            + b'Root=DeusEx.DeusExRootWindow\r\n'
            + b'CdPath=D:\r\n\r\n')
        desiredconfig = (b'[Engine.Engine]\r\nGameRenderDevice=D3D10Drv.D3D10RenderDevice\r\nAudioDevice=Galaxy.GalaxyAudioSubsystem\r\nNetworkDevice=IpDrv.TcpNetDriver\r\nDemoRecordingDevice=Engine.DemoRecDriver\r\nConsole=Engine.Console\r\nLanguage=VMD\r\nGameEngine=DeusEx.DeusExGameEngine\r\nEditorEngine=Editor.EditorEngine\r\nWindowedRenderDevice=SoftDrv.SoftwareRenderDevice\r\nRenderDevice=GlideDrv.GlideRenderDevice\r\n'
            + b'DefaultGame=VMDRandomizer.DXRandoGameInfo\r\n'
            + b';DefaultGame=DeusEx.DeusExGameInfo\r\n'
            + b'DefaultServerGame=DeusEx.DeathMatchGame\r\nViewportManager=WinDrv.WindowsClient\r\nRender=RenderExt.RenderExt\r\nInput=Extension.InputExt\r\nCanvas=Engine.Canvas\r\n'
            + b'Root=VMDRandomizer.DXRandoRootWindow\r\n'
            + b';Root=DeusEx.DeusExRootWindow\r\n'
            + b'CdPath=D:\r\n'
            + b'\r\n[Core.System]\r\nPaths=..\\VMDRandomizer\\System\\*.u\r\n' # leftover addition with no matched section gets added
            + b'\r\n')

        c = Config.Config(origconfig)
        c.ModifyConfig(
            {'Engine.Engine': {'DefaultGame': 'VMDRandomizer.DXRandoGameInfo', 'Root': 'VMDRandomizer.DXRandoRootWindow'}},#changes
            {'Core.System': {'Paths': '..\\VMDRandomizer\\System\\*.u'}}#additions
        )
        result = c.GetBinary()

        print('\nresult:')
        print(result)
        print('desired:')
        print(desiredconfig)
        print('')
        self.assertEqual(result, desiredconfig, 'got desired config text 2')

        # test config 3
        origconfig = (b'[DeusEx.DXRando]\r\n'
            + b'modules_to_load[0]=DXRTelemetry\r\n'
            + b'modules_to_load[1]=DXRMissions\r\n'
            + b'; test comment\r\n'
            + b'\r\n\r\n'
            + b'[Core.System]\r\nPaths=Maps\r\nPaths=System\r\n'
        )

        c = Config.Config(origconfig)
        data = c.sections

        print('\nresult:')
        print(data)
        print('desired:')
        print(origconfig)
        print('')
        self.assertDictEqual(data,
            {
                'DeusEx.DXRando': [
                    {'key': 'modules_to_load[0]', 'value': 'DXRTelemetry'},
                    {'key': 'modules_to_load[1]', 'value': 'DXRMissions'},
                    {'text': '; test comment'},
                ],
                'Core.System': [
                    {'key': 'Paths', 'value': 'Maps'},
                    {'key': 'Paths', 'value': 'System'},
                ],
            }, 'ReadConfig test')

if __name__ == "__main__":
    unittest.main(verbosity=9, warnings="error", failfast=True)
