module namespace zt = "http://dbx.iro37.ru/zapolnititul/";
import module namespace functx = "http://www.functx.com"; 

declare 
  %rest:path ( "/zapolnititul/{$org}" )
  %rest:query-param( "titul", "{$titul}")
  %output:method ("xhtml")
function zt:main ( $org as xs:string, $titul as xs:string ) {
  
  let $dataQuery := "https://docs.google.com/spreadsheets/d/e/2PACX-1vTy56_CSURLwhsG5xwkWGf1EamtjJ1ReB-5qTzRJnYsQ3dXBO57d_8pQkdSGTftVF294fpe7nAgDpt1/pub?gid=0&amp;single=true&amp;output=csv"
  
  let $data := 
    csv:parse (fetch:text ( $dataQuery ), map { 'header': true() } )/csv/record[ OrgID= $org and TitulID = $titul ][ 1 ]
  
  let $sidebar := 
    <div class = "pt-3" >
      <img class="img-fluid"  src="{$data/Logo/text()}"/>
    </div>

  let $content := 
    let $template := serialize( doc("src/content-tpl.html") )
    let $map := map{ 
                  "OrgLabel": upper-case( $data/OrgLabel/text() ), 
                  "TitulLabel": $data/TitulLabel/text()
                }
      return zt:fill-html-template( $template, $map )/child::*
  
  let $template := serialize( doc("src/main-tpl.html") )
  let $map := map{"sidebar": $sidebar, "content":$content, "nav": "", "nav-login" : ""}
    return zt:fill-html-template( $template, $map )/child::*
};

declare function zt:fill-html-template( $template, $content )
{
  let $changeFrom := 
      for $i in map:keys($content)
      return "\{\{" || $i || "\}\}"
  let $changeTo := map:for-each( $content, function( $key, $value ) { serialize( $value ) } )
  return 
     parse-xml ( functx:replace-multi ($template, $changeFrom, $changeTo) )
};
