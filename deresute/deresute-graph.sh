#!/usr/bin/env bash
# 2019-06-17
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me Image Archiver
# Archive info from game.
# 
scriptPath="$HOME/scripts/deresute"

# Grab user key/value pairs: key ID, private ID value
source $scriptPath/deresute-config.sh

cd $scriptPath

# Graph, go!
[ ! -d $DATA_PATH ] && mkdir $DATA_PATH
for key in ${!DERESUTE_PROFILE[@]}
do
    ./graph.py "$DATA_PATH/${key}/json" "$PUB_PATH/${DERESUTE_PROFILE[${key}]}" &
done

wait
