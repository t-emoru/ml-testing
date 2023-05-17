using LinearAlgebra
using plots

function out_prod(x,y)
    z = x*transpose(y)
    print(z)
    print(size(z))
end

x = [1,2,3]
y = [3,2,1]
out_prod(x,y)
