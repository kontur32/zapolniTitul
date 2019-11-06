module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config" at "../config.xqm";

declare variable $data:dbName as xs:string := $config:param( "dbName" );

declare 
  %public
function data:templateData
(
  $templateID as xs:string,
  $params as map(*)
) as element( data )
{
   let $templateOwner := 
      db:open( $data:dbName, "forms" )
      /forms/form[ @id= $templateID ]/@userid/data()
   let $rows := 
     if( $templateOwner = $params?userID )
     then(
       db:open( $data:dbName, "data" )
       /data/table[ @templateID = $templateID ][ empty( @status ) or ( @status != "delete" ) ]/row
     )
     else(
       db:open( $data:dbName, "data" )
       /data/table[ @templateID = $templateID and @userID = $params?userID ]
       [ empty( @status ) or ( @status != "delete" ) ]/row
     )
     [
       if( $params?about != "" )
       then( @id/data() = $params?about )
       else( true() )
     ]
   return
     if( $params?mode = "full" )
     then(
       element{ "data" }{
          element { "table" } {
            attribute { "total" } { count( $rows ) },
            $rows
          }
        }
      )
      else(
        let $rowsOrdered := 
          for $i in distinct-values( $rows/@id )
          let $r := $rows[ @id = $i ][ last() ]
          order by $r/cell[ @id = $params?orderby ]/text() ascending
          return 
            $r
        let $rowsForOutput := 
          $rowsOrdered[
            position() >= $params?starts and position() <= ( $params?starts + $params?limit - 1 )
          ]
        return
          element { "data" }{
            element { "table" } {
             attribute { "total" } { count( $rowsOrdered ) },
             attribute { "starts" } { $params?starts },
             attribute { "limit" } { $params?limit },
             attribute { "orderby" } { $params?orderby },
               for $r in $rowsForOutput
               return
                  $r update insert node attribute { "containerID" } { $r/parent::*/@id/data() } into .
           }
         }
      )
};