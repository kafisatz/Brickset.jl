
export bringcolumnstotheleft!
function bringcolumnstotheleft!(df::DataFrame,cols::Vector{Symbol})
    #df=deepcopy(brmsdf)
    #cols=[:data,:resultado]
    nms=propertynames(df)
    if !issubset(cols,nms)
        for c in cols
            if !in(c,nms)
                @show c
            end
        end
        error("bringcolumnstotheleft: Some columns were not found in DataFrame")
    end
    @assert issubset(cols,nms)

    have=cols
    donthave=setdiff(nms,cols)
    select!(df,vcat(have,donthave))
return nothing

end
bringcolumnstotheleft!(df::DataFrame,cols::String)=bringcolumnstotheleft!(df,vcat(cols))
bringcolumnstotheleft!(df::DataFrame,cols::Symbol)=bringcolumnstotheleft!(df,vcat(cols))
bringcolumnstotheleft!(df::DataFrame,cols::Vector{String})=bringcolumnstotheleft!(df,Symbol.(cols))
