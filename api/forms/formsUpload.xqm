module namespace formUpload = "http://dbx.iro37.ru/zapolnititul/api/form/upload";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

import module namespace 
  form = "http://dbx.iro37.ru/zapolnititul/funct/form" at "../../funct/functForm.xqm";

declare
  %updating 
  %rest:path ( "/zapolnititul/api/v1/forms/upload" )
  %rest:POST
  %rest:form-param ( "label", "{ $label }", "" )
  %rest:form-param ( "file", "{ $file }" )
  %rest:form-param ( "redirect", "{ $redirect }", "/zapolnititul/v/forms/confirm/" )
function formUpload:upload( $label as xs:string, $file, $redirect as xs:string ) {
    let $f := $file( map:keys( $file )[ 1 ] )
    let $timeStamp := string( current-dateTime() )
    let $formID := random:uuid()
    let $fileNameToSave := $formID || ".docx"
    let $fileFullName := $config:param( "static" ) || $config:param( "usersTemplatePath" ) || $fileNameToSave
    let $fileFullPath := $config:param( "httpStatic" ) || $formID 
 
    let $formCSV := form:csvFromTemplate ( $f )       
    let $formData :=
      <form 
        id = "{ $formID }" 
        label = "{ $label }"
        timestamp = "{ $timeStamp }" 
        fileNameOriginal = "{ map:keys( $file )[ 1 ] }"
        fileFullName = "{ $fileFullName }"
        fileFullPath = '{ $fileFullPath }'>
          { $formCSV }
      </form>
      
    return
      (
        insert node $formData into db:open("titul24","forms")/forms,
        db:output( 
          (
            file:write-binary( $fileFullName, $f),
            web:redirect( $redirect || $formID )
          )
        )
      )
 };