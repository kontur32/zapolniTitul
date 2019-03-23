module namespace view = "http://dbx.iro37.ru/zapolnititul/v/forms";

import module namespace 
  form = "http://dbx.iro37.ru/zapolnititul/funct/form" at "../../funct/functForm.xqm";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "../funct/buildForm.xqm";
  
import module namespace 
  htmlZT = "http://dbx.iro37.ru/zapolnititul/funct/htmlZT" at "../funct/htmlZT.xqm";
  
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
    return form:recordFromTemplate ( $rowTpl )
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
    let $inputForm :=  buildForm:buildInputForm ( <data>{ $formData }</data>, $formData/parent::*/@id/data(), $tplPath )
    let $templateLink := <a href="{ $tplPath }" download="{$downloadName}">Ссылка на шаблон</a>
    let $templateFieldsMap := map{ 
                  "OrgLabel": $meta/org/text(), 
                  "Title": $meta/name/text(),
                  "inputForm" : ( $templateLink, $inputForm )
                }
    let $contentTemplate := serialize( doc("../src/content-tpl.html") )            
    return htmlZT:fillHtmlTemplate( $contentTemplate, $templateFieldsMap )/child::*

let $siteTemplate := serialize( doc( "../src/main-tpl.html" ) )
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