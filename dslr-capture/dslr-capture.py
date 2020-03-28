#!/usr/bin/env python3
# 2019-07-09
# Injabie3
#
# Description:
# Autocapture script for DSLR cameras. Used for SFU Anime stuff.
# 

import asyncio
from datetime import datetime
import json
import logging
import requests
import subprocess
import sys
import cv2
from PIL import Image, ImageDraw, ImageFont

FONT = cv2.FONT_HERSHEY_SIMPLEX
FONT_SCALE = 0.6
THICKNESS = 1
TITLE_POINT = (5, 20)
COLOUR = (255, 255, 255)

EMBED = \
{"username": "LuiP-RenPi",
 "embeds":
 [{"title": "DSLR script",
   "description": "",
   "color": 16723712,
   "footer": {"text": "Autocapture script by Injabie3" }
  }
 ]
}

WEBHOOK = None # Insert Discord webhook here.

def addBanner(frame, title, titlePoint=TITLE_POINT, fontScale=FONT_SCALE,
              thickness=THICKNESS):
    """Add banner to image.

    Parameters
    ----------
    frame
        The OpenCV frame to add the banner to.
    title: str
        The title on the banner.
    titlePoint: (int, int)
        The location offset from the top right corner of the frame to
        start writing to.
    fontScale: float
        The scaling of the font size.
    thickness: int
    """
    cv2.rectangle(frame,
                  (0, titlePoint[1]+10),
                  (frame.shape[1], 0),
                  (0, 0, 0), thickness=-1)
    cv2.putText(frame, title, titlePoint,
                FONT, fontScale, COLOUR, thickness)

async def capture(logger: logging.Logger, cam: int, prefix: str, title: str="Camera",
                  offset=None):
    """Async loop to capture images from webcam using OpenCV

    Parameters
    ----------
    logger: logging.Logger
        The logger object to keep track of when images are being captured.
    cam: int
        The webcam number to capture. If you only have one webcam, pass in 0.
    prefix: str
        Filename prefix for captured images.
    title: str
        The title to add to the top.

    """

    if offset:
        await asyncio.sleep(offset)
    try:
        total = 0
        good = 0
        bad = 0
        webcam = cv2.VideoCapture(0)
        while True:
            webcam.open(cam)
            webcam.set(cv2.CAP_PROP_AUTOFOCUS, 1)
            webcam.set(cv2.CAP_PROP_FRAME_WIDTH, 1920);
            webcam.set(cv2.CAP_PROP_FRAME_HEIGHT, 1080);
            for _ in range(0, 60):
                webcam.grab()
            success, frame = webcam.read()
            #cv2.resize(frame, 0, frame, 1920, 1080)
            webcam.release()
            if success:
                currTime = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
                timestampText = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                titleText = "{} - {}".format(title, timestampText)
                addBanner(frame, titleText, titlePoint=(5, 40), fontScale=1.5, thickness=4)
                logger.info("Saving image on camera %s", cam)
                cv2.imwrite(filename="webcam-{}/camera-{}.jpg".format(prefix, currTime), img=frame)
                good += 1
            else:
                logger.error("Could not save image on cam %s! Code: %s", cam, success)
                bad += 1
            total += 1
            await asyncio.sleep(15)
    finally:
        logger.info("Cam %s - Good: %s | Bad: %s | Total: %s", prefix, good, bad, total)

async def dslr(logger: logging.Logger):
    """DSLR Capture."""
    sentAlert25 = False
    sentAlertLow = False
    while True:
        currTime = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        filename = "dslr/cam-{}.jpg".format(currTime)
        subprocess.run(["gphoto2", "--capture-image-and-download",
                        "--filename={}".format(filename)])
        batteryStatus = subprocess.Popen(("gphoto2", "--get-config=/main/status/batterylevel"),
                                         stdout=subprocess.PIPE)
        batteryStatus = subprocess.Popen(("grep", "Current:"), stdin=batteryStatus.stdout,
                                         stdout=subprocess.PIPE)
        batteryStatus = subprocess.Popen(("sed", "s/Current: //g"), stdin=batteryStatus.stdout,
                                         stdout=subprocess.PIPE)
        batteryStatus = subprocess.check_output(("sed", "s/%//g"), stdin=batteryStatus.stdout)
        logger.info("batteryStatus: %s", batteryStatus)

        try:
            timestampText = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            if str(batteryStatus) == "25\n" and not sentAlert25:
                EMBED["embeds"][0]["description"] = (":warning: The DSLR battery is running "
                                                     "low, at 25%!")
                EMBED["embeds"][0]["footer"]["text"] = "Autocapture | {}".format(timestampText)
                requests.post(WEBHOOK, data=json.dumps(EMBED),
                              headers={'Content-Type': 'application/json'})
                sentAlert25 = True
            elif str(batteryStatus) == "Low\n" and not sentAlertLow:
                EMBED["embeds"][0]["description"] = (":warning: The DSLR battery is extremely "
                                                     "low!! Please replace the battery "
                                                     "immediately!")
                EMBED["embeds"][0]["footer"]["text"] = "Autocapture | {}".format(timestampText)
                requests.post(WEBHOOK, data=json.dumps(EMBED),
                              headers={'Content-Type': 'application/json'})
                sentAlertLow = True
            elif batteryStatus == "50" or batteryStatus == "100":
                sentAlert25 = False
                sentAlertLow = False
            with Image.open(filename) as image:
                width, height = image.size
                draw = ImageDraw.Draw(image)
                font = ImageFont.truetype("Roboto-Regular.ttf", size=100)
                titleText = "{} - {}".format("DSLR", timestampText)
                draw.rectangle(((0,0), (width, 105)), fill=0)
                draw.text((0,0), titleText, font=font)
                image.save("webcam-cam1/camera-{}.jpg".format(currTime), "JPEG")

            # transcol=cv2.cvtColor(image, cv2.COLOR_BGR2YCR_CB)
            # SSV=2
            # SSH=2
            # crf=cv2.boxFilter(transcol[:,:,1],ddepth=-1,ksize=(2,2))
            # cbf=cv2.boxFilter(transcol[:,:,2],ddepth=-1,ksize=(2,2))
            # crsub=crf[::SSV,::SSH]
            # cbsub=cbf[::SSV,::SSH]
            # imSub=[transcol[:,:,0],crsub,cbsub]
            # imSub=np.array(imSub)
            logger.info("Saving image on DSLR")
        except:
            logger.error("Could not capture probably, no focus", exc_info=True)
        await asyncio.sleep(15)



def setupLogger():
    """Set up logger"""
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    formatting = logging.Formatter("%(asctime)s %(levelname)s %(module)s "
                                   "%(funcName)s %(lineno)d: %(message)s",
                                   datefmt="[%Y-%m-%d %H:%M:%S]")
    handler.setFormatter(formatting)
    logger.addHandler(handler)
    return logger

if __name__ == "__main__":
    timestampText = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    EMBED["embeds"][0]["description"] = (":information_source: The DSLR autocapture script "
                                         "has started.")
    EMBED["embeds"][0]["footer"]["text"] = "Autocapture | {}".format(timestampText)
    requests.post(WEBHOOK, data=json.dumps(EMBED),
                  headers={'Content-Type': 'application/json'})
    logger = setupLogger()
    loop = asyncio.get_event_loop()
    #loop.create_task(capture(logger, 0, "cam1", title="Camera 1"))
    loop.create_task(capture(logger, 0, "cam2", title="Camera 2", offset=5))
    loop.create_task(dslr(logger))
    loop.run_forever()
