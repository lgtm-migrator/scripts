#!/usr/bin/env python3
# 2022-04-03

from copy import deepcopy
from datetime import datetime
import logging

import cv2

import constants
from imagecounter import ImageCounter

FONT = cv2.FONT_HERSHEY_SIMPLEX
FONT_SCALE = 0.6
THICKNESS = 1
TITLE_POINT = (5, 20)
COLOUR = (255, 255, 255)

class Webcam:
    _titlePoint = (5, 40)
    _fontScale = 1.5
    _thickness = 4
    def __init__(
            self,
            logger: logging.Logger,
            cam: int,
            cameraName: str,
            path: str,
            webhook: str=None):
        self.logger = logger
        self.webhook = webhook
        self.camera = cam
        self.cameraName = cameraName
        self.embed = deepcopy(constants.EMBED)
        self.path = path
        self._imageFrame = None
        self._imageTimestamp = None

        self._counters = ImageCounter()

    def addBanner(self):
        """Add banner to image."""
        readableTs = self._imageTimestamp.strftime("%Y-%m-%d %H:%M:%S")
        bannerText = "{} - {}".format(self.cameraName, readableTs)
        assert self._imageFrame is not None, "There is no frame to add a banner to!"
        cv2.rectangle(self._imageFrame,
                      (0, self._titlePoint[1]+10),
                      (self._imageFrame.shape[1], 0),
                      (0, 0, 0), thickness=-1)
        cv2.putText(self._imageFrame, bannerText, self._titlePoint,
                    FONT, self._fontScale, COLOUR, self._thickness)

    def capture(self):
        """Capture an image from the webcam using OpenCV

        This will update the internal state for:
        - The frame captured.
        - When the frame was captured.
    
        Returns
        -------
        bool
            True if the frame was captured successfully, False otherwise.

        """
        try:
            webcam = cv2.VideoCapture(0)
            webcam.open(self.camera)
            webcam.set(cv2.CAP_PROP_AUTOFOCUS, 1)
            webcam.set(cv2.CAP_PROP_FRAME_WIDTH, 1920);
            webcam.set(cv2.CAP_PROP_FRAME_HEIGHT, 1080);
            for _ in range(0, 60):
                webcam.grab()
            success, frame = webcam.read()
            #cv2.resize(frame, 0, frame, 1920, 1080)
        finally:
            webcam.release()

        if success:
            self.logger.debug("Frame successfully captured")
            self._imageTimestamp = datetime.now()
            self._imageFrame = frame
            self._counters.good += 1
            return True
        self.logger.debug("Could not capture frame")
        self._imageTimestamp = None
        self._imageFrame = None
        self._counters.bad += 1
        return False

    def saveImageToDisk(self):
        self.logger.info("Saving image on camera %s", self.cameraName)
        # TODO Use pathlib or something here
        filenameTs = self._imageTimestamp.strftime("%Y-%m-%d_%H-%M-%S")
        filename = self.path + "camera-{}.jpg".format(filenameTs)
        cv2.imwrite(filename=filename, img=self._imageFrame)

    def fetchAndSave(self):
        if self.capture():
            self.addBanner()
            self.saveImageToDisk()
            return True
        return False

    @property
    def counters(self):
        return self._counters
