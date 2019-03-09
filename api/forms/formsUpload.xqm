module namespace formUpload = "http://dbx.iro37.ru/zapolnititul/api/form/upload";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";
import module namespace form = "http://dbx.iro37.ru/zapolnititul/" at "../../client/viewFormFromTemplate.xqm";

declare
  %updating 
  %rest:path ( "/zapolnititul/api/v1/forms/upload" )
  %rest:POST
  %rest:form-param ( "label", "{ $label }", "" )
  %rest:form-param ( "file", "{ $file }" )
function formUpload:upload( $label as xs:string, $file ) {
    let $f := $file( map:keys( $file )[ 1 ] )
    let $timeStamp := string( current-dateTime() )
    let $formID := random:uuid()
    let $fileNameToSave := $formID || ".docx"
    let $fileFullName := $config:param( "static" ) || $config:param( "usersTemplatePath" ) || $fileNameToSave
    
    let $fileFullPath := $config:param( "httpStatic" ) || $formID 
    
    let $formCSV := form:buildCSV( form:fieldsAsString( $f, $config:param( "fieldsAsStringPath" ) )/csv )
        
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
        formUpload:dbCheck( "titul24" ),
        insert node $formData into db:open("titul24","forms")/forms,
        db:output( 
          (
            file:write-binary( $fileFullName, $f),
            web:redirect("/zapolnititul/v/forms/confirm/" || $formID )
          )
        )
      )
 };
 
declare 
   %updating
   %private 
function  formUpload:dbCheck( $dbName as xs:string ) {
  if ( db:exists( $dbName, "forms") )
  then (
      if( db:open( $dbName,"forms")/forms )
      then()
      else(
        insert node <forms/> into db:open( $dbName, "forms" )
      )
  )
  else (
    db:create( $dbName, <forms/>, "forms")
  )
};