
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

    "Change to return sentences?"



    title_sentence = []
    title_word = []

    body_sentence = []
    body_word = []

    table_list = []
    df_list = []


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

    title_data = [title_word, title_sentence]
    body_data = [body_word, body_sentence]

    return title_data, body_data, df_list

end


function extraction_url(body)

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


# #LOGIN Functionality ?
# login_username = []
# login_password = []



function extraction_company(tables, body_data)
    "
    Funtion: 
        Delete tables that do not have company names

        1) From the first column of companies from data extraction
            Verfity strings are actually companies
            If Yes, push to commodities list
            Only take first 4 letters of “company name”

        This serves to create a master list of the companies in rank


    "

    rankings_list = []

    # Extract Company Names from body if NO Table
    if length(tables) == 0

        found_companies = []
        for target in body_data[1]
            if target in commodities
                target = lowercase(target)
                push!(found_companies, target)
            end
        end


        push!(rankings_list, found_companies)

    end


    # Extract Company Names from Table
    if length(tables) != 0

        for i in range(1, length(tables))

            columns_to_keep = []
            data = tables[i]

            column_names = names(tables[i])

            for column in column_names
                if any(item -> item in commodities, data[!, column])
                    data[!, column] = [lowercase(s) for s in data[!, column]]

                    push!(columns_to_keep, data[!, column])
                end

            end

            push!(rankings_list, columns_to_keep)

        end

    end


    # Master Ranking


    return rankings_list

end

function company_rank(rankings)
    #
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

        flattened_list = vcat(sublist...)

        for item in flattened_list
            if haskey(record, item)

                record[item] += 1

            else
                record[item] = 1
            end
        end
    end


    # -----------------------------------------------------------------------------
    # Webiste Rankings
    # -----------------------------------------------------------------------------




    # -----------------------------------------------------------------------------
    # Final Evaluation
    # -----------------------------------------------------------------------------



end



# Inquire Amount of Article Traffic
# Inquire Article Creation Day




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

function sentiment_words()
    #

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

urls = extraction_url(body)
"Add: 
    Try other method of extracting url***  

    feature that removes duplicate urls
    urls that require login
    urls that produce a negative login 

    more pages of the search engine

    remove urls that return 404 message
    
"


### - Obtain List of Companies
status, response = request_access(urls, 2)
title_data, body_data, tables = extraction(status, response)
rankings = extraction_company(tables, body_data)
"Add:

    Create list of companies to compare too***

    if no table data --> if no 'table of content'   -->  
    if not scan through body data for company names 


    Chekc if first column contains company name --> if not delete
    if contains company name --> Create ranking in 1st column & push names to 2nd



"

println(rankings)

"from list of companies..."
commodities = ["APPLE", "Apple",
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

### - Obtain API Result 
### - Obtain Sentiment About Company from each article


# ~FINANCIAL DATA~

### - Obtain Data from Source
### - Obtain Sentiment/Financial Analysis 


# ~PREVIOUS STOCK ACTIVITY~

### - Obtain Activity from Source
### - Obtain Volitility Rating (and other data) from Analysis




#-------------------------------------------------------------------------------

# Creating Master Rankings




