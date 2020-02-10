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

path="$HOME/scripts/deresute/data"
scriptPath="$HOME/scripts/deresute"
pubPath="/var/www/prod/deresute"

# Grab user key/value pairs: key ID, private ID value
source $scriptPath/deresute-config.sh

# Full download of images and JSON
[ ! -d $path ] && mkdir $path 
for id in ${!DERESUTE_PROFILE[@]}
do
    [ ! -d $path/$id ] && mkdir $path/$id
    wget -O "$path/$id/$id-$currentDate.png" https://deresute.me/$id/huge
done

# These downloads will have IDs hidden, and images published on the www
for privateId in ${DERESUTE_PROFILE[@]}
do
    [ ! -d $path/$privateId ] && mkdir $path/$privateId
    wget -O "$path/$privateId/$privateId-$currentDate.png" https://deresute.me/$privateId/huge
    [ ! -d $pubPath ] && mkdir $pubPath
    [ ! -d $pubPath/$privateId ] && mkdir $pubPath/$privateId
    cp "$path/$privateId/$privateId-$currentDate.png" $pubPath/$privateId/
done

