#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : server.py
# Creation Date : 23-07-2014
# Last Modified : Thu 24 Jul 2014 10:51:05 AM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import ber

def main():
  server = ber.UDPScapyReceiver(('localhost', 15000))
  server.run()

if __name__=="__main__":
  main()

