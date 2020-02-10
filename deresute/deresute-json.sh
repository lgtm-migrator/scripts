#!/usr/bin/env bash
# 2019-06-17
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me Image Archiver
# Archive info from game.
# 
currentDate=`date +"%F_%H-%M-%S"`
scriptPath="$HOME/scripts/deresute"

# Grab user key/value pairs: key ID, private ID value
source $scriptPath/deresute-config.sh

# Full download of images and JSON
[ ! -d $DATA_PATH ] && mkdir $DATA_PATH
for dl in ${!DERESUTE_PROFILE[@]}
do
    [ ! -d $DATA_PATH/$dl ] && mkdir $DATA_PATH/$dl
    [ ! -d $DATA_PATH/$dl/json ] && mkdir $DATA_PATH/$dl/json
    wget -O "$DATA_PATH/$dl/json/$dl-$currentDate.json" https://deresute.me/$dl/json
done
