#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : ber.py
# Creation Date : 21-07-2014
# Last Modified : Sat 26 Jul 2014 02:08:58 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

from socket import AF_INET, SOCK_DGRAM
from socket import socket as ssocket
from time import sleep
from time import time as ttime
from scapy.all import *
from scapy_ex import scapy_ex
from random import randint

mantra = [ '\x92', '\xc1', '\x53', '\xd2', '\x88', '\x57', '\x6e', '\xaf', '\x79', '\x4f', '\xc4', '\xf2', '\xcb', '\xe6', '\x84', '\x22',
    '\xcc', '\x33', '\xe3', '\xf2', '\x41', '\x24', '\x48', '\xe2', '\xaa', '\xd2', '\x0b', '\x6c', '\xbe', '\x58', '\x5f', '\x5f',
    '\xec', '\xa2', '\xb3', '\x41', '\xc5', '\x4d', '\xaa', '\x94', '\x7a', '\xeb', '\x88', '\x4e', '\xea', '\xd2', '\x91', '\xe4',
    '\x5d', '\xe9', '\xbf', '\xea', '\xc7', '\x78', '\x54', '\x6f', '\xfb', '\x8f', '\x9c', '\x89', '\xa1', '\x1a', '\xbc', '\x6d',
    '\xd4', '\x25', '\x3d', '\x51', '\xe1', '\x13', '\xb8', '\xfa', '\x86', '\x30', '\x71', '\x47', '\x81', '\x83', '\x4b', '\x14',
    '\xbd', '\xb4', '\x37', '\x74', '\x5a', '\x56', '\x55', '\x7d', '\x52', '\x36', '\x2b', '\x94', '\x7c', '\x5d', '\x2d', '\x06',
    '\x5e', '\x0f', '\x90', '\xa2', '\x12', '\xc9', '\x9f', '\xc4', '\x9e', '\x4c', '\x05', '\xe8', '\x67', '\x62', '\x6e', '\x22',
    '\x01', '\x4a', '\x4f', '\xe2', '\x2b', '\x89', '\x84', '\x5d', '\x68', '\x33', '\x9f', '\xb9', '\x18', '\x12', '\xcc', '\xeb' ]

mantra_large = mantra * 11

MIN_PACKET_SIZE = 8

address = ('192.168.0.41', 15000)

class UDPSender(object):
  def __init__(self, target = address):
    self.packet = ''.join(mantra_large)
    self.address = tuple(target)
    self.sock = ssocket(AF_INET, SOCK_DGRAM)

  def run(self):
    cnt = 0
    while True:
      # Pick a random size from 8 to 1408 bytes (just below the MTU size)
      _to_send = self.packet[:randint(MIN_PACKET_SIZE, len(mantra_large))]
      cnt += 1
      self.sock.sendto(_to_send, self.address)
      print 'I sent {0} packets'.format(cnt)
      sleep(0.25)

class UDPReceiver(object):
  def __init__(self, target = address):
    self.packet = ''.join(mantra_large)
    self.address = tuple(target)
    self.sock = ssocket(AF_INET, SOCK_DGRAM)
    self.sock.bind(self.address)

  def popcorn(self, data):
    print self.packet
    print data
    cnt = 0
    for i,j in zip(data, self.packet):
      if i != j:
        cnt += sum(map(int, bin(ord(i) ^ ord(j))[2:]))
    return cnt

  def capture(self):
      data, address = self.sock.recvfrom(4096)
      return data

  def run(self):
    while True:
      data = self.capture()
      print 'received with {0} out of {1}'.format(self.popcorn(data), 8*len(data))

class UDPScapyReceiver(UDPReceiver):
  def __init__(self, target = address, iface = 'mon0'):
    self.packet = ''.join(mantra_large)
    self.received = 0
    self.error = 0
    self.address = tuple(target)
    self.iface = iface
    #self.filter = '(not tcp) and (ip dst {0}) and (udp port {1})'.format(*target)
    self.filter = 'not tcp'
    print 'tuxtime, rssi, ber, prr'

  def handle(self, pkt):
    # Data udp packets only
    if pkt.haslayer(RadioTap) and pkt.haslayer(Dot11) and pkt.type == 2 and pkt.haslayer(UDP):
      ip = pkt.getlayer(IP)
      udp=pkt.getlayer(UDP)
      # With the proper IP address and UDP port
      if ip.dst == self.address[0] and udp.dport == self.address[1]:
	# Radiotap/802.11/802.11 QoS/LLC/SNAP/IP/UDP
        data = repr(pkt.payload.payload.payload.payload.payload.payload.payload)
        flips = self.popcorn(data)
	self.received += 1
        if flips > 0:
          self.error += 1

	_tuxtime = ttime()
	_rssi =  pkt[RadioTap].dBm_AntSignal
	_ber = float(flips) / 8*len(data)
	_prr = float(self.received) / (self.error + self.received)

	print '{0}, {1}, {2}, {3}'.format(_tuxtime, _rssi, _ber, _prr)

  def capture(self):
    pass

  def run(self):
    sniff(prn=self.handle, iface=self.iface, filter=str(self.filter))




def main():
  pass

if __name__=="__main__":
    main()

