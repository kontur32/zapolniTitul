module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config" at "../config.xqm";

declare variable $data:dbName as xs:string := $config:param( "dbName" );

declare variable $data:forms := function( ) {
   db:open( $data:dbName, "forms" )/forms
};

declare variable $data:form := function( $id as xs:string ) {
    $data:forms()/form[ @id = $id ]
};

declare variable $data:userData := function( $id as xs:string ) {
    db:open( $data:dbName, "data")/data/table[ @userID = $id ]
};


declare 
  %private
function data:templateData ( $templateID as xs:string ) as element( data ) {
  let $rows := 
    db:open( $data:dbName, "data" )/data/table[ @templateID = $templateID ]/row
  return
    element{ "data" }{
      element { "table" } {
        attribute { "total" } { count( $rows ) },
        $rows
      }
    }
};

declare 
  %public
function data:templateData (
  $templateID as xs:string,
  $params as map(*)
) as element( data ) {
   let $templatesData := data:templateData( $templateID )
   return
     if( $params?mode = "full" )
     then(
       $templatesData
      )
      else(
        let $ids := distinct-values( $templatesData/table/row/@id )
        let $rows := 
           for $i in $ids [ position() >= $params?starts and position() <= $params?starts + $params?limit - 1 ]
           let $b := $templatesData/table/row[ @id = $i ]
           order by $b/cell[ @id = $params?orderby ][1]
           return 
            $b[ last() ]
        return
          element { "data" }{
            element { "table" } {
             attribute { "total" } { count( $rows ) },
             attribute { "starts" } { $params?starts },
             attribute { "limit" } { $params?limit },
             $rows
           }
         }
      )
};
