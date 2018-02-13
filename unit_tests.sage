# Filename: unit_tests.sage
# Contents: Unit tests for neural code utilities

import unittest
from sage import *

load("utilities.sage")

a = CodeWord("")
b = CodeWord()
c = CodeWord("12 50 1 1 4")
d = CodeWord([12, 1, 4, 50])
e = CodeWord(Set([1, 4, 50]))
f = CodeWord([])
g = CodeWord([1, 2, 3, 5])
h = CodeWord([2])
i = CodeWord([2, 3])
j = CodeWord([3, 5])

NonConvex = Code(["", "1", "1 2", "2 3", "3"])
Convex = Code(["", "1", "1 2", "3 4", "3"])
Lien = Code(["2 3 4 5", "1 2 3", "1 3 4", "1 4 5", 
			"1 3", "1 4", "2 3", "3 4", "4 5", "3", "4", ""])
A = Code()
B = Code([])
C = Code(Set())
D = Code([[]])
E = Code(Set([CodeWord()]))
F = Code([[2]])
G = Code([[], [2]])
H = Code([[], [1, 2]])
I = Code([x for x in Set(range(1,6)).subsets()])
J = Code(["", "1 2 3 5", "2 3", "2", "3 5"])
K = Code([[], [1, 2, 3, 5], [2, 3], [2], [3, 5]])
L = Code([[1, 2, 3, 5], [2, 3], [2], [3, 5]])
M = Code([[], [1], [3], [1, 3]])
N = Code([[1], [2]])
O = Code([[2], [3], [1, 2], [2, 3], [3, 4]])
P = Code([[], [2], [3], [1, 2], [2, 3], [3, 4]])
Q = Code([[], [1], [3], [1, 2], [2, 3]])
R = Code([[], [1], [2, 3], [3, 4, 5], [3, 4, 6]])
S = Code([[], [1], [2]])
T = Code([[1], [3], [1, 2], [2, 3], [1, 3]])
U = Code([[1, 3], [2, 3]])

# Tests for the class CodeWord
class TestCodeWord(unittest.TestCase):
	def test_constructor(self):
		assert(a == b)
		assert(c == d)
		assert(c != e)
		assert(a == f)

	def test_add(self):
		assert(a.add(200) == CodeWord("200"))
		assert(a != a.add(3))
		assert(a.add(3).add(3) == a.add(3))
		assert(a.add(3).add(4).add(5) == CodeWord("3 4 5"))

	def test_remove(self):
		assert(a == a.remove(1))
		assert(g == g.remove(4))
		assert(a == g.remove(1).remove(2).remove(3).remove(5))
		assert(g.remove(2) == CodeWord([1,3,5]))
		assert(e == d.remove(12))

	def test_support(self):
		assert(a.support() == Set())
		assert(b.support() == Set())
		assert(f.support() == Set())
		assert(c.support() == Set([12, 1, 4, 50]))

	def test_contains(self):
		assert(a.contains(b))
		assert(b.contains(a))
		assert(c.contains(a))
		assert(not(a.contains(c)))
		assert(d.contains(e))
		assert(not(e.contains(d)))
		assert(g.contains(i))
		return False

	def test_order(self):
		assert(a <= b)
		assert(b <= a)
		assert(c < a)
		assert(c <= d)
		assert(d < e)
		assert(i < j)
		assert(g < h)
		assert(g < d)
		return False

# Tests for the class Code
class TestCode(unittest.TestCase):
	def test_constructor_and_equals(self):
		assert(A == B)
		assert(B == C)
		assert(A != D)
		assert(D == E)
		assert(E != F)
		assert(F != G)
		assert(G != I)
		assert(J == K)
		assert(K != L)

	def test_poset(self):
		assert(A.poset() == Poset())
		assert(B.poset() == Poset())
		assert(F.poset().height() == 1)
		assert(F.poset().width() == 1)
		assert(F.poset().has_bottom())
		assert(G.poset().height() == 2)
		assert(G.poset().width() == 1)
		assert(I.poset().height() == 6)
		assert(I.poset().cardinality() == 32)
		assert(N.poset().has_bottom() == False)
		assert(N.poset().width() == 2)
		assert(O.poset().has_top() == False)
		assert(Q.poset().has_bottom())

	def test_is_simplical_complex(self):
		assert(A.is_simplicial_complex())
		assert(E.is_simplicial_complex())
		assert(not(F.is_simplicial_complex()))
		assert(G.is_simplicial_complex())
		assert(I.is_simplicial_complex())
		assert(M.is_simplicial_complex())
		assert(not(L.is_simplicial_complex()))
		assert(not(O.is_simplicial_complex()))
		assert(not(P.is_simplicial_complex()))
		assert(S.is_simplicial_complex())

	def test_is_intersection_complete(self):
		assert(A.is_intersection_complete())
		assert(E.is_intersection_complete())
		assert(F.is_intersection_complete())
		assert(G.is_intersection_complete())
		assert(H.is_intersection_complete())
		assert(I.is_intersection_complete())
		assert(not(J.is_intersection_complete()))
		assert(not(L.is_intersection_complete()))
		assert(M.is_intersection_complete())
		assert(not(N.is_intersection_complete()))
		assert(not(O.is_intersection_complete()))
		assert(P.is_intersection_complete())

	def test_is_max_intersection_complete(self):
		assert(A.is_max_intersection_complete())
		assert(E.is_max_intersection_complete())
		assert(F.is_max_intersection_complete())
		assert(G.is_max_intersection_complete())
		assert(H.is_max_intersection_complete())
		assert(I.is_max_intersection_complete())
		assert(J.is_max_intersection_complete())
		assert(L.is_max_intersection_complete())
		assert(M.is_max_intersection_complete())
		assert(not(N.is_max_intersection_complete()))
		assert(not(O.is_max_intersection_complete()))
		assert(not(R.is_max_intersection_complete()))
		assert(P.is_max_intersection_complete())
		assert(not(T.is_max_intersection_complete()))

	def test_missing_max_intersections(self):
		assert(A.missing_max_intersections() == Set())
		assert(E.missing_max_intersections() == Set())
		assert(F.missing_max_intersections() == Set())
		assert(G.missing_max_intersections() == Set())
		assert(H.missing_max_intersections() == Set())
		assert(I.missing_max_intersections() == Set())
		assert(J.missing_max_intersections() == Set())
		assert(L.missing_max_intersections() == Set())
		assert(M.missing_max_intersections() == Set())
		assert(N.missing_max_intersections() == Set([CodeWord([])]))
		assert(O.missing_max_intersections() == Set([CodeWord([])]))
		assert(R.missing_max_intersections() == Set([CodeWord([3]), CodeWord([3, 4])]))
		assert(T.missing_max_intersections() == Set([CodeWord([2]), CodeWord([])]))
		assert(U.missing_max_intersections() == Set([CodeWord([3])]))


	def test_maximal_codewords(self):
		assert(A.maximal_codewords() == Set())
		assert(D.maximal_codewords() == Set([CodeWord()]))
		assert(F.maximal_codewords() == Set([CodeWord([2])]))
		assert(G.maximal_codewords() == Set([CodeWord([2])]))
		assert(H.maximal_codewords() == Set([CodeWord([1, 2])]))
		assert(I.maximal_codewords() == Set([CodeWord([1, 2, 3, 4, 5])]))
		assert(J.maximal_codewords() == Set([CodeWord([1, 2, 3, 5])]))
		assert(N.maximal_codewords() == Set([CodeWord([1]), CodeWord([2])]))
		assert(O.maximal_codewords() == Set([CodeWord([1, 2]), CodeWord([2, 3]), CodeWord([3, 4])]))
		assert(U.maximal_codewords() == Set([CodeWord([1, 3]), CodeWord([2, 3])]))

	def test_simplical_complex_code(self):
		assert(A.simplicial_complex_code() == A)
		assert(F.simplicial_complex_code() == G)
		assert(I.simplicial_complex_code() == I)
		assert(N.simplicial_complex_code() == S)
		assert(S.simplicial_complex_code() == S)
		assert(O.simplicial_complex_code().simplicial_complex_code() == O.simplicial_complex_code())

	def test_support(self):
		assert(A.support() == Set())
		assert(D.support() == Set())
		assert(F.support() == Set([2]))
		assert(I.support() == Set([1,2,3,4,5]))
		assert(N.support() == Set([1, 2]))
		assert(R.support() != I.support())
		assert(L.support() == Set([1,2,3,5]))
		assert(U.support() == Set([1,2,3]))

	def test_trunks(self):
		#TODO Make this more rigorous
		assert(len(A.trunks()) == 1)
		assert(len(D.trunks()) == 1)
		assert(len(F.trunks()) == 2)
		assert(len(I.trunks()) == 32)
		assert(len(N.trunks()) == 4)

	def test_codewords(self):
		assert(A.codewords() == Set())
		assert(D.codewords() == Set([CodeWord()]))
		assert(F.codewords() == Set([CodeWord([2])]))
		assert(len(I.codewords()) == 32)
		assert(P.codewords() == Set([CodeWord([]), CodeWord([2]), CodeWord([3]), 
									CodeWord([1, 2]), CodeWord([2, 3]), CodeWord([3, 4])]))
		assert(S.codewords() == Set([CodeWord([]), CodeWord([1]), CodeWord([2])]))

	def test_contains(self):
		assert(A.contains(B))
		assert(B.contains(A))
		assert(D.contains(A))
		assert(not(A.contains(D)))
		assert(I.contains(F))
		assert(I.contains(K))
		assert(not(I.contains(R)))
		assert(not(R.contains(I)))
		assert(S.contains(N))
		assert(not(N.contains(S)))

	def test_trunk(self):
		assert(A.trunk(Set()) == Set())
		assert(A.trunk(Set([1])) == Set())
		assert(D.trunk(Set()) == Set([CodeWord()]))
		assert(D.trunk(Set([1])) == Set())
		assert(H.trunk(Set([1])) == H.trunk(Set([2])))
		assert(O.trunk(Set([1])) == Set([CodeWord([1, 2])]))
		assert(O.trunk(Set([1, 2])) == Set([CodeWord([1, 2])]))
		assert(O.trunk(Set([2])) == Set([CodeWord([2]), CodeWord([1, 2]), CodeWord([2, 3])]))

	def test_irreducible_trunks(self):
		#TODO
		return False

	def test_simplicial_complex(self):
		#TODO
		return False

	def test_link(self):
		#TODO
		return False

	def test_has_trivial_homology(self):
		#TODO
		return False

	def test_has_local_obstructions(self):
		#TODO
		return False

	def test_morphism(self):
		#TODO
		return False

	def test_reduced(self):
		#TODO
		return False

	def test_image_under_morphism(self):
		#TODO
		return False

	def test_is_isomorphic_to(self):
		#TODO
		return False

	def test_mandatory_codewords(self):
		#TODO
		return False

	def test_nonmandatory_intersections(self):
		#TODO
		return False

	def test_size(self):
		#TODO
		return False

	def test_convexity(self):
		#TODO
		return False



# Run the tests
unittest.main()
