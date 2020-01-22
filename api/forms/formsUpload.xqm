module namespace formUpload = "http://dbx.iro37.ru/zapolnititul/api/form/upload";

import module namespace Session = "http://basex.org/modules/session";
import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

import module namespace 
  form = "http://dbx.iro37.ru/zapolnititul/funct/form" at "../../funct/functForm.xqm";

declare
  %updating 
  %rest:path ( "/zapolnititul/api/v1/forms/upload" )
  %rest:POST
  %rest:form-param ( "label", "{ $label }", "" )
  %rest:form-param ( "template", "{ $template }" )
  %rest:form-param ( "data", "{ $data }" )
  %rest:form-param ( "redirect", "{ $redirect }" )
function formUpload:upload( $label, $template, $data, $redirect ) {
    let $f := $template( map:keys( $template )[ 1 ] )
    let $d := 
      if ( $data instance of map(*) )
      then (
         formUpload:request( $data( map:keys( $data )[ 1 ] ) )   
      )
      else ()
    
    let $timeStamp := string( current-dateTime() )
    let $formID := random:uuid()
    let $fileNameToSave := $formID || ".docx"
    let $fileFullName := $config:param( "static" ) || $config:param( "usersTemplatePath" ) || $fileNameToSave
    let $fileFullPath := $config:param( "httpStatic" ) || $formID 
 
    let $formRecord := form:recordFromTemplate ( $f )       
    let $formData :=
      <form 
        id = "{ $formID }"
        username = "{ Session:get( 'username' ) }" 
        label = "{ $label }"
        timestamp = "{ $timeStamp }" 
        fileNameOriginal = "{ map:keys( $template )[ 1 ] }"
        fileFullName = "{ $fileFullName }"
        fileFullPath = '{ $fileFullPath }'>
          { $formRecord }
          <data>{ $d }</data>
      </form>
      
    return
      (
        insert node $formData into db:open("titul24","forms")/forms,
        update:output( 
          (
            file:write-binary( $fileFullName, $f),
            web:redirect( $redirect || $formID )
          )
        )
      )
 };
 
declare 
  %private
function formUpload:request ( $data ) {
  let $request := 
  <http:request method='post'>
      <http:header name="Content-type" value="multipart/form-data; boundary=----7MA4YWxkTrZu0gW"/>
      <http:multipart media-type = "multipart/form-data" >
          <http:header name='Content-Disposition' value='form-data; name="data"'/>
          <http:body media-type = "application/octet-stream">
             { $data }
          </http:body>
          <http:header name='Content-Disposition' value='form-data; name="template"'/>
          <http:body media-type = "xml">
             <a/>
          </http:body>
      </http:multipart> 
    </http:request>

let $response := 
    http:send-request(
      $request,
      "http://localhost:9984/xlsx/api/parse/raw-trci"
  )
  return
   $response[2]
};