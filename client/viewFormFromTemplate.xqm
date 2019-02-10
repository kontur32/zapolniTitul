module namespace form = "http://dbx.iro37.ru/zapolnititul/";

import module namespace zt = "http://dbx.iro37.ru/zapolnititul/" at "viewMain.xqm";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "buildForm.xqm";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare variable $form:getFieldsAsString := 'http://localhost:8984/ooxml/api/v1/docx/fields';
declare variable $form:delimiter := "::";
declare variable $form:map := 
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
  %rest:path("/zapolnititul/v/form")
  %output:method ("xhtml")
  %rest:query-param( "path", "{$tplPath}" )
function form:formFromTemplate ( $tplPath ){
let $rowTpl := 
  try{
    fetch:binary( 
      iri-to-uri ( $tplPath )
    )
  }
  catch*{ "Ошибка: не удалось прочитать шаблон"}

let $fieldsAsString :=
   csv:parse (
   http:send-request(
    <http:request method='post'>
      <http:header name="Content-type" value="multipart/form-data; boundary=----7MA4YWxkTrZu0gW"/>
      <http:multipart media-type = "multipart/form-data" >
          <http:header name='Content-Disposition' value='form-data; name="template"'/>
          <http:body media-type ="application/octet-stream">{ $rowTpl }</http:body>
      </http:multipart>
    </http:request>,
    $form:getFieldsAsString
    )[2],
    map { 'header': false(), 'separator' : ';' }
  )

let $formData := form:buildCSV ( $fieldsAsString/csv )

 let $content := 
    let $inputForm :=  buildForm:buildInputForm ( <a>{$formData}</a> , $tplPath )
    let $formLink := <a href="{'/zapolnititul/v/form?path=' || $tplPath}">Ссылка на эту форму</a>
    let $templateFieldsMap := map{ 
                  "OrgLabel": "Здесь можно создать готовый документ из шаблона", 
                  "Title": "готовой формы",
                  "inputForm" : ($formLink, $inputForm)
                }
    let $contentTemplate := serialize( doc("src/content-tpl.html") )
    return zt:fillHtmlTemplate( $contentTemplate, $templateFieldsMap )/child::*

let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
let $templateFieldsMap := map{ "sidebar" : "", "content" : $content, "nav" : "", "nav-login" : "" }
return zt:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};

declare 
  %private
function form:buildCSV ( $csv as element (csv) ) as element (csv) {
       element { "csv" } {
       for $record in $csv/record
       return
         element { "record" }{
           element { "ID" } {
             normalize-space( $record/entry[ 1 ]/text() )
           },
           for $entry in $record/entry[ position() >1 ]/text()
           return
             let $a := tokenize( $entry, $form:delimiter )
             return 
               element { $form:map( normalize-space( $a[ 1 ] ) ) } {
                 $form:map( normalize-space( $a[ 2 ] ) )
               }
         }
    }
};