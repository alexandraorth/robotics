import sys

def grahams(obstacle):
	print(obstacle.sort(key=lambda x: x[1]))
	# for coordinate in obstacle:



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

			grahams(obj[1])
			


			# for line in file:
			# 	if obstacles == 0:
			# 		obstacles = int(line)
			# 	elif new_obs == False:
			# 		length = int(line)
			# 		new_obs = True
			# 	else
			# 		points = []
					
			# 	print(line.strip())

	except IOError:
		sys.stderr.write("ERROR: Cannot read inputfile.\n")
		sys.exit(1)