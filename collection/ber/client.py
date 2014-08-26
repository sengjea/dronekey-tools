#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : client.py
# Creation Date : 23-07-2014
# Last Modified : Tue 29 Jul 2014 12:50:09 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import ber

def main():
  client = ber.UDPSender(('192.168.0.42', 15000))
  client.run()


if __name__=="__main__":
    main()

