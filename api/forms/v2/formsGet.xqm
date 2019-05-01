module namespace getForms = "http://dbx.iro37.ru/zapolnititul/api/forms/get";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/forms" )
  %rest:query-param( "offset", "{ $offset }", "0" )
  %rest:query-param( "limit", "{ $limit }", "10" )
function getForms:list( 
  $offset as xs:double, 
  $limit as xs:double 
) {
  let $totalCount := count( $config:forms()//form )
  let $forms := $config:formsList( $offset, $limit )
  return 
    if( $forms )
    then( 
      element{ "forms" } {
        attribute { "total"} { $totalCount },
        attribute { "offset"} { $offset },
        attribute { "limit"} { $limit },
        for $f in $forms
        return 
          element { "form" } { $f/@id, $f/@label, $f/@fileFullPath }
      }
    )
    else()
};