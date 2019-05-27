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

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/user/{ $id }/data/public" )
  %rest:query-param( "type", "{ $type }", "" )
  %rest:query-param( "field", "{ $fieldName }", "" )
function getUserData:public( $id as xs:string, $type, $fieldName ) {
  let $data := $config:userData( $id )
  let $result := 
    for $i in  $data/row[ @type = $type ]/cell[ @id = $fieldName ]/text()
    return 
      <record><label>{ $i }</label></record>
  return 
  serialize(
    <csv>
      { $result }
    </csv>,
    map {
      'method': 'csv',
      'csv': map { 'header': 'yes', 'separator': ';' }
    }
)
};