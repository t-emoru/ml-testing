
"
Algorithm Function:

    ##LOW RISK [Good]

    1. Finding Top Traded Most Profitable Companies
        i) Search 
        ii) Srub and produce List of Companies
            a) Produce List of Articles related to search [3]
            b) Srub articles for list of companies (and stock name)

        iii) Produce list of news article lists (within set time period) relating to each company in the list above


    2. Finding Top Traded Most Stable Industries 
        i) Search
        ii) Srub and produce List of Industries & Commodies to traded 
        iii) Produce list of news article lists (within set time period) relating to each
            company in the list above


    USE: CREATE LOW RISK PORTFOLIO (which will be rountinely 'checked')



    ## HIGH RISK [Bad]

    3. Finding Volatile Currently high value stock 
        i) Search
        ii) Srub and produce List of commodities
        iii) Produce list of news article lists (within set time period) relating to each
            company in the list above

    USE: CREATE HIGH RISK PORTFOLIO (more frequently 'checked', used in frequent buying)



"


using Pkg
Pkg.add("HTTP")
Pkg.add("Gumbo")
Pkg.add("AbstractTrees")
Pkg.add("ReadableRegex")
Pkg.add("Cascadia")
Pkg.add("DataFrames")
Pkg.add("CSV")


using HTTP, Gumbo
using HTTP.Cookies
using AbstractTrees
using ReadableRegex
using Cascadia
using DataFrames
using CSV
\

#-------------------------------------------------------------------------------
#Function Library
#-------------------------------------------------------------------------------


############################################################### PART 1: Search



function google_search(query)
    "
    Function: searches google using default query.
    Return: produces hmtl content of search webpage
    
    "


    # Initiatise parameters
    url = "https://www.google.com/search?q=" * query
    params = Dict("q" => query)
    headers = Dict("User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3")


    # Set up cookies container
    cookiejar = CookieJar()


    # Send the request
    search = HTTP.get(url, query=params, headers=headers, cookies=cookiejar)


    return search
end
"Add
    Refine to search a set number of pages
    remove urls that return 404 message

"


function request_access(urls, link)
    "
    Function: request to access html data of link
    Returns: Status (1 meaning Yes) and Response (contains html data)
    "


    subject = urls[link]
    response = HTTP.request("GET", subject)


    #check is request was successful
    if HTTP.status(response) == 200
        status = 1
    else
        println("Failed to access the website. Status code: ", HTTP.status(response))
    end


    return status, response
end



############################################################### PART 2:  Data Extraction



function extraction(status, response)

    "
    Function: extracts title data, body data and all tables from html data 
    Returns:
        title data --> list [words, sentences]
        body data --> list [words, sentences]
        tables --> list [datafrmaes...]

    "

    # Initiatisation Library
    title_sentence = []
    title_word = []
    body_sentence = []
    body_word = []
    table_list = []
    df_list = []



    # Extraction if Access was granted
    if status == 1


        html_content = String(HTTP.body(response))

        ##Packaging Data
        parsed_article = parsehtml(html_content)



        ## Finidng words of Title
        title_sentence = []
        title_word = []
        title_element = eachmatch(Selector("title"), parsed_article.root)

        # Words: Split the text into words using whitespace
        for element in title_element
            title = split(text(element), r"\s+")
            append!(title_word, title)
        end

        # Sentences: Split the text into words using whitespace
        for element in title_element
            title = split(text(element), r"\.")
            append!(title_sentence, title)
        end



        ## Finding words of Body
        body_sentence = []
        body_word = []
        body_elements = eachmatch(Selector("p"), parsed_article.root)

        # Words: Split the text into words using whitespace
        for element in body_elements
            body = split(text(element), r"\s+") # Split the text into words using whitespace
            append!(body_word, body)
        end

        # Sentences: Split the text into words using whitespace
        for element in body_elements
            title = split(text(element), r"\.")  # Split the text at full stops
            append!(body_sentence, title)
        end




        #-----------------------------------------------------------------------------
        # EXTRACTING TABLES
        #-----------------------------------------------------------------------------


        ## Finding Tables
        body = parsed_article.root[2]
        table_data_raw = eachmatch(sel"table", body) #returns table data. NOW CLEAN !!


        #Formatting Rows & Colums
        ntables = length(table_data_raw)
        table_list = []

        for i in range(1, ntables)

            table = []

            rows = eachmatch(sel"tr", table_data_raw[i])

            for row in rows
                cells = []
                for cell in eachmatch(sel"td", row)
                    push!(cells, nodeText(cell))
                end
                push!(table, cells)
            end


            table = permutedims(table) #columns format
            t_table = permutedims(table) #rows format

            # push!(table_list, [])
            push!(table_list, t_table)

        end


        # Creating DataFrame
        for i in range(1, length(table_list))
            table_list[i] = [x for x in table_list[i] if x ≠ []] #removes empty indexes

            df = DataFrame(table_list[i], :auto)
            df = permutedims(df)

            vscodedisplay(df)

            push!(df_list, df)
        end



    else
        println("Access Denied")
    end


    # Output Organisation
    title_data = [title_word, title_sentence]
    body_data = [body_word, body_sentence]



    return title_data, body_data, df_list

end


function extract_url(body)

    "
    Function: extraxts url from html content
    Return: Clean Urls
    
    potentional refinement: import beautifulsoup4 python functions using
    https://gist.github.com/genkuroki/c26f22d3a06a69f917fc98bb07c5c90c
    "


    #URL Types
    raw_URLs = []
    dirty_URLs = []
    clean_URLs = []
    filtered_urls = []
    url_pattern = r"(https?://[^&]+)" # Pattern for cleaning urls


    # Acquiring "Dirty" & "raw" URLs
    " 
    Optimize: try using the built in 'eachmatch' function
    "
    for elem in PreOrderDFS(body)

        try
            # println(tag(elem))  -  creates tree
            if tag(elem) == :a
                push!(raw_URLs, elem)
                #println(elem)

                href = getattr(elem, "href")
                push!(dirty_URLs, href)

            end

        catch
            println("")
        end


    end



    # Acquiring "Clean" URLs
    for urls in dirty_URLs
        matches = eachmatch(url_pattern, urls)

        if !isempty(matches)
            url = first(matches).match
            push!(clean_URLs, url)
        else
            println("No URL found in the input string.")
        end

    end



    ## Filtering Useless Clean URLs
    "If it contains 'google' or doesn't equal 200"

    for str in clean_URLs

        if !occursin("google", str)

            try
                if HTTP.status(HTTP.request("GET", str)) == 200
                    push!(filtered_urls, str)

                end

            catch
                println("Can not access site")
            end

        end
    end

    return filtered_urls


end
"
Add

    if login required --> remove urls that produce a negative login 

"



# #LOGIN Functionality ?
# login_username = []
# login_password = []



function extract_company(tables, body_data)
    "
    Function: extracts company rankings from table data
    Returns: produces list of companies 
    
    "

    company_list = []

    # Extract Company Names from body if NO Table
    if length(tables) == 0

        found_companies = []
        for target in body_data[1]
            if target in commodities
                target = lowercase(target)
                push!(found_companies, target)
            end
        end


        push!(company_list, found_companies)

    end


    # Extract Company Names from Table
    if length(tables) != 0

        for i in range(1, length(tables)) # for each table in tables

            columns_to_keep = []
            data = tables[i]

            column_names = names(tables[i])
            # println(column_names)

            for column in column_names
                if any(item -> item in commodities, data[!, column]) # comparing to reference list
                    data[!, column] = [lowercase(s) for s in data[!, column]] # converts company output to lowercase

                    push!(columns_to_keep, data[!, column])
                end



            end

            push!(company_list, columns_to_keep)

        end

    end

    "conversion of company names to lowercase is for uniformity"



    return company_list

end
"Add
    Change to Check the first 4 letter in the string 
    for company name and not entire string

    Fix list structure
"

function extract_c_rank(rankings)
    "
    Function: produces weighed master ranking from link of companies
    Returns: company master ranking
    
    "


    "from body Information create list of companies in the order they appear
    Count the number of occurrences of a certain company name 
    Rank all number 1s first then arrange number 1 based on occurrence 
    Then repeat for every rank checking
    make sure there are no repetitions"


    # -----------------------------------------------------------------------------
    # Number of Occurrences per String
    # -----------------------------------------------------------------------------

    # Create an empty dictionary to store counts
    record = Dict{String,Int}()

    # Loop through the nested lists and count occurrences
    for sublist in rankings

        flattened_list = vcat(sublist...) #flatten list

        for item in flattened_list
            if haskey(record, item)

                record[item] += 1

            else
                record[item] = 1
            end
        end
    end



    # -----------------------------------------------------------------------------
    # Company Rankings from Website
    # -----------------------------------------------------------------------------



    # -----------------------------------------------------------------------------
    # Accounting for Website Traffick 
    # -----------------------------------------------------------------------------

    "Accounting for Website Traffick
    https://www.similarweb.com/

    decide wether to put here or add to url extractoin output!

    "


    # -----------------------------------------------------------------------------
    # Final Evaluation
    # -----------------------------------------------------------------------------



end





############################################################### PART 3: Data Utilization 

"Sentiment Functions:

    The Sentiment Functions should have the ability to train a model and detect the
    sentiment of the given data set, classifying it as Positive, Negative or Neutral

        1: Build Model
        2: Train Model and Determine Accuracy

            # The process above will be rountinely repeated making adjustments
              for incorrect predictions till set accuracy is achielved 

        3: Predict Sentiment of Title and Body with Model
    


"



# Model 1 - Words Sentiment

function sentiment_words(words)
    "
    Function: intakes a list of words and finds the sentiment of each word
    Return: Positive or Negative judgment on list of words

    "


end


# Model 2 - Sentence Senitment

function sentiment_sentence()
    #

end



function sentiment()
    "applies all sentiment functions to the body & title then produces a final judgment"

end


function do_nothing()
    #
end





################################################################################
#-------------------------------------------------------------------------------
# TESTING STAGES
#-------------------------------------------------------------------------------
################################################################################



## 1. Initial Search for Companies
query = "stock markets most profitable companies"

### - Obtain Search Result URLS
search_data_raw = google_search(query)
search_data_parsed = parsehtml(String(search_data_raw))
body = search_data_parsed.root[2]

urls = extract_url(body)
"Add: 
    urls that produce a negative login 

    more pages of the search engine

    remove urls that return 404 message
    
"


### - Obtain List of Companies
status, response = request_access(urls, 1)
title_data, body_data, tables = extraction(status, response)

commodities = ["AppleAPPL", "WalmartWMT", "APPLE", "Apple",
    "Microsoft Corporation",
    "Amazon.com",
    "Alphabet",
    "Facebook",
    "Tesla",
    "Berkshire Hathaway",
    "Johnson & Johnson",
    "JPMorgan Chase",
    "Procter & Gamble",
    "Visa",
    "Walmart",
    "Mastercard Incorporated",
    "UnitedHealth Group Incorporated",
    "Home Depot",
    "Verizon Communications",
    "Coca-Cola Company",
    "Adobe",
    "NVIDIA Corporation",
    "Pfizer",
    "Walt Disney Company",
    "McDonald's Corporation",
    "Netflix",
    "AT&T",
    "Salesforce",
    "PayPal Holdings",
    "ASML Holding N.V.",
    "Cisco Systems",
    "Comcast Corporation",
    "PepsiCo",
    "Intel Corporation",
    "Costco Wholesale Corporation",
    "Amgen",
    "Zoom Video Communications",
    "Charter Communications",
    "Starbucks Corporation",
    "Baidu",
    "Broadcom",
    "Milk", "Coca", "Sugar", "Sugar"
]
"Include more company name variations"

companies = extract_company(tables, body_data)
println(companies)



"from list of companies..."




## 2. Initial Search for News on Company 1...
"Search and Extract Article Coverage and Social Media Coverage
Pull Financial Data from set sources 
Pull past stock Information from set sources
"

# ~ARTICLE COVERAGE~
query = "#company1 news"

### - Obtain Search Result URLS
### - Obtain Sentiment About Company from each article


# ~SOCIAL MEDIA COVERAGE~

### - Obtain API Result ?**
### - Obtain Sentiment About Company from each article


# ~FINANCIAL DATA~

### - Obtain Data from Source
### - Obtain Sentiment/Financial Analysis 


# ~PREVIOUS STOCK ACTIVITY~

### - Obtain Activity from Source
### - Obtain Volitility Rating (and other data) from Analysis


# ... REPEAT FOR ALL COMPANIES 


#-------------------------------------------------------------------------------


## Loading Data
    #-----------------------------------------------------------------------

    ### Training Data 1
    file_1 = "stock_data.csv"
    df_1 = DataFrame(CSV.File(file_1))

    vscodedisplay(df_1)

    negative_1 = filter(row -> row.Sentiment == -1, df_1)[!, :Text]
    positive_1 = filter(row -> row.Sentiment == 1, df_1)[!, :Text]



    ### Training Data 2
    file_2 = "data.csv"
    df_2 = DataFrame(CSV.File(file_2))
    vscodedisplay(df_2)

    negative_2 = filter(row -> row.Sentiment == "negative", df_2)[!, :Sentence]
    positive_2 = filter(row -> row.Sentiment == "positive", df_2)[!, :Sentence]
    # neutral_2 = filter(row -> row.Sentiment == "neutral", df_2)[!, :Sentence]


    ### Training Data 3
    file_3 = "tweet_data.csv"
    df_3 = DataFrame(CSV.File(file_3))
    vscodedisplay(df_3)


    negative_3 = filter(row -> row.Sentiment == 0, df_3)[!, :Sentence]
    positive_3 = filter(row -> row.Sentiment == 4, df_3)[!, :Sentence]


positive = vcat(positive_1, positive_2, positive_3)
negative = vcat(negative_1, negative_2, negative_3)

# add code that shuffles the content to improve testing


## Cleaning
p_clean = copy(positive)
n_clean = copy(negative)

    for i in range(1, length(positive))
        
        sd = StringDocument(p_clean[i])
        prepare!(sd, strip_punctuation| strip_articles| strip_definite_articles| strip_indefinite_articles| strip_pronouns| strip_html_tags)
        p_clean[i] = sd.text

    end

    for i in range(1, length(negative))
        
        sd = StringDocument(n_clean[i])
        prepare!(sd, strip_punctuation| strip_articles| strip_definite_articles| strip_indefinite_articles| strip_pronouns| strip_html_tags)
        n_clean[i] = sd.text

    end

\


## Division

\
    "training"
    ### Clean
    positive_train = p_clean[1:20000]
    negative_train = n_clean[1:20000]

    ### Un-Clean
    positive_train_d = positive[1:20000]
    negative_train_d = negative[1:20000]


    "testing"
    ### Clean
    positive_test = p_clean[20000:40000]
    negative_test = n_clean[20000:40000]

    ### Un-Clean
    positive_test_d = positive[20000:40000]
    negative_test_d = negative[20000:40000]

\


#======================================================#
## Bayes Classifier Method
#======================================================#


Pkg.add("TextAnalysis")
using TextAnalysis
using TextAnalysis: NaiveBayesClassifier, fit!, predict

## Initialisations
classes = [:positive, :negative]
model_1 = NaiveBayesClassifier(classes)
model_2 = NaiveBayesClassifier(classes)
model_3 = NaiveBayesClassifier(classes)
model_4 = NaiveBayesClassifier(classes)

### how would the inclusion of a neutral class affect results


## Training & Testing
#======================================================#



### 20k Clean [1]

### 20k Un-Clean [2]


### 70k Clean [3]

### 70k Un-Clean [4]
for i in positive[1:70000]
    fit!(model, i, :positive)
end
for i in negative[1:70000]
    fit!(model, i, :negative)
end




# Utilization & Evaluation
sentiment = predict(model, " ")

sentiment[:negative]




""" 
if the difference between positive and negative values isnt greater than a certain value
it can be classified as neutral.

how much data is needed to train a good sentiment analysis model 

Models to have:
Trained with Clean [80000]

Trained with Clean [30000]
Trained with UnClean [30000]

seperate Algorithm that sorts extremely positive and extremely negative & neutral 
into a "news stream" to be used by the front end. include engagement data

seperate algorithm to extract company name from string and sentiment of string

seperate algorithm to detect keep business phrases like short include in sentiment decision 




"""


## KNN & K-d trees
""" How would you apply this tool"""
#study text analysis library structure

## Neural Networks [RNNs & LSTMs]
""" How would you apply this tool"""



