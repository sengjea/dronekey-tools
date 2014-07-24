#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : client.py
# Creation Date : 23-07-2014
# Last Modified : Thu 24 Jul 2014 10:14:49 AM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import ber

def main():
  client = ber.UDPSender(('localhost', 15000))
  client.run()


if __name__=="__main__":
    main()

