module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  template = "http://dbx.iro37.ru/zapolnititul/forms/u/template" at "conf/forms.Template.xqm";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
  
declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/a/{ $page }/{ $currentFormID }" )
  %output:method ("xhtml")
function forms:main ( $page, $currentFormID ) {
  
  let $formMeta := $config:getFormByAPI( $currentFormID,  "meta")/form
     
  let $formFields := $config:getFormByAPI( $currentFormID,  "fields")/csv
  
  let $imgPath := 
    if( $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/img )
    then ( $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/img/text() )
    else(
      if( $formMeta/@imageFullPath/data() )
      then( $formMeta/@imageFullPath/data() )
      else()
    )
  let $sidebar := 
    <div class="container-fluid">
      <img class="img-fluid my-3" src="{ $imgPath }"/>
    </div>
  let $content := 
    <div class="container-fluid">
      <div class="h3"> { $formMeta/@label/data() } </div>
      { form:body ( $formMeta, $formFields ) }
               {
                 let $meta := (
                   [ "fileName", "ZapolniTitul.docx" ],
                   [ "templatePath", $config:apiurl( $currentFormID, "template" ) ],
                   [ "templateID", $currentFormID ],
                   [ "redirect", "/zapolnititul/forms/a/form/" || $currentFormID ]
                 )
                 let $buttons := (
                   map{
                     "method" : "POST",
                     "action" : "/zapolnititul/api/v1/document",
                     "class" : "btn btn-success btn-block",
                     "label" : "Скачать заполненный шаблон"}
                   
                 )
                 return
                  form:footer( "template", $meta, "_t24_", $buttons )
               }
    </div>
    
  let $map := map{ "sidebar": $sidebar, "content": $content, "nav": "", "nav-login" : "" }
  let $tpl := serialize( $template:get( $page ) )
   
  return
    html:fillHtmlTemplate( $tpl, $map )
};