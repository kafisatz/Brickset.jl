export getSets
export setCollection
export login

function login(username, password,apikey)
    url = "https://brickset.com/api/v3.asmx/login"
    bdy = Dict{String,String}("password" => password, "username" => username, "apiKey" => apikey)
    hdr = Dict("Content-Type"=>"application/x-www-form-urlencoded")

    res = HTTP.request("POST", url, headers=hdr, body=bdy)
    js = JSON3.read(IOBuffer(res.body))
    @assert js["status"] == "success"
    return js["hash"]
end

export checkUserHash
function checkUserHash(userhash,apikey)
    url = "https://brickset.com/api/v3.asmx/checkUserHash"
    bdy = Dict{String,String}("apiKey" => apikey, "userHash" => userhash)
    hdr = Dict("Content-Type"=>"application/x-www-form-urlencoded")

    try 
        res = HTTP.request("POST", url, headers=hdr, body=bdy)
        js = JSON3.read(IOBuffer(res.body))
        @assert js["status"] == "success"
        return true
    catch e 
         @show e
        return false
    end
end


"""
setCollection: Set a user's collection details.
own	1 or 0. If 0 then qtyOwned is automatically set to 0
want	1 or 0
qtyOwned	0-999. If > 0 then own is automatically set to 1
notes	User notes, max 1000 characters
rating	User rating 1-5
"""
function setCollection(apikey,userhash,setid::Int64,params="")
    #params = "{'own':1}"
    #setid="75274"
    url = "https://brickset.com/api/v3.asmx/setCollection"
    bdy = Dict("userHash" => userhash, "apiKey" => apikey,"SetID"=>setid,"params"=>params)
    hdr = Dict("Content-Type"=>"application/x-www-form-urlencoded")

    try
        res = HTTP.request("POST", url, headers=hdr, body=bdy)
        js = JSON3.read(IOBuffer(res.body))
        @assert js["status"] == "success"
    catch e
        @show setid
        println(e)        
    end

    return nothing 
end




function getSets(apikey,userhash,setid,params="";pageNumber=1,theme="star wars",pageSize=500,orderBy="Number")
    #pageSize	Specify how many records to retrieve (default: 20, max: 500)
    #pageNumber	Specify which page of records to retrieve, use in conjunction with pageSize (default: 1)
    #pageNumber = 1;theme="star wars";
    pageSize = 500
    orderBy = "Number"

    params = "{'theme':'$theme','pageSize':$pageSize,'pageNumber':$pageNumber,'orderBy':'$orderBy'}"
    
    url = "https://brickset.com/api/v3.asmx/getSets"
    bdy = Dict("userHash" => userhash, "apiKey" => apikey,"params"=>params)
    hdr = Dict("Content-Type"=>"application/x-www-form-urlencoded")
    #query
    res = HTTP.request("POST", url, headers=hdr, body=bdy)
    js = JSON3.read(IOBuffer(res.body))
    sets0 = copy(js["sets"]) #copy is needed to make this mutable
    size(sets0)
    typeof(sets0)
    nmatches = js["matches"]

    while pageNumber * pageSize < nmatches
        pageNumber += 1
        params = "{'theme':'$theme','pageSize':$pageSize,'pageNumber':$pageNumber,'orderBy':'$orderBy'}"
        bdy = Dict("userHash" => userhash, "apiKey" => apikey,"params"=>params)
        res = HTTP.request("POST", url, headers=hdr, body=bdy)
        js = JSON3.read(IOBuffer(res.body))
        sets = copy(js["sets"])
        append!(sets0,sets)        
    end

    size(sets0)
    if size(sets0)[1] != nmatches
        @warn "Number of sets does not match number of matches"
    end

    return sets0
end
