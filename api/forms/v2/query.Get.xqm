module namespace queries = "http://dbx.iro37.ru/zapolnititul/api/forms/get";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/queries/{ $alias }" )
  %rest:query-param( "offset", "{ $offset }", "0" )
  %rest:query-param( "limit", "{ $limit }", "10" )
  %output:method( "text" )
function queries:get(
  $alias,
  $offset as xs:double, 
  $limit as xs:double 
) {
   $config:query( $alias )
};