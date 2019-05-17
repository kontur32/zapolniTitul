module namespace iframe = "http://dbx.iro37.ru/zapolnititul/forms/iframe";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
  
declare 
  %public
function iframe:main( $currentFormID, $formElement, $apiURL, $param ){
  let $formMeta := $formElement( $currentFormID, "meta" )/form
  let $formFields := $formElement( $currentFormID, "fields" )/csv
  return
  <div class="container-fluid">{
    form:body ( $formMeta, $formFields ),
    <input form="template" type="hidden" name="fileName" value="{ iri-to-uri( $formMeta/@fileNameOriginal ) }"></input>,
    <input form="template" type="hidden" name="templatePath" 
      value='{ $apiURL( $currentFormID, "template" ) }' >
    </input>,
    <button form="template" type="submit" formaction="{  $param('host') || $param('formTarget')  }" class="btn btn-success mr-3">
         Скачать заполненную форму
    </button>,
     <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"/>
  }</div>
};
