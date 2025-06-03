#list of sets
pt = pathof(Brickset)
fi = normpath(joinpath(pt,"..","set_have.txt"))
sets = CSV.read(fi,DataFrames.DataFrame,header=false)
DataFrames.rename!(sets,Dict(1=>"set_no")); sets.set_no .= convert(Vector{String},strip.(string.(sets.set_no)))
unique!(sets)


sets[!,:have] .= 1 #set all to have
rename!(sets,Dict(:set_no=>"number_as_string"))

CSV.write(joinpath(ENV["USERPROFILE"],"OneDrive - K","Dateien","Lego","brickset","set_have.csv"),sets)