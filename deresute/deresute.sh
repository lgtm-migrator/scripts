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
for id in ${!DERESUTE_PROFILE[@]}
do
    [ ! -d $PATH/$id ] && mkdir $PATH/$id
    wget -O "$PATH/$id/$id-$currentDate.png" https://deresute.me/$id/huge
done

# These downloads will have IDs hidden, and images published on the www
for privateId in ${DERESUTE_PROFILE[@]}
do
    [ ! -d $PATH/$privateId ] && mkdir $PATH/$privateId
    wget -O "$PATH/$privateId/$privateId-$currentDate.png" https://deresute.me/$privateId/huge
    [ ! -d $PUB_PATH ] && mkdir $PUB_PATH
    [ ! -d $PUB_PATH/$privateId ] && mkdir $PUB_PATH/$privateId
    cp "$PATH/$privateId/$privateId-$currentDate.png" $PUB_PATH/$privateId/
done

