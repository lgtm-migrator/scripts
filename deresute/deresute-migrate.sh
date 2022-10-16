#!/usr/bin/env bash
# 2022-07-23
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me Image Archiver
# Archive info from game.
# 
# This script just moves from local storage to network shares
set -e

scriptPath="$HOME/scripts/deresute"

# Grab user key/value pairs: key ID, private ID value
source $scriptPath/deresute-config.sh

rsync -v -a --remove-source-files ${LOCAL_DATA_PATH}/ ${DATA_PATH}/
