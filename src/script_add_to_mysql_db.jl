
#as per other script:
dfsets_brickset

mysqlpassword = ENV["mysqlpassword.55ip"]
mysqlusername = "root"
mysqlhost = "10.14.15.55"

#get setID from mysql db
conn = DBInterface.connect(MySQL.Connection,mysqlhost, mysqlusername, mysqlpassword, db="brick")
dfsets_in_DB = DBInterface.execute(conn, "select * from sets") |> DataFrame
disallowmissing!(dfsets_in_DB)

#:number => normal let set number
#:setID => id as per Brickset

@assert allunique(dfsets_in_DB.setID)
@assert allunique(dfsets_brickset.setID)

dfsets_need_to_add = filter(x->!(in(x.setID,Set(dfsets_in_DB.setID))),dfsets_brickset)

@assert size(dfsets_need_to_add,1) + size(dfsets_in_DB,1) == size(dfsets_brickset,1)

conn = DBInterface.connect(MySQL.Connection,mysqlhost, mysqlusername, mysqlpassword, db="brick")
MySQL.load(dfsets_brickset,conn,"sets",append=true)

setID_have
dfsets_brickset.set

setiddict = Dict(zip(dfsexxxxxxts.number,dfsexxxxxts.setID))
#add setID to sets
map(x->setiddict[x],sets.set_no) #check for errors
sets.setID = map(x->setiddict[x],sets.set_no)
 
#own these sets (adds sets to brickset collection)
map(setid->setCollection(apikey,userhash,setid,"{'own':1}"),sets.setID)




#insert with phpmyadmin
#or try MySQL.load(table, conn, table_name) 
