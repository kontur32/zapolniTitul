module namespace form = "http://dbx.iro37.ru/zapolnititul/";

import module namespace zt = "http://dbx.iro37.ru/zapolnititul/" at "viewMain.xqm";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "buildForm.xqm";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare variable $form:getFieldsAsString := 'http://localhost:8984/ooxml/api/v1/docx/fields';

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
    )[2]
  )

let $formData :=
  for $i in $fieldsAsString/csv/record/entry/text()
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