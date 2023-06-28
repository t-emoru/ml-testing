println("hello")
#= 
Multi-line Comments!!
=#

#Tutorial Notes

string_1 = """This is how you make a string """
string_2 = "Also This"

typeof('a') #assign a character

#= 
"$" can used to insert a variable value in a string
=#

#Dictionary Format
phone_book = Dict("Jenny" => "12345", "Thomas" => "24689")

phone_book["John"] = "33245" #adding values

phone_book["Jenny"] #accessing value

pop!(phone_book, "Thomas") #removal of values


#Tuples
animals = ("cat", "dog", "snake")
animals[1] #this return cat, indexing starts from 1


#Array
numbers = [1, 3, 6, 7] #indexing aslo starts from 1
push!(animals, 10) #adds to the end, pop! is used to remove 

#2D & 3d Arrays
rand(4, 3)
A = zeros(3, 4) #produces a 3x4 matrix of 0


#LOOPS - General Format

#while loop
n = 0
while n < 10
    n += 1
    println(n)
end

#for loop
for n in 1:10
    println(n)
end



#Conditionals - Same as python just put "end" at the end
#Ternary Operator

a ? b : c
#if a is true b gets executed, if a is false c gets executed



#Functions

function tomi(name)
    println("My name is $name")
end

# use "!" infront of a function name indicates the variable/list being passed through is being altered

#= Broadcasting
f() = applies function to the array as a whole
f.() = applied function to each individual element of the array

=#

#Packages

Pkg.add("Example") #importing Packages

using Example #must call to actually use




#Plotting
Pkg.add("Plots")
using Plots

gr() #load the GR Backend
#OR
plotlyjs() #load the plot-js Backend

plot(x, y, label="line") #plots as line

scatter!(x, y, label="points") #plots as points

xflip!() #flip the x axis
xlabel!("New Label") #change x axis label
title!("New Title") #change graph title


