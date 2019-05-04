module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";
import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "../../funct/buildForm.xqm";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  funct = "http://dbx.iro37.ru/zapolnititul/forms/funct" at "funct/funct.xqm";

declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/u" )
function forms:user ( ) {
  let $redirect := 
    if ( session:get( 'username' ) )
    then (
      let $userFormID := 
        try {
          fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || session:get( "userid" ) || "/forms")/forms/form[1]/@id/data()
        }
        catch*{}
      return
      "/zapolnititul/forms/u/form/" || $userFormID
    )
    else (
      "/zapolnititul"
    )
  return 
    web:redirect ( $config:param( "host" ) ||  $redirect )
};

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
  let $userForms := 
    try {
      fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || session:get( "userid" ) || "/forms")/forms/form
    }
    catch*{}
  
  let $currentFormID := 
    if ( $id ) 
    then (
       let $formMeta := 
         try {
           fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $id || "/meta" )/form
         }
         catch* { }
         return 
           if ( $formMeta )
           then ( $formMeta/@id/data() )
           else (
             let $total := 
               try {
                 fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms" )/forms/@total/data()
               }
               catch* { }
              let $id := 
               try {
                 fetch:xml( web:create-url( "http://localhost:8984/zapolnititul/api/v2/forms", map {"offset" : $total - 1, "limit" : 1 } ) )/forms/form/@id/data()
               }
               catch* { }
               return $id
           )
    ) 
    else ( 
      if ( $userForms[ 1 ]/@id )
      then ( $userForms[ 1 ]/@id )
      else (
        try {
          fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms?offset=3&amp;limit=1" )//form[last()]/@id/data()
        }
        catch*{}
      )
    )
    
  let $currentFormID := 
    if ( session:get( "userid" ) )
    then ( funct:id( $id, session:get( "userid" ) ) )
    else ( funct:id( $id)  )
    
  let $sidebar := 
    if( session:get( "userid" ) )
    then(
      <div class="col">
        <h3>Ваши шаблоны</h3>
       <div class="row">
           <div>{
             for $f in $userForms
             let $href_upload := 
               web:create-url( $config:param( "uploadForm" ) || $f/@id/data(), map{ "id2" : $f/@id/data() } )
             let $href_delete := 
               web:create-url( $config:param( "deleteAPI" ), map{ "id" : $f/@id/data(), "redirect" :$config:param( 'host' ) || '/zapolnititul/forms/u/form' } )
             return
             <div class="row">
                <a class="px-2" href="{ $href_upload }">
                  <img width="18" src="{ $config:param( 'iconUpload' ) }" alt="Обновить" />
                </a>
                <a class="pr-2" href="{ $href_delete }" onclick="return confirm( 'Удалить?' );">
                  <img width="18" src="{ $config:param( 'iconDelete' ) }" alt="Удалить" />
                </a>
                <a href="/zapolnititul/forms/u/form/{ $f/@id/data() }">
                  <span class="d-inline-block text-truncate" style="max-width: 240px;">
                    { if( $f/@label/data() !="" ) then ( $f/@label/data() ) else ( "Без имени" ) }
                  </span>
                </a>
              </div>
           }</div>
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
               <div class="row">
                 <form class="ml-3 form-inline">
                 <button type="submit" formaction="{ $formMeta/@fileFullPath }" class="btn btn-info mx-3">
                   Шаблон
                 </button>
                  { if ( $formMeta/@dataFullPath/data() )
                   then (
                    <button type="submit" formaction="{ $formMeta/@dataFullPath }" class="btn btn-info">
                       Данные
                    </button>
                   )
                   else ( )
                  }
                 { if ( $formMeta/@imageFullPath/data() )
                   then (
                     <button type="button" class="btn btn-info mx-3" data-toggle="modal" data-target="#myModal">
                       Изображение
                     </button>
                   )
                   else ( )
                 }
                 </form>
                { 
                  html:fillHtmlTemplate( 
                    serialize( doc( "src/modal.html" ) ),
                    map{ "image" : <img width="100%" src="{ $formMeta/@imageFullPath }"/>}
                  ) 
                }
               </div>
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
           forms:uploadForm ( "yes", $id, $config:param( "host" ) || "/zapolnititul/forms/u/complete/" )
       case ( "complete" )
         return 
           forms:complete( $formMeta )
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
    if( $page = ( "form", "upload", "complete" ) )
    then(
      html:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )
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

declare function forms:uploadForm( $isData, $id, $redirect ) {
  <div>
    <h1>Загрузка шаблона</h1>
    <div class="form-group">
     <form method="POST" action="/zapolnititul/api/v2/forms/post" enctype="multipart/form-data">
        <div class="form-group">
         <label>Укажите название шаблона</label>
         <input class="form-control" type="text" name="label" required=""/>
       </div>
       <div class="form-group">
         <label>Выберите файл с шаблоном</label>
         <input class="form-control" type="file" name="template" required="" accept=".docx"/>
       </div>
       
       <button class="btn btn-info" type="button" data-toggle="collapse" data-target="#uploadAdditional" aria-expanded="false" aria-controls="uploadAdditional">
        Дополнительные параметры шаблона
      </button>
       
       <div class="collapse" id="uploadAdditional">
       <div class="card card-body">
       {
         if ( $isData = "yes")
         then (
           <div class="form-group">
             <label>Выберите файл с данными (.xlsx)</label>
             <input class="form-control" type="file" name="data" accept=".xlsx"/>
           </div>
         )
         else ()
       }
        <div class="form-group">
         <label>Выберите файл с изображением шаблона</label>
         <input class="form-control" type="file" name="template-image" accept="image/*"/>
       </div>
      </div>
      </div>
        <input type="hidden" name="id" value="{ $id }"/>
        <input type="hidden" name="redirect" value="{ $redirect }"/>
        <p>и нажмите </p>
        <input class="btn btn-primary" type="submit" value="Загрузить..."/>
     </form>
    </div>
    
  </div>
};

declare function forms:complete( $formMeta ) {
  <div>
    <h2>Загрузка шаблона завершена</h2>
    <p>Вы успешно загрузили шаблон <b>{ $formMeta/@label/data() }</b></p>
    <p>Ссылка на форму шаблона <a href="{ '/zapolnititul/forms/u/form/' || $formMeta/@id/data() }">здесь</a></p>
  </div>
};