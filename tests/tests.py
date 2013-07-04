import unittest
import lirc


class TestNextCode(unittest.TestCase):
    """General use tests (not really in the spirit of unittesting)."""
    def setUp(self):
        lirc.init("lirctest", "tests/lircrc.test")

    def test_nextcode(self):
        print("Press 1 on your remote.")
        self.assertEqual(lirc.nextcode(), ["horses"])

    def tearDown(self):
        lirc.deinit()


if __name__ == "__main__":
    unittest.main()
