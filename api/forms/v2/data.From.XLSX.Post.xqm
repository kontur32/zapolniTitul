module namespace dataPost = "http://dbx.iro37.ru/zapolnititul/api/form/data/save/xlsx";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";

import module namespace 
    config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

(:
  Точка для загрузки данных в виде .xlsx
  
:)
    
declare
  %rest:path ( "/zapolnititul/api/v2/data/save/xlsx" )
  %rest:POST
  %rest:form-param ( "_t24_templateID", "{ $templateID }", "" )
  %rest:form-param ( "_t24_xlsx", "{ $xlsx }", "" )
  %rest:form-param ( "_t24_saveRedirect", "{ $redirect }", "/" )
function dataPost:main( $templateID, $xlsx, $redirect ){
      
      let $request :=
        <http:request method='POST'>
          <http:multipart media-type = "multipart/form-data" >
              <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
              <http:body media-type = "text" >
                { string( map:get($xlsx, map:keys( $xlsx )[1]) ) }
              </http:body>
          </http:multipart> 
        </http:request>
  let $response := 
    http:send-request(
      $request,
      'http://localhost:8984/xlsx/api/parse/raw-trci'
    )[2]
  
  return
    $response
};