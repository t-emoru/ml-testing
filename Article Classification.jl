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



############################################################### PART 1: Finding URLs

"
Function:

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


function url_extract(body)

    "
    Function: extraxts url from html content
    Return: Clean Urls [contain names of companies to be traded]
    
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



############################################################### PART 2:  Utilising URLs
"
Function: 
Now that we have names of companies/commodities, search for news regrading
them.
.

    1. Request URL Access
    2. Extract & Package Information
    3. Train Model
    4. Inquire Amount of Article Traffic

"


#LOGIN Functionality
login_username = []
login_password = []


#COMMENT "DONE" FUNCTIONS

function request_access(urls, link)

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



function extraction(status, response)

    title_list = []
    body_list = []
    table_list = []

    if status == 1
        global title_list
        global body_list
        global table_list

        html_content = String(HTTP.body(response))

        ##Packaging Data
        parsed_article = parsehtml(html_content)


        ## Finidng words of Title
        title_list = []
        title_element = eachmatch(Selector("title"), parsed_article.root)

        for element in title_element
            title = split(text(element), r"\s+") # Split the text into words using whitespace
            append!(title_list, title)
        end




        ## Finding words of Body
        body_list = []
        body_elements = eachmatch(Selector("p"), parsed_article.root)

        for element in body_elements
            body = split(text(element), r"\s+") # Split the text into words using whitespace
            append!(body_list, body)
        end





        ## Finding Tables & other Data points
        body = parsed_article.root[2]
        table_data_raw = eachmatch(sel"table", body) #returns table data. NOW CLEAN !!


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


        "still need cleaning up and reformating before usage :/ "



    else
        println("Access Denied")
    end

    return title_list, body_list, table_list
end



function commodity_extraction(urls)
    "
    Funtion: 
        Version 1 - 
    
        1) From the first column of companies from data extraction
            Verfity strings are actually companies
            If Yes, push to commodities list

        
    
    "

end



#-------------------------------------------------------------------------------


# Getting Link
query = "stock markets most profitable companies"

search_data_raw = google_search(query)
search_data_parsed = parsehtml(String(search_data_raw))

body = search_data_parsed.root[2]
urls = url_extract(body)



#Using Link
status, response = request_access(urls, 3)
title_list, body_list, tables = extraction(status, response)



#-------------------------------------------------------------------------------





############################################################### PART 3: Developing & Utilsing Models
"Function:


"



###Training Model -Sentiment Analysis

# Model 1 - Detecting Postive Words


# Model 2 - Detecting positive phrases/simple sentence [that indicate potential business benefit]

