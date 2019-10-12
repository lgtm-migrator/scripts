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

from constants import *

class DeresuteData():
    """A class containing the info from JSON files obtained from deresute.me"""

    def __init__(self, path: str):
        """Constructor.

        Parameters:
        -----------
        path: str
            The path to the folder containing the deresute.me JSON files.
        """
        if not os.path.isdir(path):
            raise OSError("This is not a valid folder!")
        self.path = path
        self.filelist = glob.glob("*.json")
        self.filelist.sort()
        self.data = {}
        self.data[KEY_TIMESTAMP] = []

        for key in ROW_GRAPHS:
            self.data[key] = []

    def readData(self):
        """Read json data into memory."""

        for filename in self.filelist:
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
