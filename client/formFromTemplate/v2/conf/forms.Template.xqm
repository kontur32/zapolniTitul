module namespace template = "http://dbx.iro37.ru/zapolnititul/forms/u/template";

declare %private variable $template:SourcePath := "../src/";

declare variable $template:get := function( $templateID as xs:string ){
  let $templateData := 
    <templates>
      <template id="main" path="main-tpl.html" />
    </templates>
    
  return 
    doc( $template:SourcePath || $templateData/template[ @id = $templateID ]/@path/data() )
};