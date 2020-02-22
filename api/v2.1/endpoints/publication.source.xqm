module namespace publicSource = "http://dbx.iro37.ru/zapolnititul/api/v2.1/publicSource/";

import module namespace yandex = "http://dbx.iro37.ru/zapolnititul/api/v2.1/resource/yandex"
  at '../functions/yandex.xqm';

import module namespace parseExcel = "http://dbx.iro37.ru/zapolnititul/api/v2.1/parse/excel/XML"
  at '../functions/parseExcel.xqm';

declare
  %public
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2.1/data/publication/{ $publicationID }" )
function publicSource:main(
  $publicationID as xs:string
)
{
    let $data := function( $ID ){ 
      db:open( 'titul24', 'data' )
      /data/table[ row[ @id = $ID ] ][ last() ]/row
   }
  
  let $ID := 
    "http://dbx.iro37.ru/zapolnititul/сущности/публикацияРесурса#" || 
    $publicationID

  let $публикация := $data( $ID )
  
  let $ресурсID := 
    $публикация/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/ресурс']/text()
  
  let $форматВывода := 
    let $формат :=
      $публикация/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/форматВывода']/text()
    return
      switch ( $формат )
      case 'plain' return 'text/plain'
      case 'html' return 'text/html'
      case 'json' return 'application/json'
      case 'xml' return 'application/xml'
      default return 'text/plain'
  
  let $ресурс := $data( $ресурсID  )
  
  let $запросID := 
    $публикация/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/запрос']/text()
  
  let $запрос := $data( $запросID  )
  
  let $локальныйПутьРесурс :=  
    $ресурс/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/локальныйПуть']/text()
  
  let $типРесурса := 
    $ресурс/cell[ @id = "http://dbx.iro37.ru/zapolnititul/признаки/типРесурса" ]/text()
  
  let $хранилищеID := 
    $ресурс/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/хранилище']/text()
  
  let $хранилище := $data( $хранилищеID )
  
  let $токен := 
    $хранилище/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/сущности/токенДоступа' ]/text()
  
  let $хранилищеЛокальныйПуть := 
    $хранилище/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/локальныйПуть' ]/text()
  
  let $rawSource := 
    yandex:getResourceFile( $хранилищеЛокальныйПуть || '/' ||  $локальныйПутьРесурс, $токен )
  
  let $source := 
    switch ( $типРесурса )
    case 'excel-xml'
      return
        parseExcel:XMLToTRCI(
          parse-xml( convert:binary-to-string( $rawSource ) )
        )
    case 'xlsx'
      return
        parseExcel:xlsxToTRCI( $rawSource )
    default 
      return false()
  
  let $запросURL := $запрос/cell[ @id = 'https://schema.org/url' ]/text()
  
  let $xquery := fetch:text( $запросURL )
  
  let $params := 
      map:merge(
        for $i in request:parameter-names()
        return
          map{ $i : request:parameter( $i ) }
      )
  
  let $result := xquery:eval( $xquery, map{ "" :  $source, 'params' : $params, 'ID' : $publicationID } )
  
  return
    (
      <rest:response>
          <http:response status="200">
            <http:header name="Content-type" value="{ $форматВывода }"/>
          </http:response>
      </rest:response>,
     $result
   )
};