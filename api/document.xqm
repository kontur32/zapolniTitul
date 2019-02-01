module namespace restDocx = "http://iro37.ru/xq/modules/docx/rest";

import module namespace request = "http://exquery.org/ns/request";

declare 
  %rest:path ( "/zapolnititul/api/v1/document" )
  %rest:method ( "GET" )
  %rest:query-param ( "fileName", "{ $fileName }", "ZapolniTitul.docx" )
  %rest:query-param ( "templatePath", "{ $templatePath }" )
function restDocx:get ( $fileName, $templatePath as xs:string ) {
  let $tpl := 
    try {
      fetch:binary ( iri-to-uri ( $templatePath ) )
    }
    catch * { 
    }
    
  let $data :=
    <table>
      <row id="fields">
      {
        for $param in request:parameter-names()
        return 
          <cell id="{ $param }">{request:parameter( $param )}</cell>
      }
      </row>
    </table>     
    
  let $request :=
    <http:request method='post'>
      <http:multipart media-type = "multipart/*" >
          <http:body media-type = "text" >
            { string ( $tpl ) }
          </http:body>
          <http:body media-type = "xml">
            { $data }
          </http:body>
      </http:multipart> 
    </http:request>

  let $response := 
    http:send-request(
      $request,
      'http://localhost:8984/docx/api/fillTemplate'
  )
  let $ContentDispositionValue := "attachment; filename=" || $fileName
  return
 (
   <rest:response>
    <http:response status="200">
      <http:header name="Content-Disposition" value="{$ContentDispositionValue}" />
      <http:header name="Content-type" value="application/octet-stream"/>
    </http:response>
  </rest:response>,
   $response[ 2 ]
 )
};