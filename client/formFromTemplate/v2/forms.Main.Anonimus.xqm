module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace session = "http://basex.org/modules/session";

import module namespace request = "http://exquery.org/ns/request";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  template = "http://dbx.iro37.ru/zapolnititul/forms/u/template" at "conf/conf.Template.xqm";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
  
declare 
  %rest:GET
  %rest:query-param( "fields", "{ $fields }", "{}" )
  %rest:path ( "/zapolnititul/forms/a/{ $page }/{ $currentFormID }" )
  %output:method ("xhtml")
function forms:main ( $fields, $page, $currentFormID ) {
  
  let $formMeta := $config:getFormByAPI( $currentFormID,  "meta")/form
     
  let $formFields := $config:getFormByAPI( $currentFormID,  "fields")/csv
  let $formAboutField := $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]
  
  let $imgPath := 
    if( $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/img )
    then ( $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/img/text() )
    else(
      if( $formMeta/@imageFullPath/data() )
      then( $formMeta/@imageFullPath/data() )
      else()
    )
    
  let $meta := (
     [ "fileName", "ZapolniTitul.docx" ],
     [ "templatePath", $config:apiurl( $currentFormID, "template" ) ],
     [ "templateID", $currentFormID ],
     [ "type", $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/type/text() ],
     [ "saveRedirect", "/zapolnititul/forms/u/data/" || $currentFormID ]
   )
  let $buttons := (
    if( not( $formAboutField/displayDownloadButton/text() = "false" ) )
    then(
      map{
       "method" : "POST",
       "action" : "/zapolnititul/api/v1/document",
       "class" : "btn btn-success btn-block",
       "label" : "Скачать заполненный шаблон"
     }
    )
    else(),
     if( session:get( "userid" ) )
     then(
        map{
         "method" : "POST",
         "action" : "/zapolnititul/api/v2/data/save",
         "class" : "btn btn-info btn-block",
         "label" :
           if ( $formAboutField/saveButtonText/text() )
           then( $formAboutField/saveButtonText/text() )
           else ( "Сохранить введенные данные" )
       }
     )
     else( )
   )
  
  let $sidebar :=
    let $imgLink := 
      if( $formAboutField/imgLink/text() )
      then(  $formAboutField/imgLink/text() )
      else( "#" )
    return
      <div class="col-md-3">
        <a href="{ $imgLink }"><img class="img-fluid my-3" src="{ $imgPath }"/></a>
      </div>
  let $content := 
    <div class="col-md-9">
      <h3>{
        if( $formMeta/@label/data() )
        then( $formMeta/@label/data() )
        else( $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/name/text() )
      }</h3>
      {
        if($formAboutField/iframe/text())
        then(
          <div>
            <iframe id="iframe" width="100%" height="50" frameborder="0" scrolling="no" src="{ $formAboutField/iframe/text() } " allowtransparency="true"></iframe>
          </div>
        )
        else()
      }
      
      {
        if( not( $formAboutField/displayTemplateLink/text() = "false" ) )
        then(
          <div><a href="{ $formMeta/@fileFullPath/data() }">Шаблон формы</a></div>
        )
        else()
      }
      <div>Заполните поля формы и нажмите</div>
      {
          ( form:footer( "template", $meta, "_t24_", $buttons ),
            if( not ( session:get( "userid" ) ) )
            then(
              <a href="#" type="type" class="btn btn-info btn-block" data-toggle="modal" data-target="#exampleModal">{ $formAboutField/saveButtonText/text() }</a>
            )
            else()
          )
      }
      { form:body ( $currentFormID, $formFields ) }
      
      <!-- добавляет поля из параметра "fields" в формате json пример строки: {
  "fields": {
    "1": {
      "name": "aaa",
      "value": "xxx"
    },
    "2": {
      "name": "aaa",
      "value": "xxx"
    }
  }
} -->

      <div>{
        let $json := 
          try{
            json:parse( $fields )/json/fields/child::*} catch*{ false()
          }
        return
          if( $json )
          then(
            for $f in json:parse( $fields )/json/fields/child::*
            return 
              <input
                form="template"
                type="hidden"
                name="{ $f/name/text() }"
                value="{ $f/value/text() }"/>
          )
          else()
      }</div>
    </div>
  
  let $nav-login := 
    if ( session:get( 'username' ) )
    then ( 
      html:fillHtmlTemplate(
         serialize( $template:get( "logout" ) ), 
         map{
           "username" : session:get( "username" ),
           "callbackURL" :  "/zapolnititul/forms/a/" || $page || "/" || $currentFormID 
         }
       )
     )
    else ( 
      html:fillHtmlTemplate(
           serialize( $template:get( "login" ) ), 
           map{ "callbackURL" :  "/zapolnititul/forms/a/" || $page || "/" || $currentFormID }
         )
    )
      
  let $map := map{ "sidebar": $sidebar, "content": ($sidebar, $content), "nav": "", "nav-login" : $nav-login }

  let $tpl := serialize( $template:get( $page ) )
   
  return
    html:fillHtmlTemplate( $tpl, $map )
};