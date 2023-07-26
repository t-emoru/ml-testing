#For this tutroial youll need the LIBSVM ad RDatasets Packages Installed

using LIBSVM, RDatasets
using LinearAlgebra, Random, Statistics

iris = dataset("datasets", "iris")

vscodedisplay(iris) ##Viewing Dataset

"Objective:
    Create an SVM Model that we can use to make 
    classification predictions about the speices
    based on inputs from unseen data
"

## Split into the features and classes

X = Matrix(iris[:, 1:4])

y = iris.Species


"CROSS VALIDATION

    Now that we have split the dataset into Features and classes
    Now we need to split it further into 
        Training Data & Testing Data
    
    #check notion 
"

######################################################
# Functiont to split data [source: Huda Nassar]
######################################################


function perclass_splits(y, percent)
    uniq_class = unique(y)
    keep_index = []
    for class in uniq_class
        class_index = findall(y .== class)
        row_index = randsubseq(class_index, percent)
        push!(keep_index, row_index...)
    end
    return keep_index
end


"Knowledge:
    
    'randsubseq': this fucntion returns a vector consisting
    of a random sequance of a given vector 'A'

    where each element of A is included (inorder) with
    probability p

    Since the dataset we have right now is on order we can just take 
    the first 100 therefore we need to random select data values from 
    each class 

    NOTE: hover over functoin for more info/demonstration

"

## split into train and test

Random.seed!(1)

train_index = perclass_splits(y, 0.67) #2/3 for training

test_index = setdiff(1:length(y), train_index)





######################################################
# Support Vector Mahcine
######################################################

### Set up matrixes

Xtrain = X[train_index, :]
Xtest = X[test_index, :]

ytrain = y[train_index]
ytest = y[test_index]



### transpose data

Xtrain_t = Xtrain'
Xtest_t = Xtest'
"
Resason:
    The LIBSVM Package requires the orientation for 
        the features data set (both training and testing) to be horizontal 
"


### run model

model = svmtrain(Xtrain_t, ytrain) #CRAHSES THE FUCKING TERMINAL


y_hat, decision_values = svmpredict(model, Xtest_t) #makes predictions
"y_hat are output predictions"

### check accuracy
accuracy = mean(y_hat .== ytest)



######################################################
# Future Scaling 
######################################################

### split features into separate vectors

f1 = iris.SepalLength
f2 = iris.SepalWidth
f3 = iris.PetalLength
f4 = iris.PetalWidth


### Min-Max Normalization

f1_min = minimum(f1)
f2_min = minimum(f2)
f3_min = minimum(f3)
f4_min = minimum(f4)

f1_max = maximum(f1)
f2_max = maximum(f2)
f3_max = maximum(f3)
f4_max = maximum(f4)

f1_n = (f1 .- f1_min) ./ (f1_max - f1_min)
f2_n = (f2 .- f2_min) ./ (f2_max - f2_min)
f3_n = (f3 .- f3_min) ./ (f3_max - f3_min)
f4_n = (f4 .- f4_min) ./ (f4_max - f4_min)

X = [f1_n f2_n f3_n f4_n]

vscodedisplay(X)

"you can rerun the training model above and youll see
The accuracy has not changed  
"


### Standardization

f1_bar = mean(f1)
f2_bar = mean(f2)
f3_bar = mean(f3)
f4_bar = mean(f4)

f1_std = std(f1)
f2_std = std(f2)
f3_std = std(f3)
f4_std = std(f4)

f1_s = (f1 .- f1_bar) ./ f1_std
f2_s = (f2 .- f2_bar) ./ f2_std
f3_s = (f3 .- f3_bar) ./ f3_std
f4_s = (f4 .- f4_bar) ./ f4_std

"Constructing Matrix with new values"

X = [f1_s f2_s f3_s f4_s]
vscodedisplay(X)

"you can rerun the training model above and youll see
The accuracy has imporved slightly   

NOTE: since we are using a random selection from the data to train the model different random selections may yield high accuracy scores.


"