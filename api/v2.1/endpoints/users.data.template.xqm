module namespace getUserData = "http://dbx.iro37.ru/zapolnititul/api/v2.1/users/";

import module namespace request = "http://exquery.org/ns/request";

import module namespace log = "http://dbx.iro37.ru/zapolnititul/api/v2.1/log/" at "../functions/log.xqm";
import module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data" at "../functions/data.xqm";

declare
  %private
  %rest:GET
  %rest:query-param( "mode", "{ $mode }", "" )
  %rest:query-param( "starts", "{ $starts }", "1" )
  %rest:query-param( "limit", "{ $limit }", "10" )
  %rest:path ( "/zapolnititul/api/v2.1/data/users/{ $userID }/templates/{ $templateID }" )
function getUserData:templateData(
  $mode as xs:string,
  $starts as xs:integer,
  $limit as xs:integer,
  $userID as xs:string,
  $templateID as xs:string
)
{
  let $log := 
    log:log( "users.data.template.log", ( request:uri(), request:query() ) )
  let $params := 
    map{ "mode" : $mode, "starts" : $starts, "limit" : $limit }
  return
   data:templateData ( $templateID, $params )
};