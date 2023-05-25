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
    def test_stuff(self):
        self.assertEqual(1, 1, '1==1')

if __name__ == "__main__":
    unittest.main(verbosity=9, warnings="error", failfast=True)
