module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace session = "http://basex.org/modules/session";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  template = "http://dbx.iro37.ru/zapolnititul/forms/u/template" at "conf/conf.Template.xqm";

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
    <div class="col-md-3">
      <img class="img-fluid my-3" src="{ $imgPath }"/>
    </div>
  let $content := 
    <div class="col-md-9">
      <h3>{ $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/name/text() }</h3>
      <div><a href="{ $formMeta/@fileFullPath/data() }">Шаблон формы</a></div>
      <div>Заполните поля формы и нажмите</div>
      {
        
         let $meta := (
           [ "type", $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/type/text() ],
           [ "saveRedirect", "/zapolnititul/forms/u/data/" || $currentFormID ]
         )
        let $buttons := (
           map{
             "method" : "POST",
             "action" : "/zapolnititul/api/v1/document",
             "class" : "btn btn-success btn-block",
             "label" : "Скачать заполненный шаблон"},
             if( session:get( "userid" ) )
             then(
                map{
                 "method" : "POST",
                 "action" : "/zapolnititul/api/v2/data/save",
                 "class" : "btn btn-info btn-block",
                 "label" : "Сохранить введенные данные"}
             )
             else()
         )
         return
          form:footer( "template", $meta, "_t24_", $buttons )
      }
      { form:body ( $currentFormID, $formFields ) }
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
             "label" : "Скачать заполненный шаблон"},
           if( session:get( "userid" ) )
             then(
                map{
                 "method" : "POST",
                 "action" : "/zapolnititul/api/v2/data/save",
                 "class" : "btn btn-info btn-block",
                 "label" : "Сохранить введенные данные"}
             )
             else()
           
         )
         return
          form:footer( "template", $meta, "_t24_", $buttons )
       }
    </div>
  let $nav-login := 
    if ( session:get( 'username' ) )
    then ( 
      html:fillHtmlTemplate(
         serialize( $template:get( "logout" ) ), 
         map{
           "username" : session:get( "username" ),
           "callbackURL" : "/zapolnititul/forms/a/form/" || $currentFormID
         }
       )
     )
    else ( 
      html:fillHtmlTemplate(
           serialize( $template:get( "login" ) ), 
           map{ "callbackURL" : "/zapolnititul/forms/a/form/" || $currentFormID }
         )
    )
  let $map := map{ "sidebar": $sidebar, "content": ($sidebar, $content), "nav": "", "nav-login" : $nav-login }
  let $tpl := serialize( $template:get( $page ) )
   
  return
    html:fillHtmlTemplate( $tpl, $map )
};