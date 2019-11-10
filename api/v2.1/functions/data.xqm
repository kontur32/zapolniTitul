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
   let $rows := data:rows( $templateID, $params )/row 
   let $ordered := data:ordered( $rows, $params ) 
   let $result := 
     switch ( $params?mode )
     case "full" 
       return
         $rows
     case "max_id"
       return
         data:max-mode( $ordered, $params )
     case "min_id"
       return
         data:min-mode( $ordered, $params )
     case "id"
       return
         data:id-mode( $ordered, $params )
     default
       return
         data:base-mode( $ordered, $params )
     
   return
     element { "data" }{
      element { "table" } {
       attribute { "total" } { count( $rows ) },
         for $r in $result
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
 $rows
    [
      position() = ( $params?starts to  ( $params?starts + $params?limit - 1 ) )
    ]

};

declare function data:max-mode( $rows, $params ){
  if( $params?id )
  then(
    let $max_pos := 
      for $i in $rows
      count $c
      return
        if( $i/@id = $params?id )
        then(
          if( $c = count( $rows) )
          then( $c )
          else( $c - 1 )
        )
        else()
      
    let $max_num :=
      if( $max_pos < $params?limit ) then( $params?limit ) else( $max_pos )
    let $min_num :=  $max_num - $params?limit + 1
        
    return   
        $rows[ position() = ( $min_num to $max_num ) ]
  )
  else(
    $rows[ position() = ( last() - $params?limit + 1 to last() ) ]
  )
};

declare function data:min-mode( $rows, $params ){
    if( $params?id )
    then(
      let $min_pos := 
        for $i in $rows
        count $c
        return
          if( $i/@id = $params?id )
          then(
            if( $c = 1 )
            then( 1 )
            else( $c + 1 )
          )
          else()
      
      let $min_num :=  
        if( $min_pos + $params?limit > count( $rows ) )
        then( count( $rows ) - $params?limit + 1 )
        else( $min_pos )
      let $max_num :=  $min_pos + $params?limit - 1
    
      return   
          $rows[ position() = ( $min_num to $max_num ) ]
    )
    else(
      $rows[ position() = ( 1 to $params?limit ) ]
    )
};

declare function data:id-mode( $rows, $params ){
  let $pos := 
        for $i in $rows
        count $c
        return
          if ( $i/@id = $params?id ) then ( $c ) else()
  let $pos := if( $pos )then( $pos )else( 1 )
  let $pageNum := ceiling( $pos div $params?limit )
  
  let $pageStart := 
    if( ( $pageNum  - 1 ) * $params?limit + $params?limit >= count( $rows ) )
    then( count( $rows ) - $params?limit + 1 )
    else( ( $pageNum  - 1 ) * $params?limit + 1 )
    
  let $pageEnd := 
    if( $pageNum * $params?limit >= count( $rows ) )
    then( count( $rows ) )
    else( $pageNum * $params?limit )
    
  return
      $rows[ position() = ( $pageStart to $pageEnd ) ]
};

declare function data:ordered( $rows as element( row )*, $params as map(*) ){
      for $i in distinct-values( $rows/@id )
      let $r := $rows[ @id = $i ][ last() ]
      order by $r/cell[ @id = $params?orderby ]/text() ascending
      return 
        $r
};

declare function data:rows( $templateID as xs:string, $params as map(*) ){
   let $templateOwner := 
       db:open( $data:dbName, "forms" )
       /forms/form[ @id= $templateID ]/@userid/data()
   let $data := db:open( $data:dbName, "data" )
       /data/table[ @templateID = $templateID ][ empty( @status ) or ( @status != "delete" ) ]
   
   return 
        if( $templateOwner = $params?userID )
        then( $data )
        else( $data[ @userID = $params?userID ] )
};