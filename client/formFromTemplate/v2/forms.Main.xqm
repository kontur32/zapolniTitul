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
    else (
      let $userFormID :=
        try{
          fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || 
            session:get( "userid" ) || 
            "/forms" )//form[ 1 ]/@id/data()
        }catch*{}
      return
        if( $userFormID )
        then( $userFormID )
        else()
    )

  let $formMeta := $config:getFormByAPI( $currentFormID,  "meta" )/form
   
  let $formFields := 
    if( $config:getFormByAPI( $currentFormID,  "fields" )/csv )
    then(
      $config:getFormByAPI( $currentFormID,  "fields" )/csv
    )
    else( <csv/> )
  
  let $sidebar := 
       switch ( $page )
       case ( "form" )
         return (
           if( $currentFormID )
           then(
             <div class="col-md-3 border-right">
                <h3>Мои шаблоны</h3> 
                  {
                    sidebar:userFormsList ( $currentFormID, $userForms, $config:param )
                  }
              </div>
           )
           else(
             <div class="col-md-3 border-right">
               <div>У Вас ещё нет загруженных шаблонов. Возможно, самое время создать свой первый шаблон..</div>
               <p>
                  Как это сделать посмотрите 
                  <a class="my-2 btn btn-info" href="https://youtu.be/QzxlRRRCLeI">видео</a>
                   или прочитайте <a class="btn btn-info" href="http://portal.titul24.ru/pervij-shablon/">инструкцию</a>
               </p>
             </div>
           )
          
      )
      case ( "data" )
         return 
           
               let $data := $config:fetchUserData(
                   session:get( "userid"),
                   request:cookie('JSESSIONID')
                 )/data/table
            return
              if( $data )
              then(
                <div class="col-md-3 border-right">
                   <h3>Мои данные</h3>
                   { 
                     sidebar:userDataList( $currentFormID, $data )
                   }
                </div> 
              )
              else(
                <div class="col-md-3 border-right">
                  У Вас ещё нет сохранённых данных
                </div> 
              )
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
           let $userDataRequest :=
             if( $currentFormID != "1" )
             then( 
                $config:fetchUserTemplateData(
                  $currentFormID, session:get( "userid" ), request:cookie('JSESSIONID')
                )/data/table
             )
             else( <table/> )
           let $userData := 
              if( $userDataRequest )
              then( $userDataRequest )
              else( <table/> )
            return
              if( $userData[ @templateID = $formMeta/@id ] )
              then(
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
             )
             else(
               
             )
       default return ""
  
  let $nav := 
    let $id := if( $currentFormID )then( $currentFormID )else( "1" )
    let $items:= 
           (
             ["form", '/zapolnititul/forms/u/' || 'form' || '/' || $id,  "Мои шаблоны" ],
             ["data", '/zapolnititul/forms/u/' || 'data' || '/' || $id, "Мои данные" ]
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