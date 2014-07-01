#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : iperf.py
# Creation Date : 01-07-2014
# Last Modified : Tue 01 Jul 2014 07:27:20 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import threading
import subprocess

class iperf_server(threading.Thread):
  def __init__(self, bw = "10k"):
    """setup the command and spawn the iperf_server command"""
    self.command = "/usr/bin/iperf -s -u -y c"
    self.plr = 0
    self.prr = 1
    self.lost = 0
    self.received = 0
    self.subP = None
    threading.Thread.__init__(self)

  def run(self):
    self.subP = subprocess.Popen(self.command.split(), stdout=subprocess.PIPE)
    self.stdout = self.subP.stdout
    while True:
      retcode = self.subP.poll()
      l = self.stdout.readline()
      data = l.split(",")
      self.lost = int(data[10])
      self.received = int(data[11]) - self.lost
      self.prr = float(self.received) / float(data[11])
      self.plr = float(self.lost) / float(data[11])
      if retcode is not None:
        break

  def get_packets_received(self):
    return self.received

  def get_packets_lost(self):
    return self.lost

  def get_packet_loss_rate(self):
    return self.plr

  def get_packet_reception_rate(self):
    return self.prr
