#!/usr/bin/env python3
# 2019-10-11
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# Constants file

CSV_FILE = "data.csv"

KEY_FAN = "fan"
KEY_FC = "full_combo"

KEY_FC_PRO= "pro"
KEY_FC_MASTER = "master"
KEY_FC_MASTER_PLUS = "master_plus"

KEY_LEVEL = "level"
KEY_PRP = "prp"
KEY_TIMESTAMP = "timestamp"

ROW_GRAPHS = [KEY_FAN, KEY_LEVEL, KEY_PRP, KEY_FC_PRO, KEY_FC_MASTER,
              KEY_FC_MASTER_PLUS]

ROW_HEADER = \
["timestamp", "name", "id", "comment", "level", "fan", "prp", "rank"]
ROW_HEADER_CLEARED = \
["clr_debut", "clr_light", "clr_pro", "clr_master", "clr_master_plus"]
ROW_HEADER_FC = \
["debut", "light", KEY_FC_PRO, KEY_FC_MASTER, KEY_FC_MASTER_PLUS]
