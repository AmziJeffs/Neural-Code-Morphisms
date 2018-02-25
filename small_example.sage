# Filename: small_example.sage
# Contents: A small example computing image sets of two codes and comparing 
# them.

load("utilities.sage")
import time
import sys

# The two codes we will work with
C = Code(["", "1", "1 2", "2 3", "3"])
D = Code(["", "1", "1 2", "3 4", "3"])

# Keep track of start time.
start = time.time()

# Compute the sets of connected images of C, D, and E.
CImages = compute_all_images_up_to_isomorphism(C)
DImages = compute_all_images_up_to_isomorphism(D)

# Compare the various sets of images to one another.
CminusD = []
DminusC = []

print("Computing images of C that are not images of D.")
CminusD = subtract(DImages, CImages)
print("Done.")

print("Computing images of D that are not images of C.")
DminusC = subtract(CImages, DImages)
print("Done.")

print("")
print("FINAL COUNTS:")
print("There are " + str(len(list(CImages))) + " images of C.")
print("There are " + str(len(list(DImages))) + " images of D.")
print("There are " + str(len(CminusD)) + " images of C that are not images of D.")
print("There are " + str(len(DminusC)) + " images of D that are not images of C.")
print("Computed results in: " + str(time.time()-start) + " seconds")