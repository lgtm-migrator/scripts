#!/usr/bin/env python3
# 2019-08-08
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me JSON to CSV parser
# 

import csv
from datetime import datetime
import glob
import json
import logging
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
        self.path = os.path.abspath(path) # No trailing slash
        self.filelist = glob.glob("{}/*.json".format(path))
        self.filelist.sort()

        self.logger = logging.getLogger("DeresuteData")
        if self.logger.level == logging.NOTSET:
            self.logger.setLevel(logging.INFO)
            console = logging.StreamHandler()
            console.setFormatter(logging.Formatter("%(asctime)s %(message)s",
                                                   datefmt="[%d/%m/%Y %H:%M:%S]"))
            self.logger.addHandler(console)
        self.data = {}
        self.data[KEY_TIMESTAMP] = []

        for key in ROW_GRAPHS:
            self.data[key] = []
        self.logger.info("Class object initialized for path: %s", self.path)

    def readData(self):
        """Read json data into memory."""
        self.logger.info("Reading data from %s", self.path)

        for filename in self.filelist:
            self.logger.debug("Parsing file %s", filename)
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
        """Save a simple graph, REQUIRES TIMESTAMP
        
        Parameters:
        -----------
        key: str
            The key you want to graph (e.g. prp, levels, etc.).
        ylabel: str
            The y-axis label you wish to have.
        outFile: str
            The file path in which you want to save this graph.
        """
        self.logger.info("Saving graph of key %s to %s", key, outFile)
        plt.figure(figsize=(20, 10))
        plt.grid(b=True, which="both")
        plt.plot_date(self.data[KEY_TIMESTAMP], self.data[key])
        plt.xlabel("Date")
        plt.ylabel(ylabel)
        plt.gcf().autofmt_xdate()
        plt.savefig(outFile, dpi=300, figsize=(100, 10))
