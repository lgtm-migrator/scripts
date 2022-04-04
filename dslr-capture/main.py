#!/usr/bin/env python3
# 2020-03-28
# Injabie3
#
# Description:
# Autocapture script for DSLR cameras. Used for SFU Anime stuff.
# 

from dslrCapture import *

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
