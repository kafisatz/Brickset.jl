export database_insertintotable
export database_insertstatement

function database_insertstatement(
    connection::MySQL.DBInterface.Connection,
    tablename::AbstractString,
    columns::AbstractVector{<:AbstractString};
    primarykeys::AbstractVector{<:AbstractString}=[""],
    batch::Bool=false,
    batch_size::Int=1000
    )
    fields = "(" * join(columns, ",") * ")"
    value_row = "(" * join(map(x -> "?", columns), ",") * ")"
    value_update = join(map(x -> x * " = VALUE(" * x * ")", setdiff(columns, primarykeys)), ",")

    if batch
        values = join([value_row for x = 1:batch_size], ", ")
    else
        values = value_row
    end

    sql = (
        "INSERT INTO " * tablename * " " * fields * " VALUES " * values
        * " ON DUPLICATE KEY UPDATE " * value_update * ";"
    )
    
    return MySQL.DBInterface.prepare(connection, sql)
end

function database_insertintotable(
    connection::MySQL.DBInterface.Connection,
    tablename::AbstractString,
    datatoinsert::AbstractDataFrame;
    primarykeys::AbstractVector{<:AbstractString}=[""],
    batch::Bool=false,
    batch_size::Int=1000
    )
    if batch
        batch_statement = database_insertstatement(
            connection, tablename, names(datatoinsert);
            primarykeys=primarykeys, batch=batch, batch_size=batch_size
        )
        rows = collect(eachrow(datatoinsert))

        MySQL.transaction(connection) do
            MySQL.DBInterface.execute(connection, "SET autocommit=0")
            for iter_batch in partition(rows, batch_size)          
                iter_values = iter_batch |> x -> Vector.(x) |> x -> vcat(x...)
                if length(iter_batch) == batch_size
                    MySQL.DBInterface.execute(batch_statement, iter_values)
                else
                    special_batch_statement = database_insertstatement(
                        connection, tablename, names(finaldata);
                        primarykeys=primarykeys, batch=batch, batch_size=length(iter_batch)
                    )
                    MySQL.DBInterface.execute(special_batch_statement, iter_values)
                    MySQL.DBInterface.close!(special_batch_statement)
                end
                sleep(0.001)
            end
            MySQL.DBInterface.execute(connection, "COMMIT;")
        end

        MySQL.DBInterface.close!(batch_statement)
    else
        statement = database_insertstatement(
            connection, tablename, names(datatoinsert);
            primarykeys=primarykeys
        )

        MySQL.transaction(connection) do
            for row in eachrow(datatoinsert)
                MySQL.DBInterface.execute(statement, row)
            end
        end
        MySQL.DBInterface.close!(statement)
    end
    return nothing
end