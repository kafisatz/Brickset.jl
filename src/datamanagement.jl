
export setsToDataFrame
function setsToDataFrame(setjs)
    df = DataFrame()
    for i=1:size(setjs,1)        
        df0 = setsToDataFrame_single_row(setjs[i])
        append!(df,df0)
    end

    return df 
end

export setsToDataFrame_single_row
function setsToDataFrame_single_row(setsjsrow)
    #setsjsrow = setjs[i]
    df0 = DataFrame()

    default_when_missing = Dict(:numberVariant=>0,:released=>false,:packagingType=>"",:additionalImageCount=>0,:year=>0,:availability=>"",:setID=>0,:theme=>"",:category=>"",:subtheme=>"",:pieces=>0,:lastUpdated=>"",:name=>"",:instructionsCount=>0,:minifigs=>0,:themeGroup=>"",:reviewCount=>0,:rating=>0.0,:number=>"",:bricksetURL=>"")

    for k in [:numberVariant,:released,:packagingType,:additionalImageCount,:year,:availability,:setID,:theme,:category,:subtheme,:pieces,:lastUpdated,:name,:instructionsCount,:minifigs,:themeGroup,:reviewCount,:rating,:number,:bricksetURL]
        if k in keys(setsjsrow)
            df0[!,k] = [setsjsrow[k]]
        else
            df0[!,k] = [default_when_missing[k]]            
        end
    end

    df0[!,:dimensions_height] .= float.(get(setsjsrow[:dimensions],:height,0.0))
    df0[!,:dimensions_width] .= float.(get(setsjsrow[:dimensions],:width,0.0))
    df0[!,:dimensions_depth] .= float.(get(setsjsrow[:dimensions],:depth,0.0))

    df0[!,:barcode_EAN] .= get(setsjsrow[:barcode],:EAN,"")
    df0[!,:barcode_UPC] .= get(setsjsrow[:barcode],:UPC,"")
    ks = sort(string.(collect(keys(setsjsrow[:barcode]))))
    if !issubset(ks,["EAN","UPC"])
        @show df0.number
        @show df0.setID
        @show ks
    end

    df0[!,:thumbnailURL] .= get(setsjsrow[:image],:thumbnailURL,"")
    df0[!,:imageURL] .= get(setsjsrow[:image],:imageURL,"")

    return df0 
end