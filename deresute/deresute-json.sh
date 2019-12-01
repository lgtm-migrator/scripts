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

# Grab user key/value pairs: key ID, private ID value
source deresute-users.sh

path="$HOME/scripts/deresute"
pubPath="/var/www/prod/deresute"

# Full download of images and JSON
[ ! -d $path ] && mkdir $path 
for dl in ${!DERESUTE_PROFILE[@]}
do
    [ ! -d $path/$dl ] && mkdir $path/$dl
    [ ! -d $path/$dl/json ] && mkdir $path/$dl/json
    wget -O "$path/$dl/json/$dl-$currentDate.json" https://deresute.me/$dl/json
done
