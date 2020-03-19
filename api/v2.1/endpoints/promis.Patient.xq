module namespace getUserData = "http://dbx.iro37.ru/zapolnititul/api/v2.1/users/";

import module namespace 
  pagin = "http://dbx.iro37.ru/zapolnititul/api/v2.1/public/promis" 
    at 'http://localhost:9984/static/promis/functions/pagination.xqm';

declare
  %rest:GET
  %rest:query-param( "query", "{ $query }" )
  %rest:path ( "/zapolnititul/api/v2.1/data/users/{ $userID }/uqx/promis.patient.search" )
function getUserData:promis.patient.search(
  $userID as xs:integer,
  $query as xs:string
)
{
  let $data := db:open( 'titul24', 'data' )/data/table
          [ @userID = $userID ]
  let $пациенты := getUserData:getLast( $data, 'ad52a99b-2153-4a3f-8327-b23810fb38e4' ) 
  return
    <data>{
      $пациенты[ matches( row/cell[ @id = 'https://schema.org/familyName']/text(), $query ) ]
    }</data>
    
};

declare
  %rest:GET
  %rest:query-param( "mode", "{ $mode }" )
  %rest:path ( "/zapolnititul/api/v2.1/data/users/{ $userID }/uqx/promis.patient" )
function getUserData:promis.patient(
  $userID as xs:integer,
  $mode as xs:string
)
{
  let $data := db:open( 'titul24', 'data' )/data/table
          [ @userID = $userID ]
  
  return
    getUserData:eval( $data, map{ 'mode' : $mode } )
};

declare function getUserData:eval( $data, $params ){
  let $ns := 'http://dbx.iro37.ru/promis/сущности/пациенты#'
  let $mode :=
    let $m := tokenize( $params?mode, ':' )
    return
      if( $m[ 1 ] = ( 'up', 'down' ) )
      then( $m[ 1 ] || ':' || $ns || $m[ 2 ]  )
      else( 'self:' || $ns || $m[ 2 ] )
      
  let $записи := getUserData:getLast( $data, 'c1d33e2e-0f07-41bc-ab93-a6dc1fd51ee6' )
  
  let $пациенты := getUserData:getLast( $data, 'ad52a99b-2153-4a3f-8327-b23810fb38e4' ) 
  
  let $последняяЗаписьПациента :=       
    for $i in $записи/row
    where not( empty( $i/cell[ @id="https://schema.org/Date" ]/text() ) )
    let $p := $i/cell[ @id = ( 'partID' ) ]/text()
    group by $p
    return
      let $order := getUserData:dateTime( $i )
      order by $order
      return
           $i[ last() ]
  
  let $пациентыПоДате := 
    for $i in $последняяЗаписьПациента
    order by getUserData:dateTime( $i )
    return
      $i/cell[ @id = ( 'partID' ) ]/text()

  let $seq :=
    (
      reverse( $пациенты/row[ not( @id/data() = $пациентыПоДате ) ]/@id/data() ),
      $пациентыПоДате
    )
  let $пациентыРеузльтат := 
    let $pagin := pagin:fromTo( $mode, $seq )
    for $i in $pagin?1 to $pagin?2 
    return
        $пациенты/row[ @id = $seq[ $i ] ]
  
  return
    <data total="{ count( $пациенты ) }">{
      $пациентыРеузльтат,
      for $i in $записи[ row[ cell[ @id = 'partID' ]/text() = $пациентыРеузльтат/@id/data() ] ]
      return
        $i/row update  insert node attribute { 'containerID' } {  $i/@id/data() } into .
    }</data>
};

declare
function 
  getUserData:getLast( $data as element( table )*, $templateID as xs:string )
  as element( table )*
{
  for $i in $data
        [ @templateID = $templateID ]
        [ @status = "active" ]
  let $id := $i/row/@id      
  group by $id 
  return
    $i[ last() ]
};

declare function getUserData:dateTime ( $var ){
  let $d :=  $var/cell[@id="https://schema.org/Date"]/text()
  let $t :=  
      if( matches( $var/cell[ @id="https://schema.org/Time" ]/text(), '\d{2}:\d{2}' ) )
      then( $var/cell[ @id="https://schema.org/Time" ]/text() || ":00.000" )
      else( "00:00:00.000" )
  return
    xs:dateTime( $d || 'T' || $t )
};