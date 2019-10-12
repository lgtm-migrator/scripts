#!/usr/bin/env python3
# 2019-10-11
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me JSON to CSV parser
# 
import argparse
import csv
import json
import os

from constants import *
import deresute

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

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Graph deresute.me data")
    parser.add_argument("inputPath", type=str, help="Path to the folder containing *.json "
                        "files obtained from deresute.me.")
    parser.add_argument("outputPath", type=str, help="Path to the folder where the various "
                        "graphs should be outputted.")
    args = parser.parse_args()
    if not os.path.isdir(args.inputPath):
        print("This is not a valid input data path!")
        exit()
    elif not os.path.isdir(args.outputPath):
        print("This is not a valid output data path!")
        exit()
                                     
    data = deresute.DeresuteData(args.inputPath)
    data.readData()
    outputPath = os.path.abspath(args.outputPath)
    data.saveGraph("level", "Level", "{}/graph_levels.png".format(outputPath))
    data.saveGraph("prp", "PRP", "{}/graph_prp.png".format(outputPath))
    data.saveGraph("fan", "Fans", "{}/graph_fans.png".format(outputPath))
