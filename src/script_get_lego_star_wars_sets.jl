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

savedir1 = joinpath(ENV["USERPROFILE"],"OneDrive - K","Dateien","Lego","brickset")
if isdir(savedir1)
    CSV.write(joinpath(savedir1,"sets.csv"),dfsets_brickset)
end

pt0 = pkgdir(Brickset)
savedir2 = joinpath(pt0,"data")
@assert isdir(savedir2)
CSV.write(joinpath(savedir2,"sets.csv"),dfsets_brickset)

#add this to bricklink set_list
new_set = filter(x->x.year >= 2025,dfsets_brickset).number
