module namespace forms = "http://dbx.iro37.ru/zapolnititul/forms/main";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  template = "http://dbx.iro37.ru/zapolnititul/forms/u/template" at "conf/forms.Template.xqm";


declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/test/{ $page }/{$id}" )
  %rest:query-param( "datainst", "{ $datainst }", "")
  %rest:query-param( "dataver", "{ $dataver }", "")
  %rest:query-param( "message", "{ $message }", "")
  %output:method ("xhtml")
function forms:main ( $page, $id, $datainst, $dataver, $message ) {
  let $content := 
    <div class="row mt-5">
      <div class="col-md-6 border-right">Первая</div>
      <div class="col-md-3 border-right">Вторая</div>
      <div class="col-md-3">Третья</div>
    </div>
  let $templateFieldsMap := map{ "content": $content, "nav": "", "nav-login" : "" }
  let $siteTemplate := serialize( doc("src/main-tpl-footer.html") )
  return
    html:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )
};