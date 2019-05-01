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
  let $userForms := 
    try {
      fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || session:get( "userid" ) || "/forms")/forms/form
    }
    catch*{}
  
  let $currentFormID := 
    if ( $id ) 
    then ( $id ) 
    else ( 
      if ( $userForms[ 1 ]/@id )
      then ( $userForms[ 1 ]/@id )
      else (
        try {
          fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms?offset=3&amp;limit=1")//form[1]/@id/data()
        }
        catch*{}
      )
    )
  let $sidebar := 
    if( session:get( "userid") )
    then(
      <div>
        <h3>Ваши шаблоны</h3>
        <div class="form-group form-check-inline">
        <form method="POST" action="/zapolnititul/api/v2/forms/delete" enctype="multipart/form-data">
          <input type="hidden" name="redirect" value="/zapolnititul/forms/u/main"/>
          <button class="btn btn-info" onclick="return confirm('Удалить?');">Удалить…</button> 
          <div>
            { 
             for $f in $userForms
             return
               <div>
                   <input type="checkbox" name="id" value="{ $f/@id/data() }" onclick="buttons(this)">
                     <a href="/zapolnititul/forms/u/form?id={ $f/@id/data() }">
                     { if( $f/@label/data() !="" ) then ( $f/@label/data() ) else ( "Без имени" ) }
                     </a>
                   </input>
               </div>
            }
           </div>
         </form>
         </div>
       </div>
    )
    else ()
   let $formMeta := 
     try {
       fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $currentFormID || "/meta" )/form
     }
     catch* { }
            
  let $content := 
     switch ( $page )
       case ( "form" )
         return
           let $formData :=
             try {
                fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $currentFormID || "/fields" )//csv
             }
             catch* { <csv/> } 
           let $formLabel := 
             if ( $formMeta/@label/data() )
             then ( $formMeta/@label/data() )
             else ( "Шаблон без названия" )
           return
             <div>
               <h3>{ $formLabel }</h3>
               {
                buildForm:buildInputForm ( 
                  $formData, 
                  map{ 
                    "id" : $currentFormID, 
                    "templatePath" : $formMeta/@fileFullPath, 
                    "method" : "POST", 
                    "action" : "/zapolnititul/api/v1/document" }
                  )
               }
              </div>
       case ( "upload" )
         return
           forms:uploadForm ( "yes" )
       case ( "complete" )
         return 
           forms:complete( $formMeta )
       default return ""
    
  let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
  let $nav :=
    <div class="form-group"> 
      <form method="GET" action="/zapolnititul/forms/u/upload">
        <input class="btn btn-info" type="submit" value="Новая форма"/>
      </form>
    </div>
  let $templateFieldsMap := map{ "sidebar": $sidebar, "content": $content, "nav": $nav, "nav-login" : $login }
  return 
    if( $page = ( "form", "upload", "complete" ) )
    then(
      html:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
    )
    else(
      web:redirect( "http://localhost:8984/zapolnititul/forms/u/form" )
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

declare function forms:uploadForm( $data ) {
  <div>
    <h1>Загрузка шаблона</h1>
    <div class="form-group">
     <form method="POST" action="/zapolnititul/api/v2/forms/post" enctype="multipart/form-data">
        <div class="form-group">
         <label>Укажите название шаблона</label>
         <input class="form-control" type="text" name="label"/>
       </div>
       <div class="form-group">
         <label>Выберите файл с шаблоном</label>
         <input class="form-control" type="file" name="template" multiple="multiple"/>
       </div>
       {
         if ( $data = "yes")
         then (
           <div class="form-group">
             <label>Выберите файл с данными (.xlsx)</label>
             <input class="form-control" type="file" name="data" multiple="multiple"/>
           </div>
         )
         else ()
       }
        <input class="form-control" type="hidden" name="redirect" value="/zapolnititul/forms/u/complete"/>
        <p>и нажмите </p>
        <input class="btn btn-info" type="submit" value="Загрузить..."/>
     </form>
    </div>
  </div>
};

declare function forms:complete( $formMeta ) {
  <div>
    <h2>Загрузка шаблона завершена</h2>
    <p>Вы успешно загрузили шаблон <b>{ $formMeta/@label/data() }</b></p>
    <p>Ссылка на форму шаблона <a href="{ '/zapolnititul/forms/u/form?id=' || $formMeta/@id/data() }">здесь</a></p>
  </div>
};