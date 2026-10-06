#:number => normal let set number
#:setID => id as per Brickset

using Revise; using Brickset;import CSV; using DataFrames; using JSON3; using HTTP; using MySQL
#credentials
fldr = homedir(); fi = joinpath(fldr,"authbrickset.json")
@assert isfile(fi); json_text = read(fi, String)   # file is opened, read, and closed
credentials = JSON3.read(json_text); apikey = credentials["apikey"]; username = credentials["username"]; password = credentials["password"];
#login
userhash = login(username, password,apikey)
@assert checkUserHash(userhash,apikey)
#request new API key (it is automatic, usually takes 1 minute)
#https://brickset.com/tools/webservices/requestkey

#get set IDs from brickset

setjs1 = getSets(apikey,userhash,"",pageNumber=1,theme="Star Wars",pageSize=500,orderBy="Number"); size(setjs1)
setjs2 = getSets(apikey,userhash,"",pageNumber=1,theme="BrickHeadz",pageSize=500,orderBy="Number"); size(setjs2)
setjs3 = getSets(apikey,userhash,"",pageNumber=1,theme="seasonal",pageSize=500,orderBy="Number"); size(setjs3)
setjs = vcat(setjs1)
setjs = vcat(setjs1,setjs2,setjs3)
dfsets_brickset = setsToDataFrame(setjs); size(setjs)
#:number => normal let set number
#:setID => id as per Brickset

bringcolumnstotheleft!(dfsets_brickset,[:numberVariant,:released,:packagingType,:additionalImageCount,:year,:availability,:setID,:number])

try 
    savedir1 = joinpath(ENV["USERPROFILE"],"OneDrive - K","Dateien","Lego","brickset")
    if isdir(savedir1)
        CSV.write(joinpath(savedir1,"sets.csv"),dfsets_brickset)
    end
catch 
    savedir1 = ""
end

pt0 = pkgdir(Brickset)
savedir2 = joinpath(pt0,"data")
@assert isdir(savedir2)
CSV.write(joinpath(savedir2,"sets.csv"),dfsets_brickset)

#add this to bricklink set_list
new_set = filter(x->x.year >= 2025,dfsets_brickset).number

#set list  have in Bricklink.jl
pt00 = pkgdir(Brickset)
pt_bricklink = normpath(joinpath(pt00,".."),"BrickLink.jl")
@assert isdir(pt_bricklink)
fi = normpath(joinpath(pt_bricklink,"src","set_list.txt"))
@assert isfile(fi)
set_list_bricklink = CSV.read(fi, DataFrame, header=false)
DataFrames.rename!(set_list_bricklink, Dict(1=>"set_no"))
set_list_bricklink.set_no .= convert(Vector{String}, strip.(string.(set_list_bricklink.set_no)))
unique!(set_list_bricklink)

#add all set no that we have in dfsets_brickset.number
hv = deepcopy(dfsets_brickset.number)
#discard everything that is not numeric, e.g "LJXMAS02" should be disccarded
hv = filter(x -> all(isdigit, x), hv)
#discard everything with more than 5 characters 
hv = filter(x -> length(x) <= 5, hv)

#add the remaining set numbers to the bricklink set list
append!(set_list_bricklink.set_no, hv)
unique!(set_list_bricklink)
@show length_before = length(set_list_bricklink.set_no)
@show length_after = length(unique(set_list_bricklink.set_no))
CSV.write(fi, set_list_bricklink)

"75453" in set_list_bricklink.set_no
"75458" in set_list_bricklink.set_no