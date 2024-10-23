let
    func = (Consulta as table) as table => let
        // Invocación de la función Table.Profile sobre la consulta recibida
        Origen = Table.Profile(Consulta),
        // Nos quedamos con las columnas que necesitamos
        #"Selección de columnas" = Table.SelectColumns(Origen,{"Column", "Count", "NullCount", "DistinctCount"}),
        #"Ajuste de tipo de datos" = Table.TransformColumnTypes(#"Selección de columnas",{{"NullCount", Int64.Type}, {"DistinctCount", Int64.Type}
    }),
        #"Renombrado de columnas" = Table.RenameColumns(#"Ajuste de tipo de datos",{{"Column", "Columna"}, {"Count", "Total de registros"}, {"NullCount", "Total de nulos"}, {"DistinctCount", "Valores únicos"}}),
        // Adición de la columna % de nulos sobre el total tras dividir Total de nulos entre Total de registros. El tipo de la columna se especifica dentro del paso
        #"Añadir % de nulos" = Table.AddColumn(#"Renombrado de columnas", "% de nulos sobre el total", each ([Total de nulos] / [Total de registros]) * 100, type number),
        // Adición de la columna % de únicos sobre el total tras dividir Valores únicos entre Total de registros. El tipo de la columna se especifica dentro del paso
        #"Añadir % de únicos" = Table.AddColumn(#"Añadir % de nulos", "% de únicos sobre el total", each ([Valores únicos] / [Total de registros]) * 100, type number),
        // Adición de la columna control nulos en base a los resultados arrojados por el % de nulos sobre el total. El tipo devuelto se especifica en la consulta
        #"Añadir Control nulos" = Table.AddColumn(#"Añadir % de únicos", "Control nulos", each if [#"% de nulos sobre el total"] > 5 then "Revisar valores nulos" else "Aceptable", type text),
        // Adición de la columna control únicosen base a los resultados arrojados por el % de únicos sobre el total. El tipo devuelto se especifica en la consulta
        #"Añadir Control únicos" = Table.AddColumn(#"Añadir Control nulos", "Control únicos", each if [#"% de únicos sobre el total"] < 100 then "Revisar valores únicos" else "Aceptable", type text)
    in
        #"Añadir Control únicos",
documentation = [
Documentation.Name =  " Auditando a tope de Power ",
Documentation.Description = " Devuelve los resultados de auditoría para el valor de <code>Consulta</code> que se proporcione ",
Documentation.LongDescription = " Devuelve los resultados de auditoria para el valor de <code>Consulta</code> que se proporcione, incluyendo las columnas adicionales definidas sobre los resultados de la función Table.Profile  ",
Documentation.Category = " Table ",
Documentation.Source = " . https://github.com/l2aFa/verneSummitAlgodon . ",
Documentation.Version = " 1.0 ",
Documentation.Author = " Rafael Báguena ",
Documentation.Examples = {[Description =  " Devuelve una tabla con las estadísticas de cada una de las columnas de la consulta proporcionada ",
Code = " GoGoAuditRangers ( NombreConsulta ) ",
Result = " //  Columna| Total de registros| Total de nulos| Valores únicos| 
{//---------|-------------------|---------------|---------------|  
{     ""XXXX""        999               999              999      }, 
{     ""XXXX""        999               999              999      } )   "]}]
 in  
  Value.ReplaceType(func, Value.ReplaceMetadata(Value.Type(func), documentation))