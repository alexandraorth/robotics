import sys

def grahams():
	print('this is grahams')



if __name__ == "__main__":
	##length = 0
	new_obs = False
	obstacles = 0
	try:
		with open('obstacles.txt', 'r') as file:
			for line in file:
				if obstacles == 0:
					obstacles = int(line)
				elif new_obs == False:
					length = int(line)
					new_obs = True
				else
					points = []
					
				print(line.strip())

'''
	except IOError:
		sys.stderr.write("ERROR: Cannot read inputfile.\n")
		sys.exit(1)'''