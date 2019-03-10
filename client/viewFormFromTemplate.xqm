module namespace view = "http://dbx.iro37.ru/zapolnititul/v/forms";

import module namespace 
  htmlZT = "http://dbx.iro37.ru/zapolnititul/funct/htmlZT" at "funct/htmlZT.xqm";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "funct/buildForm.xqm";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare variable $view:pathGetFieldsAsString := 'http://localhost:8984/ooxml/api/v1/docx/fields';
declare variable $view:delimiter := "::";
declare variable $view:map := 
  function ( $string ) {
    let $map := doc("src/map.xml")
    return
      if ( $map/csv/record/label/text() = $string ) 
      then (
        $map/csv/record[ label/text() = $string ]/value/text()
      )
      else (
        $string
      )
  };

declare
  %rest:GET 
  %rest:path("/zapolnititul/v/forms")
  %output:method ("xhtml")
  %rest:query-param( "path", "{ $tplPath }", "" )
  %rest:query-param( "id", "{ $id }", "")
  %rest:query-param( "output", " { $output }", "main" )
function view:formFromTemplate ( $tplPath, $id, $output ){

let $formData :=
  if ( $tplPath )
  then ( 
    let $rowTpl := 
      try{ fetch:binary( iri-to-uri ( $tplPath ) ) }
      catch*{ "Ошибка: не удалось прочитать шаблон"}
    let $fieldsAsString := view:fieldsAsString( $rowTpl, $view:pathGetFieldsAsString )
    return view:buildCSV ( $fieldsAsString/csv )
  )
  else (
    db:open( "titul24", "forms" )/forms/form[ @id = $id ]/csv
  )

let $downloadName := 
  if( $tplPath )
  then ( $tplPath )
  else (
   db:open( "titul24", "forms" )/forms/form[ @id = $id ]/@fileNameOriginal/data()
  )

let $tplPath :=
  if( $tplPath )
  then ( $tplPath )
  else (
    db:open( "titul24", "forms" )/forms/form[ @id = $id ]/@fileFullPath
  )

let $meta := $formData//record[ ID/text() = ( "__ОПИСАНИЕ__", "__ABOUT__" ) ] 

 let $content := 
    let $inputForm :=  buildForm:buildInputForm ( <data>{ $formData }</data>, $tplPath )
    let $templateLink := <a href="{ $tplPath }" download="{$downloadName}">Ссылка на шаблон</a>
    let $templateFieldsMap := map{ 
                  "OrgLabel": $meta/org/text(), 
                  "Title": $meta/name/text(),
                  "inputForm" : ( $templateLink, $inputForm )
                }
    let $contentTemplate := serialize( doc("src/content-tpl.html") )            
    return htmlZT:fillHtmlTemplate( $contentTemplate, $templateFieldsMap )/child::*

let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
let $sidebar := <img class="img-fluid" src="{ $meta/img/text() }"></img>
let $templateFieldsMap := map{ "sidebar" :  $sidebar, "content" : $content, "nav" : "", "nav-login" : "" }
return 
  if ( $output = "iframe" )
  then (
    $content 
  )
  else (
    htmlZT:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
  )
};

declare 
  %public
function view:buildCSV( $csv as element(csv) ) as element(csv) {
       element { "csv" } {
       for $record in $csv/record
       return
         element { "record" }{
           element { "ID" } {
             $view:map( normalize-space( $record/entry[ 1 ]/text() ) )
           },
           for $entry in $record/entry[ position() > 1 ]/text()
           return
             let $a := tokenize( $entry, $view:delimiter )
             return 
               element { $view:map( normalize-space( $a[ 1 ] ) ) } {
                 $view:map( normalize-space( $a[ 2 ] ) )
               }
         }
    }
};

declare 
  %public
function view:fieldsAsString( $rowTpl, $pathGetFieldsAsString ) as element( csv ) {
  csv:parse (
   http:send-request(
    <http:request method='post'>
      <http:header name="Content-type" value="multipart/form-data; boundary=----7MA4YWxkTrZu0gW"/>
      <http:multipart media-type = "multipart/form-data" >
          <http:header name='Content-Disposition' value='form-data; name="template"'/>
          <http:body media-type ="application/octet-stream">{ $rowTpl }</http:body>
      </http:multipart>
    </http:request>,
    $pathGetFieldsAsString
    )[2],
    map { 'header': false(), 'separator' : ';' }
  )
};