#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : env_collector.py
# Creation Date : 07-07-2014
# Last Modified : Mon 07 Jul 2014 03:33:43 PM BST
# Created By : Greg Lyras <greglyras@gmail.com>
#_._._._._._._._._._._._._._._._._._._._._.*/

import logging

# Import required ROS libraries
import roslib

# Import these CRATES packages
roslib.load_manifest('hal_quadrotor')
roslib.load_manifest('sim')

# Use the ROS python interface
import rospy

# Import custom messages and topics from the simulator
from sim.srv import *

# Import custom messages and topics from the quadrotor HAL
from hal_quadrotor.msg import *

# We check our logfiles
import os.path

class env_collector(object):
  def __init__(self, NODE_ID = 'UAV0'):
    self.NODE_ID = NODE_ID
    LOGFILE_BASE_NAME = "{0}.log".format(NODE_ID)
    self.LOGFILE_NAME = env_collector.get_logfile_name(LOGFILE_BASE_NAME)

    # create logger
    self.logger = logging.getLogger('simple_example')
    self.logger.setLevel(logging.DEBUG)

    # create console handler and set level to debug
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(created)f: %(message)s")
    ch.setFormatter(formatter)

    # add ch to logger
    self.logger.addHandler(ch)


    rospy.init_node('env_collector', anonymous = True)
    # Wait for the Pause service to appear, then Pause the simulator
    rospy.wait_for_service('/simulator/Pause');
    try:
      service  = rospy.ServiceProxy('/simulator/Pause', Pause)
      service()
    except rospy.ServiceException, e:
      print "Service call failed: %s"

    # Wait for the Pause service to appear, then Pause the simulator
    rospy.wait_for_service('/simulator/Resume');
    try:
      service  = rospy.ServiceProxy('/simulator/Resume', Resume)
      service()
    except rospy.ServiceException, e:
      print "Service call failed: %s"

    # Wait for the Pause service to appear, then Pause the simulator
    rospy.wait_for_service('/simulator/Insert');
    try:
      service  = rospy.ServiceProxy('/simulator/Insert', Insert)
    except rospy.ServiceException, e:
      print "Service call failed: %s"

    # Create a subscriber with appropriate topic, custom message and name of callback function.
    rospy.Subscriber('/hal/' + NODE_ID + '/Estimate', State, self.callback)

    # Wait for messages on topic, go to callback function when new messages arrive.
    rospy.spin()

  def get_logfile_name(LOGFILE_NAME):
    cnt = 1
    QUALIFIED_LOGFILE_NAME = "{0:03}-{1}".format(LOGFILE_NAME)
    while os.path.isfile(QUALIFIED_LOGFILE_NAME):
      cnt += 1
      QUALIFIED_LOGFILE_NAME = "{0:03}-{1}".format(LOGFILE_NAME)
    return QUALIFIED_LOGFILE_NAME


  # Create a callback function for the subscriber.
  def callback(self, data):
    # Simply print out values in our custom message.
    self.logger.info("Quadrotor position: [%f,%f,%f]", data.x, data.y, data.z)
