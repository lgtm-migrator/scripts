#!/usr/bin/env python3
# 2019-08-08
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me JSON to CSV parser
# 

from datetime import datetime
import glob
import json
import csv
import os
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

CSV_FILE = "data.csv"

KEY_FAN = "fan"
KEY_LEVEL = "level"
KEY_PRP = "prp"
KEY_TIMESTAMP = "timestamp"

ROW_GRAPHS = [KEY_FAN, KEY_LEVEL, KEY_PRP]

ROW_HEADER = \
["timestamp", "name", "id", "comment", "level", "fan", "prp", "rank"]
ROW_HEADER_CLEARED = \
["clr_debut", "clr_light", "clr_pro", "clr_master", "clr_master_plus"]
ROW_HEADER_FC = \
["fc_debut", "fc_light", "fc_pro", "fc_master", "fc_master_plus"]

filelist = glob.glob("*.json")
filelist.sort()

def default():
    """Default parsing.

    Reads in a bunch of .json files, and outputs a csv file.
    """
    with open(CSV_FILE, "w", newline="") as csvFile:
        csvWriter = csv.writer(csvFile, delimiter=",")
        csvWriter.writerow(ROW_HEADER + ROW_HEADER_CLEARED + ROW_HEADER_FC)
        for filename in filelist:
            print(filename)
            if not os.path.getsize(filename):
                continue
    
            with open(filename, "r") as fileHandle:
                content = json.load(fileHandle)
                row = []
                if "error" in content.keys():
                    continue
                for item in ROW_HEADER:
                    row.append(content[item])
                for item in ROW_HEADER_CLEARED:
                    row.append(content["cleared"][item[4:]])
                for item in ROW_HEADER_FC:
                    row.append(content["full_combo"][item[3:]])
    
                csvWriter.writerow(row)

class DeresuteData():
    """A class containing the info from JSON files obtained from deresute.me"""

    def __init__(self):
        self.filelist = glob.glob("*.json")
        self.filelist.sort()
        self.data = {}
        self.data[KEY_TIMESTAMP] = []

        for key in ROW_GRAPHS:
            self.data[key] = []

    def readData(self):
        """Read json data into memory."""

        for filename in filelist:
            print(filename)
            if not os.path.getsize(filename):
                continue

    
            with open(filename, "r") as fileHandle:
                content = json.load(fileHandle)
                row = []
                if "error" in content.keys():
                    continue
                for item in ROW_HEADER:
                    row.append(content[item])
            
            timestamp = datetime.fromtimestamp(content[KEY_TIMESTAMP])
            self.data[KEY_TIMESTAMP].append(timestamp)
            for key in ROW_GRAPHS:
                self.data[key].append(content[key])
            
    def saveGraph(self, key: str, ylabel: str, outFile: str):
        """Save graph, REQUIRES TIMESTAMP
        
        Parameters:
        -----------
        tbd
        """
        plt.figure(figsize=(20, 10))
        plt.grid(b=True, which="both")
        plt.plot_date(self.data[KEY_TIMESTAMP], self.data[key])
        plt.xlabel("Date")
        plt.ylabel(ylabel)
        plt.gcf().autofmt_xdate()
        plt.savefig(outFile, dpi=300, figsize=(100, 10))


def parse():
    """Parse data."""
    pass

if __name__ == "__main__":
    default()
    data = DeresuteData()
    data.readData()
    data.saveGraph("level", "Level", "graph_levels.png")
    data.saveGraph("prp", "PRP", "graph_prp.png")
    data.saveGraph("fan", "Fans", "graph_fans.png")
