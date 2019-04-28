module namespace confirm = "http://dbx.iro37.ru/zapolnititul/forms/confirm";

import module namespace Session = "http://basex.org/modules/session";
import module namespace htmlZT =  "http://dbx.iro37.ru/zapolnititul/funct/htmlZT" at "../funct/htmlZT.xqm";

declare 
  %rest:path ( "/zapolnititul/v/forms/complete/{$id}" )
  %rest:query-param( "href", "{ $href }", "/zapolnititul/v/forms" )
  %output:method ("xhtml")
function confirm:main ( $id, $href ) {
  let $form := db:open("titul24", "forms")/forms/form[ @id = $id ]
  let $href := $href || "?id=" || $id
  let $content :=
    <div>
      <h2>Загрузка шаблона завершена</h2>
      <p>Вы успешно загрузили шаблон <b>{ $form/@label/data() }</b></p>
      <p>Ссылка для заполнения шаблона <a class="btn btn-info" href="{ $href }">здесь</a></p>
      <p>Обязательно сохраните эту ссылку</p>
    </div>
 let $siteTemplate := serialize( doc( "../src/main-tpl.html" ) )
 let $templateFieldsMap := map{ "sidebar" : "", "content" : $content, "nav" : "", "nav-login" : Session:get("username") }
    return htmlZT:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};