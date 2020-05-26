module namespace getUserData = "http://dbx.iro37.ru/zapolnititul/api/v2.1/users/";


declare
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2.1/data/users/{ $userID }/uqx/{ $xqueryPath }" )
function getUserData:promis.patient(
  $userID as xs:integer,
  $xqueryPath as xs:string
)
{
  let $params := 
    map:merge(
      for $i in request:parameter-names() 
      return
        map{ $i : request:parameter( $i ) }
    )
    
  let $xquery :=
    fetch:text(
      'http://localhost:9984/static/promis/functions/' || $xqueryPath || '.xq'
    )
    
  let $data := db:open( 'titul24', 'data' )/data/table
            [ @userID = $userID ]
    
  return
    xquery:eval(
      $xquery,
      map{ '' : $data, 'params' : $params },
      map{ 'permission' : 'admin'} (: временное решение :)
    )
};
