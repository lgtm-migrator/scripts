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

cd $HOME/scripts/deresute/
# source ../bin/activate

# Graph, go!
[ ! -d $path ] && mkdir $path 
for key in ${!DERESUTE_PROFILE[@]}
do
    ./graph.py "${key}/json" "$pubPath/${DERESUTE_PROFILE[${key}]}" &
done

wait
