### Basic Linear Algebra

A = rand(1:4, 3, 3) #creates a 3x3 matrix with random numbers ranging from 1 to 4

#Normal Operations rules apply

transpose = A'
conjugate_transpose = A.'

#The problem Ax = b can be solved using
x = A \ b



#FACTORIZATION


### LU FACTORIZATION

#First way to perform an LU factorization is with the function 'lu', which returns matrices l and u.
#and permuation vector p

l, u, p = lu(A)

#Pivoting is on by default so we cant assume A == L*u
#its only == to if its A[p:]

display(norm(l * u - A[p, :]))

#else you can use the following arguement during initialization

l, u, p = lu(A, Val{false})

#Second Way: is the "lufact" function. This returns one output, which you can index into to get the matrixes l and u 

Alu = lufact(A)
Alu[:P]
Alu[:L]
Alu[:U]

#= 
Solving A*x = b
PA = LU
A = P'LU
P'LUx = b
LUx = Pb
x = U\L\Pb

=#
Alu \ b #this is equivilent tot eh process above

det(A) #Finding determinant



### QR FACTORIZATION
Aqr = qrfact(A[:, 1:2]) #This returns one output, which you can index into to get the matrixes q and r

Aqr[:Q]
Aqr[:R]

Aqr \ b #can also be used to solve a linear system



### Eigendecompositions 

#METHOD 1
Asym = A + A'
AsymEig = eigfact(Asym) #forms eigen decomposition

AsymEig[:values] #returns eigenvalues
AsymEig[:vectors] #returns eigenvectors in columns

#METHOD 2
eig(Asym)



### Special Matrix Structures & Types

Diagonal(A) #turns A into a Diagonal matrix

Diagonal(diag(A)) #forms a new matrix from the diagonal values of A 

LowerTriangular(A)
Symmetric(Asym) #tells julia matrix is Symmetric

3 // 4 #declares a number as a rational number



