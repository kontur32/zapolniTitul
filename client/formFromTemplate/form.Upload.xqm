module namespace upload = "http://dbx.iro37.ru/zapolnititul/forms/upload";

import module namespace Session = "http://basex.org/modules/session";
import module namespace htmlZT =  "http://dbx.iro37.ru/zapolnititul/funct/htmlZT" at "../funct/htmlZT.xqm";

declare 
  %rest:path ( "/zapolnititul/v/forms/upload" )
  %rest:query-param( "data", "{ $data }", "no")
  %output:method ("xhtml")
function upload:main ( $data ) {
  let $content :=
  <div>
    <h1>Загрузка шаблона</h1>
    <div class="form-group">
     <form method="POST" action="/zapolnititul/api/v1/forms/upload" enctype="multipart/form-data">
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
        <input class="form-control" type="hidden" name="redirect" value="/zapolnititul/v/forms/complete/"/>
        <p>и нажмите </p>
        <input class="btn btn-info" type="submit" value="Загрузить..."/>
     </form>
    </div>
  </div>
 let $siteTemplate := serialize( doc( "../src/main-tpl.html" ) )
 let $templateFieldsMap := map{"sidebar": "", "content":$content, "nav": "", "nav-login" : Session:get("username")}
    return htmlZT:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};