import unittest
from unittest import case
from typeguard import typechecked, install_import_hook

typechecks = True
if typechecks:
    install_import_hook('Install')
    install_import_hook('Configs')
    install_import_hook('GUI')

import Install
import Configs
import GUI

@typechecked
class DXRTestCase(unittest.TestCase):
    def test_config(self):
        origconfig = (b'[Engine.Engine]\r\n'
            + b'DefaultGame=DeusEx.DeusExGameInfo\r\n'
            + b'\r\n\r\n'
            + b'[Core.System]\r\nPaths=Maps\r\nPaths=System\r\n'
        )

        desiredconfig = (b'[Engine.Engine]\r\n'
            + b'DefaultGame=GMDXRandomizer.DXRandoGameInfo\r\n'
            + b'\r\n\r\n'
            + b'[Core.System]\r\nPaths=..\GMDXRandomizer\System\*.u\r\nPaths=Maps\r\nPaths=System\r\n'
        )

        result = Configs.ModifyConfig(origconfig,
            {'Engine.Engine': {'DefaultGame': 'GMDXRandomizer.DXRandoGameInfo'}},#changes
            {'Core.System': {'Paths': '..\\GMDXRandomizer\\System\\*.u'}}#additions
        )

        print('\nresult:')
        print(result)
        print('desired:')
        print(desiredconfig)
        print('')
        self.assertEqual(result, desiredconfig, 'got desired config text')

        origconfig    = (b'[Engine.Engine]\r\nGameRenderDevice=D3D10Drv.D3D10RenderDevice\r\nAudioDevice=Galaxy.GalaxyAudioSubsystem\r\nNetworkDevice=IpDrv.TcpNetDriver\r\nDemoRecordingDevice=Engine.DemoRecDriver\r\nConsole=Engine.Console\r\nLanguage=VMD\r\nGameEngine=DeusEx.DeusExGameEngine\r\nEditorEngine=Editor.EditorEngine\r\nWindowedRenderDevice=SoftDrv.SoftwareRenderDevice\r\nRenderDevice=GlideDrv.GlideRenderDevice\r\n'
            + b'DefaultGame=DeusEx.DeusExGameInfo\r\n'
            + b'DefaultServerGame=DeusEx.DeathMatchGame\r\nViewportManager=WinDrv.WindowsClient\r\nRender=RenderExt.RenderExt\r\nInput=Extension.InputExt\r\nCanvas=Engine.Canvas\r\n'
            + b'Root=DeusEx.DeusExRootWindow\r\n'
            + b'CdPath=D:\r\n\r\n')
        desiredconfig = (b'[Engine.Engine]\r\nGameRenderDevice=D3D10Drv.D3D10RenderDevice\r\nAudioDevice=Galaxy.GalaxyAudioSubsystem\r\nNetworkDevice=IpDrv.TcpNetDriver\r\nDemoRecordingDevice=Engine.DemoRecDriver\r\nConsole=Engine.Console\r\nLanguage=VMD\r\nGameEngine=DeusEx.DeusExGameEngine\r\nEditorEngine=Editor.EditorEngine\r\nWindowedRenderDevice=SoftDrv.SoftwareRenderDevice\r\nRenderDevice=GlideDrv.GlideRenderDevice\r\n'
            + b'DefaultGame=VMDRandomizer.DXRandoGameInfo\r\n'
            + b'DefaultServerGame=DeusEx.DeathMatchGame\r\nViewportManager=WinDrv.WindowsClient\r\nRender=RenderExt.RenderExt\r\nInput=Extension.InputExt\r\nCanvas=Engine.Canvas\r\n'
            + b'Root=VMDRandomizer.DXRandoRootWindow\r\n'
            + b'CdPath=D:\r\n\r\n')

        result = Configs.ModifyConfig(origconfig,
            {'Engine.Engine': {'DefaultGame': 'VMDRandomizer.DXRandoGameInfo', 'Root': 'VMDRandomizer.DXRandoRootWindow'}},#changes
            {'Core.System': {'Paths': '..\\VMDRandomizer\\System\\*.u'}}#additions
        )

        print('\nresult:')
        print(result)
        print('desired:')
        print(desiredconfig)
        print('')
        self.assertEqual(result, desiredconfig, 'got desired config text')

if __name__ == "__main__":
    unittest.main(verbosity=9, warnings="error", failfast=True)
