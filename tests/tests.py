import os
import sys
import time
import unittest
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, parentdir + "/build/lib.linux-armv6l-3.2/")
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


class TestNonBlocking(unittest.TestCase):
    """Tests the non blocking setting."""
    def setUp(self):
        lirc.init("lirctest", "tests/lircrc.test", blocking=False)

    def test_nonblocking_nextcode(self):
        print("Don't press anything yet...")
        start_time = time.time()
        end_time = start_time + 1  # 1 second in the future
        pressed = False
        while not pressed and time.time() < end_time:
            if lirc.nextcode() == ["horses"]:
                pressed = True
        self.assertFalse(pressed)

        print("Press 1 on your remote.")
        start_time = time.time()
        end_time = start_time + 5  # 5 seconds in the future
        pressed = False
        while not pressed and time.time() < end_time:
            if lirc.nextcode() == ["horses"]:
                pressed = True
        self.assertTrue(pressed)

    def tearDown(self):
        lirc.deinit()


if __name__ == "__main__":
    unittest.main()
