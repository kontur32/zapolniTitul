module namespace getSource = "http://dbx.iro37.ru/zapolnititul/api/v2.1/public/";

import module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data" 
  at "../functions/data.xqm";

import module namespace yandex = "http://dbx.iro37.ru/zapolnititul/api/v2.1/resource/yandex"
  at '../functions/yandex.xqm';

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2.1/data/public/sources/{ $sourceID }" )
function getSource:main(
  $sourceID as xs:string
)
{
  let $ID := "http://dbx.iro37.ru/zapolnititul/сущности/запросЯндексДиск#" || $sourceID
  let $data := 
    db:open( 'titul24' )
    /data/table[ row[ @id = "http://dbx.iro37.ru/zapolnititul/сущности/запросЯндексДиск#" || $sourceID ] ][last()]/row
  let $token := $data/cell[ @id="http://dbx.iro37.ru/zapolnititul/сущности/токенДоступа" ]/text()
  let $path :=  iri-to-uri( $data/cell[ @id="http://dbx.iro37.ru/zapolnititul/признаки/локальныйПуть" ]/text() )
  
  let $XQueryPath := 
    $data/cell[ @id="https://schema.org/url" ]/text()
  
  let $xquery := fetch:text( $XQueryPath )
  
  let $source :=  yandex:getResourceFile( $path, $token )
  return 
    xquery:eval( $xquery, map{ "" :  $source } )
};