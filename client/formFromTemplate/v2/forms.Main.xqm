module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";
import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";
  
import module namespace 
  template = "http://dbx.iro37.ru/zapolnititul/forms/u/template" at "conf/conf.Template.xqm";
  
import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";

import module namespace
  data = "http://dbx.iro37.ru/zapolnititul/forms/data" at "forms.Main.Data.xqm";

import module namespace
  child = "http://dbx.iro37.ru/zapolnititul/forms/child" at "forms.Main.Child.xqm";
  
import module namespace
  upload = "http://dbx.iro37.ru/zapolnititul/forms/upload" at "forms.Main.Upload.xqm";
  
import module namespace
  complete = "http://dbx.iro37.ru/zapolnititul/forms/complete" at "forms.Main.Complete.xqm";

import module namespace
  nav = "http://dbx.iro37.ru/zapolnititul/forms/nav" at "forms.Main.Nav.xqm";
  
import module namespace
  sidebar = "http://dbx.iro37.ru/zapolnititul/forms/sidebar" at "forms.Main.Sidebar.xqm";

declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/u/{ $page }/{$id}" )
  %rest:query-param( "datainst", "{ $datainst }", "")
  %rest:query-param( "dataver", "{ $dataver }", "")
  %rest:query-param( "message", "{ $message }", "")
  %output:method ("xhtml")
function forms:main ( $page, $id, $datainst, $dataver, $message ) {
  let $login := 
       html:fillHtmlTemplate(
         serialize( $template:get( "logout" ) ), 
         map{
           "username" : session:get( "username" ),
           "callbackURL" : "/zapolnititul/forms/u/"
         }
       )
 
  let $userForms := 
        try {
          let $requestPath := "http://localhost:8984/zapolnititul/api/v2/users/" || session:get( "userid" ) || "/forms"
          let $request := web:create-url( $requestPath, map{ "limit" : $config:param( "formsLimit" ) } )
          return
            fetch:xml( $request )/forms/form
        }
        catch*{}
        
  let $currentFormID := 
    if (  $config:getFormByAPI( $id,  "meta")/form ) 
    then( $id )
    else ()

  let $formMeta := $config:getFormByAPI( $currentFormID,  "meta" )/form
   
  let $formFields := $config:getFormByAPI( $currentFormID,  "fields" )/csv
  
  let $sidebar := 
       switch ( $page )
       case ( "form" )
         return (
        <div class="col-md-3 border-right">
          <h3>Мои шаблоны</h3> 
            {
              sidebar:userFormsList ( $currentFormID, $userForms, $config:param )
            }
        </div>
      )
      case ( "data" )
         return 
           <div class="col-md-3 border-right">
             <h3>Мои формы</h3>
             { 
               let $data := $config:fetchUserData(
                   session:get( "userid"),
                   request:cookie('JSESSIONID')
                 )
            return 
               sidebar:userDataList( $currentFormID, $data/data/table )
             }
           </div>
      default return ""
    
  let $content := 
     switch ( $page )
       case ( "form" )
         return
         if ( $currentFormID )
         then (
          form:main ( $id, $formMeta, $formFields )
        )
        else (
          <div class="col-md">
               <h3>Загрузить новый шаблон</h3>
               {
                 upload:main( "yes", $id, $config:param( "host" ) || "/zapolnititul/forms/u/complete/" )
               }
               {
                 let $meta := (
                   [ "redirect", "/zapolnititul/forms/u/form/"]
                 )
                 let $buttons := (
                    map{
                     "method" : "POST",
                     "action" : "/zapolnititul/api/v2/forms/post/create",
                     "class" : "btn btn-info btn-block",
                     "label" : "Создать новую форму"}
                 )
                 return
                  form:footer( "upload", $meta, "", $buttons )
               }
             </div>
        )
       case ( "child" )
         return 
           child:main( $formMeta, $formFields )
       case ( "data" )
         return
           let $userData := 
                $config:fetchUserData(
                    session:get( "userid" ), request:cookie('JSESSIONID')
                )/data/table
            
            let $currentUserData := 
              $userData[ @templateID = $formMeta/@id ]
              [ @updated = web:decode-url( $dataver ) ]
            
            let $currentVerID := 
              if( $currentUserData )
              then ( $dataver )
              else (
               web:encode-url( 
                 $userData[ @templateID = $formMeta/@id ][ last() ]/@updated/data()
               )
              )
            let $currentInstID := 
              $userData[ @templateID = $formMeta/@id ]
              [ @updated = web:decode-url( $currentVerID ) ]/@id/data()
              
            return 
              data:main( $formMeta, $userData, $currentInstID, $currentVerID )
       default return ""
  
  let $nav := 
    let $items:= 
           (
             ["form", '/zapolnititul/forms/u/' || 'form' || '/' || $currentFormID,  "Мои шаблоны" ],
             ["data", '/zapolnititul/forms/u/' || 'data' || '/' || $currentFormID, "Мои данные" ]
           )
    return
      nav:main( $page, $items )
      
  return 
    if( $template:get( $page )  )
    then(
      let $templateFieldsMap := map{ "content": ( $sidebar, $content), "nav": $nav, "nav-login" : $login }
      let $siteTemplate := serialize( $template:get( $page ) )
      return
        html:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )
    )
    else(
        web:redirect( "http://localhost:8984/zapolnititul/forms/u/" )
    )
};