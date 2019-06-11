module namespace zt = "http://dbx.iro37.ru/zapolnititul/";

import module namespace session = "http://basex.org/modules/session";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  template = "http://dbx.iro37.ru/zapolnititul/forms/u/template" 
  at "formFromTemplate/v2/conf/conf.Template.xqm";

import module namespace buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "funct/buildForm.xqm";
import module namespace formData = "http://dbx.iro37.ru/zapolnititul/formData" at "funct/formData.xqm";
import module namespace htmlZT = "http://dbx.iro37.ru/zapolnititul/funct/htmlZT" at "funct/htmlZT.xqm";

declare variable $zt:rootPath := "https://docs.google.com/spreadsheets/d/e/2PACX-1vTy56_CSURLwhsG5xwkWGf1EamtjJ1ReB-5qTzRJnYsQ3dXBO57d_8pQkdSGTftVF294fpe7nAgDpt1/pub?gid=746210905&amp;single=true&amp;output=csv";

declare 
  %rest:path ( "/zapolnititul" )
  %output:method ("xhtml")
function zt:start ( ) {
  let $href_upload := "/zapolnititul/forms/u/upload/new"
  let $content :=
  <div class="col">
  <div class="p-3">
    <p>
      Публикуйте шаблоны для удобного заполнения и выгрузки. 
      <a href="/zapolnititul/v/ivgpu?path=iitegn/euf&amp;form=magDiplom">Например, такие...</a>
    </p>
    <p>
      Как создать простой шаблон посмотрите 
      <a class="btn btn-info" href="https://youtu.be/QzxlRRRCLeI">видео</a>
       или прочитайте <a class="btn btn-info" href="http://portal.titul24.ru/pervij-shablon/">инструкцию</a>
    </p>
    {
      if ( session:get( 'username' ) )
      then(
        <p>Чтобы создать свой первый шаблон, перейдите в <a class="btn btn-info" href="/zapolnititul/forms/u/form/new">в личный кабинет</a></p>
      )
      else(
        <div>
          <p>Чтобы загрузить шаблон без регистрации, Вам <a class="btn btn-info" href="/zapolnititul/forms/a/upload">сюда</a></p>
          <p>Для управления шаблонами и данными введите Ваш логин и пароль. Если Вы ещё не зарегистрированы, то Вам <a class="btn btn-info" href="http://portal.titul24.ru/register/">сюда</a></p>
        </div>
      )
    }
  </div>
  </div>
  let $nav-login := 
    if ( session:get( 'username' ) )
    then ( 
      html:fillHtmlTemplate(
         serialize( $template:get( "logout" ) ), 
         map{
           "username" : session:get( "username" ),
           "callbackURL" : "/zapolnititul/forms/u/"
         }
       )
     )
    else ( 
      html:fillHtmlTemplate(
           serialize( $template:get( "login" ) ), 
           map{ "callbackURL" : "/zapolnititul/forms/u/" }
         )
    )

 let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
 let $templateFieldsMap := map{"sidebar": "", "content":$content, "nav": "", "nav-login" : $nav-login}
    return htmlZT:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};

declare 
  %rest:path ( "/zapolnititul/v/{$org}" )
  %rest:query-param( "path", "{ $path }", "")
  %rest:query-param( "form", "{ $formID }")
  %output:method ("xhtml")
function zt:form ( $org as xs:string, $path as xs:string , $formID as xs:string ) {
  let $data := formData:getFormData ( $zt:rootPath, $org || "/" || $path, $formID )
  let $sidebar := 
    <div class = "pt-3" >
      <img class="img-fluid"  src="{ $data/logoPath/text() }"/>
    </div>

  let $content := 
    let $inputFormParam := csv:parse( fetch:text( $data/formURL/text() ), map { 'header': true() } )/csv
    let $inputForm := 
      <div>
        {
        buildForm:buildInputForm (  
          $inputFormParam, 
           map{ 
              "id" : "id", 
              "templatePath" :  $data/formTemplate/text(), 
              "method" : "POST", 
              "action" : "/zapolnititul/api/v1/document"
            }
        )
        }
        <div class="form-group">
              <input form="template" type="hidden" name="_t24_fileName" value="ZapolniTitul.docx"></input>
              <input form="template" type="hidden" name="_t24_templatePath" 
                value='{ $data/formTemplate/text() }' >
              </input>
            <button form="template" type="submit" formaction="/zapolnititul/api/v1/document" class="btn btn-success mx-3">
             Скачать заполненную форму
            </button>
       </div>
     </div> 
    let $templateFieldsMap := map{ 
                  "OrgLabel": $data/formTitle/text(), 
                  "Title": $data/formLabel/text(),
                  "inputForm" : $inputForm
                }
    let $contentTemplate := serialize( doc("src/content-tpl.html") )
    return htmlZT:fillHtmlTemplate( $contentTemplate, $templateFieldsMap )/child::*
  
  let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
  let $templateFieldsMap := map{"sidebar": $sidebar, "content":$content, "nav": "", "nav-login" : ""}
    return htmlZT:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};