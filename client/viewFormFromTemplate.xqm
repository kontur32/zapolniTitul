module namespace zt = "http://dbx.iro37.ru/zapolnititul/";

import module namespace zt2 = "http://dbx.iro37.ru/zapolnititul/" at "viewMain.xqm";
import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "buildForm.xqm";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare
  %rest:GET 
  %rest:path("/zapolnititul/v/form")
  %output:method ("xhtml")
  %rest:query-param( "path", "{$tplPath}" )
function zt:formFromTemplate ( $tplPath ){
let $rowTpl := 
  try{
    fetch:binary( 
      iri-to-uri ( $tplPath )
    )
  }
  catch*{ "Ошибка: не удалось прочитать шаблон"}

let $xmlTpl := 
      parse-xml ( 
          archive:extract-text($rowTpl,  'word/document.xml')
      )/w:document
let $formData :=
  for $i in $xmlTpl//w:r/w:instrText/text()
  return
    <record>
      <ID>{normalize-space( $i )}</ID>
      <inputType>text</inputType>
      <label>{normalize-space( $i )}</label>
    </record>

 let $content := 
    let $inputForm :=  buildForm:buildInputForm ( <a><csv>{$formData}</csv></a> , $tplPath )
    let $formLink := <a href="{'/zapolnititul/v/form?path=' || $tplPath}">Ссылка на эту форму</a>
    let $templateFieldsMap := map{ 
                  "OrgLabel": "", 
                  "Title": "",
                  "inputForm" : ($formLink, $inputForm)
                }
    let $contentTemplate := serialize( doc("src/content-tpl.html") )
    return zt:fillHtmlTemplate( $contentTemplate, $templateFieldsMap )/child::*

let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
let $templateFieldsMap := map{ "sidebar" : "", "content" : $content, "nav" : "", "nav-login" : "" }
return zt:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};