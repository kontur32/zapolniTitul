module namespace formData = "http://dbx.iro37.ru/zapolnititul/api/form/template";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

declare
  %rest:path ( "/zapolnititul/api/v1/forms/data/{$id}" )
  %rest:query-param( "f", "{$field}", "")
  %output:method("csv")
  %rest:GET
function formData:get( $id as xs:string, $field ) {
  let $data := 
    for $r in $config:forms()//forms/form[ @id = $id ]/data/table/row
    return 
      <row>{ $r/cell[ @label = $field ] }</row>  
  return
    (
      <data>{$data}</data>
    )
};