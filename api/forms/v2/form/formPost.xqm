module namespace formPost = "http://dbx.iro37.ru/zapolnititul/api/form/post";

import module namespace session = "http://basex.org/modules/session";
import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../../config.xqm";

declare
  %updating
  %private 
  %rest:path ( "/zapolnititul/api/v2/forms/post/{ $id }" )
  %rest:POST
  %rest:form-param ( "label", "{ $label }", "" )
  %rest:form-param ( "template", "{ $template }" )
  %rest:form-param ( "data", "{ $data }" )
  %rest:form-param ( "template-image", "{ $template-image }" )
  %rest:form-param ( "redirect", "{ $redirect }", "/" )
function formPost:post( 
  $id as xs:string,
  $label as xs:string, 
  $template as map(*), 
  $data as item()*,
  $template-image as item()*, 
  $redirect as xs:string
) {
    let $t := $template( map:keys( $template )[ 1 ] )
      
    let $formRecord := 
      formPost:request( 
        $t, 
        "template", 
        "http://localhost:8984/ooxml/api/v1/docx/fields/record"
      )
      
    let $d := 
      if( $data instance of map(*) ) 
      then(
        if ( map:keys( $data )[ 1 ] )
        then (
          formPost:request( 
            $data( map:keys( $data )[ 1 ] ), 
            "data", 
            "http://localhost:8984/xlsx/api/parse/raw-trci"
          )
        )
        else( )
      ) 
      else ( )   
    let $tpl-img := $template-image( map:keys( $template-image )[ 1 ] )
    
    let $timeStamp := string( current-dateTime() )
    let $formID := 
       if ( $config:form( $id )[ @userid = session:get( 'userid' ) ] )
       then ( $id )
       else ( random:uuid() )
    let $fileNameToSave := $formID || ".docx"
    let $imageNameToSave := "template-images/" || $formID  || "---" || map:keys( $template-image )[ 1 ]
    let $fileFullName := $config:param( "static" ) || $config:param( "usersTemplatePath" ) || $fileNameToSave
    let $imageFullName := 
      if ( map:keys( $template-image )[ 1 ] )
      then (
        $config:param( "static" ) || $config:param( "usersTemplatePath" ) || $imageNameToSave
      )
      else ( ) 
    
    let $fileFullPath := $config:param( "httpStatic" ) || $formID || "/template"
    
    let $imageFullPath := 
      if ( map:keys( $template-image )[ 1 ] ) 
      then ( $config:param( "httpStatic" ) || $formID || "/template-image" )
      else ()
    
    let $dataFullPath := 
      if ( $d ) 
      then ( $config:param( "httpStatic" ) || $formID || "/data" ) 
      else ( )  
    
    let $formData :=
      <form 
        id = "{ $formID }"
        userid = "{ session:get( 'userid' ) }"
        username = "{ session:get( 'username' ) }" 
        label = "{ $label }"
        timestamp = "{ $timeStamp }" 
        fileNameOriginal = "{ map:keys( $template )[ 1 ] }"
        fileFullName = "{ $fileFullName }"
        fileFullPath = '{ $fileFullPath }'
        imageNameOriginal = "{ map:keys( $template-image )[ 1 ] }"
        imageFullName = "{ $imageFullName }"
        imageFullPath = '{ $imageFullPath }'
        dataFullPath = "{ $dataFullPath }">
          { $formRecord }
          <data>{ $d }</data>
      </form>
      
    return
      (
        if (
          $config:form( $formID )
          and not( $id = "create" )
        )
        then (
          replace node $config:form( $formID ) with $formData
        )
        else ( 
          insert node $formData into $config:forms()
        ),
        update:output( 
          (
            file:write-binary( $fileFullName, $t ),
            if ( map:keys( $template-image )[ 1 ] )
            then ( file:write-binary( $imageFullName, $tpl-img ) )
            else (),
            web:redirect( web:create-url( $redirect ||  $formID, map{ "id" : $formID } ) )
          )
        )
      )
 };
 
declare 
  %public
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