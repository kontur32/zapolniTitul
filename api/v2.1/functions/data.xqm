module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config" at "../config.xqm";

declare variable $data:dbName as xs:string := $config:param( "dbName" );

declare 
  %public
function data:templateData (
  $templateID as xs:string,
  $params as map(*)
) as element( data ) {
   let $templateOwner := 
      db:open( $data:dbName, "forms" )
      /forms/form[ @id= $templateID ]/@userid/data()
   let $rows := 
     if( $templateOwner = $params?userID )
     then(
       db:open( $data:dbName, "data" )
       /data/table[ @templateID = $templateID ]/row
     )
     else(
       db:open( $data:dbName, "data" )
       /data/table[ @templateID = $templateID and @userID = $params?userID ]/row
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
        let $ids := 
          distinct-values( $rows/@id )[ position() >= $params?starts and position() <= ( $params?starts + $params?limit - 1 ) ]
        let $rows := 
           for $i in $ids 
           let $b := $rows[ @id = $i ]
           return 
            $b[ last() ]
            
        return
          element { "data" }{
            element { "table" } {
             attribute { "total" } { count( $rows ) },
             attribute { "starts" } { $params?starts },
             attribute { "limit" } { $params?limit },
               for $r in $rows
               order by $r/cell[ @id = $params?orderby ]
               return
                 $r
           }
         }
      )
};