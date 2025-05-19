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
setjs = vcat(setjs1,setjs2,setjs3)
dfsets = setsToDataFrame(setjs); size(setjs)

bringcolumnstotheleft!(dfsets,[:numberVariant,:released,:packagingType,:additionalImageCount,:year,:availability,:setID,:number])

CSV.write(joinpath(ENV["USERPROFILE"],"OneDrive - K","Dateien","Lego","brickset","sets.csv"),dfsets)

#=
#insert with phpmyadmin
#or try MySQL.load(table, conn, table_name) 

mysqlpassword = ENV["MYSQLPASSWORD"]
mysqlusername = "root"
mysqlhost = "10.14.15.106"

#get setID from mysql db
conn = DBInterface.connect(MySQL.Connection,mysqlhost, mysqlusername, mysqlpassword, db="brick")
dfsets = DBInterface.execute(conn, "select * from sets") |> DataFrame
disallowmissing!(dfsets)

setiddict = Dict(zip(dfsets.number,dfsets.setID))
#add setID to sets
map(x->setiddict[x],sets.set_no) #check for errors
sets.setID = map(x->setiddict[x],sets.set_no)
 
#own these sets (adds sets to brickset collection)
map(setid->setCollection(apikey,userhash,setid,"{'own':1}"),sets.setID)

=#