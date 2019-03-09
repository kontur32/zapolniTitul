module namespace upload = "http://dbx.iro37.ru/zapolnititul/form/upload";

import module namespace htmlZT =  "http://dbx.iro37.ru/zapolnititul/funct/htmlZT" at "../funct/htmlZT.xqm";

declare 
  %rest:path ( "/zapolnititul/forms/upload" )
  %output:method ("xhtml")
function upload:start ( ) {
  let $content :=
  <div>
    <h1>ЗагрузиШаблон</h1>
    <div class="form-group">
     <form method="POST" action="/zapolnititul/api/v1/forms/upload" enctype="multipart/form-data">
        <div class="form-group">
         <label>Укажите название шаблона</label>
         <input class="form-control" type="text" name="label"/>
       </div>
       <div class="form-group">
         <label>Выберите файл с шаблоном</label>
         <input class="form-control" type="file" name="file" multiple="multiple"/>
       </div>
        <p>и нажмите </p>
        <input class="btn btn-info" type="submit" value="Загрузить..."/>
     </form>
    </div>
  </div>
 let $siteTemplate := serialize( doc( "../src/main-tpl.html" ) )
 let $templateFieldsMap := map{"sidebar": "", "content":$content, "nav": "", "nav-login" : ""}
    return htmlZT:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};