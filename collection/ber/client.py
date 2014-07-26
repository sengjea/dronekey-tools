#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : client.py
# Creation Date : 23-07-2014
# Last Modified : Fri 25 Jul 2014 08:30:12 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import ber

def main():
  client = ber.UDPSender(('192.168.0.41', 15000))
  client.run()


if __name__=="__main__":
    main()

