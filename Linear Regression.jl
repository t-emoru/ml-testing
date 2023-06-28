"Basic Steps for Setup"

#load the Julia REPEL by using (A)lt + O) & (Alt + J)
#change working directory to this file ' cd("Test) '
#Activate "activate ."

#then load packages

using CSV, GLM, Plots, TypedTables

#use CSV pacakge to import the data from the CSV file
data = CSV.File("raw.githubusercontent.com_julia4ta_tutorials_master_Series 05_Files_housingdata.csv")

X = data.size
Y = round.(Int, data.price / 1000)
t = Table(X=X, Y=Y)



############################################################################
#UNTRAINED LINEAR REGRESSION
############################################################################



#creating plots

gr(size=(600, 600))


p_scatter = scatter(X, Y,
    xlims=(0, 5000),
    ylims=(0, 800), xlabel="Size",
    ylabel="Price",
    title="Housing Prices in Portland",
    legend=false,
    color=:red
)

#generating linear regression model using GLM [Generalised Linear Models]

"Ordinary Least Squares Method"
ols = lm(@formula(Y ~ X), t)

plot!(X, predict(ols), color=:green, linewidth=3) #adds regression line generated



#value prediction/generation

newX = Table(X=[1250])
predict(ols, newX)


"this approach works for simple data sets"




################################################################################
#MACHINE LEARNING APPROACH
################################################################################

epochs = 0
## then plot graph
p_scatter = scatter(X, Y,
    xlims=(0, 5000),
    ylims=(0, 800), xlabel="Size",
    ylabel="Price",
    title="Housing Prices in Portland (ML)",
    legend=false,
    color=:red
)
#initialse parameters

theta_0 = 0.0  # y-intercept [bias]
theta_1 = 0.0  # slope [weight]

#linear regression model definition

h(x) = theta_0 .+ theta_1 .* x


plot!(X, h(X), color=:blue, linewidth=3)

"Now we have to train the computer. A Cost function is used to do this
checking how good or bad an estimate is

A good solution is found when the cost function is minimised 
"
#Cost Function 1: From Andrew Ng - ROOT MEAN SQUARE / 2

m = length(X) #number of values
y_hat = h(X) #predicted value of Y

function cost(X, Y)
    (1 / (2 * m)) * sum((y_hat - Y) .^ 2)
end

J = cost(X, Y)


## Tracking Value
J_history = []
push!(J_history, J)


## Gradient Descent Algorithm [refer to notion for math]
function pd_theta_0(X, Y)
    (1 / m) * sum(y_hat - Y)
end

function pd_theta_1(X, Y)
    (1 / m) * sum((y_hat - Y) .* X)
end


# set learning rates (alpha)
alpha_0 = 0.09
alpha_1 = 0.00000008


while epochs > 10

    ### Calculating theta values/partial derivities
    theta_0_temp = pd_theta_0(X, Y)
    theta_1_temp = pd_theta_1(X, Y)
    "meaining: these values essentially answer the question 
    How do I imporve the Parameters?
    Does the Change need to be positive or negative?
    Big or Small?
    "

    ### Adjustment of values based on learning rate
    global theta_0 -= alpha_0 * theta_0_temp
    global theta_1 -= alpha_1 * theta_1_temp


    #Recalculate and Reset Regression Equation, Cost Calculation then store
    global y_hat = h(X)
    global J = cost(X, Y)

    push!(J_history, J)



    # replot prediction
    global epochs += 1
    plot!(X, y_hat, color=:blue, alpha=0.5,
        title="Housing Prices in Portland (epochs = $epochs)"
    )

end


#CANNOT GET THE WHILE LOOP TO WORK