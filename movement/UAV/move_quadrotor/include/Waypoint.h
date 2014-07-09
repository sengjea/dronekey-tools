/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
* File Name : myfile.c
* Creation Date : 09-07-2014
* Last Modified : Wed 09 Jul 2014 01:54:14 PM BST
* Created By : Greg Lyras <greglyras@gmail.com>
_._._._._._._._._._._._._._._._._._._._._.*/
#ifndef DRONKEY_WAYPOINT
#define DRONKEY_WAYPOINT

#include <hal_quadrotor/control/Waypoint.h>

namespace dronkey {
  class Waypoint : public hal_quadrotor::Waypoint {
    public:
      friend istream &operator>>(istream &is, Waypoint &w);
  };
}

#endif /* DRONKEY_WAYPOINT */
