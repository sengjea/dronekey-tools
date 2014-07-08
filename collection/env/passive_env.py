#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : passive_env.py
# Creation Date : 07-07-2014
# Last Modified : Tue 08 Jul 2014 09:56:38 AM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/


# DRONES = [ "Bananas",
#             "Peanut",
#             "Parfait",
#             "Coco",
#             "Debbie" ]

DRONES = [ "UAV0" ]

from env_collector import env_collector

def main():
  # Initialize the node and name it.
  collectors = [env_collector.env_collector_factory(drone) for drone in DRONES]



if __name__=="__main__":
  main()

