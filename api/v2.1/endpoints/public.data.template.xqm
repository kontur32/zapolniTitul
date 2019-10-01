module namespace getPublicData = "http://dbx.iro37.ru/zapolnititul/api/v2.1/public/";

import module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data" at "../functions/data.xqm";

declare
  %private
  %rest:GET
  %rest:query-param( "mode", "{ $mode }", "last" )
  %rest:query-param( "starts", "{ $starts }", "1" )
  %rest:query-param( "limit", "{ $limit }", "10" )
  %rest:query-param( "orderby", "{ $orderby }", "id" )
  %rest:query-param( "about", "{ $about }", "" )
  %rest:query-param( "xqurl", "{ $xqurl }", "" )
  %rest:path ( "/zapolnititul/api/v2.1/data/public/users/{ $userID }/templates/{ $templateID }" )
function getPublicData:templateData(
  $userID as xs:string,
  $mode as xs:string,
  $starts as xs:integer,
  $limit as xs:integer,
  $orderby as xs:string,
  $about as xs:string,
  $templateID as xs:string,
  $xqurl as xs:string
)
{
  let $params := 
    map{
      "userID" : $userID,
      "mode" : $mode,
      "starts" : $starts,
      "limit" : $limit,
      "orderby" : $orderby,
      "about" : $about
    }
  let $access := 
    fetch:xml(
      "http://localhost:8984/zapolnititul/api/v2/forms/" || $templateID || "/fields"
    )/csv/record[ ID/text() = "__ОПИСАНИЕ__" ]/access/text()
  let $data := 
    if( $access = "public" ) then ( data:templateData ( $templateID, $params ) ) else()
  let $xquery :=
    try{
      fetch:text( $xqurl )
    }
    catch*{
      "."
    } 
    
  return
    xquery:eval( $xquery, map { '': $data }, map{ "permission" : "none" } )
};