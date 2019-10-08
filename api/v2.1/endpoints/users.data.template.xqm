module namespace getUserData = "http://dbx.iro37.ru/zapolnititul/api/v2.1/users/";

import module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data" at "../functions/data.xqm";

declare
  %private
  %rest:GET
  %rest:query-param( "mode", "{ $mode }", "last" )
  %rest:query-param( "starts", "{ $starts }", "1" )
  %rest:query-param( "limit", "{ $limit }", "100" )
  %rest:query-param( "orderby", "{ $orderby }", "id" )
  %rest:query-param( "about", "{ $about }", "" )
  %rest:path ( "/zapolnititul/api/v2.1/data/users/{ $userID }/templates/{ $templateID }" )
function getUserData:templateData(
  $mode as xs:string,
  $starts as xs:integer,
  $limit as xs:integer,
  $orderby as xs:string,
  $about as xs:string,
  $userID as xs:string,
  $templateID as xs:string
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
  return
   data:templateData ( $templateID, $params )
};