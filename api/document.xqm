module namespace restDocx = "http://iro37.ru/xq/modules/docx/rest";

import module namespace request = "http://exquery.org/ns/request";

declare 
  %rest:path ( "/zapolnititul/api/v1/document" )
  %rest:method ( "GET" )
  %rest:query-param ( "fileName", "{ $fileName }", "ZapolniTitul.docx" )
  %rest:query-param ( "templatePath", "{ $templatePath }" )
function restDocx:document ( $fileName, $templatePath as xs:string ) {
  let $template := 
    try {
      string( fetch:binary( iri-to-uri( $templatePath ) ) )
    }
    catch * { 
    }
    
  let $data :=
    <table>
      <row id="fields">
      {
        for $param in request:parameter-names()
        return 
          <cell id="{ $param }">{ request:parameter( $param ) }</cell>
      }
      </row>
    </table>     
    
  let $request :=
    <http:request method='post'>
      <http:multipart media-type = "multipart/form-data" >
          <http:header name="Content-Disposition" value= 'form-data; name="template";'/>
          <http:body media-type = "application/octet-stream" >
            { $template }
          </http:body>
          <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
          <http:body media-type = "application/xml">
            { $data }
          </http:body>
      </http:multipart> 
    </http:request>

  let $response := 
    http:send-request(
      $request,
      'http://localhost:8984/api/v1/ooxml/docx/template/complete'
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


(:------------------- старый вариант ---------------------------- :)
declare 
  %rest:path ( "/zapolnititul/api/v1/document1" )
  %rest:method ( "GET" )
  %rest:query-param ( "fileName", "{ $fileName }", "ZapolniTitul.docx" )
  %rest:query-param ( "templatePath", "{ $templatePath }" )
function restDocx:document1 ( $fileName, $templatePath as xs:string ) {
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
      'http://localhost:8984/ooxml/api/v1/docx/single1'
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