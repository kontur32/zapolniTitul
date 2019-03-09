module namespace htmlZT =  "http://dbx.iro37.ru/zapolnititul/funct/htmlZT";

import module namespace functx = "http://www.functx.com";

declare function htmlZT:fillHtmlTemplate( $template, $content )
{
  let $changeFrom := 
      for $i in map:keys( $content )
      return "\{\{" || $i || "\}\}"
  let $changeTo := map:for-each( $content, function( $key, $value ) { serialize( $value ) } )
  return 
     parse-xml ( functx:replace-multi ( $template, $changeFrom, $changeTo) )
};