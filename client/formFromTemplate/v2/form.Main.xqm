module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";
import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "../../funct/buildForm.xqm";


declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/u/{ $page }" )
  %rest:query-param( "id", "{ $id }", "")
  %rest:query-param( "message", "{ $message }", "")
  %output:method ("xhtml")
function forms:main ( $page, $id, $message ) {
  let $login := 
    if ( session:get( 'username' ) )
    then ( 
      forms:logoutForm ( "/zapolnititul/api/v1/users/logout", session:get( "username" ), "/zapolnititul/forms/u/" || $page )
     )
    else ( 
      forms:loginForm ( "/zapolnititul/api/v1/users/login", "/zapolnititul/forms/u/" || $page , "#" )
    )
  let $sidebar := 
    if( session:get( "userid") )
    then(
      <ul>{ 
         for $f in fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || session:get( "userid" ) || "/forms")/forms/form
         return
           <li>{ $f/@id/data() }</li>
       }</ul>
    )
    else ()
    
  let $content := 
     switch ( $page )
       case ( "main" )
         return
           let $formData := 
            fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $id || "/fields" )//csv
           return
              buildForm:buildInputForm ( 
                $formData, 
                map{ 
                  "id" : $id, 
                  "templatePath" : "", 
                  "method" : "POST", 
                  "action" : "/zapolnititul/api/v1/document" }
                ) 
       case ( "upload" )
         return
           "Загрузка"
       case ( "complete" )
         return "Загрузка завершена"
       default return ""
    
  let $siteTemplate := serialize( doc( "../../src/main-tpl.html" ) )
  let $templateFieldsMap := map{ "sidebar": $sidebar, "content": $content, "nav": "", "nav-login" : $login }
  return 
    if( $page = ( "main", "upload", "complete" ) )
    then(
      html:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
    )
    else(
      web:redirect( "http://localhost:8984/zapolnititul/forms/u/main" )
    )
  
};

declare 
  %private
function forms:loginForm ( $actionURL, $callbackURL, $regURL ) {
  <div class="form-group">
    <form method="GET" action="{ $actionURL }" class="form-group form-inline my-sm-0">
      <input type="text" name="username" placeholder="логин"  class="mr-sm-1"/>
      <input type="password" name="password" placeholder="пароль" class="mr-sm-1"/>
      <input type="hidden" name="callbackURL" value="{ $callbackURL }"/>
      <input class="btn btn-info" type="submit" value="Войти"/>
    </form>
    <div class="my-sm-0">
      <a href="{ $regURL }">Зарегистрироваться</a>
    </div>
  </div>
};

declare 
  %private
function forms:logoutForm ( $actionURL, $username, $callbackURL ) {
  <div class="form-group form-check-inline">
    <form method="GET" action="{ $actionURL }">
      { $username }
      <input type="hidden" name="callbackURL" value="{ $callbackURL }"/>
      <input class="btn btn-info ml-sm-1" type="submit" value="Выйти"/>
    </form>
  </div>
};

