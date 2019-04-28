module namespace user = "http://dbx.iro37.ru/zapolnititul/api/users/forms";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

declare
  %private
  %rest:GET
  %rest:path( "/zapolnititul/api/v2/users/{ $userid }/forms" )
  %rest:query-param( "offset", "{ $offset }", "0" )
  %rest:query-param( "limit", "{ $limit }", "10" )
function user:formsList( 
  $userid as xs:string, 
  $offset as xs:double, 
  $limit as xs:double ) 
{
  let $forms := $config:userForms( $userid, $offset, $limit )
  return
    if( $forms )
    then( 
      element{ "forms" } {
        for $f in $forms
        return 
          element { "form" } { $f/@id, $f/@label }
      }
    )
    else()
};