module namespace getSource = "http://dbx.iro37.ru/zapolnititul/api/v2.1/public/";

import module namespace request = "http://exquery.org/ns/request";

import module namespace data = "http://dbx.iro37.ru/zapolnititul/api/v2.1/data" at "../functions/data.xqm";

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
  
  let $source :=   getSource:ya( $path, $token )
  let $params := 
    map:merge(
      for $i in request:parameter-names()
      return
        map{ $i : request:parameter( $i ) }
    )
  
  return 
    xquery:eval( $xquery, map{ "" :  $source, 'params' : $params } )
};

declare function getSource:ya(
  $path as xs:string,
  $token as xs:string
)
{
  let $href := 
     http:send-request(
               <http:request method='GET'>
                 <http:header name="Authorization" value="{ 'OAuth ' || $token }"/>
                 <http:body media-type = "text" >              
                  </http:body>
               </http:request>,
              'https://cloud-api.yandex.net:443/v1/disk/resources/download?path=disk:/' || $path || '&amp;fields=href'
          )[2]/*:json/*:href/text()
    
  let $rowData := fetch:xml( $href )
  return
    $rowData
};