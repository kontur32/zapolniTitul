module namespace formTpl = "http://dbx.iro37.ru/zapolnititul/api/form/template";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

declare
  %rest:path ( "/zapolnititul/api/v1/forms/template/{$id}" )
  %rest:GET
function formTpl:get( $id as xs:string ) {
  let $fileFullName := $config:forms()//forms/form[ @id = $id ]/@fileFullName/data()
  let $file := file:read-binary( $fileFullName ) 
  let $ContentDispositionValue := "attachment; filename=" || "titul24.docx"
  return 
    (
      <rest:response>
        <http:response status="200">
          <http:header name="Content-Disposition" value="{$ContentDispositionValue}" />
          <http:header name="Content-type" value="application/octet-stream"/>
        </http:response>
      </rest:response>,
      $file
     )
};