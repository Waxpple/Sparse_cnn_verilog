# WHAT PARAMETER?
sparsity = from 0.1 to 1 will produce different sparsity matrix.
padding = "valid" then will crop the boarder (example 28*28->PE->24*24).
padding = "full" the will output full convolution (28*28->PE->32*32).
N = fmap size N*N.
# HOW TO USE?
gen_pattern(28,0.5,"full")