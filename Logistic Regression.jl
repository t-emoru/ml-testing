"Its application would be useful in Media Data Classification for final stock algorithm"

using Plots

gr(size={600, 600})

# plot logistic (sigmoid) curve
logistic(x) = 1 / (1 + exp(-x))



# plot logistic function
p_logistic = plot(-6:0.1:6, logistic,
    xlabel="Inputs (x)",
    ylabel="Outputs (y)",
    title="Logistic (Sigmoid) Curve",
    legend=false,
    color=:blue
)

"We want to modify the shape of the curve to best fit the data
inorder to make accurate classification preductions 
Modification is done through entering a function for X - the equation for a straight line
"

#Curve modification
theta_0 = 0.0    # y-intercept (default = 0 | try 1 & -1)
theta_1 = 1.0    # slope (default = 1 | try 0.5 & -0.5)

z(x) = theta_0 .+ theta_1 * x
h(x) = 1 ./ (1 .+ exp.(-z(x)))

#TEST [should produce the same lines as the line above]
plit!(h(x), color=:red, linestyle=:dash, linewidth=5)

