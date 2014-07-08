#!/usr/bin/python
import math,copy
class coords:
	def __init__(self, x, y, z):
		self.x = x
		self.y = y
		self.z = z

	def __str__(self):
		return "({},{},{})".format(self.x, self.y, self.z)

def get_points(origin, radius, theta_step, phi_step):
	point_list = []	
	for iter_p in range(5,90,phi_step):
		phi = math.radians(90 - iter_p)
		for iter_t in range(5,360,theta_step):
			theta = math.radians(iter_t)	
			dest = copy.deepcopy(origin)	
			dest.x += radius * math.sin(phi) * math.cos(theta)
			dest.y += radius * math.sin(phi) * math.sin(theta)
			dest.z += radius * math.cos(phi)
			point_list.append(dest)
	return point_list 

if __name__ == "__main__":
	ap_location = coords(0,0,0)
	points = get_points(ap_location, 5, 60, 30)
	for p in points:
		print p
