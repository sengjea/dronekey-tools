#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : passive.py
# Creation Date : 26-06-2014
# Last Modified : Tue 01 Jul 2014 04:12:58 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

from time import time, sleep

INTERFACE="wlan0"
INFO_FILE="/proc/net/dev"
WIRELESS_FILE="/proc/net/wireless"

def pkts_received(lines):
  for line in lines:
    words = map(lambda x: x.strip(), line.split())
    iface = words[0]
    if iface.startswith(INTERFACE):
      pkts = words[2]
      return int(pkts)

def timestamp():
  return time()

#def errs_received(lines):
#  for line in lines:
#    words = map(lambda x: x.strip(), line.split())
#    iface = words[0]
#    if iface.startswith(INTERFACE):
#      pkts = words[3]
#      return pkts

def rssi(lines):
  for line in lines:
    words = map(lambda x: x.strip(), line.split())
    iface = words[0]
    if iface.startswith(INTERFACE):
      rssi = words[3]
      return float(rssi)


def get_file_data():
  inpt_dev = open(INFO_FILE)
  inpt_wifi = open(WIRELESS_FILE)
  ts = timestamp()
  inpt_dev_lines = inpt_dev.readlines()
  inpt_wifi_lines = inpt_wifi.readlines()
  inpt_dev.close()
  inpt_wifi.close()
  return (ts, inpt_dev_lines, inpt_wifi_lines)



def main():
  (ts_previous, inpt_dev_lines, inpt_wifi_lines) = get_file_data()
  previous = pkts_received(inpt_dev_lines)
  print "{0},\t{1},\t{2}".format("Timestamp", "RSSI", "Received")
  while True:
    (ts, inpt_dev_lines, inpt_wifi_lines) = get_file_data()
    received = pkts_received(inpt_dev_lines) - previous
    rssi_value = rssi(inpt_wifi_lines)
    print "{0},\t{1},\t{2}".format(ts, rssi_value, received)
    sleep(1)


if __name__=="__main__":
   main()

