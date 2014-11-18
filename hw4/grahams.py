import matplotlib.pyplot as plt
from matplotlib.path import Path
import matplotlib.patches as patches
from matplotlib import collections  as mc
import numpy as np
import Queue
import math 
import sys

# Runs Graham's algorithm on a set of coordinates that makes up an obstacle
# Takes in a list of coordinates that an obstacle is comprised of
# Returns a list of coordinates corresponding to the convex hull of an obstacle
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
	
# Strictly-less-than function takes in 3 coordinates
# Returns true if the 3 points form a "left-turn" angle, false otherwise
def sttl(p1, p2, p3):
	difference = (p2[0] - p1[0])*(p3[1] - p1[1]) - (p2[1] - p1[1])*(p3[0]-p1[0]);
	return difference > 0 

# Grows an obstacle's coordinates by an amount defined within the function
# Returns a list of grown coordinates of the original list of coordinates
def grow_obstacle(coordinates):
	rd = 0.5 #robotdiameter
	newcoordinates = []

	# Grows by adding four new coordinates for each coordinate from argument
	for c in coordinates:
		newcoordinates.append([c[0] + rd, c[1] + rd])
		newcoordinates.append([c[0] + rd, c[1] - rd])
		newcoordinates.append([c[0] - rd, c[1] + rd])
		newcoordinates.append([c[0] - rd, c[1] - rd])

	return newcoordinates

# Takes in a list of obstacles and creates edges for each obstacle
# Returns a list of edges of one point to another in an obstacle
def create_obstacle_edges(obstacles):
	edges = []
	for obstacle in obstacles:
		for i in range(0, len(obstacle) - 1):
			edges.append([obstacle[i], obstacle[i+1]])

	return edges

def get_vertices(obstacles):
	vertices = []
	for obstacle in obstacles:
		for i in range(0, len(obstacle) - 1):
			vertices.append(obstacle[i])
	
	return vertices

def create_vertex_edges(vertices):
	edges = []
	for i in vertices:
		for j in vertices:
			if j > i:
				edges.append([j, i])

	return edges

def on_segment(p, q, r):
	if (q[0] <= max(p[0], r[0]) 
		and q[0] >= min(p[0], r[0]) 
		and q[1] <= max(p[1], r[1])
		and q[1] >= min(p[1], r[1])):
		return True

	return False

# 0 --> p, q and r are colinear
# 1 --> Clockwise
# 2 --> Counterclockwise
# Takes in three coordinates
# Returns either 0, 1 or 2 indicating orientation of the three coordinates
def orientation(p, q, r):
	val = (q[1] - p[1]) * (r[0] - q[0]) - (q[0] - p[0]) * (r[1] - q[1])
	if val == 0:
		return 0

	return 1 if val > 0 else 2

# Takes in two line, where each line consists of two coordinates
# If the endpoints of the two lines are the same, it is not intersecting
# Returns true if the two lines intersect, false otherwise
def intersect(line1, line2):
	p1 = line1[0]
	q1 = line1[1]
	p2 = line2[0]
	q2 = line2[1]

	s = set()
	s.add("{x}".format(x=p1))
	s.add("{x}".format(x=q1))
	s.add("{x}".format(x=p2))
	s.add("{x}".format(x=q2))

	if len(s) < 4:
		return False

	o1 = orientation(p1, q1, p2)
	o2 = orientation(p1, q1, q2)
	o3 = orientation(p2, q2, p1)
	o4 = orientation(p2, q2, q1)

	if o1 != o2 and o3 != o4:
		return True

    # p1, q1 and p2 are colinear and p2 lies on segment p1q1
	if o1 == 0 and on_segment(p1, p2, q1): 
		return True
 
    # p1, q1 and p2 are colinear and q2 lies on segment p1q1
	if o2 == 0 and on_segment(p1, q2, q1): 
		return True
 
    # p2, q2 and p1 are colinear and p1 lies on segment p2q2
	if o3 == 0 and on_segment(p2, p1, q2): 
		return True
 
    # p2, q2 and q1 are colinear and q1 lies on segment p2q2
	if o4 == 0 and on_segment(p2, q1, q2): 
		return True

	return False

# Creates visibility graph
# Returns a list of valid edges such that the valid edges are
# vertex edges which do not intersect with any obstacle edge
def visibility_graph(obs_edges, vertex_edges):
	valid_edges = []

	# for each of the vertex edges, goes through all of the 
	# obstacle edges and sees if they intersect 
	for v_edge in vertex_edges:
		state = False
		for o_edge in obs_edges:
			if intersect(v_edge, o_edge):
				state = True

		if state == False:
			valid_edges.append(v_edge)

	print len(vertex_edges)
	print len(valid_edges)

	return valid_edges
	
# Draws a graph with obstacles, grown obstacles, valid edges to
# traverse, bounding box and shortest path from start to goal
def draw_graph(obstacles, grownobstacles, edges, sp, bb):
	fig, ax = plt.subplots()

	#DRAW GROWN OBSTACLES
	for vertices in grownobstacles:
		codes = [Path.MOVETO]
		for vertex in range(0, len(vertices) - 2):
			codes.append(Path.LINETO)
		codes.append(Path.CLOSEPOLY)

		newvertices = []
		for vertex in vertices:
			newvertices.append((vertex[0], vertex[1]))
		
		path = Path(newvertices, codes)

		ax = fig.add_subplot(111)
		patch = patches.PathPatch(path, facecolor='#BEDB39', lw=0, alpha=0.3)
		ax.add_patch(patch)

	#DRAW SMALL OBSTACLES
	for vertices in obstacles:
		codes = [Path.MOVETO]
		for vertex in range(0, len(vertices) - 2):
			codes.append(Path.LINETO)
		codes.append(Path.CLOSEPOLY)

		newvertices = []
		for vertex in vertices:
			newvertices.append((vertex[0], vertex[1]))
		
		path = Path(newvertices, codes)

		ax = fig.add_subplot(111)
		patch = patches.PathPatch(path, facecolor='#BEDB39', lw=0)
		ax.add_patch(patch)

	# DRAW ALL POSSIBLE LINES IN VISIBILITY GRAPH
	lines = []
	for edge in edges:
		lines.append([(edge[0][0], edge[0][1]),(edge[1][0], edge[1][1])])

	c = np.array(['#077EA8'])

	lc = mc.LineCollection(lines, colors=c, linewidths=2)
	ax.add_collection(lc)

	# DRAW SHORTEST PATH
	to_highlight = []
	for i in range(0, len(sp) - 1):
		to_highlight.append([sp[i], sp[i+1]])

	c = np.array(['#FD7400'])
	lc = mc.LineCollection(to_highlight, colors=c, linewidths=3)
	ax.add_collection(lc)

	# DRAW BOUNDING BOX
	bounding = []
	for i in range(0, len(bb) - 1):
		bounding.append([bb[i], bb[i+1]])

	c = np.array(['#BEDB39'])
	lc = mc.LineCollection(bounding, colors=c, linewidths=2)
	ax.add_collection(lc)

	ax.autoscale()
	ax.margins(0.1)

	plt.show()

# Returns the distance between points p and q
def get_dist(p, q):
	return math.sqrt(math.pow(p[0] - q[0], 2) + math.pow(p[1] - q[1], 2))

# Runs dijkstras algorithm for shortest path
# Returns a list of points that consists of the shortest path
def dijkstras(m, start, goal):
	Q = Queue.PriorityQueue()
	dist = {}
	previous = {}
	for vertex in m:
		dist[vertex] = float("inf")
		previous[vertex] = None
		Q.put((dist[vertex], vertex))

	dist[start] = 0
	Q.put((dist[start], start))

	while not Q.empty():
		u = Q.get()
		for v in m[u[1]]:
			alt = dist[u[1]] + get_dist(u[1], v)
			if alt < dist[v]:
				dist[v] = alt
				previous[v] = u[1]

	path = []
	path.append(goal)
	cur_node = previous[goal]
	while cur_node != None:
		path.append(cur_node)
		cur_node = previous[cur_node]

	return path

# Takes in a list of edges, where each edge consists of two coordinates
# Returns a dictionary, where the keys are a node
# and the key values are other nodes reachable by the node
def create_map(edges):
	m = {}
	for edge in edges:
		# print edge
		node0 = (edge[0][0], edge[0][1])
		node1 = (edge[1][0], edge[1][1])

		if node0 in m:
			m[node0].append(node1)
		else:
			m[node0] = [node1]

		if node1 in m:
			m[node1].append(node0)
		else:
			m[node1] = [node0]

	return m

if __name__ == "__main__":
	try:
		with open('goals.txt', 'r') as file:
			startline = file.readline().strip().split(' ')
			start = [float(startline[0]), float(startline[1])]

			endline = file.readline().strip().split(' ')
			end = [float(endline[0]), float(endline[1])]

		
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

			# Store convex hull of grown obstacles in grownobstacles
			# and store convex hull of the original obstacles in o
			o = []
			grownobstacles = []
			for i in range(1,len(obj)):
				convexhull = grahams(obj[i])
				o.append(convexhull)
				grownhull = grow_obstacle(convexhull)
				grownobstacles.append(grahams(grownhull))

			# Creates visibility graph using grown obstacle edges and grown vertices edges
			# Vertices edges includes the start and goal coordinates
			grown_obstacle_edges = create_obstacle_edges(grownobstacles)
			grown_vertices = get_vertices(grownobstacles)
			grown_vertices.append(end)
			grown_vertices.append(start)
			grown_vertex_edges = create_vertex_edges(grown_vertices)
			grown_valid_edges = visibility_graph(grown_obstacle_edges, grown_vertex_edges)


			obstacle_edges = create_obstacle_edges(o)

			# Create a new visibility graph taking into account the bounding box
			bounding_box = obj[0]
			bounding_box.append(bounding_box[0])
			for i in range(0, len(bounding_box) - 1):
				obstacle_edges.append([bounding_box[i], bounding_box[i+1]])
			valid_edges = visibility_graph(obstacle_edges, grown_valid_edges)

			# Creates map of nodes and edges and run dijkstras to obtain the shortest path
			m = create_map(valid_edges)
			shortest_path = dijkstras(m, (start[0], start[1]), (end[0], end[1]))

			# Display the graph and write the shortest path coordinates to a file
			draw_graph(o, grownobstacles, valid_edges, shortest_path, bounding_box)
			shortest_path = reversed(shortest_path)
			with open("path.txt", "wb") as output:
				for point in shortest_path:
					output.write(str(point).strip(")").strip("(").replace(",", "") + "\n")

	except IOError:
		sys.stderr.write("ERROR: Cannot read inputfile.\n")
		sys.exit(1)
