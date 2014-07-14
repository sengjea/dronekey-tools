#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : env_collector.py
# Creation Date : 07-07-2014
# Last Modified : Mon 14 Jul 2014 03:15:26 PM BST
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

# Import custom messages and topics from the quadrotor HAL
from hal_sensor_compass.msg import *

# We check our logfiles
import os.path

class env_collector(object):
  def __init__(self, NODE_ID = 'UAV0'):
    self.NODE_ID = NODE_ID
    LOGFILE_BASE_NAME = "{0}_estimate.log".format(NODE_ID)
    self.LOGFILE_ESTIMATE_NAME = env_collector.get_logfile_name(LOGFILE_BASE_NAME)
    LOGFILE_BASE_NAME = "{0}_compass.log".format(NODE_ID)
    self.LOGFILE_COMPASS_NAME = env_collector.get_logfile_name(LOGFILE_BASE_NAME)


    # create estimate logger
    self.estimate_logger = self.get_formatted_logger('estimate_logger', self.LOGFILE_ESTIMATE_NAME)
    self.estimate_logger.debug("DateTime, Time stamp, X position (X == +East), Y position (Y == +North), Z position (Z == +Up), roll (anti-clockwise about X), pitch (anti-clockwise about Y), yaw (anti-clockwise about Z), X velocity, Y velocity, Z velocity, roll angular velocity, pitch angular velocity, yaw angular velocity, has goal been reached, current controllertype")


    # create compass logger
    self.compass_logger = self.get_formatted_logger('compass_logger', self.LOGFILE_COMPASS_NAME)
    self.compass_logger.debug("DateTime, Time stamp, X, Y, Z")

    rospy.init_node('env_collector', anonymous = True)
    # Create a subscriber with appropriate topic, custom message and name of callback function.
    rospy.Subscriber('/hal/' + NODE_ID + '/Estimate', State, self.estimate_callback)

    # Create a subscriber with appropriate topic, custom message and name of callback function.
    rospy.Subscriber('/hal/' + NODE_ID + '/sensor/compass/Data', Data, self.compass_callback)

    # Wait for messages on topic, go to callback function when new messages arrive.
    rospy.spin()

  def get_formatted_logger(self, logger_name, logfile_name):
    formatted_logger = logging.getLogger(logger_name)
    formatted_logger.setLevel(logging.DEBUG)

    # create console handler and set level to debug
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(created)f, %(message)s")
    ch.setFormatter(formatter)

    # add ch to logger
    formatted_logger.addHandler(ch)

    handler = logging.FileHandler(logfile_name, "w")
    handler.setLevel(logging.DEBUG)
    handler.setFormatter(formatter)
    formatted_logger.addHandler(handler)
    return formatted_logger


  @staticmethod
  def get_logfile_name(LOGFILE_NAME):
    cnt = 1
    QUALIFIED_LOGFILE_NAME = "{0:03}-{1}".format(cnt, LOGFILE_NAME)
    while os.path.isfile(QUALIFIED_LOGFILE_NAME):
      cnt += 1
      QUALIFIED_LOGFILE_NAME = "{0:03}-{1}".format(cnt, LOGFILE_NAME)
    return QUALIFIED_LOGFILE_NAME

  @staticmethod
  def env_collector_factory(NODE_ID = "UAV0"):
    return env_collector(NODE_ID)

  def compass_callback(self, data):
    # Simply print out values in our custom message.
    self.compass_logger.debug("%f, %f, %f, %f",
                        data.t,
                        data.x,
                        data.y,
                        data.z)

  # Create a callback function for the subscriber.
  def estimate_callback(self, data):
    # Simply print out values in our custom message.
    self.estimate_logger.debug("%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f",
                        data.t,
                        data.x,
                        data.y,
                        data.z,
                        data.roll,
                        data.pitch,
                        data.yaw,
                        data.u,
                        data.v,
                        data.w,
                        data.p,
                        data.q,
                        data.r,
                        data.rch,
                        data.ctrl)
