#ifndef DRONEKEY_PARSER
#define DRONEKEY_PARSER

#include <hal_quadrotor/control/Waypoint.h>

#include <sstream>
#include <string>
#include <fstream>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <boost/foreach.hpp>

namespace dronekey {
	class wpParser {
	private:
		boost::property_tree::ptree pt;
	public:
		wpParser(const char *jsonfile);

		void getWaypoints(std::list<hal_quadrotor::Waypoint> &waypointList);
	};
}

#endif