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

injabie3Profile="<ID here>"
injabie3ProfilePrivate="<private ID from deresute.me"
friendProfile="<ID here>"
friendProfilePrivate="<private ID from deresute.me"

privateDownload=($injabie3ProfilePrivate $friendProfilePrivate) # Obscured IDs
fullDownload=($injabie3Profile $friendProfile) # Full IDs

path="$HOME/scripts/deresute"
pubPath="/var/www/prod/deresute"

# Full download of images and JSON
[ ! -d $path ] && mkdir $path 
for dl in ${fullDownload[*]}
do
    [ ! -d $path/$dl ] && mkdir $path/$dl
    [ ! -d $path/$dl/json ] && mkdir $path/$dl/json
    wget -O "$path/$dl/$dl-$currentDate.png" https://deresute.me/$dl/huge
    wget -O "$path/$dl/json/$dl-$currentDate.json" https://deresute.me/$dl/json
done

# These downloads will have IDs hidden, and images published on the www
for dl in ${privateDownload[*]}
do
    [ ! -d $path/$dl ] && mkdir $path/$dl
    wget -O "$path/$dl/$dl-$currentDate.png" https://deresute.me/$dl/huge
    [ ! -d $pubPath ] && mkdir $pubPath
    [ ! -d $pubPath/$dl ] && mkdir $pubPath/$dl
    cp "$path/$dl/$dl-$currentDate.png" $pubPath/$dl/
done

