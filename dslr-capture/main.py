#!/usr/bin/env python3
# 2020-03-28
# Injabie3
#
# Description:
# Autocapture script for DSLR cameras. Used for SFU Anime stuff.
# 

from dslrCapture import *
from webcam import Webcam

async def webcamCapture(logger):
    cameraName = "Summer Festival"
    webcam = Webcam(logger, 0, cameraName=cameraName,
                    path="/home/pi/git/scripts/dslr-capture/webcam-usb/")
    try:
        while True:
            webcam.fetchAndSave()
            await asyncio.sleep(5)
    finally:
        ctrs = webcam.counters
        logger.info("Cam %s - Good: %s | Bad: %s | Total: %s", cameraName,
                    ctrs.good, ctrs.bad, ctrs.total)



if __name__ == "__main__":
    timestampText = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    #EMBED["embeds"][0]["description"] = (":information_source: The DSLR autocapture script "
    #                                     "has started.")
    #EMBED["embeds"][0]["footer"]["text"] = "Autocapture | {}".format(timestampText)
    #requests.post(WEBHOOK, data=json.dumps(EMBED),
    #              headers={'Content-Type': 'application/json'})
    logger = setupLogger()
    loop = asyncio.get_event_loop()
    #loop.create_task(capture(logger, 0, "cam1", title="Camera 1"))
    loop.create_task(webcamCapture(logger))
    #loop.create_task(dslr(logger))
    loop.run_forever()
