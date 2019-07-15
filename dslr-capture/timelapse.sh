#!/bin/bash
# 2019-07-13
# Injabie3
#
# Description:
# Convert still images to timelapse using ffmpeg.
# 


ffmpeg -pattern_type glob -i "webcam-cam1/*.jpg" -vf scale=1920:1080 -vcodec libx264 dslr.mp4
ffmpeg -pattern_type glob -i "webcam-cam2/*.jpg" -vf scale=1920:1080 -vcodec libx264 webcam.mp4
