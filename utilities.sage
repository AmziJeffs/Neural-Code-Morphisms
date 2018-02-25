# Filename: utilities.sage
# Contents: Several functions for computing useful statistics on neural codes

load("NeuralCode.sage")

# Computes all codes on up to n bits, up to isomorphism
def compute_all_connected_codes_up_to_isomorphism(n, verbose = True):
	start = time.time()
	if verbose:
		print("Computing all connected codes on up to "+str(n)+" bits")

	fullcode = Set([x for x in Set(range(1,n+1)).subsets()])
	codes = []

	i = 0
	tot = pow(2,pow(2,n))
	if verbose:
		sys.stdout.write("0 percent complete.")
		sys.stdout.flush()

	percent = int(tot/100)
	for C in fullcode.subsets():
		if(verbose):
			i = i + 1
			if i%percent == 0:
				sys.stdout.write('\r'+str(int(100*i/tot)) + " percent complete.")
				sys.stdout.flush()

		C = Code(C)
		add = True
		if not C.has_redundancies() and C.connected():
			for D in codes:
				if D.is_isomorphic_to(C):
					add = False
					break
		else:
			add = False

		if add:
			codes = codes + [C]

	if verbose:
		print("\nComputed all codes in: " + str(time.time()-start) + " seconds")

	return codes

# A function that computes all the images of a code up to isomorphism, 
# returning them all in a set.
def compute_all_images_up_to_isomorphism(C, verbose = True):
	start = time.time()
	if verbose:
		print("Computing all images of the code: " + C.compact())

	images = []

	# First compute the distinct nonempty proper trunks
	TT = C.trunks()
	distinct = []
	for T in TT:
		add = True
		if TT[T] == C.codewords() or TT[T] == Set():
			add = False
		else:
			for x in distinct:
				if TT[T] == TT[x]:
					add = False
		if add:
			distinct = distinct + [T]

	# Then compute all the images under morphisms defined by subsets
	# of these trunks
	tot = pow(2, len(distinct))
	percent = max(1, int(tot/100))
	i = 0
	for BB in Set(distinct).subsets():
		if verbose:
			i = i + 1
			if i%percent == 0:
				sys.stdout.write('\r'+str(int(100*i/tot)) + " percent complete.")
				sys.stdout.flush()

		I = C.image_under_morphism(list(BB))
		add = True

		# Only have to check the images without redundant neurons
		if I.has_redundancies():
			add = False
		else:
			for D in images:
				if D.is_isomorphic_to(I):
					add = False
					break

		if add:
			images =  [I] + images 

	print("Computed images in: " + str(time.time()-start) + " seconds")
	return Set(images)


# A function that computes all the images of a code up to isomorphism, 
# returning them all in a set.
def compute_all_connected_images_up_to_isomorphism(C, verbose = True):
	start = time.time()
	if verbose:
		print("Computing all connected images of the code: " + C.compact())

	images = []

	# First compute the distinct nonempty proper trunks
	TT = C.trunks()
	distinct = []
	for T in TT:
		add = True
		if TT[T] == C.codewords() or TT[T] == Set():
			add = False
		else:
			for x in distinct:
				if TT[T] == TT[x]:
					add = False
		if add:
			distinct = distinct + [T]

	tot = pow(2, len(distinct))
	percent = max(1, int(tot/100))
	i = 0
	for BB in Set(distinct).subsets():
		if verbose:
			i = i + 1
			if i%percent == 0:
				sys.stdout.write('\r'+str(int(100*i/tot)) + " percent complete.")
				sys.stdout.flush()

		I = C.image_under_morphism(list(BB))
		add = True

		# Only have to check the connected images without redundant neurons
		if not I.has_redundancies() and I.connected():
			for D in images:
				if D.is_isomorphic_to(I):
					add = False
					break
		else: 
			add = False
		if add:
			images =  [I] + images 

	print("Computed images in: " + str(time.time()-start) + " seconds")
	return Set(images)

# A function that takes two lists (or sets) of codes L and M and returns
# a list containing the codes in M which are not (up to isomorphism)
# present in L.
def subtract(L, M):
	result = []
	for C in M:
		add = True
		for D in L:
			if C.is_isomorphic_to(D):
				add = False
				break
		if add:
			result = result + [C]
	return result