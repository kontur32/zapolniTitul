module namespace zt = "http://dbx.iro37.ru/zapolnititul/";

import module namespace functx = "http://www.functx.com"; 

declare variable $zt:rootPath := "https://docs.google.com/spreadsheets/d/e/2PACX-1vTy56_CSURLwhsG5xwkWGf1EamtjJ1ReB-5qTzRJnYsQ3dXBO57d_8pQkdSGTftVF294fpe7nAgDpt1/pub?gid=746210905&amp;single=true&amp;output=csv";

declare 
  %rest:path ( "/zapolnititul/v" )
  %output:method ("xhtml")
function zt:main1 ( ) {
  <a href="/zapolnititul/v/ivgpu?path=iitegn/euf&amp;form=magDiplom&amp;title=Кафедра экономики, управления и финансов">/zapolnititul/v/ivgpu?path=iitegn/euf&amp;form=magDiplom&amp;title=Кафедра экономики, управления и финансов</a>
};

declare 
  %rest:path ( "/zapolnititul/v/{$org}" )
  %rest:query-param( "path", "{$path}", "")
  %rest:query-param( "form", "{$form}")
  %output:method ("xhtml")
function zt:main ( $org as xs:string, $path as xs:string , $form as xs:string ) {
  
  let $data := zt:formData ( $zt:rootPath, $org || "/" || $path, $form )
  
  let $sidebar := 
    <div class = "pt-3" >
      <img class="img-fluid"  src="{ $data/logoPath/text() }"/>
    </div>

  let $content := 
    let $contentTemplate := serialize( doc("src/content-tpl.html") )
    let $inputFormData := csv:parse ( fetch:text ( $data/formURL/text() ), map { 'header': true() } )
    let $inputForm := zt:buildInputForm (  $inputFormData, $data/formTemplate/text() )
    let $templateFieldsMap := map{ 
                  "OrgLabel": $data/formTitle/text(), 
                  "TitulLabel": $data/formLabel/text(),
                  "Template" : $data/formTemplate/text(),
                  "inputForm" : $inputForm
                }
      return zt:fill-html-template( $contentTemplate, $templateFieldsMap )/child::*
  
  let $siteTemplate := serialize( doc( "src/main-tpl.html" ) )
  let $templateFieldsMap := map{"sidebar": $sidebar, "content":$content, "nav": "", "nav-login" : ""}
    return zt:fill-html-template( $siteTemplate, $templateFieldsMap )/child::*
};

declare function zt:formPath ( $path, $URL ) {
  if ( substring-before ( $path, "/") )
  then (
    let $domain := substring-before ( $path, "/")
    let $data := 
      csv:parse ( fetch:text ( $URL ), map { 'header': true() } )
    return 
       zt:formPath ( substring-after ( $path, "/" ), $data/csv/record[ ID = $domain ]/URL/text() )
  )
  else (
    let $data := 
      csv:parse ( fetch:text ( $URL ), map { 'header': true() } )
    return 
      $data/csv/record[ ID = $path ]/URL/text()
  )
};

declare function zt:formData ( $rootPath, $path, $formID ) {
  let $formsPath := zt:formPath ( $path, $rootPath )
  let $formData := csv:parse (fetch:text ( $formsPath ), map { 'header': true() } )/csv/record[ formID = $formID ]
    return 
      $formData  
}; 

declare function zt:buildInputForm ( $inputFormData, $templatePath ){
  
  let $inputFormFields :=
     for $field in $inputFormData/csv/record
     return
       switch ( $field/inputType/text() ) 
       case ( "text" )
         return
           <div> 
             <label>
               <p>{ $field/label/text() }</p>
               <input type="text" size = "45" name="{ $field/ID/text() }" value="{ $field/defaultValue/text() }">{}</input>
             </label>
           </div>
       case  ( "textarea" ) 
         return
           <div>
             <label>
               <p>{ $field/label/text() }</p> 
               <textarea cols="45" name="{ $field/ID/text() }">{ $field/defaultValue/text() }</textarea>
             </label>
           </div>
       default return ""
 
  return
     <form method="GET" action="/docx/api/заполниТитул.docx">
       { $inputFormFields }
        <p>и нажмите </p>
        <input type="hidden" size = "45" name="template" value="{ $templatePath }"/>
        <input class="btn btn-info" type="submit" value="Скачать..."/>
     </form>
 };
(: ------------------------------------------------------------------------------ :)

declare function zt:fill-html-template( $template, $content )
{
  let $changeFrom := 
      for $i in map:keys($content)
      return "\{\{" || $i || "\}\}"
  let $changeTo := map:for-each( $content, function( $key, $value ) { serialize( $value ) } )
  return 
     parse-xml ( functx:replace-multi ($template, $changeFrom, $changeTo) )
};