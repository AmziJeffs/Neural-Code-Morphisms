# Filename: LSW_example.sage
# Contents: An example computing a heuristic comparison between several codes
# found in "Obstructions to Convexity in Neural Codes" by Lienkaemper, 
# Shiu, and Woodstock.

load("utilities.sage")
import time
import sys

# A nonconvex code with no local obstructions. See Theorem 3.1 in LSW paper.
C = Code(["2 3 4 5", "1 2 3", "1 3 4", "1 4 5", "1 3", "1 4", "2 3", "3 4", "4 5", "3", "4", ""])

# Two minimal extensions of C to codes with the same simplicial complex
# which are convex. See Prop 3.3 in LSW paper.
D = Code(["2 3 4 5", "1 2 3", "1 3 4", "1 4 5", "1 3", "1 4", "2 3", "3 4", "4 5", "3", "4", "", "2 3 4", "3 4 5"])
E = Code(["2 3 4 5", "1 2 3", "1 3 4", "1 4 5", "1 3", "1 4", "2 3", "3 4", "4 5", "3", "4", "", "1"])

# Keep track of start time.
start = time.time()

# Compute the sets of connected images of C, D, and E.
CImages = compute_all_images_up_to_isomorphism(C)
DImages = compute_all_images_up_to_isomorphism(D)
EImages = compute_all_images_up_to_isomorphism(E)

# Compare the various sets of images to one another.
CminusD = []
DminusC = []
CminusE = []
EminusC = []
DminusE = []
EminusD = []

print("Computing images of C that are not images of D.")
CminusD = subtract(DImages, CImages)
print("Done.")

print("Computing images of C that are not images of E.")
CminusE = subtract(EImages, CImages)
print("Done.")

print("Computing images of D that are not images of C.")
DminusC = subtract(CImages, DImages)
print("Done.")

print("Computing images of E that are not images of C.")
EminusC = subtract(CImages, EImages)
print("Done.")

print("Computing images of D that are not images of E.")
DminusE = subtract(EImages, DImages)
print("Done.")

print("Computing images of E that are not images of D.")
EminusD = subtract(DImages, EImages)
print("Done.")

print("")
print("FINAL COUNTS:")
print("There are " + str(len(list(CImages))) + " images of C.")
print("There are " + str(len(list(DImages))) + " images of D.")
print("There are " + str(len(list(EImages))) + " images of E.")
print("There are " + str(len(CminusD)) + " images of C that are not images of D.")
print("There are " + str(len(DminusC)) + " images of D that are not images of C.")
print("There are " + str(len(CminusE)) + " images of C that are not images of E.")
print("There are " + str(len(EminusC)) + " images of E that are not images of C.")
print("There are " + str(len(DminusE)) + " images of D that are not images of E.")
print("There are " + str(len(EminusD)) + " images of E that are not images of D.")
print("Computed results in: " + str(time.time()-start) + " seconds")