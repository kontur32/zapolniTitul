module namespace getUserData = "http://dbx.iro37.ru/zapolnititul/api/user/data";

import module namespace session = "http://basex.org/modules/session";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/user/{ $id }/data" )
function getUserData:get( $id as xs:string ) {
  let $data := $config:userData( $id )
  return 
    if ( session:get( "userid" )= $id )
    then( <data>{ $data }</data> )
    else ( <error>Пользователь не опознан</error>)
  
};

(:
  метод для публикации публично доступных данных
  !!! - требуется подключение механизма проверки статуса публичности
  данные о публичности в модели данных
:)
declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/user/{ $id }/data/public" )
  %rest:query-param( "type", "{ $type }", "" )
  %rest:query-param( "field", "{ $fieldName }", "" )
  %output:method("csv")
  %output:csv("header=yes")
function getUserData:public( $id as xs:string, $type, $fieldName ) {
  let $data := $config:userData( $id )[ row[ @type = $type ] ]
  let $result := 
    for $i in  distinct-values( $data/@id/data() )
    return 
       $data[ @id = $i ][last()]
  return 
      <csv>{
        for $r in $result
        return 
          <record>
            <label>{ $r/row/cell[ @id = $fieldName ]/text() }</label>
          </record>
      }</csv>
      
};

(:
  метод для публикации модели данных
:)
declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/user/{ $userID }/models/{ $modelID }" )
  %output:method("xml")
function getUserData:model( $userID as xs:string,  $modelID as xs:string ) {
  let $data := $config:userData( $userID )[ @templateID = $modelID ]
  let $result := 
    for $i in  distinct-values( $data/@id/data() )
    return 
       $data[ @id = $i ][last()]
  return 
      <table>{
        for $r in $result
        return 
          $r/row
      }</table>    
};