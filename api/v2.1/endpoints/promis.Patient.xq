module namespace getUserData = "http://dbx.iro37.ru/zapolnititul/api/v2.1/users/";

import module namespace 
  pagin = "http://dbx.iro37.ru/zapolnititul/api/v2.1/public/promis" 
    at 'http://localhost:9984/static/promis/functions/pagination.xqm';

declare variable $getUserData:ns := '';

declare
  %rest:GET
  %rest:query-param( "mode", "{ $mode }" )
  %rest:path ( "/zapolnititul/api/v2.2/data/users/21/uqx/promis.patient" )
function getUserData:templateData(
  $mode as xs:string
)
{
  let $записи:= 
    for $i in db:open( 'titul24', 'data' )/data/table
          [ @userID = 21 ]
          [ @templateID = 'c1d33e2e-0f07-41bc-ab93-a6dc1fd51ee6' ]
          [ @status = "active" ]
       
    let $id := $i/row/@id      
    group by $id 
    return
      $i[ last() ]
        
  let $пациенты :=
     for $i in db:open('titul24', 'data')/data/table
          [ @userID = 21 ]
          [ @templateID = 'ad52a99b-2153-4a3f-8327-b23810fb38e4' ]
          [ @status = "active" ]
          /row
    let $id := $i/@id
    group by $id 
    return
      $i[ last() ]
  
  let $последняяЗаписьПациента :=       
    for $i in $записи/row
    let $p := $i/cell[ @id = ( 'partID' ) ]/text()
    group by $p
    return 
      let $d :=  $i/cell[ @id="https://schema.org/Date" ]/text()
      let $t :=  
            if( matches( $i/cell[ @id="https://schema.org/Time" ]/text(), '\d{2}:\d{2}' ) )
            then( $i/cell[ @id="https://schema.org/Time" ]/text() || ":00.000" )
            else( "00:00:00.000" )
      where not( empty( $d ) )
      order by xs:dateTime( $d || 'T' || $t ) 
      return
           $i[ last() ]
  
  let $пациентыПоДате := 
    for $i in $последняяЗаписьПациента
    let $p := $i/cell[@id= ('partID')]/text()
    let $d :=  $i/cell[@id="https://schema.org/Date"]/text()
    let $t :=  
        if( matches( $i/cell[ @id="https://schema.org/Time" ]/text(), '\d{2}:\d{2}' ) )
        then( $i/cell[ @id="https://schema.org/Time" ]/text() || ":00.000" )
        else( "00:00:00.000" )
    order by xs:dateTime( $d || 'T' || $t )
    return
      $p
  
  let $mode1 :=
    let $m := tokenize( $mode, ':' )
    return
      if( $m[ 1 ] = ( 'up', 'down' ) )
      then( $m[ 1 ] || ':http://dbx.iro37.ru/promis/сущности/пациенты#' || $m[ 2 ]  )
      else( 'self:http://dbx.iro37.ru/promis/сущности/пациенты#' || $m[ 2 ] )
  
  let $aa := ( reverse( $пациенты[ not( @id/data() = $пациентыПоДате ) ]/@id/data() ), $пациентыПоДате )
  let $пацинетыРеузльтат := 
    let $pagin := pagin:fromTo( $mode1, $aa )
    for $i in $pagin?1 to $pagin?2 
    return
        $пациенты[ @id = $aa[ $i ] ]
  
  return
    <data total="{ count( $пациенты ) }" mode = "{ $mode1 }">{
      $пацинетыРеузльтат,
      for $i in $записи[ row[ cell[ @id = 'partID' ]/text() = $пацинетыРеузльтат/@id/data() ] ]
      return
        $i/row update  insert node attribute { 'containerID' } {  $i/@id/data() } into .
    }</data>
};