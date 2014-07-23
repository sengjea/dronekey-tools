#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : client.py
# Creation Date : 23-07-2014
# Last Modified : Wed 23 Jul 2014 03:05:35 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import ber

def main():
  client = ber.UDPSender(('localhost', 15000))
  client.start()


if __name__=="__main__":
    main()

