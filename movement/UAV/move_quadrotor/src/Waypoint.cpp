/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
* File Name : Waypoint.cpp
* Creation Date : 09-07-2014
* Last Modified : Wed 09 Jul 2014 01:53:22 PM BST
* Created By : Greg Lyras <greglyras@gmail.com>
_._._._._._._._._._._._._._._._._._._._._.*/


using namespace dronkey;

friend istream &operator>>(istream &is, Waypoint &w)
{
  /* XXX:read formatted input */
  w.request.x = 0.0;
  w.request.y = 0.0;
  w.request.z = 0.0;
  w.request.yaw = 1.0;
  return is;
}


