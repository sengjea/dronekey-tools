#include <Navigate.h>

using namespace dronkey;

Navigate::Navigate(ros::NodeHandle &n, std::string &modelName, std::string &wpPath){
	//@todo remove hard coded File Path
	std::string test = "/home/codeporter/codeporter_crates/crates/examples/move_quadrotor/waypoints.json";
	
	//Read Waypoint File
	dronekey::wpParser wp(wpPath.c_str());
	wp.getWaypoints(movement);

	//Initialize Iterator
	movement_iterator = movement.begin();

	//Start Services!!
	srvHover = n.serviceClient<hal_quadrotor::Hover>("/hal/"+ modelName +"/controller/Hover");
	srvWaypoint = n.serviceClient<hal_quadrotor::Waypoint>("/hal/"+ modelName +"/controller/Waypoint");
	quadState = n.subscribe("/hal/" + modelName + "/Estimate", 1000, &Navigate::StateCallback, this);
}	

void Navigate::StateCallback(const hal_quadrotor::State::ConstPtr& msg){
	ROS_INFO("Quadrotor Update: [%f, %f, %f, %f] Destination State: [%d, %d]", msg->x, msg->y, msg->z, msg->yaw, msg->rch, msg->ctrl);
	hal_quadrotor::Waypoint& tmp = *movement_iterator;
	
	/**
	 * @todo fix first waypoint being skipped
	 */
	if(msg->ctrl == 2 || msg->rch == 1){
		ROS_INFO("GOAL REACHED!!");
		++movement_iterator;
		if(movement.end() == movement_iterator){
			ROS_INFO("BEGINING MOVEMENT");
			movement_iterator = movement.begin();
		}

		tmp = *movement_iterator;
		ROS_INFO("!!!--CALLING NEW WAYPOINT--!!! - NEW COORDIANTES: [%f, %f, %f]",tmp.request.x, tmp.request.y, tmp.request.z);
		if(!srvWaypoint.call(tmp)){
			ROS_FATAL("NO WAYPOINT!!");
		}
	}
}

Navigate::~Navigate(){

}