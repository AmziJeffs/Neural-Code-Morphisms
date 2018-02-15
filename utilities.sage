# Filename: utilities.sage
# Contents: Classes and functions for working with neural codes

from sage.sets import *
import itertools
import time
PP = PositiveIntegers()





# Constructor for CodeWord object. Parameter 'support' determines the 
# support of the codeword, and must be one of the following:
#  - A string of integers separated by spaces, or
#  - a list of integers, or
#  - a set of integers
def CodeWord(support = Set()):
	if isinstance(support, basestring):
		S = []
		for x in support.split(" "):
			if x != "":
				S = S + [int(float(x))]
		support = Set(S)
	return Set(support)

	# Returns a string displaying the codeword
def to_string(c):
	if len(c) == 0:
		return "Empty"
	r = ""
	for i in sorted(list(c)):
		r = r + str(i) + " "
	return r[:-1]

	# Returns a string displaying the codeword without whitespace
def to_string_compact(self):
	if len(c) == 0:
		return "Empty"
	r = ""
	for i in sorted(list(c)):
		r = r + str(i)
	return r

# Less than or equal, used for lexicographical ordering of codewords
def lecodewords(c, d):
	if len(c) > len(d):
		return True
	elif len(c) < len(d):
		return False
	else:
		return to_string(c) <= to_string(d)

# Less than, used for lexicographical ordering of codewords
def ltcodewords(c, d):
	if len(c) > len(d):
		return True
	elif len(c) < len(d):
		return False
	else:
		return to_string(c) < to_string(d)

# A class for neural codes
class Code(SageObject):
	# Constructor for Code object. Parameter 'codewords' must be a list or set
	# in which each element is a 
	#  - string of integers separated by spaces, or
	#  - a set of integers, or
	#  - a list of integers
	def __init__(self, codewords=Set(), support='uncomputed', is_reduced=False):
		assert set.is_Set(codewords) or isinstance(codewords, list)
		C = []
		n = []
		if set.is_Set(codewords):
			codewords = codewords.list()
		for c in codewords:
			c = CodeWord(c)
			n = n + list(c)
			C.append(c)

		self._codewords = Set(C)
		# Partial order whose elements are codewords ordered by inclusion
		self._poset = 'uncomputed'
		# A set of neurons, namely those that are nontrivial in the code
		self._support = Set(n)
		# A dictionary indexed by sets of neurons which contains trunks 
		self._trunks = 'uncomputed'
		# Set of sets of indices indexing the irreducible trunks
		self._irreducible_trunks = 'uncomputed' 
		# Set of mandatory codewords
		self._mandatory_codewords = 'uncomputed' 
		# Set of nonmandatory intersections of maximal codewords
		self._nonmandatory_intersections = 'uncomputed' 
		# Reduced set of codewords for the code isomorphic to this one
		self._reduced = 'uncomputed'
		# Tracks whether the code itself is equal to its reduced code
		self._is_reduced = is_reduced

	def __repr__(self):
		if len(self._codewords) == 0:
			return "{}"
		r = "{"
		for c in sorted(self._codewords.list()):
			r = r + to_string(c) + ", "
		return r[:-2] + "}"

	# Returns the code as a partially ordered set
	def poset(self):
		if self._poset == 'uncomputed':
			self._compute_poset()
		return self._poset

	# Returns true if the code is a simplicial complex, false otherwise
	def is_simplicial_complex(self):
		return self == self.simplicial_complex_code()

	# Returns true if the code is a intersection complete, false otherwise
	def is_intersection_complete(self):
		for c in self._codewords:
			for d in self._codewords:
				if not CodeWord(c.intersection(d)) in self._codewords:
					return False
		return True

	# Returns true if the code is a max-int complete, false otherwise
	def is_max_intersection_complete(self):
		if len(self.missing_max_intersections()) == 0:
			return True
		else:
			return False

	# Returns the set of intersections of maximal codewords that aren't
	# already in the code
	def missing_max_intersections(self):
		missing = []
		for S in self.maximal_codewords().subsets():
			S = list(S)
			c = []
			if len(S) >= 1:
				c = S[0]
				for d in S:
					c = c.intersection(d)
				if not c in self._codewords:
					missing = missing + [c]
		return Set(missing)

	# Returns the set of maximal codewords
	def maximal_codewords(self):
		return Set(self.poset().maximal_elements())

	# Returns the simplicial complex of the code as a Code object
	def simplicial_complex_code(self):
		C = []
		for m in self.maximal_codewords():
			C = C + [c for c in m.subsets()]
		return Code(C)

	# Returns true if code has local obstructions, false otherwise. Note that
	# we include the possibility that the code covers some convex region in 
	# which it is realized, and test the nerve of this cover too.
	def has_local_obstructions(self):
		if self.mandatory_codewords().issubset(self.codewords()):
			return False
		else:
			return True

	# Returns the codewords necessary to avoid local obstructions. Note that
	# we include the possibility that the code covers some convex region in 
	# which it is realized, and test the nerve of this cover too.
	def mandatory_codewords(self):
		if self._mandatory_codewords == 'uncomputed':
			self._compute_mandatory_and_nonmandatory_codewords()
		return self._mandatory_codewords

	# Returns the codewords intersections of maximal codewords which are
	# not mandatory for the code to be convex.
	def nonmandatory_intersections(self):
		if self._nonmandatory_intersections == 'uncomputed':
			self._compute_mandatory_and_nonmandatory_codewords()
		return self._nonmandatory_intersections

	# Returns the simplicial complex associated to a code
	def simplicial_complex(self):
		return SimplicialComplex([list(x) for x in self.maximal_codewords()])

	# Returns true if simplicial complex of the code has trivial homology.
	# Provides a coarse test for whether simplicial complex is contractible.
	# Based on code from https://goo.gl/cJEYLW
	def has_trivial_homology(self):
		H = self.simplicial_complex().homology()
		length = len(H)
		trivial = SimplicialComplex([range(0, length)])
		return H == trivial.homology()

	# Returns the image of a code under morphism defined by a list of sets of 
	# indices T. To represent empty trunk we use "Empty" in T.
	# The output is a dictionary indexed by elements of the code, with entries
	# being the images of these elements.
	def morphism(self, T):
		D = {}
		m = len(T)
		for c in self.codewords():
			im = []
			for j in range(0, m):
				if T[j] != "Empty":
					if T[j].issubset(c):
						im = im + [j+1]
			D[c] = CodeWord(im)
		return D

	# Does the same as morphism(self, T), but just returns the image as a code
	def image_under_morphism(self, T):
		D = []
		TT = self.trunks()
		T = [TT[s] for s in T]
		m = len(T)
		for c in self.codewords():
			im = []
			for j in range(0, m):
				if T[j] != "Empty":
					if c in T[j]:
						im = im + [j+1]
			D = D + [im]
		return Code(D, Set(range(1, m+1)))

	# Computes the link code of a set of neurons s. This is the code consisting
	# of codewords containing s, but with s removed from all of them.
	def link(self, s):
		trunk = self.trunk(s)
		words = []
		for c in trunk:
			words = words + [CodeWord(c.difference(s))]
		return Code(words)

	# Returns the set of trunks in the code
	def support(self):
		return self._support

	# Returns the set of trunks in the code
	def trunks(self):
		if self._trunks == 'uncomputed':
			self._compute_trunks()
		return self._trunks

	# Returns the set of irreducible trunks in the code
	def irreducible_trunks(self):
		if self._irreducible_trunks == 'uncomputed':
			self._compute_irreducible_trunks()
		return self._irreducible_trunks

	# Returns the set of codewords in the code
	def codewords(self):
		return self._codewords

	# Returns true if self contains other as codes, false otherwise
	def contains(self, other):
		return other.codewords().issubset(self.codewords())

	# Returns a string displaying the code with no whitespace between neurons.
	def compact(self):
		if len(self._codewords) == 0:
			return "{}"
		r = "{"
		#TODO make this sort properly
		for c in sorted(self._codewords.list(), key=lecodewords):
			r = r + to_string_compact(c) + ", "
		return r[:-2] + "}"

	# Returns the trunk of a set of neurons
	def trunk(self, s):
		T = self.trunks()
		if s in T:
			return self.trunks()[s]
		return Set()


	# Returns the set of codewords in the code with no redundant or trivial
	# neurons which is isomorphic to this one
	def reduced(self):
		if self._is_reduced:
			return self
		if self._reduced == 'uncomputed':
			self._compute_reduced_codewords()
		return self._reduced

	# Tests whether two codes are isomorphic
	def is_isomorphic_to(self, other):
		# First perform easy checks on size and equality
		if self.size() != other.size():
			return False
		if self == other:
			return True

		# Next compute the reduced associated codes
		C = self.reduced()
		D = other.reduced()

		# Test all permuted versions of C. If any are the same as D, 
		# then we return true. Else, false. Since we already know C
		# and D have the same since, we just have to check that every
		# permuted codeword from C lies in D (i.e. that the permutation)
		# gives us an injective map C->D.
		CC = C.codewords()
		DD = D.codewords()
		for p in list(itertools.permutations(list(C.support()))):
			equal = True
			for c in CC:
				cc = CodeWord([p[i-1] for i in c])
				if not cc in DD:
					equal = False
					break
			if equal:
				return True
		return False

	# Returns the number of codewords in the code
	def size(self):
		return len(self._codewords)

	# Returns 0 if code is not convex, 1 if code is convex, and -1
	# if tests are inconclusive
	def convexity(self):
		if self.is_max_intersection_complete():
			return 1
		if not self.mandatory_codewords().issubset(self.codewords()):
			return 0

		# Check links for convexity
		for i in self.support():
			if self.trunk(Set([i])) != self.codewords():
					if self.link(Set([i])).convexity() == 0:
						return 0
		return -1

	# Returns True if the simplicial complex of the code is connected, and
	# returns False otherwise.
	def connected(self):
		return self.simplicial_complex().is_connected()

	# Returns True if the code has redundant neurons
	def has_redundancies(self):
		TT = self.trunks()
		for i in self.support():
			for s in self.support().difference(Set([i])).subsets():
				if TT[Set([i])] == TT[s]:
					return True
		return False

	# 
	# Below this line are internal utility methods that shouldn't be accessed 
	# by outside functions.
	#

	# Computes the mandatory codewords for the code to be convex,
	# while simultaneously computing the maximal intersections which are 
	# nonmandatory
	def _compute_mandatory_and_nonmandatory_codewords(self):
		M = []
		mand = []
		nonmand = []
		for S in self.maximal_codewords().subsets():
			S = list(S)
			if len(S) >= 1:
				c = S[0]
				for d in S:
					c = c.intersection(d)
				M = M + [c]
		for m in Set(M):
			L = self.link(m)
			if L.has_trivial_homology():
				nonmand = nonmand + [CodeWord(m)]
			else:
				mand = mand + [CodeWord(m)]
		self._mandatory_codewords = Set(mand)
		self._nonmandatory_intersections = Set(nonmand).difference(self.maximal_codewords())

	# Computes the partially ordered set containing all codewords
	def _compute_poset(self):
		fcn = lambda c,d : c.issubset(d)
		self._poset = Poset([self._codewords, fcn])

	# Updates the set of trunks 
	def _compute_trunks(self):
		TT = {}
		for s in self.support().subsets():
			#TODO rewrite this using T as a list
			T = Set()
			for c in self._codewords:
				if s.issubset(c):
					T = T.union(Set([c]))
			TT[s] = T
		self._trunks = TT

	# Updates the set of irreducible trunks
	def _compute_irreducible_trunks(self):
		TT = self.trunks()
		S = self.support()
		irred_trunks = []
		irred_indices = []

		# Suffices to compute the simple trunks that are irreducible
		for i in self.support():
			T = TT[Set([i])]
			s = S
			for c in T:
				s = s.intersection(c)
			add = True
			smi = s.difference(Set([i]))
			for ss in smi.subsets():
				for j in smi.difference(ss):
					if add == True and TT[Set([j])] != T and TT[ss] != T and TT[ss.union(Set([j]))] == T:
						add = False
						break
			if add and not T in irred_trunks:
				irred_trunks = irred_trunks + [T]
				irred_indices = irred_indices + [i]
		return Set([Set([i]) for i in irred_indices])

	# Computes the codewords in the isomorphism representative for this code
	# which has no trivial or redundant neurons
	def _compute_reduced_codewords(self):
		self._reduced = self.image_under_morphism([s for s in self._compute_irreducible_trunks()])
		self._reduced._is_reduced = True

	# Checks if two codes are equal
	def __eq__(self, other):
		if not isinstance(other, Code):
			return False
		return self.codewords() == other.codewords()

	# Checks if two codes are not equal
	def __ne__(self, other):
		return not self == other




















# Computes all codes on n bits, up to isomorphism
def compute_all_connected_codes_up_to_isomorphism(n):
	start = time.time()
	fullcode = Set([x for x in Set(range(1,n+1)).subsets()])

	codes = []
	i = 0
	for C in fullcode.subsets():
		i = i + 1
		C = Code(C)
		add = True
		if C.connected():
			for D in codes:
				if D.is_isomorphic_to(C):
					add = False
					break
		else:
			add = False

		if add:
			print(float(i)/pow(2,pow(2,n)))
			codes = codes + [C]

	print("Computed all codes in: " + str(time.time()-start) + " seconds")
	return codes

# A function that computes all the images of a code up to isomorphism, 
# returning them all in a set
def compute_all_connected_images_up_to_isomorphism(C):
	start = time.time()
	images = []

	# First compute the distinct nonempty proper trunks
	TT = C.trunks()
	distinct = []
	for T in TT:
		add = True
		for x in distinct:
			if TT[T] == TT[x] or TT[T] == C.codewords() or TT[T] == Set():
				add = False
		if add:
			distinct = distinct + [T]

	tot = pow(2, len(distinct))
	i=0
	for B in Set(distinct).subsets():
		i = i+1
		I = C.image_under_morphism(list(B))
		add = True
		if I.connected():
			for D in images:
				if D.is_isomorphic_to(I):
					add = False
		else: 
			add = False
		if add:
			images =  [I] + images 
			print(len(images))
			print(float(i/tot))

	print("Computed images in: " + str(time.time()-start) + " seconds")
	return Set([x.reduced() for x in images])
	

# A function that computes all the images of a code up to isomorphism, 
# returning them all in a set
def compute_all_connected_images_up_to_isomorphism_2(C):
	start = time.time()
	images = []

	# First compute the distinct nonempty proper trunks
	TT = C.trunks()
	distinct = []
	for T in TT:
		add = True
		for x in distinct:
			if TT[T] == TT[x] or TT[T] == C.codewords() or TT[T] == Set():
				add = False
		if add:
			distinct = distinct + [T]

	tot = pow(2, len(distinct))
	i=0
	for BB in Set(distinct).subsets():
		i = i+1

		I = C.image_under_morphism(list(BB))
		add = True

		# Only have to check the connected images without redundant neurons
		if I.connected() and not I.has_redundancies():
			for D in images:
				if D.is_isomorphic_to(I):
					add = False
		else: 
			add = False
		if add:
			images =  [I] + images 
			print(len(images))
			print(float(i/tot))

	print("Computed images in: " + str(time.time()-start) + " seconds")
	return Set(images)