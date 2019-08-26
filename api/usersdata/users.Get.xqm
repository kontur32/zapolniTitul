module namespace getUserData = "http://dbx.iro37.ru/zapolnititul/api/user/data";

import module namespace session = "http://basex.org/modules/session";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

declare
  %private
  %rest:GET
  %rest:query-param( "type", "{ $type }", ".*" )
  %rest:query-param( "id", "{ $id }", ".*" )
  %rest:query-param( "unique", "{ $unique }", "false" )
  %rest:path ( "/zapolnititul/api/v2/user/{ $userID }/data" )
function getUserData:get( $userID as xs:string, $type, $id, $unique as xs:boolean  ) {
  let $data := $config:userData( $userID )[ row[ matches( @type, $type ) and matches( @id, $id ) ] ]
  
  let $data := 
    if ( $unique )
    then(
      for $subject in distinct-values( $data/@id )
      return
        $data[ @id = $subject ][ last() ]
    )
    else( $data )
    
  return 
    if ( session:get( "userid" ) = $userID )
    then( <data>{ $data }</data> )
    else ( <error>Пользователь не опознан</error> ) 
};

declare
  %private
  %rest:GET
  %rest:header-param("Authorization", "{$auth}")
  %rest:path ( "/zapolnititul/api/v2/user/{ $userID }/data/templates/{ $templateID }" )
function getUserData:templateData( $auth, $userID as xs:string, $templateID as xs:string ) {
  let $data := $config:templateData( $templateID )
  let $formOwner := 
    try {
      $config:apiResult( $templateID, "meta" )/form/@userid
    }
    catch*{}
  let $sessionUserID := 
    if( session:get( "userid" ) )
    then(
      session:get( "userid" )
    )
    else(
      getUserData:getUserID( substring-after( $auth,  "Bearer " ) )
    )
  return 
    if ( $sessionUserID = ( $userID , $formOwner ) )
    then( 
      if( session:get( "userid" ) = $formOwner )
      then ( <data>{ $data }</data> )
      else( <data>{ $data[ @userID = $userID ] }</data> )
     )
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


declare function getUserData:getUserID( $token ){
  let $request := 
  <http:request method='get'>
    <http:header name="Authorization" value= '{ "Bearer " || $token }' />
  </http:request>

  let $response := 
      http:send-request(
        $request,
        "http://portal.titul24.ru" || "/wp-json/wp/v2/users/me?context=edit"
    )
    return
      $response[2]/json/id/text()
};