module namespace template = "http://dbx.iro37.ru/zapolnititul/forms/u/template";

declare %private variable $template:SourcePath := "../src/";

declare %private variable  
   $template:data := 
    <templates>
      <template id="form" path="main-tpl2.html" />
      <template id="data" path="main-tpl2.html" />
      <template id="complete" path="main-tpl.html" />
      <template id="child" path="main-tpl2.html" />
      <template id="iframe" path="iframe-tpl.html" />
      <template id="logout" path="logout-tpl.html" />
      <template id="login" path="login-tpl.html" />
    </templates>;

declare variable $template:get := function( $templateID as xs:string ) as node() {
    doc( $template:SourcePath || $template:data/template[ @id = $templateID ]/@path/data() )
};