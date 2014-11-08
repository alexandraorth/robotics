import sys
import math 

def grahams(obstacle):
	obstacle = sorted(obstacle, key=lambda x: (x[1], -x[0]))
	p0 = obstacle[0]

	# sorting by angle
	for p1 in obstacle[1:len(obstacle)]:
		p1.append(math.atan2((p1[1] - p0[1]), (p1[0] - p0[0])))
	obstacle[1:len(obstacle)] = sorted(obstacle[1:len(obstacle)], key=lambda x: x[2])

	stack = []

	stack.append(obstacle[-1])
	stack.append(obstacle[0])

	i = 1
	while i < len(obstacle):
		B = stack.pop()
		A = stack[-1]

		if(sttl(A, B, obstacle[i])):
			stack.append(B)
			stack.append(obstacle[i])
			i = i + 1

	return stack

def sttl(p1, p2, p3):
	difference = (p2[0] - p1[0])*(p3[1] - p1[1]) - (p2[1] - p1[1])*(p3[0]-p1[0]);
	return difference > 0 

def growobstacle(coordinates):
	rd = 0.35 #robotdiameter
	newcoordinates = []

	for c in coordinates:
		newcoordinates.append([c[0] + rd, c[1] + rd])
		newcoordinates.append([c[0] + rd, c[1] - rd])
		newcoordinates.append([c[0] - rd, c[1] + rd])
		newcoordinates.append([c[0] - rd, c[1] - rd])

	return newcoordinates

if __name__ == "__main__":
	##length = 0
	new_obs = False
	obstacles = 0
	try:
		with open('obstacles.txt', 'r') as file:
			obstacles = int(file.readline().strip())

			# create object			
			obj = []
			for i in range(obstacles):
				length = int(file.readline().strip())
				obstacle = []
				for j in range(length):
					line = file.readline().strip()
					coordinate = [float(i) for i in line.split(' ')]
					obstacle.append(coordinate)
				obj.append(obstacle)

			convexhull = grahams(obj[2])
			grownhull = growobstacle(convexhull)
			newconvexhull = grahams(grownhull)

			print convexhull
			print newconvexhull

			# for i in range(1,len(obj)):
			# 	convexhull = grahams(obj[i])
			#	growobtacle(convexhull)

	except IOError:
		sys.stderr.write("ERROR: Cannot read inputfile.\n")
		sys.exit(1)