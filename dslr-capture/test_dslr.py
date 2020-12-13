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
        self.assertIsNone(self.dslr.batteryStatus, "Failed sanity check")
        with patch("dslr.subprocess.run", subRun):
            self.dslr.fetchBatteryStatus()
            self.assertEqual(self.dslr.batteryStatus, -1,
                             "We should have set battery status to -1!")

    def testFetchBatteryStatusPercentages(self):
        text = "Label: Battery Level\nReadonly: 0\nType: TEXT\nCurrent: {}%"
        self.assertIsNone(self.dslr.batteryStatus, "Failed sanity check")
        for level in [ "100", "75", "50", "25", "Low" ]:
            subRun = MagicMock(subprocess.run)
            subRun.return_value = subprocess.CompletedProcess(["test"], returncode=0,
                                                              stdout=text.format(level))
            with patch("dslr.subprocess.run", subRun):
                self.dslr.fetchBatteryStatus()
                self.assertEqual(self.dslr.batteryStatus, level,
                                 f"Battery level doesn't match {level}")

    def testMaybeSendAlertWithNoWebhook(self):
        with patch("dslr.requests.post") as request:
            self.dslr.maybeSendAlert()
            request.assert_not_called()

    def testMaybeSendAlertWithBatteryStatusGood(self):
        self.dslr.webhook = "SomeWebhook"
        with patch("dslr.requests.post") as request:
            for level in [ "100", "75", "50" ]:
                self.dslr.batteryStatus = level
                self.dslr.maybeSendAlert()
                request.assert_not_called()

    def testMaybeSendAlertWithBatteryStatusInvalid(self):
        self.dslr.webhook = "SomeWebhook"
        with patch("dslr.requests.post") as request:
            self.dslr.batteryStatus = "-1"
            self.assertRaises(ValueError, self.dslr.maybeSendAlert)
            request.assert_not_called()

    def testMaybeSendAlertWithBatteryStatus25(self):
        self.dslr.webhook = "SomeWebhook"
        with patch("dslr.requests.post") as request:
            self.dslr.batteryStatus = "25"
            self.dslr.maybeSendAlert()
            request.assert_called()
            self.assertTrue(self.dslr.sentAlert25, "Flag was not modified!")

        # If it's been sent once, don't send again.
        with patch("dslr.requests.post") as request:
            self.dslr.maybeSendAlert()
            request.assert_not_called()

        self.dslr.batteryStatus = "100"
        self.dslr.maybeSendAlert()
        self.assertFalse(self.dslr.sentAlert25, "Flag not reset after recovering!")
        self.assertFalse(self.dslr.sentAlertLow, "Flag not reset after recovering!")

    def testMaybeSendAlertWithBatteryStatusLow(self):
        self.dslr.webhook = "SomeWebhook"
        with patch("dslr.requests.post") as request:
            self.dslr.batteryStatus = "Low"
            self.dslr.maybeSendAlert()
            request.assert_called()
            self.assertTrue(self.dslr.sentAlertLow, "Flag was not modified!")

        # If it's been sent once, don't send again.
        with patch("dslr.requests.post") as request:
            self.dslr.maybeSendAlert()
            request.assert_not_called()

        # Going back to good status should reset flags.
        self.dslr.batteryStatus = "100"
        with patch("dslr.requests.post") as request:
            self.dslr.maybeSendAlert()
            request.assert_not_called()
            self.assertFalse(self.dslr.sentAlert25, "Flag not reset after recovering!")
            self.assertFalse(self.dslr.sentAlertLow, "Flag not reset after recovering!")

if __name__ == '__main__':
    unittest.main()

