#!/usr/bin/python
import math, copy, random
class coords:
	def __init__(self, x, y, z):
		self.x = x
		self.y = y
		self.z = z

	def __str__(self):
		return "({0}, {1}, {2})".format(self.x, self.y, self.z)

def get_points(origin, distances, theta_step, phi_step):
	point_list = []
	random.shuffle(distances)
	for d in test_distances:
		for iter_p in range(15,90,phi_step):
			phi = math.radians(90 - iter_p)
			for iter_t in range(45,360,theta_step):
				theta = math.radians(iter_t)
				dest = copy.deepcopy(origin)
				dest.x += d * math.sin(phi) * math.cos(theta)
				dest.y += d * math.sin(phi) * math.sin(theta)
				dest.z += d * math.cos(phi)
				point_list.append(dest)
	return point_list

if __name__ == "__main__":
	ap_location = coords(0,0,0)
	test_distances = range(2,12,2)
	points = get_points(ap_location, test_distances, 90, 30)
	for p in points:
		print p
