module namespace restDocx = "http://iro37.ru/xq/modules/docx/rest";

import module namespace request = "http://exquery.org/ns/request";

declare 
  %rest:path ( "/zapolnititul/api/v1/document" )
  %rest:method ( "POST" )
  %rest:form-param ( "fileName", "{ $fileName }", "ZapolniTitul.docx" )
  %rest:form-param ( "templatePath", "{ $templatePath }" )
function restDocx:document-POST ( $fileName  as xs:string, $templatePath as xs:string ) {
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
        let $paramValue := request:parameter( $param )
        where not ( $paramValue instance of map(*)  )
        return
            <cell id="{ $param }" contentType = "field">{ $paramValue }</cell>
      }
      </row>
      <row id="pictures">
      {
        for $param in request:parameter-names()
        let $paramValue := request:parameter( $param )
        where ( $paramValue instance of map(*)  )
        return
            <cell id="{ $param }" contentType = "img"> 
              { map:get( $paramValue, map:keys( $paramValue )[1] )  }
            </cell>  
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
          <http:header name="Content-type" value="application/xml"/>
        </http:response>
      </rest:response>,
      $response[2]
     )
};