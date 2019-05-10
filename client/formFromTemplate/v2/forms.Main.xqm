module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";
import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "funct/buildForm.xqm";

import module namespace 
  getFormID = "http://dbx.iro37.ru/zapolnititul/forms/getFormID" at "funct/getFormID.xqm";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";

import module namespace
  child = "http://dbx.iro37.ru/zapolnititul/forms/child" at "forms.Main.Child.xqm";
  
import module namespace
  upload = "http://dbx.iro37.ru/zapolnititul/forms/upload" at "forms.Main.Upload.xqm";
  
import module namespace
  complete = "http://dbx.iro37.ru/zapolnititul/forms/complete" at "forms.Main.Complete.xqm";
  
import module namespace
  sidebar = "http://dbx.iro37.ru/zapolnititul/forms/sidebar" at "forms.Main.Sidebar.xqm";


declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/u/{ $page }/{$id}" )
  %rest:query-param( "message", "{ $message }", "")
  %output:method ("xhtml")
function forms:main ( $page, $id, $message ) {
  let $login := 
    if ( session:get( 'username' ) )
    then ( 
      forms:logoutForm ( "/zapolnititul/api/v1/users/logout", session:get( "username" ), "/zapolnititul/forms/u/" )
     )
    else ( 
      forms:loginForm ( "/zapolnititul/api/v1/users/login", "/zapolnititul/forms/u/" , "http://portal.titul24.ru/register/" )
    )
  
 
  let $currentFormID := 
    if ( session:get( "userid" ) )
    then ( getFormID:id( $id, session:get( "userid" ) ) )
    else ( getFormID:id( $id )  )
  
  let $formMeta := 
     try {
       fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $currentFormID || "/meta" )/form
     }
     catch* { }
  let $formFields := 
     try {
       fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $currentFormID || "/fields" )/csv
     }
     catch* { }
  
  let $sidebar := 
    if( session:get( "userid" ) )
    then(
      let $userForms := 
        try {
          fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || session:get( "userid" ) || "/forms")/forms/form
        }
        catch*{}
      return
        <div class="col">
          <h3>Ваши шаблоны</h3> 
            {
              sidebar:userFormsList ( $userForms, $config:param )
            }
        </div>
    )
    else ()
    
  let $content := 
     switch ( $page )
       case ( "form" )
         return (
           <div class="container">
           <h3>{ $formMeta/@label/data() }</h3>
           { form:metaButtons ( $currentFormID, $config:getFormByAPI ) }
           { form:form ( $formMeta, $formFields ) }
           <div class="form-group">
              <input form="template" type="hidden" name="fileName" value="ZapolniTitul.docx"></input>
              <input form="template" type="hidden" name="templatePath" 
                value='{"http://localhost:8984/zapolnititul/api/v2/forms/" || $currentFormID || "/template"}' >
              </input>
            <button form="template" type="submit" formaction="/zapolnititul/api/v1/document" class="btn btn-success mx-3">
             Скачать заполненную форму
            </button>
            <button form="template" type="submit" formaction="{'/zapolnititul/forms/u/child/' || $currentFormID }" formmethod="GET" class="btn btn-info mx-3">
              Создать дочернюю форму
            </button>
          </div>
          </div>
        )
       case ( "upload" )
         return
           upload:main( "yes", $id, $config:param( "host" ) || "/zapolnititul/forms/u/complete/" )
       case ( "complete" )
         return 
           complete:main( $formMeta )
       case ( "child" )
         return 
           child:main( $formMeta, $formFields )
       default return ""
    
  let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
  let $nav :=
    <div class="form-group"> 
      <form method="GET" action="/zapolnititul/forms/u/upload/new">
        <input class="btn btn-info" type="submit" value="Новая форма"/>
      </form>
    </div>
  
  let $templateFieldsMap := map{ "sidebar": $sidebar, "content": $content, "nav": $nav, "nav-login" : $login }
  return 
    if( $page = ( "form", "upload", "complete", "child" ) )
    then(
      html:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )
    )
    else(
      web:redirect( "http://localhost:8984/zapolnititul/forms/u/" )
    )
};

declare 
  %private
function forms:loginForm ( $actionURL, $callbackURL, $regURL ) {
  <div class="form-group">
    <div class="form-inline">
      <form method="GET" action="{ $actionURL }" class="form-group form-inline my-sm-0">
        <input type="text" name="username" placeholder="логин"  class="mr-sm-1"/>
        <input type="password" name="password" placeholder="пароль" class="mr-sm-1"/>
        <input type="hidden" name="callbackURL" value="{ $callbackURL }"/>
        <input class="btn btn-info" type="submit" value="Войти"/>
      </form>
    </div>
    <div class="my-sm-0">
        <a class="text-muted" href="{ $regURL }">Зарегистрироваться</a>
    </div>
  </div>
};

declare 
  %private
function forms:logoutForm( $actionURL, $username, $callbackURL ) {
  <div class="form-group form-inline text-muted">
    <form method="GET" action="{ $actionURL }">
      { $username }
      <input type="hidden" name="callbackURL" value="{ $callbackURL }"/>
      <input class="btn btn-info ml-sm-1" type="submit" value="Выйти"/>
    </form>
  </div>
};