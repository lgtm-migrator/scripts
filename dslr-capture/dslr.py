#!/usr/bin/env python4
# 2019-07-09
# Injabie3
#
# Description:
# Autocapture script for DSLR cameras. Used for SFU Anime stuff.
# 
from copy import deepcopy
from datetime import datetime
import json
import logging
from re import search
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFont
import requests

import constants

class DSLR(object):
    """Capture DSLR images and place a timestamp on them."""

    def __init__(self, logger: logging.Logger, webhook: str=None):
        self.sentAlert25 = False
        self.sentAlertLow = False
        self.batteryStatus = None
        self.logger = logger
        self.webhook = webhook
        self.embed = deepcopy(constants.EMBED)

    def fetchBatteryStatus(self):
        batteryStatus = subprocess.run(["gphoto2", "--get-config=/main/status/batterylevel"],
                                         stdout=subprocess.PIPE)
        if batteryStatus.returncode != 0:
            self.logger.error("Could not fetch battery status!")
            self.batteryStatus = -1
            return
        level = search(r"(?:Current: )(\d+|Low)(?:%)?", batteryStatus.stdout).group(1)
        self.batteryStatus = level
        self.logger.info("DSLR battery status: %s", batteryStatus)

    def maybeSendAlert(self):
        if not self.webhook:
            return
        timestampText = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if not self.batteryStatus in [ "100", "75", "50", "25", "Low" ]:
            raise ValueError("Invalid batteryStatus!")
        elif self.batteryStatus == "25" and not self.sentAlert25:
            self.embed["embeds"][0]["description"] = (":warning: The DSLR battery is running "
                                                      "low, at 25%!")
            self.embed["embeds"][0]["footer"]["text"] = "Autocapture | {}".format(timestampText)
            requests.post(self.webhook, data=json.dumps(self.embed),
                          headers={'Content-Type': 'application/json'})
            self.sentAlert25 = True
        elif self.batteryStatus == "Low" and not self.sentAlertLow:
            self.embed["embeds"][0]["description"] = (":warning: The DSLR battery is extremely "
                                                      "low!! Please replace the battery "
                                                      "immediately!")
            self.embed["embeds"][0]["footer"]["text"] = "Autocapture | {}".format(timestampText)
            requests.post(self.webhook, data=json.dumps(self.embed),
                          headers={'Content-Type': 'application/json'})
            self.sentAlertLow = True
        elif self.batteryStatus == "50" or self.batteryStatus == "100":
            self.sentAlert25 = False
            self.sentAlertLow = False
