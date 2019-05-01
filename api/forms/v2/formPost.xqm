module namespace formPost = "http://dbx.iro37.ru/zapolnititul/api/form/post";

import module namespace session = "http://basex.org/modules/session";
import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

declare
  %updating
  %private 
  %rest:path ( "/zapolnititul/api/v2/forms/post" )
  %rest:POST
  %rest:form-param ( "id", "{ $id }", "" )
  %rest:form-param ( "label", "{ $label }", "" )
  %rest:form-param ( "template", "{ $template }" )
  %rest:form-param ( "data", "{ $data }" )
  %rest:form-param ( "redirect", "{ $redirect }", "/" )
function formPost:post( 
  $id,
  $label, 
  $template, 
  $data, 
  $redirect
) {
    let $t := $template( map:keys( $template )[ 1 ] )
    let $formRecord := formPost:request( $t, "template", "http://localhost:8984/ooxml/api/v1/docx/fields/record" )
    let $d := if( $data instance of map(*) ) then( formPost:request( $data( map:keys( $data )[ 1 ] ), "data", "http://localhost:8984/xlsx/api/parse/raw-trci" ) ) else ( )   

    let $timeStamp := string( current-dateTime() )
    let $formID := 
       if ( $config:form( $id )[ @userid = session:get( 'userid' ) ] )
       then ( $id )
       else ( random:uuid() )
    let $fileNameToSave := $formID || ".docx"
    let $fileFullName := $config:param( "static" ) || $config:param( "usersTemplatePath" ) || $fileNameToSave
    let $fileFullPath := $config:param( "httpStatic" ) || $formID     
    
    let $formData :=
      <form 
        id = "{ $formID }"
        userid = "{ session:get( 'userid' )}"
        username = "{ session:get( 'username' )}" 
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
        if ( $config:form( $formID ) )
        then (
          replace node $config:form( $formID ) with $formData
        )
        else ( 
          insert node $formData into $config:forms()
        ),
        db:output( 
          (
            file:write-binary( $fileFullName, $t ),
            web:redirect( web:create-url( $redirect, map{ "id" : $formID } ) )
          )
        )
      )
 };
 
declare 
  %private
function formPost:request ( $data, $name, $host ) {
  let $request := 
  <http:request method='POST'>
      <http:header name="Content-type" value="multipart/form-data; boundary=----7MA4YWxkTrZu0gW"/>
      <http:multipart media-type = "multipart/form-data" >
          <http:header name='Content-Disposition' value='form-data; name="{$name}"'/>
          <http:body media-type = "application/octet-stream">
             { $data }
          </http:body>
      </http:multipart> 
    </http:request>

let $response := 
    http:send-request(
      $request,
      $host
  )
  return
   $response[2]
};