#!/usr/bin/env python3
import dslr
import unittest
from unittest.mock import MagicMock, patch
import logging
import subprocess

class TestDslr(unittest.TestCase):
    def setUp(self):
        self.logger = logging.Logger("Test")
        self.dslr = dslr.DSLR(self.logger) 

    def testFetchBatteryStatusThatIsUnableToFetch(self):
        subRun = MagicMock(subprocess.run)
        subRun.return_value = subprocess.CompletedProcess(["test"], -1)
        assert self.dslr.batteryStatus == None, "Failed sanity check"
        with patch("dslr.subprocess.run", subRun):
            self.dslr.fetchBatteryStatus()
            assert self.dslr.batteryStatus == -1, "We should have set battery status to -1!"

    def testFetchBatteryStatusPercentages(self):
        text = "Label: Battery Level\nReadonly: 0\nType: TEXT\nCurrent: {}%"
        assert self.dslr.batteryStatus == None, "Failed sanity check"
        for level in [ "100", "75", "50", "25", "Low" ]:
            subRun = MagicMock(subprocess.run)
            subRun.return_value = subprocess.CompletedProcess(["test"], returncode=0,
                                                              stdout=text.format(level))
            with patch("dslr.subprocess.run", subRun):
                self.dslr.fetchBatteryStatus()
                assert self.dslr.batteryStatus == level, f"Battery level doesn't match {level}"

        


if __name__ == '__main__':
    unittest.main()

