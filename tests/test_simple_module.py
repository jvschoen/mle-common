import unittest
from my_package import simple_module

class MyModuleTest(unittest.TestCase):
    def test_add(self):
        result = simple_module.add(1, 2)
        self.assertEqual(result, 3)

    def test_subtract(self):
        result = simple_module.subtract(5, 3)
        self.assertEqual(result, 2)


if __name__ == '__main__':
    unittest.main()