#!/usr/bin/env python3.5
import subprocess
import time
from RPLCD.gpio import CharLCD
import RPi.GPIO as GPIO

WLAN0_CMD = """ifconfig wlan0 | grep "inet " | awk '{print $2}'"""
ETH0_CMD = """ifconfig eth0 | grep "inet " | awk '{print $2}'"""
LCD = CharLCD(pin_rs=14,
              pin_rw=16,
              pin_e=15,
              pins_data=[25, 8, 7, 1],
              numbering_mode=GPIO.BCM,
              charmap="A00",
              cols=16,
              rows=2,
              auto_linebreaks=True)

LCD.clear()
LCD.write_string("   Welcome to   \r\n    Raspbian    ")
time.sleep(5)


while True:
    wlan0IP = subprocess.check_output(WLAN0_CMD, shell=True).decode()
    hostname = subprocess.check_output("hostname", shell=True).decode()
    eth0IP = subprocess.check_output(ETH0_CMD, shell=True).decode()
    LCD.clear()
    LCD.write_string("Hostname:\r\n{}".format(hostname))
    time.sleep(3)
    LCD.clear()
    LCD.write_string("eth0 IPv4:\r\n{}".format(eth0IP if eth0IP else "Disconnected"))
    time.sleep(3)
    LCD.clear()
    LCD.write_string("wlan0 IPv4:\r\n{}".format(wlan0IP if wlan0IP else "Disconnected"))
    time.sleep(3)
