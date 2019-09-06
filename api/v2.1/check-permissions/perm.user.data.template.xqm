module namespace check = "http://dbx.iro37.ru/zapolnititul/api/v2.1/funct/check/";

import module namespace request = "http://exquery.org/ns/request";

import module namespace 
  auth = "http://dbx.iro37.ru/zapolnititul/api/v2.1/funct/auth/"
    at "../functions/auth.xqm";

declare 
  %perm:check( '/zapolnititul/api/v2.1/data/users/', '{ $perm }' )
function check:check( $perm ) {
  let $authorization := request:header( "Authorization" )
  let $requestUserID := 
    substring-before(
      substring-after( $perm?path, '/zapolnititul/api/v2.1/data/users/' ),
      "/"
    )
  let $tokenUserID := 
    auth:userID( $authorization )
  return
    if( $authorization )
    then(
      if( $requestUserID = $tokenUserID )
      then() (: разрешает обращение :)
      else(
        <rest:response>
          <http:response status="403" message="Forbidden"/>
        </rest:response>
      )
    )
    else(
      <rest:response>
        <http:response status="401" message="Unauthorized">
          <http:header name="WWW-Authenticate" value="Required bearer token"/>
        </http:response>
      </rest:response>
    )
};