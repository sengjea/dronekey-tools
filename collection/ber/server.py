#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : server.py
# Creation Date : 23-07-2014
# Last Modified : Wed 23 Jul 2014 03:05:42 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import ber

def main():
  server = ber.UDPReceiver(('localhost', 15000))
  server.start()

if __name__=="__main__":
  main()

