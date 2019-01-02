module namespace zt = "http://dbx.iro37.ru/zapolnititul/";

import module namespace buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "buildForm.xqm";
import module namespace functx = "http://www.functx.com"; 

declare variable $zt:rootPath := "https://docs.google.com/spreadsheets/d/e/2PACX-1vTy56_CSURLwhsG5xwkWGf1EamtjJ1ReB-5qTzRJnYsQ3dXBO57d_8pQkdSGTftVF294fpe7nAgDpt1/pub?gid=746210905&amp;single=true&amp;output=csv";

declare 
  %rest:path ( "/zapolnititul/v" )
  %output:method ("xhtml")
function zt:main1 ( ) {
  <a href="/zapolnititul/v/ivgpu?path=iitegn/euf&amp;form=magDiplom">/zapolnititul/v/ivgpu?path=iitegn/euf&amp;form=magDiplom</a>
};

declare 
  %rest:path ( "/zapolnititul/v/{$org}" )
  %rest:query-param( "path", "{$path}", "")
  %rest:query-param( "form", "{$formID}")
  %output:method ("xhtml")
function zt:main ( $org as xs:string, $path as xs:string , $formID as xs:string ) {
  
  let $data := zt:getFormData ( $zt:rootPath, $org || "/" || $path, $formID )
  
  let $sidebar := 
    <div class = "pt-3" >
      <img class="img-fluid"  src="{ $data/logoPath/text() }"/>
    </div>

  let $content := 
    let $inputFormData := csv:parse ( fetch:text ( $data/formURL/text() ), map { 'header': true() } )
    let $inputForm := buildForm:buildInputForm (  $inputFormData, $data/formTemplate/text() )
    let $templateFieldsMap := map{ 
                  "OrgLabel": $data/formTitle/text(), 
                  "Title": $data/formLabel/text(),
                  "inputForm" : $inputForm
                }
    let $contentTemplate := serialize( doc("src/content-tpl.html") )
    return zt:fillHtmlTemplate( $contentTemplate, $templateFieldsMap )/child::*
  
  let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
  let $templateFieldsMap := map{"sidebar": $sidebar, "content":$content, "nav": "", "nav-login" : ""}
    return zt:fillHtmlTemplate( $siteTemplate, $templateFieldsMap )/child::*
};

declare function zt:getFormData ( $rootPath, $path, $formID ) {
  let $formsPath := zt:formPath ( $path, $rootPath )
  let $formData := csv:parse ( fetch:text ( $formsPath ), map { 'header': true() } )/csv/record[ formID = $formID ]
    return 
      $formData  
}; 

declare function zt:formPath ( $path, $URL ) {
  let $data := 
      csv:parse ( fetch:text ( $URL ), map { 'header': true() } )
  return
    if ( substring-before ( $path, "/") )
    then (
      let $domain := substring-before ( $path, "/")
      return 
         zt:formPath ( 
           substring-after ( $path, "/" ), 
           $data/csv/record[ fn:normalize-space ( ID ) = $domain ]/URL/text()
         )
    )
    else (
         $data/csv/record[ fn:normalize-space ( ID ) = $path ]/URL/text()
    )
};

(: ------------------------------------------------------------------------------ :)

declare function zt:fillHtmlTemplate( $template, $content )
{
  let $changeFrom := 
      for $i in map:keys( $content )
      return "\{\{" || $i || "\}\}"
  let $changeTo := map:for-each( $content, function( $key, $value ) { serialize( $value ) } )
  return 
     parse-xml ( functx:replace-multi ( $template, $changeFrom, $changeTo) )
};