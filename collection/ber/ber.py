#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : ber.py
# Creation Date : 21-07-2014
# Last Modified : Wed 23 Jul 2014 02:50:36 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

from socket import socket, AF_INET, SOCK_DGRAM
import threading
from time import sleep
import struct

mantra = [ '\x92', '\xc1', '\x53', '\xd2', '\x88', '\x57', '\x6e', '\xaf', '\x79', '\x4f', '\xc4', '\xf2', '\xcb', '\xe6', '\x84', '\x22',
    '\xcc', '\x33', '\xe3', '\xf2', '\x41', '\x24', '\x48', '\xe2', '\xaa', '\xd2', '\x0b', '\x6c', '\xbe', '\x58', '\x5f', '\x5f',
    '\xec', '\xa2', '\xb3', '\x41', '\xc5', '\x4d', '\xaa', '\x94', '\x7a', '\xeb', '\x88', '\x4e', '\xea', '\xd2', '\x91', '\xe4',
    '\x5d', '\xe9', '\xbf', '\xea', '\xc7', '\x78', '\x54', '\x6f', '\xfb', '\x8f', '\x9c', '\x89', '\xa1', '\x1a', '\xbc', '\x6d',
    '\xd4', '\x25', '\x3d', '\x51', '\xe1', '\x13', '\xb8', '\xfa', '\x86', '\x30', '\x71', '\x47', '\x81', '\x83', '\x4b', '\x14',
    '\xbd', '\xb4', '\x37', '\x74', '\x5a', '\x56', '\x55', '\x7d', '\x52', '\x36', '\x2b', '\x94', '\x7c', '\x5d', '\x2d', '\x06',
    '\x5e', '\x0f', '\x90', '\xa2', '\x12', '\xc9', '\x9f', '\xc4', '\x9e', '\x4c', '\x05', '\xe8', '\x67', '\x62', '\x6e', '\x22',
    '\x01', '\x4a', '\x4f', '\xe2', '\x2b', '\x89', '\x84', '\x5d', '\x68', '\x33', '\x9f', '\xb9', '\x18', '\x12', '\xcc', '\xeb' ]

mantra_large = mantra * 12

address = ('192.168.0.41', 15000)

class UDPSender(threading.Thread):
  def __init__(self, target = address):
    self.packet = ''.join(mantra_large)
    self.address = tuple(target)
    self.sock = socket(AF_INET, SOCK_DGRAM)
    threading.Thread.__init__(self)

  def run(self):
    while True:
      sent = self.sock.sendto(self.packet, self.address)
      print "Yo, I sent the bloody thing", sent
      sleep(0.25)

class UDPReceiver(threading.Thread):
  def __init__(self, target = address):
    self.packet = ''.join(mantra_large)
    self.address = tuple(target)
    self.sock = socket(AF_INET, SOCK_DGRAM)
    self.sock.bind(self.address)
    threading.Thread.__init__(self)

  def run(self):
    while True:
      data, address = self.sock.recvfrom(4096)
      print 'received %s bytes from %s' % (len(data), address)
      for i,j in zip(data, self.packet):
        if i != j:
          print 'bang'


def main():
  pass

if __name__=="__main__":
    main()

