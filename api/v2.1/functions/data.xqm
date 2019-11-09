module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config" at "../config.xqm";

declare variable $data:dbName as xs:string := $config:param( "dbName" );

declare 
  %public
function data:templateData
(
  $templateID as xs:string,
  $params as map(*)
) as element( data )*
{  
   let $rows := data:rows( $templateID, $params )  
   let $result := 
     switch ( $params?mode )
     case "full" 
       return
         data:full-mode( $rows, $params )
     case "pagination"
       return
         data:maxID-mode( $rows, $params )
     default
       return
         data:base-mode( $rows, $params )
     
   return
     $result
};

declare function data:rows( $templateID as xs:string, $params as map(*) ){
   let $templateOwner := 
       db:open( $data:dbName, "forms" )
       /forms/form[ @id= $templateID ]/@userid/data()
   return 
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
};

declare function data:full-mode( $rows as element( row )*, $params as map(*) ){
    element { "data" }{
      element { "table" } {
       attribute { "total" } { count( $rows ) },
       attribute { "starts" } { $params?starts },
       attribute { "limit" } { $params?limit },
       attribute { "orderby" } { $params?orderby },
         for $r in $rows
         return
            element{ "row" }{
              $r/attribute::*,
              attribute { "containerID" } { $r/parent::*/@id/data() },
              attribute { "userID" } { $r/parent::*/@userID/data() },
              $r/child::*
            }
     }
   }
};


declare function data:base-mode( $rows as element( row )*, $params as map(*) ){
  let $rowsForOutput :=  data:ordered( $rows, $params )
          [
            position() >= $params?starts and position() <= ( $params?starts + $params?limit - 1 )
          ]
  return
    element { "data" }{
      element { "table" } {
       attribute { "total" } { count( $rows ) },
       attribute { "starts" } { $params?starts },
       attribute { "limit" } { $params?limit },
       attribute { "orderby" } { $params?orderby },
         for $r in $rowsForOutput
         return
            element{ "row" }{
              $r/attribute::*,
              attribute { "containerID" } { $r/parent::*/@id/data() },
              attribute { "userID" } { $r/parent::*/@userID/data() },
              $r/child::*
            }
     }
   }
};

declare function data:maxID-mode( $rows, $params ){
  data:ordered( $rows, $params )
};

declare function data:ordered( $rows as element( row )*, $params as map(*) ){
      for $i in distinct-values( $rows/@id )
      let $r := $rows[ @id = $i ][ last() ]
      order by $r/cell[ @id = $params?orderby ]/text() ascending
      return 
        $r
};