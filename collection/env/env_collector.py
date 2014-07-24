#!/usr/bin/env python
# -*- coding: utf-8
#
#* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
# File Name : env_collector.py
# Creation Date : 07-07-2014
# Last Modified : Tue 08 Jul 2014 04:15:22 PM BST
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
    formatter = logging.Formatter("%(created)f, %(message)s")
    ch.setFormatter(formatter)

    # add ch to logger
    self.logger.addHandler(ch)


    handler = logging.FileHandler(self.LOGFILE_NAME, "w")
    handler.setLevel(logging.DEBUG)
    handler.setFormatter(formatter)
    self.logger.addHandler(handler)

    """
    tuxtime - Time on the Fit2PC running this python
    embtime - time on the embedded system giving this data
    x - x position, +x is east
    y - y position, +y is north
    z - z position, +z is up
    roll - deg/rads about the x axis
    pitch - deg/rads about the y axis
    yaw - deg/rads about the z axis
    v_x - velocity along the x axis
    v_y - velocity along the y axis
    v_z - velocity along the z axis
    v_roll - deg/rads about the x axis
    v_pitch - deg/rads about the y axis
    v_yaw - deg/rads about the z axis
    reached - has the goal been reached
    ctype - current controller type 
    """
    
    self.logger.debug("tuxtime,embtime,x,y,z,roll,pitch,yaw,v_x,v_y,v_z,v_roll,v_pitch,v_yaw,reached,ctype")
    rospy.init_node('env_collector', anonymous = True)
    ## # Wait for the Pause service to appear, then Pause the simulator
    ## rospy.wait_for_service('/simulator/Pause');
    ## try:
    ##   service  = rospy.ServiceProxy('/simulator/Pause', Pause)
    ##   service()
    ## except rospy.ServiceException, e:
    ##   print "Service call failed: %s"

    ## # Wait for the Pause service to appear, then Pause the simulator
    ## rospy.wait_for_service('/simulator/Resume');
    ## try:
    ##   service  = rospy.ServiceProxy('/simulator/Resume', Resume)
    ##   service()
    ## except rospy.ServiceException, e:
    ##   print "Service call failed: %s"

    ## # Wait for the Pause service to appear, then Pause the simulator
    ## rospy.wait_for_service('/simulator/Insert');
    ## try:
    ##   service  = rospy.ServiceProxy('/simulator/Insert', Insert)
    ## except rospy.ServiceException, e:
    ##   print "Service call failed: %s"

    # Create a subscriber with appropriate topic, custom message and name of callback function.
    rospy.Subscriber('/hal/' + NODE_ID + '/Estimate', State, self.callback)

    # Wait for messages on topic, go to callback function when new messages arrive.
    rospy.spin()

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


  # Create a callback function for the subscriber.
  def callback(self, data):
    # Simply print out values in our custom message.
    self.logger.debug("%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f",
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

