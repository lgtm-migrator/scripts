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
[ ! -d $PATH ] && mkdir $PATH
for dl in ${!DERESUTE_PROFILE[@]}
do
    [ ! -d $PATH/$dl ] && mkdir $PATH/$dl
    [ ! -d $PATH/$dl/json ] && mkdir $PATH/$dl/json
    wget -O "$PATH/$dl/json/$dl-$currentDate.json" https://deresute.me/$dl/json
done
