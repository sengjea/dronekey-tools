#include <wpParser.h>

using namespace dronekey;

wpParser::wpParser(const char *jsonfile)
{	
	//Open file
	std::ifstream wpFile (jsonfile);
	std::stringstream jsonStream;
	
	//File open??
	if(wpFile){
		//Input file into buffer
		jsonStream << wpFile.rdbuf();
		//output buffer
		std::cout << jsonStream.str() << std::endl;

		boost::property_tree::read_json(jsonStream, pt);
		
		wpFile.close();
		//set buffer
		
	}
}

void wpParser::getWaypoints(std::list<hal_quadrotor::Waypoint> &waypointList)
{
	hal_quadrotor::Waypoint tmp;
	BOOST_FOREACH(boost::property_tree::ptree::value_type &vPath, pt.get_child("path"))
    {
    	tmp.request.x = vPath.second.get<int>("x");
    	tmp.request.y = vPath.second.get<int>("y");    	
    	tmp.request.z = vPath.second.get<int>("z");
    	tmp.request.yaw = 1.0;

    	waypointList.push_back(tmp);
    }	
}