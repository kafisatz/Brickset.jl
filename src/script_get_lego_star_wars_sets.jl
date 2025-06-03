#:number => normal let set number
#:setID => id as per Brickset

using Revise; using Brickset;import CSV; using DataFrames; using JSON3; using HTTP; using MySQL
#credentials
fldr = ENV["USERPROFILE"]; fi = joinpath(fldr,"authbrickset.json")
@assert isfile(fi)
credentials = JSON3.read(fi); apikey = credentials["apikey"]; username = credentials["username"]; password = credentials["password"];
#login
userhash = login(username, password,apikey)
@assert checkUserHash(userhash,apikey)

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

CSV.write(joinpath(ENV["USERPROFILE"],"OneDrive - K","Dateien","Lego","brickset","sets.csv"),dfsets_brickset)

