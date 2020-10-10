module namespace publicSource = "http://dbx.iro37.ru/zapolnititul/api/v2.1/publicSource/";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config"
  at '../config.xqm';

import module namespace yandex = "http://dbx.iro37.ru/zapolnititul/api/v2.1/resource/yandex"
  at '../functions/yandex.xqm';

import module namespace nextCloud = 'http://dbx.iro37.ru/zapolnititul/api/v2.1/nextCloud/'
  at '../functions/nextCloud.xqm';
  
import module namespace trciToRdf = 'http://dbx.iro37.ru/zapolnititul/api/v2.1/trciToRdf/'
  at '../functions/trciToRdf.xqm';  

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
  let $data := 
    function( $ID ){ 
      config:usersData()
      [ row[ ends-with( @id/data(), $ID ) ] ]
      [ last() ]
      /row
    }
  
  let $userData := 
    function( $ID, $userID ){ 
      config:userData( $userID )
      [ row[ ends-with( @id/data(), $ID ) ] ]
      [ last() ]
      /row
    }
  
  let $публикация := $data( $publicationID )
  
  let $userID := $публикация/parent::*/@userID/data()
  
  let $ресурсID := 
    $публикация/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/ресурс']/text()
  
  let $ресурс := $userData( $ресурсID, $userID  )
  
  let $хранилище :=
    $userData(
      $ресурс/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/хранилище' ]/text(),
      $userID
    )
  
  let $sourceNamespace := tokenize( $ресурс/@id/data(), '#')[ 1 ]
  let $source := 
    switch( $sourceNamespace )
    
    case ( 'http://dbx.iro37.ru/zapolnititul/сущности/ресурсЯндексДиск' )
      return
        publicSource:получениеРесурсаЯндекса( $ресурс, $хранилище )
    
    case ( 'http://dbx.iro37.ru/zapolnititul/сущности/ресурсSaaS' )
    return
      let $fileData := 
        nextCloud:получитьРесурс(
          trciToRdf:sourceData( $ресурс  ),
          $хранилище,
          $config:param( 'tokenRecordsFilePath' )
        )
      return
        parseExcel:WorkbookToTRCI( $fileData )
    default
      return $ресурс
  
  let $xquery := publicSource:получениеТекстаЗапроса( $публикация, $data )
  
  let $params := 
      map:merge(
        for $i in request:parameter-names()
        return
          map{ $i : request:parameter( $i ) }
      )
  
  let $result := 
    xquery:eval(
      $xquery,
      map{ '' :  $source, 'params' : $params, 'ID' : $publicationID }
    )
  
  let $форматВывода := publicSource:форматВывода( $публикация )
  
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

(:----------------------------------------------------------------------------:)
(:
  вспомогательные функции
:)
declare
  %private
function publicSource:форматВывода( $публикация ){
  let $формат :=
      $публикация/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/форматВывода']/text()
    return
      switch ( $формат )
      case 'plain' return 'text/plain'
      case 'html' return 'text/html'
      case 'json' return 'application/json'
      case 'xml' return 'application/xml'
      default return 'text/plain'
};

declare
  %private
function 
  publicSource:обработкаРесурсаЯндекса(
    $типРесурса,
    $rawSource,
    $полныйПуть
  ){
  switch ( $типРесурса )
    case 'excel-xml'
      return
        parseExcel:XMLToTRCI(
          parse-xml( convert:binary-to-string( $rawSource ) )
        )
    case 'xlsx'
      return
        parseExcel:xlsxToTRCI( $rawSource )
    case 'xlsx-workbook'
      return
        parseExcel:WorkbookToTRCI( $rawSource )
    case 'xlsx-dir'
      return
        <directory path = '{ web:decode-url( $полныйПуть ) }'>{
          for $i in $rawSource//_[ type = 'file' ][ ends-with( name, '.xlsx' ) ]
          let $filePath := $i/file/text()
          let $file := fetch:binary( $filePath )
          return
            parseExcel:WorkbookToTRCI( $file )
            update insert node attribute { 'filename' } { $i/name/text() } into ./child::*
        }</directory>
        
    default 
      return false()
};

declare
  %private
function 
  publicSource:получениеРесурсаЯндекса( $ресурс, $хранилище ){
  let $локальныйПутьРесурс :=  
    iri-to-uri(
      $ресурс/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/локальныйПуть']/text()
    )
    
  let $типРесурса := 
    $ресурс/cell[ @id = "http://dbx.iro37.ru/zapolnititul/признаки/типРесурса" ]/text()
  
  let $токен := 
    $хранилище/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/сущности/токенДоступа' ]/text()
  
  let $хранилищеЛокальныйПуть :=
    iri-to-uri( 
      $хранилище/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/локальныйПуть' ]/text()
    )
  
  let $полныйПуть := $хранилищеЛокальныйПуть || '/' ||  $локальныйПутьРесурс
     
  let $rawSource := 
    yandex:getResource(
      $типРесурса,
      $полныйПуть,
      $токен
    )
  
  return 
    publicSource:обработкаРесурсаЯндекса(
      $типРесурса,
      $rawSource,
      $полныйПуть
    )
};
  
declare 
  %private
function publicSource:получениеТекстаЗапроса( $публикация, $data ){
  let $запросID := 
    $публикация/cell[ @id = 'http://dbx.iro37.ru/zapolnititul/признаки/запрос']/text()
  let $запрос := $data( $запросID  )
  let $запросURL := $запрос/cell[ @id = 'https://schema.org/url' ]/text()
  return
    if( $запросURL )
    then( fetch:text( $запросURL ) )
    else( '.' )
};